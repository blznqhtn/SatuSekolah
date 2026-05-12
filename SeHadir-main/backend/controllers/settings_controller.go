package controllers

import (
	"crypto/rand"
	"e-presence-backend/config"
	"e-presence-backend/models"
	"encoding/json"
	"fmt"
	"math/big"
	"strconv"
	"time"

	"github.com/gofiber/fiber/v2"
	"github.com/google/uuid"
	"gorm.io/gorm"
	"gorm.io/gorm/clause"
)

// ==========================================
// DATA TRANSFER OBJECTS (DTOs) & STRUCTS
// ==========================================

type UpsertSettingRequest struct {
	Service                     string   `json:"service"`
	ApiKey                      *string  `json:"api_key"`
	AttendanceMethod            *string  `json:"attendance_method"`
	FaceRecognitionEnabled      *bool    `json:"face_recognition_enabled"`
	AntiSpoofingEnabled         *bool    `json:"anti_spoofing_enabled"`
	FaceConfidenceThreshold     *float64 `json:"face_confidence_threshold"`
	SpEnabled                   *bool    `json:"sp_enabled"`
	SpMaxLatePerMonth           *int     `json:"sp_max_late_per_month"`
	SpTemplate                  *string  `json:"sp_template"`
	WhatsappNotificationEnabled *bool    `json:"whatsapp_notification_enabled"`

	NamaSekolah      *string `json:"nama_sekolah"`
	KepalaSekolah    *string `json:"kepala_sekolah"`
	NamaPerwakilanTu *string `json:"nama_perwakilan_tu"`
	Whatsapp         *string `json:"whatsapp"`
	ApikeyWhatsapp   *string `json:"apikey_whatsapp"`
	Email            *string `json:"email"`
	Website          *string `json:"website"`
	Alamat           *string `json:"alamat"`
	Ikon             *string `json:"ikon"`
}

type SaveHariRequest struct {
	IDSekolah     string   `json:"sekolah"`
	Bulan         int      `json:"bulan"`
	Tahun         int      `json:"tahun"`
	HariProduktif []string `json:"hari_produktif"`
	HariTambahan  []string `json:"hari_tambahan"`
	HariLibur     []string `json:"hari_libur"`
}

type SendVerificationRequest struct {
	Email string `json:"email"`
}

type VerifyCodeRequest struct {
	Email string `json:"email"`
	Code  string `json:"code"`
}

type ConnectServiceRequest struct {
	Service,
	ApiKey string
}

type DisconnectServiceRequest struct {
	Service string `json:"service"`
}

func GetSettings(c *fiber.Ctx) error {
	idSekolah, err := getSchoolID(c)
	if err != nil {
		return c.Status(403).JSON(fiber.Map{"status": "failed", "message": "Tidak dapat masuk ke sekolah lain."})
	}

	cacheKey := "settings:sekolah:" + idSekolah
	if cached, err := config.RDB.Get(config.Ctx, cacheKey).Result(); err == nil {
		c.Type("json")
		return c.SendString(cached)
	}

	var settings []models.Setting
	if err := config.DB.WithContext(c.Context()).Where("id_sekolah = ?", idSekolah).Find(&settings).Error; err != nil {
		return c.Status(500).JSON(fiber.Map{"status": "failed", "message": "Gagal mengambil pengaturan"})
	}

	var sekolah models.Sekolah
	if err := config.DB.WithContext(c.Context()).Where("id = ?", idSekolah).First(&sekolah).Error; err != nil {
		return c.Status(500).JSON(fiber.Map{"status": "failed", "message": "Gagal mengambil data sekolah"})
	}

	response := fiber.Map{
		"status":  "success",
		"data":    settings,
		"sekolah": sekolah,
	}

	if resBytes, err := json.Marshal(response); err == nil {
		config.RDB.Set(config.Ctx, cacheKey, resBytes, 24*time.Hour)
	}

	return c.JSON(response)
}

