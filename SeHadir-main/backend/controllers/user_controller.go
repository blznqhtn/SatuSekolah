package controllers

import (
	"context"
	"e-presence-backend/config"
	"e-presence-backend/models"
	"errors"
	"fmt"
	"math"
	"os"
	"regexp"
	"strconv"
	"time"

	"github.com/gofiber/fiber/v2"
	"github.com/google/uuid"
	"golang.org/x/crypto/bcrypt"
	"gorm.io/gorm"
	"gorm.io/gorm/clause"
)

// ==========================================
// DATA TRANSFER OBJECTS (DTOs) & STRUCTS
// ==========================================

type CreateUserRequest struct {
	IDSchoolMember string `json:"id_school_member"`
	Username       string `json:"username"`
	Email          string `json:"email"`
	Password       string `json:"password"`
	Role           string `json:"role"`
}

type LinkedCardRequest struct {
	IDCard string `json:"id_card"`
}

type RFIDStatusRequest struct {
	RfidID        string `json:"rfid_id"`
	CurrentUserID string `json:"current_user_id"`
}

type RFIDConnectRequest struct {
	Uid    string `json:"uid"`
	UserID string `json:"user_id"`
}

type CreateAdminRequest struct {
	IDSchoolMember string `json:"id_school_member"`
	Username       string `json:"username"`
	Email          string `json:"email"`
	Password       string `json:"password"`
}

type UpdateAdminRequest struct {
	Username string `json:"username"`
	Email    string `json:"email"`
}

type AggregateResult struct {
	Bulan             int   `gorm:"column:bulan"`
	TotalProduktif    int   `gorm:"column:total_produktif"`
	TotalNonProduktif int   `gorm:"column:total_non_produktif"`
	TotalHadir        int64 `gorm:"column:total_hadir"`
	TotalAlpa         int64 `gorm:"column:total_alpa"`
	TotalIzin         int64 `gorm:"column:total_izin"`
	AbsenHariIni      int64 `gorm:"column:absen_hari_ini"`
}

func getCurrentUserID(c *fiber.Ctx) (uuid.UUID, error) {
	uidStr, ok := c.Locals("uid").(string)
	if !ok {
		return uuid.Nil, fiber.ErrUnauthorized
	}
	return uuid.Parse(uidStr)
}

func GetUsers(c *fiber.Ctx) error {
	schoolID, errAuth := getSchoolID(c)
	if errAuth != nil {
		return c.Status(fiber.StatusUnauthorized).JSON(fiber.Map{"status": "failed", "message": "Sesi tidak valid"})
	}

	search := c.Query("search", "")

	id_kelas := c.Query("kelas_id", c.Query("id_kelas", ""))

	page, _ := strconv.Atoi(c.Query("page", "1"))
	limit, _ := strconv.Atoi(c.Query("limit", "20"))
	offset := (page - 1) * limit

	var users []models.User
	var totalData int64

	db := config.DB.WithContext(c.Context()).Model(&models.User{}).
		Joins("JOIN school_members ON school_members.id = users.id_school_member").
		Joins("LEFT JOIN kelas ON kelas.id = school_members.id_kelas").
		Where("school_members.id_sekolah = ?", schoolID)

	if id_kelas != "" && id_kelas != "all" {
		db = db.Where("school_members.id_kelas = ?", id_kelas)
	}

	if search != "" {
		searchTerm := "%" + search + "%"
		db = db.Where(
			"(school_members.no_induk ILIKE ? OR users.username ILIKE ? OR users.email ILIKE ? OR users.role ILIKE ? OR school_members.name ILIKE ? OR kelas.name ILIKE ?)",
			searchTerm, searchTerm, searchTerm, searchTerm, searchTerm, searchTerm,
		)
	}

	db.Count(&totalData)

	db = db.Order("school_members.no_induk ASC").Order("users.role ASC")

	if err := db.Preload("SchoolMember").Preload("SchoolMember.Kelas").Limit(limit).Offset(offset).Find(&users).Error; err != nil {
		return c.Status(500).JSON(fiber.Map{"status": "failed", "message": "Gagal mengambil data"})
	}

	return c.JSON(fiber.Map{
		"status": "success",
		"data":   sanitizeUsers(users),
		"meta": fiber.Map{
			"current_page": page,
			"per_page":     limit,
			"total_data":   totalData,
			"total_pages":  int(math.Ceil(float64(totalData) / float64(limit))),
		},
	})
}

