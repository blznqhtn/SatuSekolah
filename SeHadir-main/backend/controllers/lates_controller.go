package controllers

import (
	"e-presence-backend/config"
	"e-presence-backend/models"
	"encoding/json"
	"fmt"
	"slices"
	"strings"
	"time"

	"github.com/gofiber/fiber/v2"
	"gorm.io/gorm"
)

// Konstanta Key Redis agar konsisten di seluruh fungsi
const PresenceCacheKey = "presence:all:today"

type ResponseData struct {
	Total                      string                  `json:"total"`
	TotalHariIni               string                  `json:"total_hari_ini"`
	TotalAlpa                  string                  `json:"total_alpa"`
	TotalTidakHadir            string                  `json:"total_tidak_hadir"`
	DataPresensi               []models.Presence       `json:"data_presensi"`
	LeaveDocuments             []models.LeaveDocument  `json:"leave_documents"`
	Filter                     string                  `json:"filter"`
	Tab                        string                  `json:"tab"`
	HeadTab                    string                  `json:"head_tab"`
	DayType                    *string                 `json:"day_type"`
	TodayDayType               string                  `json:"today_day_type"`
	TotalMasukHariNonProduktif string                  `json:"total_masuk_non_produktif"`
	DateFrom                   time.Time               `json:"date_from"`
	DateTo                     time.Time               `json:"date_to"`
}

// --- FORM VIEWS ---

func ShowArrivalForm(c *fiber.Ctx) error {
	token := c.Query("token")
	var lateEntry models.LateEntry

	if err := config.DB.Where("token = ?", token).First(&lateEntry).Error; err != nil || lateEntry.Type != "Presensi Masuk" {
		return c.Status(404).JSON(fiber.Map{
			"status":  "error",
			"message": "Token tidak valid",
		})
	}

	var user models.User
	config.DB.Preload("SchoolMember").Where("id = ?", lateEntry.IDUser).First(&user)

	return c.JSON(fiber.Map{
		"status":     "success",
		"user":       user,
		"late_entry": lateEntry,
	})
}

func ShowDepartureForm(c *fiber.Ctx) error {
	token := c.Query("token")
	var lateEntry models.LateEntry

	if err := config.DB.Where("token = ?", token).First(&lateEntry).Error; err != nil || lateEntry.Type != "Presensi Keluar" {
		return c.Status(404).JSON(fiber.Map{"message": "Token tidak valid"})
	}

	var user models.User
	config.DB.Preload("SchoolMember").Where("id = ?", lateEntry.IDUser).First(&user)

	return c.JSON(fiber.Map{
		"user":       user,
		"late_entry": lateEntry,
	})
}

func ShowReasonForm(c *fiber.Ctx) error {
	token := c.Query("token")
	var lateEntry models.LateEntry

	if err := config.DB.Where("token = ?", token).First(&lateEntry).Error; err != nil {
		return c.Status(404).JSON(fiber.Map{"message": "Token tidak valid"})
	}

	var user models.User
	config.DB.Preload("SchoolMember").Where("id = ?", lateEntry.IDUser).First(&user)

	return c.JSON(fiber.Map{
		"user":         user,
		"reason_entry": lateEntry,
	})
}

func ShowEarlyDepartureForm(c *fiber.Ctx) error {
	token := c.Query("token")
	var entry models.LateEntry

	if err := config.DB.Where("token = ?", token).First(&entry).Error; err != nil {
		return c.Status(404).JSON(fiber.Map{"message": "Token tidak valid"})
	}

	var user models.User
	config.DB.Preload("SchoolMember").Where("id = ?", entry.IDUser).First(&user)

	return c.JSON(fiber.Map{
		"user":        user,
		"early_entry": entry,
	})
}

// --- STORE ACTIONS (With Cache Invalidation) ---

