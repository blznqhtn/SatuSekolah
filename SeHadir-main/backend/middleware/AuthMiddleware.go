package middleware

import (
	"context"
	"crypto/sha256"
	"encoding/hex"
	"errors"
	"fmt"
	"os"
	"strings"
	"time"

	"e-presence-backend/config"
	"e-presence-backend/models"

	"github.com/gofiber/fiber/v2"
	"github.com/golang-jwt/jwt/v5"
	"github.com/google/uuid"
)

func RequireAuth(c *fiber.Ctx) error {
	authHeader := c.Get("Authorization")
	if authHeader == "" || !strings.HasPrefix(authHeader, "Bearer ") {
		return unauthorized(c, "Missing or invalid auth header")
	}

	tokenString := strings.TrimPrefix(authHeader, "Bearer ")

	hash := sha256.Sum256([]byte(tokenString))
	tokenKey := "blacklist:" + hex.EncodeToString(hash[:])

	if config.RDB != nil {
		if config.RDB.Exists(config.Ctx, tokenKey).Val() == 1 {
			return unauthorized(c, "Token blacklisted")
		}
	}

	secret := os.Getenv("JWT_SECRET")
	if secret == "" {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
			"status":  "error",
			"message": "JWT_SECRET not configured",
		})
	}

	claims := jwt.MapClaims{}
	token, err := jwt.ParseWithClaims(tokenString, claims, func(t *jwt.Token) (interface{}, error) {
		if _, ok := t.Method.(*jwt.SigningMethodHMAC); !ok {
			return nil, errors.New("invalid signing method")
		}
		return []byte(secret), nil
	})

	if err != nil || !token.Valid {
		return unauthorized(c, "Invalid or expired token")
	}

	uidStr, _ := claims["uid"].(string)
	sessionID, _ := claims["session_id"].(string)
	tv, _ := claims["token_version"].(float64)
	tokenVersion := int(tv)

	if uidStr == "" || sessionID == "" {
		return unauthorized(c, "Invalid token claims")
	}

	if claims["iss"] != "sehadir-api" || claims["aud"] != "sehadir-client" {
		return unauthorized(c, "Invalid token origin")
	}

	if config.RDB == nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{"status": "error", "message": "Redis unavailable"})
	}

	sessionKey := "session:" + sessionID
	val, err := config.RDB.HGetAll(config.Ctx, sessionKey).Result()
	if err != nil || len(val) == 0 {
		return unauthorized(c, "Session not found in redis (logged out or limit reached)")
	}

	if val["user_id"] != uidStr {
		return unauthorized(c, "Session user mismatch")
	}

	config.RDB.Expire(config.Ctx, sessionKey, 7*24*time.Hour)

	uid, err := uuid.Parse(uidStr)
	if err != nil {
		return unauthorized(c, "Invalid user ID format")
	}

	ctx, cancel := context.WithTimeout(c.UserContext(), 3*time.Second)
	defer cancel()

	var dbTokenVersion int
	cacheVersionKey := "user:token_version:" + uid.String()

	cachedVer, err := config.RDB.Get(ctx, cacheVersionKey).Int()
	if err == nil {
		dbTokenVersion = cachedVer
	} else {
		var user models.User
		err = config.DB.WithContext(ctx).
			Select("id", "role", "token_version", "status_ban").
			Where("id = ?", uid).
			First(&user).Error

		if err != nil {
			return unauthorized(c, "User not found in database")
		}

		if user.StatusBan != "active" {
			return c.Status(fiber.StatusForbidden).JSON(fiber.Map{"status": "failed", "message": "Account banned"})
		}

		dbTokenVersion = user.TokenVersion
		config.RDB.Set(ctx, cacheVersionKey, dbTokenVersion, 5*time.Minute)
	}

	if tokenVersion != dbTokenVersion {
		return unauthorized(c, "Token version mismatch (forced logout)")
	}

	c.Locals("uid", uidStr)
	c.Locals("role", val["role"])
	c.Locals("session_id", sessionID)

	return c.Next()
}

// ==========================
// HELPERS
// ==========================
func unauthorized(c *fiber.Ctx, message string) error {
	fmt.Printf("[AUTH DEBUG] 401 Unauthorized: %s\n", message)

	return c.Status(fiber.StatusUnauthorized).JSON(fiber.Map{
		"status":  "failed",
		"message": message,
	})
}