func GetUserById(c *fiber.Ctx) error {
	id, err := uuid.Parse(c.Params("id"))
	if err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{
			"status":  "failed",
			"message": "Format ID tidak valid",
		})
	}

	schoolID, errAuth := getSchoolID(c)
	if errAuth != nil {
		return c.Status(fiber.StatusUnauthorized).JSON(fiber.Map{
			"status":  "failed",
			"message": "Sesi tidak valid",
		})
	}

	var user models.User

	db := config.DB.WithContext(c.Context()).
		Joins("JOIN school_members ON school_members.id = users.id_school_member").
		Where("school_members.id_sekolah = ?", schoolID).
		Where("users.id = ?", id).
		Preload("SchoolMember").
		Preload("SchoolMember.Kelas").
		Preload("SchoolMember.Sekolah")

	// Optional debug
	// db = db.Debug()

	if err := db.First(&user).Error; err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return c.Status(fiber.StatusNotFound).JSON(fiber.Map{
				"status":  "failed",
				"message": "User tidak ditemukan",
			})
		}

		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
			"status":  "failed",
			"message": "Terjadi kesalahan server",
		})
	}

	return c.JSON(fiber.Map{
		"status": "success",
		"data":   sanitizeUser(user),
	})
}

func CreateUser(c *fiber.Ctx) error {
	var req CreateUserRequest
	if err := c.BodyParser(&req); err != nil {
		return c.Status(400).JSON(fiber.Map{"status": "failed", "message": "Invalid request"})
	}

	if req.IDSchoolMember == "" || req.Username == "" || req.Password == "" {
		return c.Status(422).JSON(fiber.Map{"status": "failed", "message": "Field wajib tidak boleh kosong"})
	}

	if len(req.Password) < 8 {
		return c.Status(422).JSON(fiber.Map{"status": "failed", "message": "Password minimal 8 karakter"})
	}

	emailRegex := regexp.MustCompile(`^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$`)
	if req.Email != "" && !emailRegex.MatchString(req.Email) {
		return c.Status(422).JSON(fiber.Map{"status": "failed", "message": "Format email tidak valid"})
	}

	idSchoolMember, err := uuid.Parse(req.IDSchoolMember)
	if err != nil {
		return c.Status(400).JSON(fiber.Map{"status": "failed", "message": "Format ID tidak valid"})
	}

	tx := config.DB.WithContext(c.Context()).Begin()

	var member models.SchoolMember
	if err := tx.Select("id").First(&member, idSchoolMember).Error; err != nil {
		tx.Rollback()
		return c.Status(404).JSON(fiber.Map{"status": "failed", "message": "Member tidak ditemukan"})
	}

	role := "user"
	if req.Role == "admin" || req.Role == "superadmin" {
		role = req.Role
	}

	hashed, err := bcrypt.GenerateFromPassword([]byte(req.Password), 12)
	if err != nil {
		tx.Rollback()
		return c.Status(500).JSON(fiber.Map{"status": "failed", "message": "Gagal hashing password"})
	}

	user := models.User{
		IDSchoolMember: idSchoolMember,
		Username:       req.Username,
		Password:       string(hashed),
		Email:          &req.Email,
		Role:           role,
	}

	if req.Email != "" {
		user.Email = &req.Email
	}

	if err := tx.Create(&user).Error; err != nil {
		tx.Rollback()
		return c.Status(400).JSON(fiber.Map{"status": "failed", "message": "Username/email sudah digunakan"})
	}

	if err := tx.Commit().Error; err != nil {
		tx.Rollback()
		return c.Status(500).JSON(fiber.Map{"status": "failed", "message": "Gagal commit data"})
	}

	return c.JSON(fiber.Map{
		"status":  "success",
		"message": "User berhasil dibuat",
		"data":    sanitizeUser(user),
	})
}