func StoreArrival(c *fiber.Ctx) error {
	type Request struct {
		Alasan string `json:"alasan"`
		Token  string `json:"token"`
	}
	req := new(Request)
	if err := c.BodyParser(req); err != nil {
		return c.Status(400).JSON(fiber.Map{"message": "Request tidak valid"})
	}

	tx := config.DB.Begin()
	defer tx.Rollback()

	var lateEntry models.LateEntry
	if err := tx.Where("token = ?", req.Token).First(&lateEntry).Error; err != nil {
		return c.Status(404).JSON(fiber.Map{"message": "Token kadaluwarsa"})
	}

	newPresence := models.Presence{
		IDUser:            lateEntry.IDUser,
		TimeMasuk:         lateEntry.Time,
		Status:            "Terlambat",
		StatusHari:        "Hari Produktif",
		AlasanDatangTelat: &req.Alasan,
	}

	if err := tx.Create(&newPresence).Error; err != nil {
		return c.Status(500).JSON(fiber.Map{"message": "Gagal simpan"})
	}

	tx.Delete(&lateEntry)
	tx.Commit()

	// Invalidate Cache agar Dashboard Realtime
	config.RDB.Del(config.Ctx, PresenceCacheKey)
	go finalizePresensiEffects(lateEntry.IDUser.String())

	return c.JSON(fiber.Map{"status": "success", "message": "Presensi terlambat disimpan"})
}

func StoreReason(c *fiber.Ctx) error {
	type Request struct {
		Alasan string `json:"alasan"`
		Token  string `json:"token"`
	}
	req := new(Request)
	c.BodyParser(req)

	tx := config.DB.Begin()
	defer tx.Rollback()

	var lateEntry models.LateEntry
	if err := tx.Where("token = ?", req.Token).First(&lateEntry).Error; err != nil {
		return c.Status(404).JSON(fiber.Map{"message": "Token tidak valid"})
	}

	newPresence := models.Presence{
		IDUser:       lateEntry.IDUser,
		TimeMasuk:    lateEntry.Time,
		Status:       "Hadir",
		StatusHari:   "Hari Non-Produktif",
		AlasanDatang: &req.Alasan,
	}

	tx.Create(&newPresence)
	tx.Delete(&lateEntry)
	tx.Commit()

	config.RDB.Del(config.Ctx, PresenceCacheKey)
	go finalizePresensiEffects(lateEntry.IDUser.String())

	return c.JSON(fiber.Map{"status": "success", "message": "Presensi berhasil"})
}

func StoreDeparture(c *fiber.Ctx) error {
	type Request struct {
		Alasan string `json:"alasan"`
		Token  string `json:"token"`
	}
	req := new(Request)
	c.BodyParser(req)

	tx := config.DB.Begin()
	defer tx.Rollback()

	var lateEntry models.LateEntry
	if err := tx.Where("token = ?", req.Token).First(&lateEntry).Error; err != nil {
		return c.Status(404).JSON(fiber.Map{"message": "Token tidak valid"})
	}

	entryStart, entryEnd := startOfDay(lateEntry.Time), endOfDay(lateEntry.Time)
	
	var presence models.Presence
	if err := tx.Where("id_user = ? AND time_masuk BETWEEN ? AND ?", lateEntry.IDUser, entryStart, entryEnd).First(&presence).Error; err != nil {
		return c.Status(404).JSON(fiber.Map{"message": "Belum absen masuk"})
	}

	statusKeluar := "Terlambat"
	tx.Model(&presence).Updates(models.Presence{
		AlasanPulangTelat: &req.Alasan,
		StatusKeluar:      &statusKeluar,
		TimeKeluar:        &lateEntry.Time,
	})

	tx.Delete(&lateEntry)
	tx.Commit()

	config.RDB.Del(config.Ctx, PresenceCacheKey)
	go finalizePresensiEffects(lateEntry.IDUser.String())

	return c.JSON(fiber.Map{"status": "success", "message": "Kepulangan terlambat disimpan"})
}