func UpsertSetting(c *fiber.Ctx) error {
	idSekolah, errSchool := getSchoolID(c)

	if errSchool != nil {
		return c.Status(400).JSON(fiber.Map{"status": "failed", "message": "ID Sekolah tidak valid"})
	}

	var req UpsertSettingRequest
	if err := c.BodyParser(&req); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"status": "failed", "message": "Invalid request"})
	}

	if req.Service == "" {
		return c.Status(fiber.StatusUnprocessableEntity).JSON(fiber.Map{"status": "failed", "message": "Service tidak boleh kosong"})
	}

	if errSchool == nil {
		updateData := make(map[string]interface{})

		if req.NamaSekolah != nil {
			updateData["nama_sekolah"] = *req.NamaSekolah
		}
		
		if req.KepalaSekolah != nil {
			updateData["kepala_sekolah"] = *req.KepalaSekolah
		}

		if req.NamaPerwakilanTu != nil {
			updateData["nama_perwakilan_tu"] = *req.NamaPerwakilanTu
		}

		if req.Whatsapp != nil {
			updateData["whatsapp"] = *req.Whatsapp
		}

		if req.ApikeyWhatsapp != nil {
			updateData["apikey_whatsapp"] = *req.ApikeyWhatsapp
		}

		if req.Email != nil {
			updateData["email"] = *req.Email
		}

		if req.Website != nil {
			updateData["website"] = *req.Website
		}

		if req.Alamat != nil {
			updateData["alamat"] = *req.Alamat
		}

		if req.Ikon != nil {
			updateData["ikon"] = *req.Ikon
		}

		if len(updateData) > 0 {
			if err := config.DB.WithContext(c.Context()).Model(&models.Sekolah{}).Where("id = ?", idSekolah).Updates(updateData).Error; err != nil {
				return c.Status(500).JSON(fiber.Map{"status": "failed", "message": "Gagal memperbarui informasi sekolah"})
			}
		}
	}

	var setting models.Setting
	if config.DB.WithContext(c.Context()).Where("id_sekolah = ? AND service = ?", idSekolah, req.Service).First(&setting).Error != nil {
		setting = models.Setting{
			IDSekolah:   uuid.MustParse(idSekolah),
			Service:     req.Service,
			ConnectedAt: time.Now(),
		}
	}

	if req.AttendanceMethod != nil {
		setting.AttendanceMethod = *req.AttendanceMethod
	}

	if req.FaceRecognitionEnabled != nil {
		setting.FaceRecognitionEnabled = *req.FaceRecognitionEnabled
	}

	if req.AntiSpoofingEnabled != nil {
		setting.AntiSpoofingEnabled = *req.AntiSpoofingEnabled
	}

	if req.FaceConfidenceThreshold != nil {
		setting.FaceConfidenceThreshold = *req.FaceConfidenceThreshold
	}

	if req.SpEnabled != nil {
		setting.SpEnabled = *req.SpEnabled
	}

	if req.SpMaxLatePerMonth != nil {
		setting.SpMaxLatePerMonth = *req.SpMaxLatePerMonth
	}

	if req.SpTemplate != nil {
		setting.SpTemplate = req.SpTemplate
	}

	if req.WhatsappNotificationEnabled != nil {
		setting.WhatsappNotificationEnabled = *req.WhatsappNotificationEnabled
	}

	if err := config.DB.WithContext(c.Context()).Save(&setting).Error; err != nil {
		return c.Status(500).JSON(fiber.Map{"status": "failed", "message": "Gagal menyimpan pengaturan sistem"})
	}

	go invalidateSettingsCache(idSekolah)

	return c.JSON(fiber.Map{"status": "success", "message": "Pengaturan dan Informasi Sekolah berhasil disimpan", "data": setting})
}

func DeleteSetting(c *fiber.Ctx) error {
	id := c.Params("id")

	var setting models.Setting
	if err := config.DB.WithContext(c.Context()).First(&setting, "id = ?", id).Error; err != nil {
		return c.Status(404).JSON(fiber.Map{"status": "failed", "message": "Setting tidak ditemukan"})
	}

	config.DB.WithContext(c.Context()).Delete(&setting)
	go invalidateSettingsCache(setting.IDSekolah.String())

	return c.JSON(fiber.Map{"status": "success", "message": "Setting dihapus"})
}

func GetHari(c *fiber.Ctx) error {
	idSekolah, _ := getSchoolID(c)

	now := time.Now()
	bulan, _ := strconv.Atoi(c.Query("bulan", fmt.Sprintf("%d", now.Month())))
	tahun, _ := strconv.Atoi(c.Query("tahun", fmt.Sprintf("%d", now.Year())))

	cacheKey := fmt.Sprintf("hari:m:%d:y:%d:sch:%s", bulan, tahun, idSekolah)
	if cached, err := config.RDB.Get(config.Ctx, cacheKey).Result(); err == nil {
		c.Type("json")
		return c.SendString(cached)
	}

	var hari models.Hari
	if err := config.DB.WithContext(c.Context()).Where("bulan = ? AND tahun = ? AND id_sekolah = ?", bulan, tahun, idSekolah).First(&hari).Error; err != nil {
		emptyRes := fiber.Map{
			"status": "success",
			"data": fiber.Map{
				"bulan": bulan, "tahun": tahun,
				"hari_produktif": []string{},
				"hari_tambahan":  []string{},
				"hari_libur":     []string{},
			},
		}
		emptyBytes, _ := json.Marshal(emptyRes)
		config.RDB.Set(config.Ctx, cacheKey, emptyBytes, 24*time.Hour)
		return c.JSON(emptyRes)
	}

	response := fiber.Map{"status": "success", "data": hari}
	resBytes, _ := json.Marshal(response)
	config.RDB.Set(config.Ctx, cacheKey, resBytes, 24*time.Hour)

	return c.JSON(response)
}

