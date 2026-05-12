package controllers

import (
	"context"
	"crypto/rand"
	"crypto/sha256"
	"encoding/hex"
	"errors"
	"log"
	"os"
	"strconv"
	"strings"
	"time"

	"e-presence-backend/config"
	"e-presence-backend/models"

	"github.com/gofiber/fiber/v2"
	"github.com/golang-jwt/jwt/v5"
	"github.com/google/uuid"
	"golang.org/x/crypto/bcrypt"
	"gorm.io/gorm"
)

type UnifiedLoginRequest struct {
	Type     string `json:"type"` // "user", "admin", "rfid"
	Username string `json:"username,omitempty"`
	Password string `json:"password,omitempty"`
	RFIDID   string `json:"rfid_id,omitempty"`
}

type ForgotPasswordRequest struct {
	Email string `json:"email"`
}

type ResetPasswordRequest struct {
	Token                string `json:"token"`
	Email                string `json:"email"`
	Password             string `json:"password"`
	PasswordConfirmation string `json:"password_confirmation"`
}

type RegisterRequest struct {
	NoInduk  string `json:"no_induk"`
	Username string `json:"username"`
	Email    string `json:"email"`
	Password string `json:"password"`
}

type RefreshRequest struct {
	RefreshToken string `json:"refresh_token"`
}

type TapRequest struct {
	ID string `json:"id"`
}

func Login(c *fiber.Ctx) error {
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()

	var req UnifiedLoginRequest
	if err := c.BodyParser(&req); err != nil {
		return badRequest(c, "Invalid request body")
	}

	if req.Type != "user" && req.Type != "admin" && req.Type != "rfid" {
		return badRequest(c, "Invalid login type")
	}

	ip := c.IP()
	userAgent := c.Get("User-Agent")

	maxAttempts := 5
	window := 15 * time.Minute
	sessionTTL := 24 * time.Hour

	if v := os.Getenv("LOGIN_MAX_ATTEMPTS"); v != "" {
		if val, err := strconv.Atoi(v); err == nil {
			maxAttempts = val
		}
	}

	if v := os.Getenv("LOGIN_WINDOW"); v != "" {
		if d, err := time.ParseDuration(v); err == nil {
			window = d
		}
	}

	if v := os.Getenv("SESSION_MAX"); v != "" {
		if d, err := time.ParseDuration(v); err == nil {
			sessionTTL = d
		}
	}

	if config.RDB != nil {
		var key string
		if req.Type == "rfid" {
			key = "login_attempt:rfid:" + req.RFIDID + ":" + ip
		} else {
			key = "login_attempt:" + req.Username + ":" + ip
		}

		count, err := config.RDB.Incr(ctx, key).Result()
		if err == nil {
			if count == 1 {
				config.RDB.Expire(ctx, key, window)
			}
			if count > int64(maxAttempts) {
				return c.Status(429).JSON(fiber.Map{
					"status":  "failed",
					"message": "Too many attempts",
				})
			}
		}
	}

	var user models.User
	var err error
	switch req.Type {
	case "user":
		user, err = authenticateUser(req.Username, req.Password)
	case "admin":
		user, err = authenticateAdmin(req.Username, req.Password)
	case "rfid":
		user, err = authenticateRFID(req.RFIDID)
	}

	if err != nil {
		log.Printf("[AUTH] FAIL type=%s id=%s ip=%s err=%v", req.Type, getIdentifier(req), ip, err)
		return unauthorized(c)
	}

	if user.StatusBan != "active" {
		return c.Status(403).JSON(fiber.Map{
			"status":  "failed",
			"message": "Account banned",
		})
	}

	if req.Type == "admin" && user.Membership == "false" {
		return c.Status(403).JSON(fiber.Map{
			"status":  "failed",
			"message": "Membership inactive",
		})
	}

	if config.RDB == nil {
		log.Println("[AUTH] Redis unavailable")
		return serverError(c)
	}

	if req.Type != "rfid" {
		userSessionKey := "user:sessions:" + user.ID.String()

		currentSessions, _ := config.RDB.SCard(ctx, userSessionKey).Result()

		if currentSessions >= 5 {
			oldSessionID, err := config.RDB.SPop(ctx, userSessionKey).Result()
			if err == nil && oldSessionID != "" {
				config.RDB.Del(ctx, "session:"+oldSessionID)
				log.Printf("[AUTH] Session limit reached for %s. Removed old session: %s", user.ID, oldSessionID)
			}
		}
	}

	sessionID := generateRandomString(32)
	accessToken, err := generateAccessToken(user, sessionID)
	if err != nil {
		log.Printf("[AUTH] Token generation error: %v", err)
		return serverError(c)
	}

	refreshToken, hashedRefreshToken := generateRefreshToken()
	sessionKey := "session:" + sessionID

	err = config.RDB.HSet(ctx, sessionKey, map[string]interface{}{
		"token":      hashedRefreshToken,
		"user_id":    user.ID.String(),
		"ip":         ip,
		"user_agent": userAgent,
		"type":       req.Type,
		"created_at": time.Now().Unix(),
	}).Err()

	if err != nil {
		log.Printf("[AUTH] Redis HSet error: %v", err)
		return serverError(c)
	}

	config.RDB.Expire(ctx, sessionKey, sessionTTL)

	if req.Type != "rfid" {
		userSessionKey := "user:sessions:" + user.ID.String()
		config.RDB.SAdd(ctx, userSessionKey, sessionID)
		config.RDB.Expire(ctx, userSessionKey, sessionTTL)
	}

	log.Printf("[AUTH] SUCCESS type=%s user=%s session=%s ip=%s", req.Type, user.ID, sessionID, ip)

	return c.JSON(fiber.Map{
		"status":        "success",
		"access_token":  accessToken,
		"refresh_token": refreshToken,
		"session_id":    sessionID,
		"uid":           user.ID,
		"role":          user.Role,
	})
}

