package routes

import (
	"e-presence-backend/controllers"
	"github.com/gofiber/fiber/v2"
	"github.com/gofiber/fiber/v2/middleware/cache"
	"github.com/gofiber/storage/redis/v3"

	"time"
	"os"
	"strconv"
)


func SetupRoutesWeb(app *fiber.App) {
	portStr := os.Getenv("REDIS_PORT")
	port, _ := strconv.Atoi(portStr)
	if port == 0 {
		port = 6379
	}

	store := redis.New(redis.Config{
		Host: os.Getenv("REDIS_HOST"),
		Port: port,
	})

	web := app.Group("/")

	web.Get("get-reviews", cache.New(cache.Config{
		Expiration:   24 * time.Hour,
		CacheControl: true,
		Storage:      store,
	}), controllers.GetGoogleMapsReviews)

	web.Get("kelas", controllers.GetKelas)
	web.Get("validate", controllers.ValidateSecret)

	users := web.Group("users")
	users.Get("/total", controllers.TotalUsers)

	presences := web.Group("presences")
	presences.Get("/", controllers.StudentPresenceByClass)
	presences.Get("/all", controllers.AllPresensi)
}