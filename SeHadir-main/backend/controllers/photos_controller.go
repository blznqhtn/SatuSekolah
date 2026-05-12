package controllers

import (
	"context"
	"e-presence-backend/config"
	"encoding/json"
	"fmt"
	"strings"
	"time"

	"github.com/aws/aws-sdk-go-v2/service/s3"
	"github.com/gofiber/fiber/v2"
)

type PhotoItem struct {
	Name string `json:"name"`
	URL  string `json:"url"`
	Size string `json:"size"`
}

func getSchoolID(c *fiber.Ctx) (string, error) {
	// 1. Cek parameter sekolah (Digunakan oleh Web Admin Dashboard & Aplikasi Desktop/Kiosk)
	sekolahParam := c.Query("sekolah")
	if sekolahParam != "" {
		var schoolID string
		// Validasi apakah school ID tersebut valid dan ada di database
		err := config.DB.WithContext(c.Context()).
			Table("sekolah").
			Select("id").
			Where("id = ?", sekolahParam).
			Scan(&schoolID).Error

		if err == nil && schoolID != "" {
			return schoolID, nil
		}
		return "", fmt.Errorf("unauthorized: parameter/secret key sekolah tidak valid atau tidak ditemukan")
	}

	// 2. Jika tidak ada parameter sekolah, pastikan ini adalah request dengan sesi aktif
	uidLocals := c.Locals("uid")
	if uidLocals == nil {
		return "", fmt.Errorf("unauthorized: tidak ada sesi aktif atau parameter sekolah")
	}

	userID := uidLocals.(string)
	userRole := c.Locals("role")

	// Admin Logic: Admin WAJIB memberikan parameter sekolah, jika sampai di sini berarti kosong
	if userRole == "admin" || userRole == "superadmin" {
		return "", fmt.Errorf("admin request harus menyertakan parameter sekolah (ID_INSTANSI)")
	}

	// 3. Regular User Logic (Cache & DB Lookup)
	var schoolID string
	cacheKey := "user_school_id:" + userID

	val, err2 := config.RDB.Get(c.Context(), cacheKey).Result()
	if err2 == nil && val != "" {
		return val, nil
	}

	err := config.DB.WithContext(c.Context()).
		Table("users").
		Select("sekolah.id").
		Joins("JOIN school_members ON school_members.id = users.id_school_member").
		Joins("JOIN sekolah ON sekolah.id = school_members.id_sekolah").
		Where("users.id = ?", userID).
		Scan(&schoolID).Error

	if err != nil {
		return "", err
	}

	if schoolID == "" {
		return "", fmt.Errorf("user tidak terasosiasi dengan sekolah manapun")
	}

	config.RDB.Set(c.Context(), cacheKey, schoolID, 24*time.Hour)

	return schoolID, nil
}

func ListPhotos(c *fiber.Ctx) error {
	schoolID, err := getSchoolID(c)
	if err != nil {
		return c.Status(fiber.StatusUnauthorized).JSON(fiber.Map{"status": "failed", "message": "Sesi tidak valid"})
	}

	userID := c.Locals("uid").(string)

	cacheKey := fmt.Sprintf("s3:photos:%s:profile:%s", schoolID, userID)
	ctx := context.Background()

	cachedData, errRedis := config.RDB.Get(ctx, cacheKey).Result()
	if errRedis == nil {
		var cachedPhotos []PhotoItem
		if errUnmarshal := json.Unmarshal([]byte(cachedData), &cachedPhotos); errUnmarshal == nil {
			return c.JSON(fiber.Map{
				"status": "success",
				"data":   cachedPhotos,
			})
		}
	}

	prefix := fmt.Sprintf("%s/profile/", schoolID)
	
	output, errS3 := config.S3Client.ListObjectsV2(ctx, &s3.ListObjectsV2Input{
		Bucket: &config.S3Bucket,
		Prefix: &prefix,
	})

	photos := []PhotoItem{}
	if errS3 == nil {
		for _, obj := range output.Contents {
			if *obj.Key != prefix {
				fileName := strings.TrimPrefix(*obj.Key, prefix)

				var sizeStr string
				if obj.Size != nil {
					sizeStr = formatSize(*obj.Size)
				}

				photos = append(photos, PhotoItem{
					Name: fileName,
					URL:  config.S3BaseURL + "/" + *obj.Key,
					Size: sizeStr,
				})
			}
		}
	} else {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
			"status":  "failed",
			"message": "Gagal mengambil data dari AWS S3",
		})
	}

	photoBytes, errMarshal := json.Marshal(photos)
	if errMarshal == nil {
		config.RDB.Set(ctx, cacheKey, photoBytes, 2*time.Minute)
	}

	return c.JSON(fiber.Map{
		"status": "success",
		"data":   photos,
	})
}