func authenticateUser(username, password string) (models.User, error) {
	if username == "" || password == "" {
		return models.User{}, fiber.ErrUnauthorized
	}

	var user models.User
	err := config.DB.Where("username = ?", username).First(&user).Error
	if err != nil {
		return models.User{}, err
	}

	if bcrypt.CompareHashAndPassword([]byte(user.Password), []byte(password)) != nil {
		return models.User{}, fiber.ErrUnauthorized
	}

	return user, nil
}

func authenticateAdmin(username, password string) (models.User, error) {
	if username == "" || password == "" {
		return models.User{}, fiber.ErrUnauthorized
	}

	var admin models.User
	err := config.DB.Where("username = ? AND role IN ('admin','superadmin')", username).First(&admin).Error
	if err != nil {
		return models.User{}, err
	}

	if bcrypt.CompareHashAndPassword([]byte(admin.Password), []byte(password)) != nil {
		return models.User{}, fiber.ErrUnauthorized
	}

	return admin, nil
}

func authenticateRFID(rfidID string) (models.User, error) {
	if rfidID == "" {
		return models.User{}, fiber.ErrUnauthorized
	}

	var user models.User
	err := config.DB.Where("rfid_id = ?", rfidID).First(&user).Error
	if err != nil {
		return models.User{}, err
	}
	return user, nil
}

func isRateLimited(c *fiber.Ctx, req UnifiedLoginRequest) bool {
	if config.RDB == nil {
		return false
	}

	ctx := config.Ctx
	ip := c.IP()

	var key string
	var limit int
	var window time.Duration

	switch req.Type {
	case "user", "admin":
		// rate limit per username + IP
		key = "login_attempt:" + req.Username + ":" + ip
		limit = 5
		window = 1 * time.Minute
	case "rfid":
		// rate limit per RFID ID + IP
		key = "login_attempt:rfid:" + req.RFIDID + ":" + ip
		limit = 10
		window = 1 * time.Minute
	default:
		return false
	}

	count, err := config.RDB.Incr(ctx, key).Result()
	if err != nil {
		log.Printf("[RATELIMIT] Redis incr error: %v", err)
		return false
	}

	if count == 1 {
		config.RDB.Expire(ctx, key, window)
	}

	return count > int64(limit)
}