func SaveHari(c *fiber.Ctx) error {
	var req SaveHariRequest
	if err := c.BodyParser(&req); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{
			"status":  "failed",
			"message": "Invalid request",
		})
	}

	idSekolah, err := uuid.Parse(req.IDSekolah)
	if err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{
			"status":  "error",
			"message": "ID Sekolah tidak valid",
		})
	}

	err = config.DB.WithContext(c.Context()).Transaction(func(tx *gorm.DB) error {
		hari := models.Hari{
			IDSekolah:     idSekolah,
			Bulan:         req.Bulan,
			Tahun:         req.Tahun,
			HariProduktif: models.StringArray(req.HariProduktif),
			HariTambahan:  models.StringArray(req.HariTambahan),
			HariLibur:     models.StringArray(req.HariLibur),
		}

		// UPSERT (atomic, anti race condition)
		if err := tx.Clauses(clause.OnConflict{
			Columns: []clause.Column{
				{Name: "id_sekolah"},
				{Name: "bulan"},
				{Name: "tahun"},
			},
			DoUpdates: clause.AssignmentColumns([]string{
				"hari_produktif",
				"hari_tambahan",
				"hari_libur",
				"updated_at",
			}),
		}).Create(&hari).Error; err != nil {
			return err
		}

		return nil
	})

	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
			"status":  "error",
			"message": "Gagal menyimpan ke database",
		})
	}

	go invalidateHariCache(req.Bulan, req.Tahun, req.IDSekolah)

	return c.JSON(fiber.Map{
		"status":  "success",
		"message": "Jadwal hari berhasil disimpan",
	})
}

func SendVerificationCode(c *fiber.Ctx) error {
	var req SendVerificationRequest
	if err := c.BodyParser(&req); err != nil {
		return c.Status(400).JSON(fiber.Map{"status": "failed", "message": "Request tidak valid"})
	}
	if req.Email == "" {
		return c.Status(422).JSON(fiber.Map{"status": "failed", "message": "Email tidak boleh kosong"})
	}

	max := big.NewInt(1000000)
	n, err := rand.Int(rand.Reader, max)
	if err != nil {
		return c.Status(500).JSON(fiber.Map{"status": "failed", "message": "Gagal membuat kode keamanan"})
	}
	code := fmt.Sprintf("%06d", n.Int64())

	tx := config.DB.WithContext(c.Context()).Begin()
	tx.Where("email = ?", req.Email).Delete(&models.VerificationCode{})

	if err := tx.Create(&models.VerificationCode{
		Email: req.Email, Code: code, ExpiresAt: time.Now().Add(10 * time.Minute),
	}).Error; err != nil {
		tx.Rollback()
		return c.Status(500).JSON(fiber.Map{"status": "failed", "message": "Gagal menyimpan kode verifikasi"})
	}

	tx.Commit()

	go config.SendEmail(
		req.Email,
		"Kode Verifikasi SeHadir",
		fmt.Sprintf("Kode verifikasi Anda adalah: <b>%s</b>\nKode ini berlaku selama 10 menit.", code),
	)

	return c.JSON(fiber.Map{"status": "success", "message": "Kode verifikasi telah dikirimkan ke email"})
}

func VerifyCode(c *fiber.Ctx) error {
	var req VerifyCodeRequest
	if err := c.BodyParser(&req); err != nil {
		return c.Status(400).JSON(fiber.Map{"status": "failed", "message": "Request tidak valid"})
	}

	var code models.VerificationCode
	if err := config.DB.WithContext(c.Context()).Where("email = ? AND code = ?", req.Email, req.Code).First(&code).Error; err != nil {
		return c.Status(200).JSON(fiber.Map{"status": "failed", "message": "Kode verifikasi tidak valid"})
	}

	if time.Now().After(code.ExpiresAt) {
		return c.Status(200).JSON(fiber.Map{"status": "failed", "message": "Kode verifikasi sudah kadaluwarsa"})
	}

	config.DB.WithContext(c.Context()).Delete(&code)
	return c.JSON(fiber.Map{"status": "success", "message": "Kode verifikasi valid"})
}