func UpdateUser(c *fiber.Ctx) error {
	id, err := uuid.Parse(c.Params("id"))
	if err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{
			"status":  "failed",
			"message": "Format ID tidak valid",
		})
	}

	type UpdateUserRequest struct {
		Username string `json:"username"`
		Email    string `json:"email"`
		Nomor    string `json:"nomor"`
		RfidID   string `json:"rfid_id"`
	}

	var req UpdateUserRequest
	if err := c.BodyParser(&req); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{
			"status":  "failed",
			"message": "Invalid request body",
		})
	}

	if req.Username == "" && req.Email == "" {
		return c.Status(fiber.StatusUnprocessableEntity).JSON(fiber.Map{
			"status":  "failed",
			"message": "Minimal satu field (username atau email) harus diisi",
		})
	}

	emailRegex := regexp.MustCompile(`^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$`)
	if req.Email != "" && !emailRegex.MatchString(req.Email) {
		return c.Status(fiber.StatusUnprocessableEntity).JSON(fiber.Map{
			"status":  "failed",
			"message": "Format email tidak valid",
		})
	}

	tx := config.DB.WithContext(c.Context()).Begin()
	defer tx.Rollback()

	var user models.User
	if err := tx.First(&user, id).Error; err != nil {
		return c.Status(fiber.StatusNotFound).JSON(fiber.Map{
			"status":  "failed",
			"message": "User tidak ditemukan",
		})
	}

	currentEmail := ""
	if user.Email != nil {
		currentEmail = *user.Email
	}

	if req.Email != "" && req.Email != currentEmail {
		var existingEmail models.User
		if err := tx.Where("email = ? AND id != ?", req.Email, user.ID).First(&existingEmail).Error; err == nil {
			return c.Status(fiber.StatusConflict).JSON(fiber.Map{
				"status":  "failed",
				"message": "Email sudah terdaftar pada akun lain",
			})
		}
	}

	if req.Username != "" && req.Username != user.Username {
		var existingUsername models.User
		if err := tx.Where("username = ? AND id != ?", req.Username, user.ID).First(&existingUsername).Error; err == nil {
			return c.Status(fiber.StatusConflict).JSON(fiber.Map{
				"status":  "failed",
				"message": "Username sudah dipakai oleh akun lain",
			})
		}
	}

	if req.RfidID != "" {
        var existingRfid models.User
        if err := tx.Where("rfid_id = ? AND id != ?", req.RfidID, user.ID).First(&existingRfid).Error; err == nil {
            return c.Status(fiber.StatusConflict).JSON(fiber.Map{
                "status":  "failed",
                "message": "RFID sudah dipakai oleh akun lain",
            })
        }
    }

	userUpdates := map[string]interface{}{
		"username": req.Username,
	}

	if req.Email != "" {
		userUpdates["email"] = req.Email
	} else {
		userUpdates["email"] = nil
	}

	if req.RfidID != "" {
        userUpdates["rfid_id"] = req.RfidID
    }

	if err := tx.Model(&user).Updates(userUpdates).Error; err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
			"status":  "failed",
			"message": "Gagal memperbarui data akun",
		})
	}

	if err := tx.Model(&models.SchoolMember{}).Where("id = ?", user.IDSchoolMember).Update("nomor", req.Nomor).Error; err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
			"status":  "failed",
			"message": "Gagal memperbarui data kontak",
		})
	}

	if err := tx.Commit().Error; err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
			"status":  "failed",
			"message": "Gagal menyimpan perubahan ke database",
		})
	}

	go invalidateUserDashboardCache(id.String())

	return c.JSON(fiber.Map{
		"status":  "success",
		"message": "Akun berhasil diperbarui",
	})
}

func DeleteUser(c *fiber.Ctx) error {
	idStr := c.Params("id")
	id, err := uuid.Parse(idStr)
	if err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"status": "failed", "message": "Format ID tidak valid"})
	}

	var user models.User
	if err := config.DB.WithContext(c.Context()).First(&user, id).Error; err != nil {
		return c.Status(fiber.StatusNotFound).JSON(fiber.Map{"status": "failed", "message": "User tidak ditemukan"})
	}

	config.DB.WithContext(c.Context()).Delete(&user)

	go invalidateUserDashboardCache(id.String())

	return c.JSON(fiber.Map{"status": "success", "message": "User berhasil dihapus"})
}

func DeleteMultipleUsers(c *fiber.Ctx) error {
	schoolID, errAuth := getSchoolID(c)
	if errAuth != nil {
		return c.Status(fiber.StatusUnauthorized).JSON(fiber.Map{
			"status":  "failed",
			"message": "Sesi tidak valid",
		})
	}

	var req struct {
		IDs []string `json:"ids"`
	}
	if err := c.BodyParser(&req); err != nil || len(req.IDs) == 0 {
		return c.Status(400).JSON(fiber.Map{"status": "failed", "message": "Format request tidak valid atau ID kosong"})
	}

	tx := config.DB.WithContext(c.Context()).Begin()
	defer tx.Rollback()

	var users []models.User
	if err := tx.Joins("JOIN school_members ON school_members.id = users.id_school_member").
		Where("school_members.id_sekolah = ? AND users.id IN ?", schoolID, req.IDs).
		Find(&users).Error; err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
			"status":  "failed",
			"message": "Gagal mencari dan memverifikasi data user",
		})
	}

	if len(users) == 0 {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{
			"status":  "failed",
			"message": "Tidak ada user valid yang ditemukan untuk dihapus",
		})
	}

	if err := tx.Delete(&users).Error; err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
			"status":  "failed",
			"message": "Gagal menghapus data users",
		})
	}

	tx.Commit()

	for _, user := range users {
		go invalidateUserDashboardCache(user.ID.String())
	}

	return c.JSON(fiber.Map{
		"status":  "success",
		"message": fmt.Sprintf("%d data akun user berhasil dihapus", len(users)),
	})
}

