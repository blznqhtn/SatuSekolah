package http

import (
	"time"

	"github.com/gofiber/fiber/v2"
	"github.com/golang-jwt/jwt/v5"
	"github.com/google/uuid"
	"golang.org/x/crypto/bcrypt"
	"google.golang.org/api/idtoken"
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

// RegisterParentRequest is the request body for POST /users/register.
type RegisterParentRequest struct {
	Name     string `json:"name"`
	Email    string `json:"email"`
	Password string `json:"password"`
}

// LoginRequest is the request body for POST /users/login.
type LoginRequest struct {
	Identifier string `json:"identifier"`
	Password   string `json:"password"`
}

// RegisterParent registers a new parent account.
// POST /api/v1/users/register
func (h *UserHandler) RegisterParent(c *fiber.Ctx) error {
	var req RegisterParentRequest
	if err := c.BodyParser(&req); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "invalid request body"})
	}
	if req.Name == "" || req.Email == "" || req.Password == "" {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "name, email, and password are required"})
	}

	// Check if email already exists
	existingUser, _ := h.repo.GetUserByEmail(c.Context(), req.Email)
	if existingUser != nil {
		return c.Status(fiber.StatusConflict).JSON(fiber.Map{"error": "email already registered"})
	}

	// Fetch default tenant
	defaultTenant, err := h.repo.GetFirstTenant(c.Context())
	if err != nil || defaultTenant == nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{"error": "could not determine default tenant"})
	}

	// Create new parent user
	user := &domain.User{
		ID:            uuid.New(),
		TenantID:      defaultTenant.ID,
		Category:      "parent",
		Name:          req.Name,
		Email:         req.Email,
		Password:      req.Password, // CreateUser will hash this
		AccountNumber: "PR" + time.Now().Format("060102150405"), // generate random account number
		CreatedAt:     time.Now(),
	}

	if err := h.repo.CreateUser(c.Context(), user); err != nil {
		c.App().Config().ErrorHandler(c, err) // print err to server logs or terminal
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{"error": "could not create user account: " + err.Error()})
	}

	return c.Status(fiber.StatusCreated).JSON(fiber.Map{
		"message": "account created successfully",
		"user": fiber.Map{
			"id":    user.ID,
			"name":  user.Name,
			"email": user.Email,
		},
	})
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

	// Check SPMB status for parents
	spmbCompleted := false
	if user.Category == "parent" {
		spmbCompleted, _ = h.repo.CheckSpmbCompleted(c.Context(), userID)
	}

	return c.Status(fiber.StatusOK).JSON(fiber.Map{
		"data": fiber.Map{
			"id":             user.ID,
			"name":           user.Name,
			"email":          user.Email,
			"phone":          user.Phone,
			"address":        user.Address,
			"avatar_url":     user.AvatarURL,
			"category":       user.Category,
			"role":           claims.Role,
			"permissions":    permissions,
			"tenant_id":      user.TenantID,
			"spmb_completed": spmbCompleted,
		},
	})
}

// UpdateProfileRequest is the request body for PUT /users/profile.
type UpdateProfileRequest struct {
	Name      string  `json:"name"`
	Phone     *string `json:"phone"`
	Address   *string `json:"address"`
	AvatarURL *string `json:"avatar_url"`
}

// UpdateProfile updates the authenticated user's profile.
// PUT /api/v1/users/profile  (requires JWT)
func (h *UserHandler) UpdateProfile(c *fiber.Ctx) error {
	claims, ok := c.Locals("claims").(*middleware.Claims)
	if !ok || claims == nil {
		return c.Status(fiber.StatusUnauthorized).JSON(fiber.Map{"error": "unauthorized"})
	}

	userID, err := uuid.Parse(claims.UserID)
	if err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "invalid user id in token"})
	}

	var req UpdateProfileRequest
	if err := c.BodyParser(&req); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "invalid request body"})
	}

	user, err := h.repo.GetUserByID(c.Context(), userID)
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{"error": "internal server error"})
	}
	if user == nil {
		return c.Status(fiber.StatusNotFound).JSON(fiber.Map{"error": "user not found"})
	}

	// Update fields
	if req.Name != "" {
		user.Name = req.Name
	}
	user.Phone = req.Phone
	user.Address = req.Address
	user.AvatarURL = req.AvatarURL

	if err := h.repo.UpdateUserProfile(c.Context(), user); err != nil {
		c.App().Config().ErrorHandler(c, err)
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{"error": "could not update profile"})
	}

	return c.Status(fiber.StatusOK).JSON(fiber.Map{
		"message": "profile updated successfully",
	})
}

// GoogleAuthRequest represents the payload from Flutter's Google Sign In.
type GoogleAuthRequest struct {
	IDToken string `json:"id_token"`
}

// GoogleLogin handles Google OAuth login/registration.
// POST /api/v1/users/auth/google
func (h *UserHandler) GoogleLogin(c *fiber.Ctx) error {
	var req GoogleAuthRequest
	if err := c.BodyParser(&req); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "invalid request payload"})
	}

	if req.IDToken == "" {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "id_token is required"})
	}

	// Validate the token with Google
	payload, err := idtoken.Validate(c.Context(), req.IDToken, h.cfg.App.GoogleClientID)
	if err != nil {
		return c.Status(fiber.StatusUnauthorized).JSON(fiber.Map{"error": "invalid google token"})
	}

	email := payload.Claims["email"].(string)
	name := payload.Claims["name"].(string)
	var picture *string
	if pic, ok := payload.Claims["picture"].(string); ok {
		picture = &pic
	}

	// Check if user exists
	user, err := h.repo.GetUserByEmail(c.Context(), email)
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{"error": "database error"})
	}

	if user == nil {
		// Auto-register user as Parent
		newUser := &domain.User{
			Category:  "parent",
			Name:      name,
			Email:     email,
			Password:  "", // No password for Google login
			AvatarURL: picture,
		}

		err = h.repo.CreateUser(c.Context(), newUser)
		if err != nil {
			return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{"error": "failed to register user"})
		}
		user = newUser
	} else if user.AvatarURL == nil && picture != nil {
		// Update avatar if they didn't have one
		user.AvatarURL = picture
		_ = h.repo.UpdateUserProfile(c.Context(), user)
	}

	// Generate JWT Token
	claims := middleware.Claims{
		UserID: user.ID.String(),
		Role:   "parent",
		RegisteredClaims: jwt.RegisteredClaims{
			ExpiresAt: jwt.NewNumericDate(time.Now().Add(24 * time.Hour)),
			IssuedAt:  jwt.NewNumericDate(time.Now()),
		},
	}

	token := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)
	tokenString, err := token.SignedString([]byte(h.cfg.JWT.Secret))
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{"error": "could not generate token"})
	}

	// Optional: Get permissions for UI
	permissions, _ := h.repo.GetUserPermissions(c.Context(), user.ID)

	return c.Status(fiber.StatusOK).JSON(fiber.Map{
		"token": tokenString,
		"user": fiber.Map{
			"id":          user.ID,
			"name":        user.Name,
			"email":       user.Email,
			"role":        "parent",
			"permissions": permissions,
		},
	})
}