func enforceSessionLimit(userID string) error {
	if config.RDB == nil {
		return nil
	}

	ctx := config.Ctx
	userSessionKey := "user:sessions:" + userID
	maxSessions := 5

	sessionIDs, err := config.RDB.SMembers(ctx, userSessionKey).Result()
	if err != nil {
		return err
	}

	if len(sessionIDs) >= maxSessions {
		// Hapus session paling lama (FIFO)
		oldest := sessionIDs[0]
		config.RDB.Del(ctx, "session:"+oldest)
		config.RDB.SRem(ctx, userSessionKey, oldest)
		log.Printf("[SESSION] Removed oldest session %s for user %s (limit %d)", oldest, userID, maxSessions)
	}
	return nil
}

func ForgotPassword(c *fiber.Ctx) error {
	var req ForgotPasswordRequest
	if err := c.BodyParser(&req); err != nil {
		return badRequest(c, "Invalid request")
	}

	if req.Email == "" {
		return badRequest(c, "Invalid request")
	}

	var user models.User
	if err := config.DB.Where("email = ?", req.Email).First(&user).Error; err == nil {

		rawToken, hashToken := generateResetToken()

		reset := models.PasswordResetToken{
			Email:     req.Email,
			Token:     hashToken,
			ExpiresAt: time.Now().Add(15 * time.Minute),
		}

		config.DB.Create(&reset)

		go config.SendEmail(req.Email, "Password Reset Request", "Use this token to reset your password: "+rawToken)
	}

	time.Sleep(300 * time.Millisecond)

	return c.JSON(fiber.Map{
		"status": "success",
		"message": "Jika email terdaftar, instruksi reset password telah dikirim.",
	})
}

func ResetPassword(c *fiber.Ctx) error {
	var req ResetPasswordRequest
	if err := c.BodyParser(&req); err != nil {
		return badRequest(c, "Invalid request")
	}

	if req.Password != req.PasswordConfirmation || len(req.Password) < 8 {
		return badRequest(c, "Invalid request")
	}

	hash := sha256.Sum256([]byte(req.Token))
	hashedToken := hex.EncodeToString(hash[:])

	var reset models.PasswordResetToken
	if err := config.DB.
		Where("email = ? AND token = ? AND expires_at > ?", req.Email, hashedToken, time.Now()).
		First(&reset).Error; err != nil {
		return unauthorized(c)
	}

	newPass, err := bcrypt.GenerateFromPassword([]byte(req.Password), bcrypt.DefaultCost)
	if err != nil {
		return serverError(c)
	}

	err = config.DB.Transaction(func(tx *gorm.DB) error {
		if err := tx.Model(&models.User{}).
			Where("email = ?", req.Email).
			Updates(map[string]interface{}{
				"password":      string(newPass),
				"token_version": gorm.Expr("token_version + 1"),
			}).Error; err != nil {
			return err
		}

		if err := tx.Delete(&models.PasswordResetToken{}, "email = ?", req.Email).Error; err != nil {
			return err
		}

		return nil
	})

	if err != nil {
		return serverError(c)
	}

	return c.JSON(fiber.Map{
		"status": "success",
	})
}

func Logout(c *fiber.Ctx) error {
	uid, ok := c.Locals("uid").(string)
	if !ok {
		return unauthorized(c)
	}

	err := config.DB.Model(&models.User{}).
		Where("id = ?", uid).
		Update("token_version", gorm.Expr("token_version + 1")).Error

	if err != nil {
		return serverError(c)
	}

	if config.RDB != nil {
		config.RDB.Del(context.Background(), "user:token_version:"+uid)

		authHeader := c.Get("Authorization")
		if authHeader != "" {
			token := strings.TrimPrefix(authHeader, "Bearer ")

			hash := sha256.Sum256([]byte(token))
			tokenKey := "blacklist:" + hex.EncodeToString(hash[:])

			config.RDB.Set(config.Ctx, tokenKey, 1, 15*time.Minute)
		}
	}

	return c.JSON(fiber.Map{
		"status": "success",
	})
}

func RegisterAccount(c *fiber.Ctx) error {
	var req RegisterRequest
	if err := c.BodyParser(&req); err != nil {
		return badRequest(c, "Invalid request")
	}

	if len(req.Password) < 8 {
		return badRequest(c, "Invalid request")
	}

	hash, err := bcrypt.GenerateFromPassword([]byte(req.Password), bcrypt.DefaultCost)
	if err != nil {
		return serverError(c)
	}

	var emailPtr *string
	if req.Email != "" {
		emailPtr = &req.Email
	}

	user := models.User{
		Username: req.Username,
		Email:    emailPtr,
		Password: string(hash),
		Role:     "user",
	}

	if err := config.DB.Create(&user).Error; err != nil {
		return serverError(c)
	}

	return c.Status(201).JSON(fiber.Map{"status": "success"})
}