func ToggleBanUser(c *fiber.Ctx) error {
	id, err := uuid.Parse(c.Params("id"))
	if err != nil {
		return c.Status(400).JSON(fiber.Map{"status": "failed", "message": "Format ID tidak valid"})
	}

	var user models.User
	if err := config.DB.WithContext(c.Context()).First(&user, id).Error; err != nil {
		return c.Status(404).JSON(fiber.Map{"status": "failed", "message": "User tidak ditemukan"})
	}

	newStatus := "active"
	if user.StatusBan == "active" {
		newStatus = "inactive"
	}

	config.DB.WithContext(c.Context()).Model(&user).Update("status_ban", newStatus)

	go invalidateUserDashboardCache(id.String())

	return c.JSON(fiber.Map{
		"status":  "success",
		"message": "Status user diperbarui",
	})
}

func LinkedCard(c *fiber.Ctx) error {
	id, err := uuid.Parse(c.Params("id"))
	if err != nil {
		return c.Status(400).JSON(fiber.Map{"status": "failed", "message": "Format ID tidak valid"})
	}

	var req LinkedCardRequest
	if err := c.BodyParser(&req); err != nil {
		return c.Status(400).JSON(fiber.Map{"status": "failed", "message": "Invalid request"})
	}

	if req.IDCard == "" {
		return c.Status(422).JSON(fiber.Map{"status": "failed", "message": "ID kartu kosong"})
	}

	tx := config.DB.WithContext(c.Context()).Begin()

	var user models.User
	if err := tx.Clauses(clause.Locking{Strength: "UPDATE"}).First(&user, id).Error; err != nil {
		tx.Rollback()
		return c.Status(404).JSON(fiber.Map{"status": "failed", "message": "User tidak ditemukan"})
	}

	if user.RfidID != nil {
		tx.Rollback()
		return c.Status(400).JSON(fiber.Map{"status": "failed", "message": "RFID sudah terhubung"})
	}

	if err := tx.Model(&user).Update("rfid_id", req.IDCard).Error; err != nil {
		tx.Rollback()
		return c.Status(400).JSON(fiber.Map{"status": "failed", "message": "RFID sudah digunakan"})
	}

	if err := tx.Commit().Error; err != nil {
		tx.Rollback()
		return c.Status(500).JSON(fiber.Map{"status": "failed", "message": "Gagal commit"})
	}

	go invalidateUserDashboardCache(id.String())

	return c.JSON(fiber.Map{
		"status":  "success",
		"message": "RFID berhasil dihubungkan",
	})
}

func CheckStatusCard(c *fiber.Ctx) error {
	id := c.Params("id")
	var user models.User
	if err := config.DB.WithContext(c.Context()).Where("rfid_id = ?", id).First(&user).Error; err != nil {
		return c.JSON(fiber.Map{"success": false, "message": "RFID belum terdaftar!"})
	}
	return c.JSON(fiber.Map{"success": true, "message": "RFID telah terdaftar!"})
}

func CheckRfidStatus(c *fiber.Ctx) error {
	var req RFIDStatusRequest
	if err := c.BodyParser(&req); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"success": false, "message": "Invalid request"})
	}

	if req.RfidID == "" || req.CurrentUserID == "" {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"success": false, "message": "rfid_id dan current_user_id diperlukan"})
	}

	currentUserID, errParse := uuid.Parse(req.CurrentUserID)
	if errParse != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"success": false, "message": "Format ID User tidak valid"})
	}

	var existingUser models.User
	if err := config.DB.WithContext(c.Context()).Preload("SchoolMember").Preload("SchoolMember.Kelas").Where("rfid_id = ? AND id != ?", req.RfidID, currentUserID).First(&existingUser).Error; err == nil {

		name := "Unknown"
		kelasName := "Unknown"

		if existingUser.SchoolMember != nil {
			name = existingUser.SchoolMember.Name

			if existingUser.SchoolMember.Kelas.ID != uuid.Nil {
				kelasName = existingUser.SchoolMember.Kelas.Name
			}
		}

		return c.JSON(fiber.Map{
			"success": false,
			"message": "RFID ini sudah digunakan oleh akun lain",
			"user": fiber.Map{
				"name":  name,
				"kelas": kelasName,
			},
		})
	}

	return c.JSON(fiber.Map{"success": true, "message": "RFID tersedia untuk digunakan"})
}