func StoreEarlyDeparture(c *fiber.Ctx) error {
	type Request struct {
		Alasan string `json:"alasan"`
		Token  string `json:"token"`
	}
	req := new(Request)
	c.BodyParser(req)

	tx := config.DB.Begin()
	defer tx.Rollback()

	var lateEntry models.LateEntry
	if err := tx.Where("token = ?", req.Token).First(&lateEntry).Error; err != nil {
		return c.Status(404).JSON(fiber.Map{"message": "Token tidak valid"})
	}

	entryStart, entryEnd := startOfDay(lateEntry.Time), endOfDay(lateEntry.Time)
	var presence models.Presence
	if err := tx.Where("id_user = ? AND time_masuk BETWEEN ? AND ?", lateEntry.IDUser, entryStart, entryEnd).First(&presence).Error; err != nil {
		return c.Status(404).JSON(fiber.Map{"message": "Belum absen masuk"})
	}

	statusKeluar := "Belum Waktunya"
	tx.Model(&presence).Updates(models.Presence{
		AlasanPulangDuluan: &req.Alasan,
		StatusKeluar:       &statusKeluar,
		TimeKeluar:         &lateEntry.Time,
	})

	tx.Delete(&lateEntry)
	tx.Commit()

	config.RDB.Del(config.Ctx, PresenceCacheKey)
	go finalizePresensiEffects(lateEntry.IDUser.String())

	return c.JSON(fiber.Map{"status": "success", "message": "Pulang awal disimpan"})
}

func AllPresensi(c *fiber.Ctx) error {
    idSekolah, err := getSchoolID(c)
    if err != nil || idSekolah == "" {
        return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{
            "status":  "failed",
            "message": "User tidak memiliki akses ke sekolah ini",
        })
    }

    loc, _ := time.LoadLocation("Asia/Jakarta")
    now := time.Now().In(loc)
    dateStr := now.Format("2006-01-02")
    
    // 1. Tambahkan tanggal hari ini ke dalam Cache Key
    cacheKey := fmt.Sprintf("presence:%s:%s", idSekolah, dateStr)

    cachedData, err := config.RDB.Get(config.Ctx, cacheKey).Result()
    if err == nil {
        c.Set("Content-Type", "application/json")
        return c.SendString(cachedData)
    }

    var presences []models.Presence
    start, end := startOfDay(now), startOfDay(now).Add(24*time.Hour)

    err = config.DB.Preload("User.SchoolMember.Kelas").
        Joins("JOIN users ON users.id = presences.id_user").
        Joins("JOIN school_members ON school_members.id = users.id_school_member").
        Where("presences.time_masuk >= ? AND presences.time_masuk < ?", start, end).
        Where("school_members.id_sekolah = ?", idSekolah).
        Order("presences.time_masuk DESC").
        Find(&presences).Error

    if err != nil {
        return c.Status(500).JSON(fiber.Map{"error": "Database error"})
    }

    type Item struct {
        ID           int    `json:"id"`
        NoInduk      string `json:"no"`
        WaktuMasuk   string `json:"waktu_masuk"`
        WaktuKeluar  string `json:"waktu_keluar"`
        StatusMasuk  string `json:"status_masuk"`
        StatusKeluar string `json:"status_keluar"`
        AlasanDatang string `json:"alasan_datang"`
        AlasanPulang string `json:"alasan_pulang"`
        NamaLengkap  string `json:"nama_lengkap"`
        Kelas        string `json:"kelas"`
    }

    count := len(presences)
    result := make([]Item, count)
    tidakHadir := 0

    for i := 0; i < count; i++ {
        p := presences[i]
        if p.Status == "Izin" || p.Status == "Sakit" {
            tidakHadir++
        }

        alasanDatang := "-"
        if p.AlasanDatangTelat != nil {
            alasanDatang = *p.AlasanDatangTelat
        } else if p.AlasanDatang != nil {
            alasanDatang = *p.AlasanDatang
        }

        alasanPulang := "-"
        if p.AlasanPulangTelat != nil {
            alasanPulang = *p.AlasanPulangTelat
        } else if p.AlasanPulangDuluan != nil {
            alasanPulang = *p.AlasanPulangDuluan
        }

        waktuKeluar := "-"
        if p.TimeKeluar != nil {
            waktuKeluar = p.TimeKeluar.Format("2006-01-02 15:04:05")
        }

        statusKeluar := "-"
        if p.StatusKeluar != nil && *p.StatusKeluar != "" {
            statusKeluar = *p.StatusKeluar
        }

        nama, kelas, noInduk := "-", "-", "-"
        if p.User != nil && p.User.SchoolMember != nil {
            nama = p.User.SchoolMember.Name
            noInduk = p.User.SchoolMember.NoInduk

            if p.User.SchoolMember.Kelas.Name != "" {
                kelas = p.User.SchoolMember.Kelas.Name
            }
        }

        result[i] = Item{
            ID: i + 1, NoInduk: noInduk, NamaLengkap: nama, Kelas: kelas,
            WaktuMasuk: p.TimeMasuk.Format("2006-01-02 15:04:05"), WaktuKeluar: waktuKeluar,
            StatusMasuk: p.Status, StatusKeluar: statusKeluar, AlasanDatang: alasanDatang, AlasanPulang: alasanPulang,
        }
    }

    responseBody := fiber.Map{
        "data": result, "count": count, "total_tidak_hadir": tidakHadir,
    }

    jsonData, _ := json.Marshal(responseBody)
    
    config.RDB.Set(config.Ctx, cacheKey, jsonData, 1 * time.Minute)

    return c.JSON(responseBody)
}

