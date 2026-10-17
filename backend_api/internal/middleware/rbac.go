package middleware

import "github.com/gofiber/fiber/v2"

// RequireRole returns a Fiber middleware that checks whether the authenticated
// user (from JWT claims) has one of the allowed roles.
// Must be placed AFTER JWTAuth in the middleware chain.
func RequireRole(roles ...string) fiber.Handler {
	return func(c *fiber.Ctx) error {
		claims, ok := c.Locals("claims").(*Claims)
		if !ok || claims == nil {
			return c.Status(fiber.StatusUnauthorized).JSON(fiber.Map{
				"error": "unauthorized",
			})
		}
		for _, r := range roles {
			if claims.Role == r {
				return c.Next()
			}
		}
		return c.Status(fiber.StatusForbidden).JSON(fiber.Map{
			"error": "forbidden: insufficient role. Required: " + joinRoles(roles),
		})
	}
}

func joinRoles(roles []string) string {
	result := ""
	for i, r := range roles {
		if i > 0 {
			result += ", "
		}
		result += r
	}
	return result
}
