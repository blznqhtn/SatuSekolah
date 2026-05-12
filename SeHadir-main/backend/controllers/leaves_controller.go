package controllers

import (
	"e-presence-backend/config"
	"e-presence-backend/models"
	"encoding/json"
	"fmt"
	"path/filepath"
	"strconv"
	"strings"
	"time"

	"github.com/gofiber/fiber/v2"
	"github.com/google/uuid"
	"golang.org/x/text/cases"
	"golang.org/x/text/language"
)

func incrementCacheVersion(schoolID string) {
	cacheKey := fmt.Sprintf("leave_documents_version:%s", schoolID)
	config.RDB.Incr(config.Ctx, cacheKey)
}

func getCacheVersion(schoolID string) string {
	cacheKey := fmt.Sprintf("leave_documents_version:%s", schoolID)
	version, err := config.RDB.Get(config.Ctx, cacheKey).Result()
	if err != nil {
		config.RDB.Set(config.Ctx, cacheKey, "1", 0)
		return "1"
	}
	return version
}

type SendLeaveDocumentRequest struct {
	NoInduk   string `form:"no_induk"`
	Type      string `form:"type"`
	StartDate string `form:"start_date"`
	EndDate   string `form:"end_date"`
	Reason    string `form:"reason"`
}

func SendLeaveDocument(c *fiber.Ctx) error {
	noInduk := c.FormValue("no_induk")
	if noInduk == "" {
		noInduk = c.FormValue("nis")
	}

	if noInduk == "" {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{
			"status":  "failed",
			"message": "Nomor Induk tidak boleh kosong",
		})
	}

	typeStr := c.FormValue("type")
	startDateStr := c.FormValue("start_date")
	endDateStr := c.FormValue("end_date")
	reason := c.FormValue("reason")

	validTypes := map[string]bool{
		"izin":  true,
		"sakit": true,
	}

	if !validTypes[strings.ToLower(typeStr)] {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{
			"status":  "failed",
			"message": "Tipe izin tidak valid",
		})
	}

	var userInfo struct {
		UserID   string `gorm:"column:user_id"`
		SchoolID string `gorm:"column:school_id"`
	}

	if err := config.DB.Table("users").
		Select("users.id as user_id, school_members.id_sekolah as school_id").
		Joins("JOIN school_members ON school_members.id = users.id_school_member").
		Where("school_members.no_induk = ?", noInduk).
		Scan(&userInfo).Error; err != nil || userInfo.UserID == "" {
		return c.Status(fiber.StatusNotFound).JSON(fiber.Map{
			"status":  "failed",
			"message": "Nomor Induk tidak terdaftar",
		})
	}

	startDate, err1 := time.Parse("02/01/2006", startDateStr)
	endDate, err2 := time.Parse("02/01/2006", endDateStr)

	if err1 != nil || err2 != nil {
		startDate, err1 = time.Parse("2006-01-02", startDateStr)
		endDate, err2 = time.Parse("2006-01-02", endDateStr)

		if err1 != nil || err2 != nil {
			return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{
				"status":  "failed",
				"message": "Format tanggal tidak valid",
			})
		}
	}

	if endDate.Before(startDate) {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{
			"status":  "failed",
			"message": "Tanggal selesai harus setelah atau sama dengan tanggal mulai",
		})
	}

	var documentPath *string
	var s3Key string

	fileHeader, err := c.FormFile("document")

	if err == nil {
		ext := strings.ToLower(filepath.Ext(fileHeader.Filename))
		allowedExts := map[string]bool{".jpg": true, ".jpeg": true, ".png": true, ".pdf": true}

		if !allowedExts[ext] {
			return c.Status(fiber.StatusUnprocessableEntity).JSON(fiber.Map{
				"status":  "failed",
				"message": "Format file tidak diizinkan. Hanya boleh JPG, PNG, atau PDF.",
			})
		}

		src, err := fileHeader.Open()
		if err != nil {
			return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
				"status":  "failed",
				"message": "Gagal membaca file dari request",
			})
		}
		defer src.Close()

		contentType := "application/octet-stream"
		switch ext {
		case ".jpg", ".jpeg":
			contentType = "image/jpeg"
		case ".png":
			contentType = "image/png"
		case ".pdf":
			contentType = "application/pdf"
		}

		filename := strconv.FormatInt(time.Now().UnixNano(), 10) + ext

		// KEY S3 BARU: <id_sekolah>/surat/<no_induk>/nama-file.ext
		s3Key = fmt.Sprintf("%s/surat/%s/%s", userInfo.SchoolID, noInduk, filename)

		uploadedURL, err := config.UploadToS3(src, s3Key, contentType)
		if err != nil {
			return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
				"status":  "failed",
				"message": "Gagal mengunggah dokumen ke server Cloud S3",
			})
		}

		documentPath = &uploadedURL
	}

	caser := cases.Title(language.Indonesian)
	presenceType := caser.String(strings.ToLower(typeStr))

	parsedUserID, err := uuid.Parse(userInfo.UserID)
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
			"status":  "failed",
			"message": "ID pengguna tidak valid",
		})
	}

	leaveDoc := models.LeaveDocument{
		IDUser:       parsedUserID,
		Type:         presenceType,
		StartDate:    startDate,
		EndDate:      endDate,
		Reason:       &reason,
		DocumentPath: documentPath,
	}

	if err := config.DB.Create(&leaveDoc).Error; err != nil {
		if documentPath != nil {
			_ = config.DeleteFromS3(s3Key)
		}
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
			"status":  "failed",
			"message": "Gagal menyimpan data ke database",
		})
	}

	// Loop untuk memasukkan data ke tabel presences dari startDate sampai endDate
	loc, _ := time.LoadLocation("Asia/Jakarta")
	for d := startDate; !d.After(endDate); d = d.AddDate(0, 0, 1) {
		currentDate := d.In(loc)
		dateStr := currentDate.Format("2006-01-02")

		// Cek kalender akademik untuk menentukan status hari
		var hari models.Hari
		config.DB.Where("id_sekolah = ? AND bulan = ? AND tahun = ?",
			userInfo.SchoolID, int(currentDate.Month()), currentDate.Year()).First(&hari)

		// Cek apakah hari libur
		isLibur := false
		for _, liburDate := range hari.HariLibur {
			if liburDate == dateStr {
				isLibur = true
				break
			}
		}

		// Jika hari libur, lewati (tidak perlu buat record presensi)
		if isLibur {
			continue
		}

		// Tentukan status hari (Produktif atau Non-Produktif)
		statusHari := "Hari Produktif"
		isAdditional := false
		for _, addDate := range hari.HariTambahan {
			if addDate == dateStr {
				isAdditional = true
				break
			}
		}
		if isAdditional {
			statusHari = "Hari Non-Produktif"
		}

		// Buat record presensi
		newPresence := models.Presence{
			IDUser:     parsedUserID,
			TimeMasuk:  currentDate, // Jam 00:00:00 sebagai tanda izin
			Status:     presenceType,
			StatusHari: statusHari,
		}

		// Gunakan FirstOrCreate atau check manual untuk menghindari duplikasi di tanggal yang sama
		var existingPresence models.Presence
		errCheck := config.DB.Where("id_user = ? AND DATE(time_masuk) = ?", parsedUserID, dateStr).First(&existingPresence).Error

		if errCheck != nil { // Jika tidak ditemukan, baru buat
			config.DB.Create(&newPresence)
		} else {
			// Jika sudah ada (mungkin Alpa), update statusnya menjadi Izin/Sakit
			config.DB.Model(&existingPresence).Updates(models.Presence{
				Status:     presenceType,
				StatusHari: statusHari,
			})
		}
	}

	// Hapus cache dashboard agar statistik langsung terupdate
	cacheKey := fmt.Sprintf("dashboard_user:%s", parsedUserID.String())
	config.RDB.Del(config.Ctx, cacheKey)

	incrementCacheVersion(userInfo.SchoolID)

	return c.JSON(fiber.Map{
		"status":  "success",
		"message": "Dokumen izin berhasil dikirim",
	})
}