func ValidateToken(c *fiber.Ctx) error {
	return c.JSON(fiber.Map{
		"status": "success",
	})
}

func GetMe(c *fiber.Ctx) error {
    uid := c.Locals("uid")
    role := c.Locals("role")

    val := c.Locals("session_id")
    if val == nil {
        return c.Status(401).JSON(fiber.Map{
            "status": "failed",
            "message": "Unauthenticated: Session context missing",
        })
    }

    sessionID, ok := val.(string)
    if !ok {
        return c.Status(500).JSON(fiber.Map{
            "status": "error",
            "message": "Internal error: Invalid session format",
        })
    }

    if config.RDB == nil {
        return c.Status(500).JSON(fiber.Map{"status": "error", "message": "Redis unavailable"})
    }

    exists, err := config.RDB.Exists(config.Ctx, "session:"+sessionID).Result()
    if err != nil || exists == 0 {
        return c.Status(401).JSON(fiber.Map{
            "status": "failed",
            "message": "Session expired or deleted",
        })
    }

    return c.JSON(fiber.Map{
        "status": "success",
        "user": fiber.Map{
            "id":   uid,
            "role": role,
        },
    })
}

func DaftarAkun(c *fiber.Ctx) error {
	var req RegisterRequest
	if err := c.BodyParser(&req); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"status": "failed", "message": "Data tidak valid"})
	}

	var schoolMember models.SchoolMember
	if err := config.DB.Preload("Kelas").Where("no_induk = ?", req.NoInduk).First(&schoolMember).Error; err != nil {
		return c.Status(fiber.StatusNotFound).JSON(fiber.Map{"status": "failed", "message": "Nomor Induk tidak ditemukan di database sekolah"})
	}

	var user models.User
	if err := config.DB.Where("id_school_member = ?", schoolMember.ID).First(&user).Error; err == nil {
		return c.Status(fiber.StatusConflict).JSON(fiber.Map{"status": "failed", "message": "Akun dengan Nomor Induk ini sudah terdaftar"})
	}

	return c.JSON(fiber.Map{
		"status": "success",
		"data":   fiber.Map{
			"id": schoolMember.ID,
			"name": schoolMember.Name,
			"no_induk": schoolMember.NoInduk,
			"kelas": schoolMember.Kelas.Name,
			"alamat": schoolMember.Alamat,
		},
		"include": fiber.Map{
			"no_induk": req.NoInduk,
			"username": req.Username,
			"email":    req.Email,
			"password": req.Password,
		},
	})
}

func TotalUsers(c *fiber.Ctx) error {
	var total int64
	if err := config.DB.Model(&models.User{}).Where("role = ?", "user").Count(&total).Error; err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
			"status":  "error",
			"message": "Gagal mengambil data jumlah pengguna",
		})
	}

	return c.JSON(fiber.Map{
		"status": "success",
		"total":  total,
	})
}

// ============================================================================
// HELPERS
// ============================================================================
func getIdentifier(req UnifiedLoginRequest) string {
	switch req.Type {
	case "user", "admin":
		return req.Username
	case "rfid":
		return req.RFIDID
	default:
		return "unknown"
	}
}

func generateAccessToken(user models.User, sessionID string) (string, error) {
	claims := jwt.MapClaims{
		"uid":           user.ID.String(),
		"role":          user.Role,
		"session_id":    sessionID,
		"token_version": user.TokenVersion,
		"iss":           "sehadir-api",
		"aud":           "sehadir-client",
		"exp":           time.Now().Add(15 * time.Minute).Unix(),
		"iat":           time.Now().Unix(),
	}
	token := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)
	secret := os.Getenv("JWT_SECRET")

	if secret == "" {
		return "", errors.New("jwt secret not set")
	}

	return token.SignedString([]byte(secret))
}