func RfidConnect(c *fiber.Ctx) error {
	var req RFIDConnectRequest
	if err := c.BodyParser(&req); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"success": false, "message": "Invalid request"})
	}

	if req.Uid == "" {
		return c.JSON(fiber.Map{"success": false, "message": "RFID tidak boleh kosong"})
	}

	userID, errParse := uuid.Parse(req.UserID)
	if errParse != nil {
		return c.JSON(fiber.Map{"success": false, "message": "Format User ID tidak valid"})
	}

	var user models.User
	if err := config.DB.WithContext(c.Context()).Where("id = ?", userID).First(&user).Error; err != nil {
		return c.JSON(fiber.Map{"success": false, "message": "Akun tidak ditemukan"})
	}

	user.RfidID = &req.Uid
	config.DB.WithContext(c.Context()).Save(&user)

	go invalidateUserDashboardCache(userID.String())

	return c.JSON(fiber.Map{"success": true, "message": "RFID berhasil terdaftar!"})
}

func RemoveRfid(c *fiber.Ctx) error {
	idStr := c.Params("id")
	id, err := uuid.Parse(idStr)
	if err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"status": "failed", "message": "Format ID tidak valid"})
	}

	var user models.User
	if err := config.DB.WithContext(c.Context()).Where("id = ?", id).First(&user).Error; err != nil {
		return c.Status(fiber.StatusNotFound).JSON(fiber.Map{"status": "failed", "message": "Akun tidak ditemukan"})
	}

	config.DB.WithContext(c.Context()).Model(&user).Update("rfid_id", nil)

	go invalidateUserDashboardCache(id.String())

	return c.JSON(fiber.Map{"status": true, "message": "RFID berhasil dihapus"})
}

func GetSchoolMembersNoRfid(c *fiber.Ctx) error {
	schoolID, errAuth := getSchoolID(c)
	if errAuth != nil {
		return c.Status(fiber.StatusUnauthorized).JSON(fiber.Map{
			"status":  "failed",
			"message": "Sesi tidak valid",
		})
	}

	var users []models.User

	// Cari User yang ada di sekolah ini dan belum punya RFID
	err := config.DB.WithContext(c.Context()).
		Joins("JOIN school_members ON school_members.id = users.id_school_member").
		Preload("SchoolMember").
		Preload("SchoolMember.Kelas").
		Where("school_members.id_sekolah = ?", schoolID).
		Where("users.rfid_id IS NULL OR users.rfid_id = ''").
		Find(&users).Error

	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
			"status":  "failed",
			"message": "Gagal mengambil data",
		})
	}

	return c.JSON(fiber.Map{
		"status": "success",
		"data":   sanitizeUsers(users),
	})
}

func BanAccount(c *fiber.Ctx) error {
	idStr := c.Params("id")
	id, err := uuid.Parse(idStr)
	if err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"status": "failed", "message": "Format ID tidak valid"})
	}

	config.DB.WithContext(c.Context()).Model(&models.User{}).Where("id = ?", id).Update("status_ban", "inactive")
	go invalidateUserDashboardCache(id.String())

	return c.JSON(fiber.Map{"status": "success", "message": "Akun berhasil di-banned", "id": id})
}

func UnbanAccount(c *fiber.Ctx) error {
	idStr := c.Params("id")
	id, err := uuid.Parse(idStr)
	if err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"status": "failed", "message": "Format ID tidak valid"})
	}

	config.DB.WithContext(c.Context()).Model(&models.User{}).Where("id = ?", id).Update("status_ban", "active")
	go invalidateUserDashboardCache(id.String())

	return c.JSON(fiber.Map{"status": "success", "message": "Akun berhasil di-unban", "id": id})
}