func GetLeaveDocuments(c *fiber.Ctx) error {
	schoolID, errAuth := getSchoolID(c)
	if errAuth != nil {
		return c.Status(fiber.StatusUnauthorized).JSON(fiber.Map{"status": "failed", "message": "Sesi tidak valid"})
	}

	pageStr := c.Query("page", "1")
	limitStr := c.Query("limit", "20")

	page, _ := strconv.Atoi(pageStr)
	limit, _ := strconv.Atoi(limitStr)
	offset := (page - 1) * limit

	currentVersion := getCacheVersion(schoolID)

	cacheKey := fmt.Sprintf("leave_docs:%s:v%s:page:%s:limit:%s", schoolID, currentVersion, pageStr, limitStr)

	cachedData, err := config.RDB.Get(config.Ctx, cacheKey).Result()
	if err == nil {
		c.Type("json")
		return c.SendString(cachedData)
	}

	var docs []models.LeaveDocument
	var totalData int64

	query := config.DB.Model(&models.LeaveDocument{}).
		Joins("JOIN users ON users.id = leave_documents.id_user").
		Joins("JOIN school_members ON school_members.id = users.id_school_member").
		Where("school_members.id_sekolah = ?", schoolID)

	query.Count(&totalData)

	query.Preload("User.SchoolMember").
		Order("leave_documents.created_at DESC").
		Limit(limit).
		Offset(offset).
		Find(&docs)

	response := fiber.Map{
		"status": "success",
		"data":   docs,
		"meta": fiber.Map{
			"current_page": page,
			"per_page":     limit,
			"total_data":   totalData,
		},
	}

	responseBytes, errMarshal := json.Marshal(response)
	if errMarshal == nil {
		config.RDB.Set(config.Ctx, cacheKey, responseBytes, 24*time.Hour)
	}

	return c.JSON(response)
}