func StudentPresenceByClass(c *fiber.Ctx) error {
	updateLastSeen(c)
	filter := c.Query("filter", "Hari ini")
	tab := c.Query("tab", "all")
	kelas := c.Query("kelas")
	idSekolah := c.Query("sekolah")
	if idSekolah == "" {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{
			"status":  "failed",
			"message": "User tidak memiliki akses ke sekolah",
		})
	}

	dateFrom, dateTo := getDataRange(filter, c)

	baseConditions := func(db *gorm.DB) *gorm.DB {
		q := db.Joins("JOIN users ON users.id = presences.id_user").
			Joins("JOIN school_members ON school_members.id = users.id_school_member").
			Joins("JOIN kelas ON kelas.id = school_members.id_kelas").
			Where("presences.time_masuk BETWEEN ? AND ?", dateFrom, dateTo).
			Where("school_members.id_sekolah = ?", idSekolah)

		if kelas != "" {
			q = q.Where("kelas.id = ?", kelas)
		}
		return q
	}

	var stats struct {
		TotalHadir, TotalTidakHadir, TotalAlpa, TotalNonProduktif int
	}

	config.DB.Model(&models.Presence{}).Scopes(baseConditions).
		Select(`
			SUM(CASE WHEN presences.status IN ('Hadir', 'Terlambat') THEN 1 ELSE 0 END) as total_hadir,
			SUM(CASE WHEN presences.status IN ('Izin', 'Sakit') THEN 1 ELSE 0 END) as total_tidak_hadir,
			SUM(CASE WHEN presences.status = 'Alpa' THEN 1 ELSE 0 END) as total_alpa,
			SUM(CASE WHEN presences.status_hari = 'Hari Non-Produktif' THEN 1 ELSE 0 END) as total_non_produktif
		`).Scan(&stats)

	var presences []models.Presence
	tableQuery := config.DB.Model(&models.Presence{}).Scopes(baseConditions).Preload("User.SchoolMember").Preload("User.SchoolMember.Kelas")
	applyStatusFilter(tableQuery, tab)

	page, _ := c.ParamsInt("page", 1)
	tableQuery.Offset((page - 1) * 10).Limit(10).Find(&presences)

	var leaveDocuments []models.LeaveDocument
	leaveQuery := config.DB.Model(&models.LeaveDocument{}).
		Joins("JOIN users ON users.id = leave_documents.id_user").
		Joins("JOIN school_members ON school_members.id = users.id_school_member").
		Where("school_members.id_sekolah = ?", idSekolah).
		Where("leave_documents.start_date <= ? AND leave_documents.end_date >= ?", dateTo, dateFrom).
		Preload("User.SchoolMember")

	if kelas != "" {
		leaveQuery = leaveQuery.Joins("JOIN kelas ON kelas.id = school_members.id_kelas").
			Where("kelas.id = ?", kelas)
	}
	leaveQuery.Find(&leaveDocuments)

	totalUser := countTotalUser(kelas, idSekolah)
	loc, _ := time.LoadLocation("Asia/Jakarta")
	today := time.Now().In(loc)
	currentDayType := determineDayType(today, idSekolah)
	filteredDayType := determineDayType(dateFrom, idSekolah)

	return c.JSON(fiber.Map{
		"status": "success",
		"data": ResponseData{
			Total:           fmt.Sprintf("%d", totalUser),
			TotalHariIni:    fmt.Sprintf("%d", stats.TotalHadir),
			TotalAlpa:       fmt.Sprintf("%d", stats.TotalAlpa),
			TotalTidakHadir: fmt.Sprintf("%d", stats.TotalTidakHadir),
			DataPresensi:    presences,
			LeaveDocuments:  leaveDocuments,
			Filter:          filter,
			Tab:             tab,
			DayType:         &filteredDayType,
			TodayDayType:    currentDayType,
			DateFrom:        dateFrom,
			DateTo:          dateTo,
		},
	})
}