func UploadPhotos(c *fiber.Ctx) error {
	schoolID, errAuth := getSchoolID(c)
	if errAuth != nil {
		return c.Status(fiber.StatusUnauthorized).JSON(fiber.Map{"status": "failed", "message": "Sesi tidak valid"})
	}

	form, err := c.MultipartForm()
	if err != nil {
		return c.Status(400).JSON(fiber.Map{"status": "failed", "message": "No files uploaded"})
	}

	files := form.File["photo_files"]
	var uploaded []string

	for _, fileHeader := range files {
		file, errOpen := fileHeader.Open()
		if errOpen != nil {
			continue
		}
		defer file.Close()

		filename := fileHeader.Filename
		key := fmt.Sprintf("%s/profile/%s", schoolID, filename)
		
		url, errUpload := config.UploadToS3(file, key, fileHeader.Header.Get("Content-Type"))

		if errUpload == nil {
			uploaded = append(uploaded, url)
		}
	}

	if len(uploaded) > 0 {
		ctx := context.Background()
		iter := config.RDB.Scan(ctx, 0, fmt.Sprintf("s3:photos:%s:profile:*", schoolID), 0).Iterator()
		for iter.Next(ctx) {
			config.RDB.Del(ctx, iter.Val())
		}
	}

	return c.JSON(fiber.Map{
		"status":  "success",
		"message": fmt.Sprintf("Successfully uploaded %d photos", len(uploaded)),
		"data":    uploaded,
	})
}

func DeletePhoto(c *fiber.Ctx) error {
    type Request struct {
        Filename string `json:"filename"`
        Sekolah  string `json:"sekolah"`
    }

    var req Request
    if err := c.BodyParser(&req); err != nil {
        return c.Status(400).JSON(fiber.Map{"status": "failed", "message": "Invalid request"})
    }

    schoolID := req.Sekolah
    if schoolID == "" {
        return c.Status(fiber.StatusUnauthorized).JSON(fiber.Map{"status": "failed", "message": "Sesi tidak valid"})
    }

    key := strings.TrimPrefix(req.Filename, config.S3BaseURL+"/")
    expectedPrefix := fmt.Sprintf("%s/profile/", schoolID)

    if !strings.Contains(key, "/") {
        key = expectedPrefix + key
    }

    if !strings.HasPrefix(key, expectedPrefix) && schoolID != "global_school" {
        return c.Status(403).JSON(fiber.Map{"status": "failed", "message": "Akses ditolak: Anda tidak dapat menghapus file milik sekolah lain"})
    }

    if err := config.DeleteFromS3(key); err != nil {
        return c.Status(500).JSON(fiber.Map{"status": "failed", "message": "Failed to delete photo"})
    }

    ctx := context.Background()
    iter := config.RDB.Scan(ctx, 0, fmt.Sprintf("s3:photos:%s:profile:*", schoolID), 0).Iterator()
    for iter.Next(ctx) {
        config.RDB.Del(ctx, iter.Val())
    }

    return c.JSON(fiber.Map{"status": "success", "message": "Photo deleted successfully"})
}

// ==========================================
// HELPERS
// ==========================================
func formatSize(bytes int64) string {
	if bytes < 1024 {
		return fmt.Sprintf("%d B", bytes)
	} else if bytes < 1024*1024 {
		return fmt.Sprintf("%.2f KB", float64(bytes)/1024.0)
	}
	return fmt.Sprintf("%.2f MB", float64(bytes)/(1024.0*1024.0))
}