func GetAdminAccounts(c *fiber.Ctx) error {
	currentUserID, err := getCurrentUserID(c)
	if err != nil {
		return c.Status(401).JSON(fiber.Map{"status": "failed", "message": "Unauthorized"})
	}

	var sekolahID uuid.UUID
	if err := config.DB.WithContext(c.Context()).
		Table("users").
		Select("school_members.id_sekolah").
		Joins("JOIN school_members ON school_members.id = users.id_school_member").
		Where("users.id = ?", currentUserID).
		Scan(&sekolahID).Error; err != nil {

		return c.Status(500).JSON(fiber.Map{"status": "failed", "message": "Gagal mengambil data sekolah"})
	}

	var admins []models.User
	if err := config.DB.WithContext(c.Context()).
		Preload("SchoolMember").
		Joins("JOIN school_members ON school_members.id = users.id_school_member").
		Where("users.role = ? AND school_members.id_sekolah = ?", "admin", sekolahID).
		Find(&admins).Error; err != nil {

		return c.Status(500).JSON(fiber.Map{"status": "failed", "message": "Gagal mengambil data admin"})
	}

	return c.JSON(fiber.Map{"status": "success", "data": sanitizeUsers(admins)})
}

func CreateAdmin(c *fiber.Ctx) error {
	var req CreateAdminRequest
	if err := c.BodyParser(&req); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"status": "failed", "message": "Invalid request"})
	}

	if req.IDSchoolMember == "" || req.Username == "" || req.Password == "" {
		return c.Status(fiber.StatusUnprocessableEntity).JSON(fiber.Map{"status": "failed", "message": "Data lengkap diperlukan"})
	}

	if len(req.Password) < 8 {
		return c.Status(fiber.StatusUnprocessableEntity).JSON(fiber.Map{"status": "failed", "message": "Password minimal 8 karakter"})
	}

	emailRegex := regexp.MustCompile(`^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$`)
	if req.Email != "" && !emailRegex.MatchString(req.Email) {
		return c.Status(fiber.StatusUnprocessableEntity).JSON(fiber.Map{"status": "failed", "message": "Format email tidak valid"})
	}

	idSchoolMember, errParse := uuid.Parse(req.IDSchoolMember)
	if errParse != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"status": "failed", "message": "Format ID School Member tidak valid"})
	}

	hashed, _ := bcrypt.GenerateFromPassword([]byte(req.Password), 12)
	admin := models.User{
		IDSchoolMember: idSchoolMember,
		Username:       req.Username,
		Password:       string(hashed),
		Role:           "admin",
	}

	if req.Email != "" {
		admin.Email = &req.Email
	}

	if err := config.DB.WithContext(c.Context()).Create(&admin).Error; err != nil {
		return c.Status(400).JSON(fiber.Map{"status": "failed", "message": "Username atau email sudah digunakan"})
	}

	return c.JSON(fiber.Map{"status": "success", "message": "Admin berhasil ditambahkan", "data": sanitizeUser(admin)})
}

func DeleteAdmin(c *fiber.Ctx) error {
	idStr := c.Params("id")
	id, err := uuid.Parse(idStr)
	if err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"status": "failed", "message": "Format ID tidak valid"})
	}

	if err := config.DB.WithContext(c.Context()).Where("id = ? AND role = ?", id, "admin").Delete(&models.User{}).Error; err != nil {
		return c.Status(500).JSON(fiber.Map{"status": "failed", "message": "Gagal menghapus admin"})
	}

	return c.JSON(fiber.Map{"status": "success", "message": "Admin berhasil dihapus"})
}

func UpdateAdmin(c *fiber.Ctx) error {
	idStr := c.Params("id")
	id, err := uuid.Parse(idStr)
	if err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"status": "failed", "message": "Format ID tidak valid"})
	}

	var req UpdateAdminRequest
	if err := c.BodyParser(&req); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"status": "failed", "message": "Invalid request body"})
	}

	emailRegex := regexp.MustCompile(`^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$`)
	if req.Email != "" && !emailRegex.MatchString(req.Email) {
		return c.Status(fiber.StatusUnprocessableEntity).JSON(fiber.Map{"status": "failed", "message": "Format email tidak valid"})
	}

	var admin models.User
	if err := config.DB.WithContext(c.Context()).Where("id = ? AND role = ?", id, "admin").First(&admin).Error; err != nil {
		return c.Status(fiber.StatusNotFound).JSON(fiber.Map{"status": "failed", "message": "Admin tidak ditemukan"})
	}

	if req.Username != "" {
		admin.Username = req.Username
	}
	if req.Email != "" {
		admin.Email = &req.Email
	}

	if err := config.DB.WithContext(c.Context()).Save(&admin).Error; err != nil {
		return c.Status(400).JSON(fiber.Map{"status": "failed", "message": "Username atau email sudah digunakan"})
	}

	go invalidateUserDashboardCache(id.String())

	return c.JSON(fiber.Map{"status": "success", "message": "Admin berhasil diupdate", "data": sanitizeUser(admin)})
}