// --- HELPERS ---

func updateLastSeen(c *fiber.Ctx) {
	if admin := c.Locals("admin"); admin != nil {
		adminUser := admin.(models.User)
		config.DB.Model(&adminUser).Update("last_seen", time.Now())
	}
}

func determineDayType(t time.Time, idSekolah string) string {
    var hari models.Hari
    
    // Gunakan Limit(1).Find() untuk menghindari error log 'record not found'
    res := config.DB.Where("id_sekolah = ? AND bulan = ? AND tahun = ?", idSekolah, int(t.Month()), t.Year()).Limit(1).Find(&hari)

    if res.Error != nil || res.RowsAffected == 0 {
        return "Hari Produktif" // Default jika kalender belum diatur
    }

    // 1. Amankan Zona Waktu (Pastikan t menggunakan waktu lokal Indonesia)
    loc, err := time.LoadLocation("Asia/Jakarta")
    if err == nil {
        t = t.In(loc)
    }
    
    ds := fmt.Sprintf("%d", t.Day())

	fmt.Printf("\n[DEBUG] Tgl: %s | ID Sekolah: %s | DB Produktif: %v | DB Libur: %v\n", ds, idSekolah, hari.HariProduktif, hari.HariLibur)

    // 2. Balik Prioritas: Cek Hari Produktif LEBIH DULU
    // Jika admin sengaja menset tanggal ini sebagai produktif, status ini harus menang
    if slices.Contains(hari.HariProduktif, ds) {
        return "Hari Produktif"
    }
    if slices.Contains(hari.HariTambahan, ds) {
        return "Hari Non-Produktif"
    }
    if slices.Contains(hari.HariLibur, ds) {
        return "Hari Libur"
    }

    return "Hari Produktif"
}

func applyStatusFilter(query *gorm.DB, tab string) {
	switch strings.ToLower(tab) {
	case "hadir":
		query.Where("presences.status IN ?", []string{"Hadir", "Terlambat"})
	case "izin":
		query.Where("presences.status = ?", "Izin")
	case "sakit":
		query.Where("presences.status = ?", "Sakit")
	case "alpa":
		query.Where("presences.status = ?", "Alpa")
	}
}

func countTotalUser(kelas string, idSekolah string) int64 {
	var count int64
	db := config.DB.Model(&models.User{}).
		Joins("JOIN school_members ON school_members.id = users.id_school_member").
		Where("school_members.id_sekolah = ?", idSekolah).
		Where("users.role = ?", "user")

	if kelas != "" {
		db = db.Joins("JOIN kelas ON kelas.id = school_members.id_kelas").
			Where("kelas.id = ?", kelas)
	}

	db.Count(&count)
	return count
}

func startOfDay(t time.Time) time.Time {
	return time.Date(t.Year(), t.Month(), t.Day(), 0, 0, 0, 0, t.Location())
}

func endOfDay(t time.Time) time.Time {
	return time.Date(t.Year(), t.Month(), t.Day(), 23, 59, 59, 0, t.Location())
}

func getDefaultHeadTab(c *fiber.Ctx) string {
	idSekolah, _ := getSchoolID(c)
	loc, _ := time.LoadLocation("Asia/Jakarta")
	if determineDayType(time.Now().In(loc), idSekolah) == "Hari Non-Produktif" {
		return "non_produktif"
	}
	return "produktif"
}
