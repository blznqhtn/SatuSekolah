package http

import (
	"time"

	"github.com/gofiber/fiber/v2"
	"github.com/golang-jwt/jwt/v5"
	"github.com/google/uuid"
	"golang.org/x/crypto/bcrypt"
	"neuracakrawira.asia/satu-sekolah-backend/internal/config"
	"neuracakrawira.asia/satu-sekolah-backend/internal/middleware"
	"neuracakrawira.asia/satu-sekolah-backend/internal/modules/core/domain"
)

// UserHandler handles authentication and user profile operations.
type UserHandler struct {
	repo domain.CoreRepository
	cfg  *config.Config
}

func NewUserHandler(repo domain.CoreRepository, cfg *config.Config) *UserHandler {
	return &UserHandler{repo: repo, cfg: cfg}
}

type LoginRequest struct {
	Identifier string `json:"identifier"`
	Password   string `json:"password"`
}

// Login authenticates a user and returns a signed JWT token.
// POST /api/v1/users/login
func (h *UserHandler) Login(c *fiber.Ctx) error {
	var req LoginRequest
	if err := c.BodyParser(&req); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "invalid request body"})
	}
	if req.Identifier == "" || req.Password == "" {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "identifier and password are required"})
	}

	// 1. Fetch user from DB by identifier
	user, err := h.repo.GetUserByLoginIdentifier(c.Context(), req.Identifier)
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{"error": "internal server error"})
	}
	if user == nil {
		// Generic message to avoid user enumeration
		return c.Status(fiber.StatusUnauthorized).JSON(fiber.Map{"error": "Identitas atau kata sandi salah"})
	}

	// 2. Compare bcrypt hash
	if err := bcrypt.CompareHashAndPassword([]byte(user.Password), []byte(req.Password)); err != nil {
		return c.Status(fiber.StatusUnauthorized).JSON(fiber.Map{"error": "Identitas atau kata sandi salah"})
	}

	// 3. Fetch the user's role
	roleName, err := h.repo.GetUserRoleName(c.Context(), user.ID)
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{"error": "could not resolve user role"})
	}

	// Fetch permissions
	permissions, err := h.repo.GetUserPermissions(c.Context(), user.ID)
	if err != nil {
		permissions = []string{}
	}

	// 4. Sign JWT with 24-hour expiry
	claims := middleware.Claims{
		UserID:   user.ID.String(),
		TenantID: user.TenantID.String(),
		Role:     roleName,
		Name:     user.Name,
		RegisteredClaims: jwt.RegisteredClaims{
			ExpiresAt: jwt.NewNumericDate(time.Now().Add(24 * time.Hour)),
			IssuedAt:  jwt.NewNumericDate(time.Now()),
		},
	}
	token := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)
	signed, err := token.SignedString([]byte(h.cfg.JWT.Secret))
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{"error": "could not sign token"})
	}

	return c.Status(fiber.StatusOK).JSON(fiber.Map{
		"token":      signed,
		"expires_in": 86400, // seconds
		"user": fiber.Map{
			"id":          user.ID,
			"name":        user.Name,
			"email":       user.Email,
			"role":        roleName,
			"category":    user.Category,
			"permissions": permissions,
			"tenant_id":   user.TenantID,
		},
	})
}

// UploadPublicKey stores the user's E2EE public key on the server.
// The public key is distributed to contacts via GET /communication/contacts
// so they can encrypt messages intended for this user on their device.
//
// PUT /api/v1/users/profile/public-key  (requires JWT)
//
// Expected body:
//
//	{ "public_key": "<Base64-encoded RSA or X25519 public key>" }
func (h *UserHandler) UploadPublicKey(c *fiber.Ctx) error {
	claims, ok := c.Locals("claims").(*middleware.Claims)
	if !ok || claims == nil {
		return c.Status(fiber.StatusUnauthorized).JSON(fiber.Map{"error": "unauthorized"})
	}

	var req struct {
		PublicKey string `json:"public_key"`
	}
	if err := c.BodyParser(&req); err != nil || req.PublicKey == "" {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "public_key is required"})
	}

	userID, err := uuid.Parse(claims.UserID)
	if err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "invalid user id in token"})
	}

	if err := h.repo.UpdatePublicKey(c.Context(), userID, req.PublicKey); err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{"error": "could not update public key"})
	}

	return c.JSON(fiber.Map{"message": "public key updated successfully"})
}

// GetProfile returns the authenticated user's profile.
// GET /api/v1/users/profile  (requires JWT)
func (h *UserHandler) GetProfile(c *fiber.Ctx) error {
	claims, ok := c.Locals("claims").(*middleware.Claims)
	if !ok || claims == nil {
		return c.Status(fiber.StatusUnauthorized).JSON(fiber.Map{"error": "unauthorized"})
	}

	userID, err := uuid.Parse(claims.UserID)
	if err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "invalid user id in token"})
	}

	user, err := h.repo.GetUserByID(c.Context(), userID)
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{"error": "internal server error"})
	}
	if user == nil {
		return c.Status(fiber.StatusNotFound).JSON(fiber.Map{"error": "user not found"})
	}

	permissions, err := h.repo.GetUserPermissions(c.Context(), userID)
	if err != nil {
		permissions = []string{}
	}

	return c.Status(fiber.StatusOK).JSON(fiber.Map{
		"data": fiber.Map{
			"id":          user.ID,
			"name":        user.Name,
			"email":       user.Email,
			"category":    user.Category,
			"role":        claims.Role,
			"permissions": permissions,
			"tenant_id":   user.TenantID,
		},
	})
}
