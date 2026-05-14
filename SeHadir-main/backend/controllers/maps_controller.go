package controllers

import (
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"os"
	"time"

	"github.com/gofiber/fiber/v2"
)

func GetGoogleMapsReviews(c *fiber.Ctx) error {
	placeID := os.Getenv("GOOGLE_PLACE_ID")
	apiKey := os.Getenv("GOOGLE_MAPS_API_KEY")

	url := fmt.Sprintf(
		"https://maps.googleapis.com/maps/api/place/details/json?place_id=%s&fields=rating,reviews,user_ratings_total&key=%s",
		placeID,
		apiKey,
	)

	client := &http.Client{
        Timeout: 10 * time.Second,
    }

	resp, err := client.Get(url)
    if err != nil {
        return c.Status(500).JSON(fiber.Map{
            "status":  "error",
            "message": "Gagal terhubung ke Google Maps API: " + err.Error(),
        })
    }
    defer resp.Body.Close()

    body, err := io.ReadAll(resp.Body)
    if err != nil {
        return c.Status(500).JSON(fiber.Map{
            "status":  "error",
            "message": "Gagal membaca balasan dari Google",
        })
    }

    var data map[string]any
    if err := json.Unmarshal(body, &data); err != nil {
         return c.Status(500).JSON(fiber.Map{
            "status":  "error",
            "message": "Gagal memproses data JSON",
        })
    }

	return c.JSON(data)
}