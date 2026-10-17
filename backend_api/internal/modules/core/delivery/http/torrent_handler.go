package http

import (
	"database/sql"
	"fmt"

	"github.com/gofiber/fiber/v2"
	"neuracakrawira.asia/satu-sekolah-backend/internal/utils"
)

type TorrentHandler struct {
	db *sql.DB
}

func NewTorrentHandler(db *sql.DB) *TorrentHandler {
	return &TorrentHandler{db: db}
}

// UploadMedia handles any media upload, applies limits/conversion, and triggers torrent generation if > 10MB
func (h *TorrentHandler) UploadMedia(c *fiber.Ctx) error {
	file, err := c.FormFile("file")
	if err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "file is required"})
	}

	baseDir := "./uploads/media"
	baseURL := "/files/media"

	result, err := utils.ProcessUpload(file, baseDir, baseURL)
	if err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": err.Error()})
	}

	// If file is > 15MB
	if result.FinalSizeB > 15*1024*1024 {
		go func(path, url string) {
			// Generate WebSeed URL
			webSeedURL := fmt.Sprintf("http://localhost:8080%s", url) 
			trackerURL := "ws://localhost:8000"
			
			infoHash, magnetLink, err := utils.GenerateTorrentMetadata(path, webSeedURL, trackerURL)
			if err == nil {
				// Save to database
				_, _ = h.db.Exec(
					"INSERT INTO torrent_metadata (file_path, info_hash, magnet_link) VALUES (?, ?, ?) ON DUPLICATE KEY UPDATE info_hash=VALUES(info_hash), magnet_link=VALUES(magnet_link)",
					url, infoHash, magnetLink,
				)
			}
		}(result.SavePath, result.FileURL)
	}

	return c.JSON(fiber.Map{
		"message": "Upload successful",
		"data": fiber.Map{
			"file_url":       result.FileURL,
			"original_size":  result.OrigSizeB,
			"final_size":     result.FinalSizeB,
			"converted":      result.Converted,
			"is_torrentable": result.FinalSizeB > 15*1024*1024,
		},
	})
}

// GetTorrentMeta returns torrent details for a given file_path
func (h *TorrentHandler) GetTorrentMeta(c *fiber.Ctx) error {
	filePath := c.Query("path")
	if filePath == "" {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "path is required"})
	}

	var infoHash, magnetLink string
	err := h.db.QueryRow("SELECT info_hash, magnet_link FROM torrent_metadata WHERE file_path = ?", filePath).Scan(&infoHash, &magnetLink)
	if err != nil {
		return c.Status(fiber.StatusNotFound).JSON(fiber.Map{"error": "torrent metadata not found or file is < 10MB"})
	}

	return c.JSON(fiber.Map{
		"info_hash":   infoHash,
		"magnet_link": magnetLink,
	})
}
