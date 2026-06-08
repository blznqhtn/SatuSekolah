package middleware

import (
	"context"
	"database/sql"

	"github.com/gofiber/fiber/v2"
	"github.com/google/uuid"
)

// RequirePermission returns a Fiber middleware that checks whether the authenticated
// user has a specific named permission (from the permissions table via role_permissions).
// Admin users (category = 'Admin') automatically bypass this check.
// Must be placed AFTER JWTAuth in the middleware chain.
func RequirePermission(db *sql.DB, permissionName string) fiber.Handler {
	return func(c *fiber.Ctx) error {
		claims, ok := c.Locals("claims").(*Claims)
		if !ok || claims == nil {
			return c.Status(fiber.StatusUnauthorized).JSON(fiber.Map{
				"error": "unauthorized",
			})
		}

		// Admin role bypasses all permission checks
		if claims.Role == "Admin" {
			return c.Next()
		}

		userID, err := uuid.Parse(claims.UserID)
		if err != nil {
			return c.Status(fiber.StatusUnauthorized).JSON(fiber.Map{
				"error": "invalid user identity",
			})
		}

		allowed, err := checkUserPermission(db, c.Context(), userID, permissionName)
		if err != nil {
			return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
				"error": "failed to verify permissions",
			})
		}
		if !allowed {
			return c.Status(fiber.StatusForbidden).JSON(fiber.Map{
				"error": "forbidden: permission '" + permissionName + "' is required",
			})
		}

		return c.Next()
	}
}

// checkUserPermission queries the DB to verify user has a specific permission
// via their assigned role(s).
func checkUserPermission(db *sql.DB, ctx context.Context, userID uuid.UUID, permissionName string) (bool, error) {
	// Check if user's category is Admin (always allowed)
	var category string
	catErr := db.QueryRowContext(ctx,
		`SELECT category FROM users WHERE id = $1 AND deleted_at IS NULL`, userID,
	).Scan(&category)
	if catErr == nil && category == "Admin" {
		return true, nil
	}

	// Check role → permission mapping
	var count int
	err := db.QueryRowContext(ctx, `
		SELECT COUNT(p.id) FROM permissions p
		JOIN role_permissions rp ON rp.permission_id = p.id
		JOIN user_roles ur ON ur.role_id = rp.role_id
		WHERE ur.user_id = $1 AND p.name = $2
	`, userID, permissionName).Scan(&count)
	if err != nil {
		return false, err
	}
	return count > 0, nil
}