func generateRefreshToken() (string, string) {
	b := make([]byte, 32)
	if _, err := rand.Read(b); err != nil {
		panic("failed to generate secure random")
	}
	raw := hex.EncodeToString(b)
	hash := sha256.Sum256([]byte(raw))
	return raw, hex.EncodeToString(hash[:])
}

func generateRandomString(n int) string {
	b := make([]byte, n)
	if _, err := rand.Read(b); err != nil {
		panic("failed to generate secure random")
	}
	return hex.EncodeToString(b)
}

func generateResetToken() (string, string) {
	b := make([]byte, 32)
	if _, err := rand.Read(b); err != nil {
		panic("failed to generate secure token")
	}

	raw := hex.EncodeToString(b)
	hash := sha256.Sum256([]byte(raw))

	return raw, hex.EncodeToString(hash[:])
}

func RefreshToken(c *fiber.Ctx) error {
	var req RefreshRequest
	if err := c.BodyParser(&req); err != nil {
		return badRequest(c, "Invalid request")
	}

	if req.RefreshToken == "" {
		return unauthorized(c)
	}

	if config.RDB == nil {
		return serverError(c)
	}

	sessionID := c.Get("X-Session-ID")
	if sessionID == "" {
		return unauthorized(c)
	}

	key := "session:" + sessionID

	// ===== AMBIL SESSION =====
	val, err := config.RDB.HGetAll(config.Ctx, key).Result()
	if err != nil || len(val) == 0 {
		return unauthorized(c)
	}

	storedHash := val["token"]
	userID := val["user_id"]

	// ===== VALIDASI TOKEN =====
	hash := sha256.Sum256([]byte(req.RefreshToken))
	if storedHash != hex.EncodeToString(hash[:]) {
		return unauthorized(c)
	}

	config.RDB.Del(config.Ctx, key)

	newRefresh, newHash := generateRefreshToken()

	config.RDB.HSet(config.Ctx, key, map[string]interface{}{
		"token":   newHash,
		"user_id": userID,
	})
	config.RDB.Expire(config.Ctx, key, 7*24*time.Hour)

	var user models.User
	if err := config.DB.Where("id = ?", userID).First(&user).Error; err != nil {
		return unauthorized(c)
	}

	newAccess, err := generateAccessToken(user, sessionID)
	if err != nil {
		return serverError(c)
	}

	return c.JSON(fiber.Map{
		"status":        "success",
		"access_token":  newAccess,
		"refresh_token": newRefresh,
	})
}

func ValidateSecret(c *fiber.Ctx) error {
    secret := c.Query("secret")

    if secret == "" {
        return c.Status(400).JSON(fiber.Map{
            "status":  "failed",
            "message": "Secret key (ID Sekolah) wajib diisi",
        })
    }

    if _, err := uuid.Parse(secret); err != nil {
        return c.Status(400).JSON(fiber.Map{
            "status":  "failed",
            "message": "Format Secret Key tidak valid",
        })
    }

    var sekolah models.Sekolah
    err := config.DB.Where("id = ?", secret).First(&sekolah).Error

    if err != nil {
        return c.Status(404).JSON(fiber.Map{
            "status":  "failed",
            "message": "Secret Key tidak terdaftar atau salah",
        })
    }

	var setting models.Setting
	config.DB.Where("id_sekolah = ?", sekolah.ID).First(&setting)

	attendanceMethod := setting.AttendanceMethod
	if attendanceMethod == "" {
		attendanceMethod = "rfid" // default
	}

    return c.JSON(fiber.Map{
        "status":  "success",
        "message": "Validasi berhasil",
        "data": fiber.Map{
            "id":   sekolah.ID,
            "nama": sekolah.NamaSekolah,
			"kepsek": sekolah.KepalaSekolah,
        },
		"settings": fiber.Map{
			"attendance_method":        attendanceMethod,
			"face_recognition_enabled": setting.FaceRecognitionEnabled,
		},
    })
}

func badRequest(c *fiber.Ctx, msg string) error {
	return c.Status(400).JSON(fiber.Map{"status": "failed", "message": msg})
}

func unauthorized(c *fiber.Ctx) error {
	return c.Status(401).JSON(fiber.Map{"status": "failed", "message": "Invalid credentials"})
}

func serverError(c *fiber.Ctx) error {
	return c.Status(500).JSON(fiber.Map{"status": "error", "message": "Internal server error"})
}