func GetMyAccount(c *fiber.Ctx) error {
	id, err := getCurrentUserID(c)
	if err != nil {
		return c.Status(401).JSON(fiber.Map{"status": "failed", "message": "Unauthorized"})
	}

	// Cache dimatikan sementara untuk memastikan data selalu terbaru (Real-time)
	/*
	cacheKey := fmt.Sprintf("dashboard_user:%s", id.String())
	cachedData, errRedis := config.RDB.Get(config.Ctx, cacheKey).Result()
	if errRedis == nil {
		c.Type("json")
		return c.SendString(cachedData)
	}
	*/

	var user models.User
	if err := config.DB.WithContext(c.Context()).
		Preload("SchoolMember").
		Preload("SchoolMember.Kelas").
		First(&user, id).Error; err != nil {
		return c.Status(404).JSON(fiber.Map{"status": "failed", "message": "User tidak ditemukan"})
	}

	// 1. Ambil Waktu Realtime (WIB)
	loc, _ := time.LoadLocation("Asia/Jakarta")
	now := time.Now().In(loc)

	// Cari data presensi terakhir untuk menentukan konteks waktu testing
	var latest struct {
		Year  int
		Month int
		Date  string
	}
	config.DB.Model(&models.Presence{}).
		Where("id_user = ?", user.ID).
		Select("EXTRACT(YEAR FROM MAX(time_masuk)) as year, EXTRACT(MONTH FROM MAX(time_masuk)) as month, CAST(MAX(time_masuk) AS DATE) as date").
		Group("id_user").
		Scan(&latest)

	displayYear := now.Year()
	displayMonth := int(now.Month())
	checkDate := now.Format("2006-01-02")

	// Jika ada data testing di masa depan, gunakan konteks itu agar statistik muncul dan tombol hilang
	if latest.Year > now.Year() || (latest.Year == now.Year() && latest.Month >= int(now.Month())) {
		displayYear = latest.Year
		displayMonth = latest.Month
		checkDate = latest.Date
	}

	// 2. Cek Status Absen Hari Ini (Sangat Penting untuk tombol Buat Surat)
	var statsAbsenHariIni int64
	config.DB.Model(&models.Presence{}).
		Where("id_user = ? AND CAST(time_masuk AS DATE) = ?", user.ID, checkDate).
		Count(&statsAbsenHariIni)

	// 3. Ambil Agregat Bulanan (Untuk Grafik & Statistik Box)
	var aggregates []AggregateResult
	config.DB.WithContext(c.Context()).Model(&models.Presence{}).
		Select(`
			EXTRACT(MONTH FROM time_masuk) as bulan,
			SUM(CASE WHEN status IN ('Hadir', 'Terlambat') AND status_hari = 'Hari Produktif' THEN 1 ELSE 0 END) as total_produktif,
			SUM(CASE WHEN status IN ('Hadir', 'Terlambat') AND status_hari = 'Hari Non-Produktif' THEN 1 ELSE 0 END) as total_non_produktif,
			SUM(CASE WHEN status NOT IN ('Izin', 'Sakit', 'Alpa') THEN 1 ELSE 0 END) as total_hadir,
			SUM(CASE WHEN status = 'Alpa' THEN 1 ELSE 0 END) as total_alpa,
			SUM(CASE WHEN status NOT IN ('Hadir', 'Terlambat', 'Alpa') THEN 1 ELSE 0 END) as total_izin
		`).
		Where("id_user = ?", user.ID).
		Where("EXTRACT(YEAR FROM time_masuk) = ?", displayYear).
		Group("EXTRACT(MONTH FROM time_masuk)").
		Scan(&aggregates)

	fullData := make([]fiber.Map, 12)
	fullNonData := make([]fiber.Map, 12)
	var statsTotalHadir, statsTotalAlpa, statsTotalIzin int64

	for i := 0; i < 12; i++ {
		fullData[i] = fiber.Map{"bulan": i + 1, "total": 0, "persentase": 0}
		fullNonData[i] = fiber.Map{"bulan": i + 1, "total": 0, "persentase": 0}
	}

	for _, agg := range aggregates {
		index := agg.Bulan - 1

		var hari models.Hari
		config.DB.Where("id_sekolah = ? AND bulan = ? AND tahun = ?", user.SchoolMember.IDSekolah, agg.Bulan, displayYear).First(&hari)

		totalHariKerja := len(hari.HariProduktif)
		if totalHariKerja == 0 { totalHariKerja = 20 }

		persentase := (float64(agg.TotalProduktif) / float64(totalHariKerja)) * 100
		if persentase > 100 { persentase = 100 }

		fullData[index]["total"] = agg.TotalProduktif
		fullData[index]["persentase"] = int(math.Round(persentase))
		fullNonData[index]["total"] = agg.TotalNonProduktif

		// Statistik Box mengikuti Konteks Bulan yang ditampilkan
		if agg.Bulan == displayMonth {
			statsTotalHadir = agg.TotalHadir
			statsTotalAlpa = agg.TotalAlpa
			statsTotalIzin = agg.TotalIzin
		}
	}

	name := "Unknown"
	noInduk := "Unknown"
	kelas := "Unknown"
	profileUrl := ""

	if user.SchoolMember != nil {
		name = user.SchoolMember.Name
		noInduk = user.SchoolMember.NoInduk
		if user.SchoolMember.Kelas.ID != uuid.Nil {
			kelas = user.SchoolMember.Kelas.Name
		}
		if user.SchoolMember.FotoProfile != nil {
			profileUrl = *user.SchoolMember.FotoProfile
		}
	}

	// Cek batas waktu (Alpha)
	batasJamStr := os.Getenv("BATAS_ABSEN_JAM")
	if batasJamStr == "" {
		batasJamStr = "9"
	}
	batasMenitStr := os.Getenv("BATAS_ABSEN_MENIT")
	if batasMenitStr == "" {
		batasMenitStr = "0"
	}

	batasJam, _ := strconv.Atoi(batasJamStr)
	batasMenit, _ := strconv.Atoi(batasMenitStr)

	batasWaktu := time.Date(now.Year(), now.Month(), now.Day(), batasJam, batasMenit, 0, 0, now.Location())

	// Tombol izin hanya muncul jika belum absen DAN belum lewat jam batas
	canCreateLeave := (statsAbsenHariIni == 0) && now.Before(batasWaktu)

	response := fiber.Map{
		"status":                           "success",
		"name":                             name,
		"no_induk":                         noInduk,
		"kelas":                            kelas,
		"absensi_per_bulan":                fullData,
		"absensi_per_bulan_non_productive": fullNonData,
		"total_hadir_bulan_ini":            statsTotalHadir,
		"total_alpa_bulan_ini":             statsTotalAlpa,
		"total_izin_bulan_ini":             statsTotalIzin,
		"absen_hari_ini_status":            statsAbsenHariIni > 0,
		"can_create_leave":                 canCreateLeave,
		"rfid_status":                      user.RfidID != nil && *user.RfidID != "",
		"profile":                          profileUrl,
	}

	/*
	responseBytes, errMarshal := json.Marshal(response)
	if errMarshal == nil {
		config.RDB.Set(config.Ctx, cacheKey, responseBytes, 24*time.Hour)
	}
	*/

	return c.JSON(response)
}