func GetLeaveDocument(c *fiber.Ctx) error {
	id := c.Params("id")
	schoolID, _ := getSchoolID(c)

	var doc models.LeaveDocument

	if err := config.DB.
		Joins("JOIN users ON users.id = leave_documents.id_user").
		Joins("JOIN school_members ON school_members.id = users.id_school_member").
		Where("leave_documents.id = ? AND school_members.id_sekolah = ?", id, schoolID).
		Preload("User.SchoolMember").
		First(&doc).Error; err != nil {
		return c.Status(fiber.StatusNotFound).JSON(fiber.Map{
			"status":  "failed",
			"message": "Dokumen tidak ditemukan atau akses ditolak",
		})
	}

	return c.JSON(fiber.Map{
		"status": "success",
		"data":   doc,
	})
}

func DeleteLeaveDocument(c *fiber.Ctx) error {
	id := c.Params("id")
	schoolID, _ := getSchoolID(c)

	var doc models.LeaveDocument

	if err := config.DB.
		Joins("JOIN users ON users.id = leave_documents.id_user").
		Joins("JOIN school_members ON school_members.id = users.id_school_member").
		Where("leave_documents.id = ? AND school_members.id_sekolah = ?", id, schoolID).
		First(&doc).Error; err != nil {
		return c.Status(fiber.StatusNotFound).JSON(fiber.Map{
			"status":  "failed",
			"message": "Dokumen tidak ditemukan atau akses ditolak",
		})
	}

	if doc.DocumentPath != nil {
		s3Key := strings.TrimPrefix(*doc.DocumentPath, config.S3BaseURL+"/")
		_ = config.DeleteFromS3(s3Key)
	}

	config.DB.Delete(&doc)

	if schoolID != "" {
		incrementCacheVersion(schoolID)
	}

	return c.JSON(fiber.Map{
		"status":  "success",
		"message": "Dokumen berhasil dihapus",
	})
}