func GetSekolah(c *fiber.Ctx) error {
	if cached, err := config.RDB.Get(config.Ctx, "sekolah_info").Result(); err == nil {
		c.Type("json")
		return c.SendString(cached)
	}

	var sekolah models.Sekolah
	if err := config.DB.WithContext(c.Context()).First(&sekolah).Error; err != nil {
		return c.JSON(fiber.Map{"status": "success", "data": nil})
	}

	response := fiber.Map{"status": "success", "data": sekolah}
	resBytes, _ := json.Marshal(response)
	config.RDB.Set(config.Ctx, "sekolah_info", resBytes, 24*time.Hour)

	return c.JSON(response)
}

func UpdateSekolah(c *fiber.Ctx) error {
	var body models.Sekolah
	if err := c.BodyParser(&body); err != nil {
		return c.Status(400).JSON(fiber.Map{"status": "failed", "message": "Request tidak valid"})
	}

	var sekolah models.Sekolah
	config.DB.WithContext(c.Context()).First(&sekolah)

	if sekolah.ID == uuid.Nil {
		if err := config.DB.WithContext(c.Context()).Create(&body).Error; err != nil {
			return c.Status(500).JSON(fiber.Map{"status": "error", "message": "Gagal membuat profil sekolah"})
		}
	} else {
		if err := config.DB.WithContext(c.Context()).Model(&sekolah).Updates(body).Error; err != nil {
			return c.Status(500).JSON(fiber.Map{"status": "error", "message": "Gagal update profil sekolah"})
		}
	}

	go invalidateSekolahCache()

	return c.JSON(fiber.Map{"status": "success", "message": "Info sekolah berhasil diperbarui"})
}

// ==========================================
// EXTERNAL SERVICES (Cek Kepemilikan)
// ==========================================

func ConnectService(c *fiber.Ctx) error {
	idSekolah, err := getSchoolID(c)
	if err != nil {
		return c.Status(401).JSON(fiber.Map{"status": "failed", "message": "Unauthorized"})
	}

	var req ConnectServiceRequest
	if err := c.BodyParser(&req); err != nil {
		return c.Status(400).JSON(fiber.Map{"status": "failed", "message": "Request tidak valid"})
	}

	var setting models.Setting
	config.DB.WithContext(c.Context()).Where("id_sekolah = ? AND service = ?", idSekolah, req.Service).First(&setting)

	setting.IDSekolah = uuid.MustParse(idSekolah)
	setting.Service = req.Service
	setting.ApiKey = &req.ApiKey
	setting.ConnectedAt = time.Now()

	if err := config.DB.WithContext(c.Context()).Save(&setting).Error; err != nil {
		return c.Status(500).JSON(fiber.Map{"status": "error", "message": "Gagal menghubungkan servis"})
	}

	go invalidateSettingsCache(idSekolah)

	return c.JSON(fiber.Map{"status": "success", "message": "Service connected successfully"})
}

func DisconnectService(c *fiber.Ctx) error {
	idSekolah, err := getSchoolID(c)
	if err != nil {
		return c.Status(401).JSON(fiber.Map{"status": "failed", "message": "Unauthorized"})
	}

	var req DisconnectServiceRequest
	if err := c.BodyParser(&req); err != nil {
		return c.Status(400).JSON(fiber.Map{"status": "failed", "message": "Request tidak valid"})
	}

	config.DB.WithContext(c.Context()).Where("id_sekolah = ? AND service = ?", idSekolah, req.Service).Delete(&models.Setting{})
	go invalidateSettingsCache(idSekolah)

	return c.JSON(fiber.Map{"status": "success", "message": "Service disconnected successfully"})
}

// ==========================================
// HELPERS
// ==========================================
func invalidateSettingsCache(idSekolah string) {
	config.RDB.Del(config.Ctx, "settings:sekolah:"+idSekolah)
}

func invalidateHariCache(bulan, tahun int, idSekolah string) {
	config.RDB.Del(config.Ctx, fmt.Sprintf("hari:m:%d:y:%d:sch:%s", bulan, tahun, idSekolah))
}

func invalidateSekolahCache() {
	config.RDB.Del(config.Ctx, "sekolah_info")
}