func GetKelas(c *fiber.Ctx) error {
	kelas := []models.Kelas{}

	idSekolah := c.Query("sekolah")
	fmt.Print(idSekolah)
	if idSekolah == "" {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{
			"status":  "failed",
			"message": "ID Sekolah tidak ditemukan",
		})
	}

	ctx, cancel := context.WithTimeout(c.UserContext(), 5*time.Second)
	defer cancel()

	result := config.DB.WithContext(ctx).
		Order("name ASC").
		Find(&kelas)

	if result.Error != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
			"status":  "failed",
			"message": "Gagal mengambil data kelas",
		})
	}

	// Berikan info jumlah data untuk memudahkan debug di Android
	return c.JSON(fiber.Map{
		"status": "success",
		"count":  result.RowsAffected,
		"data":   kelas,
	})
}

// ==============================
// HELPERS & SANITIZATION
// ==============================

func sanitizeUser(u models.User) fiber.Map {
	return fiber.Map{
		"id":               u.ID,
		"id_school_member": u.IDSchoolMember,
		"rfid_id":          u.RfidID,
		"username":         u.Username,
		"email":            u.Email,
		"status_ban":       u.StatusBan,
		"membership":       u.Membership,
		"role":             u.Role,
		"last_seen":        u.LastSeen,
		"school_member":    u.SchoolMember,
	}
}

func sanitizeUsers(users []models.User) []fiber.Map {
	result := make([]fiber.Map, 0, len(users))
	for _, u := range users {
		result = append(result, sanitizeUser(u))
	}
	return result
}

func invalidateUserDashboardCache(userID string) {
	cacheKey := fmt.Sprintf("dashboard_user:%s", userID)
	config.RDB.Del(config.Ctx, cacheKey)
}
