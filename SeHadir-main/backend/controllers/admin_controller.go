package controllers

import (
	"e-presence-backend/config"
	"e-presence-backend/models"
	"time"
	"strconv"
	"log"

	"github.com/gofiber/fiber/v2"
)

func GetDashboardStats(c *fiber.Ctx) error {
	filter := c.Query("filter", "Hari ini")
	tab := c.Query("tab", "all")
	headTab := c.Query("head-tabs", "")
	kelas := c.Query("kelas", "") // Menangkap parameter kelas
	idSekolah, err := getSchoolID(c)
	if err != nil {
		return c.Status(403).JSON(fiber.Map{"status": "failed", "message": "Tidak dapat masuk ke sekolah lain."})
	}

	dateFrom, dateTo := getDataRange(filter, c)

	loc, _ := time.LoadLocation("Asia/Jakarta")
	now := time.Now().In(loc)
	todayStart := startOfDay(now)
	todayDayType := determineDayType(todayStart, idSekolah)

	if headTab == "" {
		if todayDayType == "Hari Non-Produktif" || todayDayType == "Hari Libur" {
			headTab = "non_produktif"
		} else {
			headTab = "produktif"
		}
	}

	type StatsResult struct {
		TotalHadir      int64 `gorm:"column:total_hadir"`
		TotalTidakHadir int64 `gorm:"column:total_tidak_hadir"`
		TotalAlpa       int64 `gorm:"column:total_alpa"`
	}
	var stats StatsResult

	// --- 1. Query untuk Statistik ---
	statsQuery := config.DB.Model(&models.Presence{}).
		Joins("JOIN users ON users.id = presences.id_user").
		Joins("JOIN school_members ON school_members.id = users.id_school_member").
		Joins("JOIN kelas ON kelas.id = school_members.id_kelas").
		Where("presences.time_masuk BETWEEN ? AND ?", dateFrom, dateTo).
		Where("school_members.id_sekolah = ?", idSekolah)

	if kelas != "" {
		statsQuery = statsQuery.Where("kelas.id = ?", kelas) // Tambahan filter kelas
	}

	if headTab == "non_produktif" {
		statsQuery = statsQuery.Where("presences.status_hari = ?", "Hari Non-Produktif")
	} else {
		statsQuery = statsQuery.Where("presences.status_hari = ?", "Hari Produktif")
	}

	statsQuery.Select(`
		COALESCE(SUM(CASE WHEN presences.status IN ('Hadir', 'Terlambat') THEN 1 ELSE 0 END), 0) as total_hadir,
		COALESCE(SUM(CASE WHEN presences.status IN ('Izin', 'Sakit') THEN 1 ELSE 0 END), 0) as total_tidak_hadir,
		COALESCE(SUM(CASE WHEN presences.status = 'Alpa' THEN 1 ELSE 0 END), 0) as total_alpa
	`).Scan(&stats)

	// --- 2. Query untuk List Presensi ---
	var presences []models.Presence
	listQuery := config.DB.Model(&models.Presence{}).
		Preload("User.SchoolMember").
		Preload("User.SchoolMember.Kelas").
		Joins("JOIN users ON users.id = presences.id_user").
		Joins("JOIN school_members ON school_members.id = users.id_school_member").
		Joins("JOIN kelas ON kelas.id = school_members.id_kelas"). // Pastikan JOIN kelas ada untuk memfilter
		Where("presences.time_masuk BETWEEN ? AND ?", dateFrom, dateTo).
		Where("school_members.id_sekolah = ?", idSekolah)

	if kelas != "" {
		listQuery = listQuery.Where("kelas.id = ?", kelas) // Tambahan filter kelas
	}

	if headTab == "non_produktif" {
		listQuery = listQuery.Where("presences.status_hari = ?", "Hari Non-Produktif")
	} else {
		listQuery = listQuery.Where("presences.status_hari = ?", "Hari Produktif")
	}

	if tab != "all" {
		applyStatusFilter(listQuery, tab)
	}

	page, _ := strconv.Atoi(c.Query("page", "1"))
	listQuery.Order("presences.time_masuk DESC").
		Offset((page - 1) * 10).
		Limit(10).
		Find(&presences)

	// --- 3. Query untuk Dokumen Izin/Cuti ---
	var leaveDocuments []models.LeaveDocument
	leaveQuery := config.DB.Model(&models.LeaveDocument{}).
		Joins("JOIN users ON users.id = leave_documents.id_user").
		Joins("JOIN school_members ON school_members.id = users.id_school_member").
		Joins("LEFT JOIN kelas ON kelas.id = school_members.id_kelas"). // JOIN kelas untuk memfilter
		Where("school_members.id_sekolah = ?", idSekolah).
		Where("((leave_documents.start_date <= ? AND leave_documents.end_date >= ?))", dateTo, dateFrom).
		Preload("User.SchoolMember")

	if kelas != "" {
		leaveQuery = leaveQuery.Where("kelas.id = ?", kelas) // Tambahan filter kelas
	}

	leaveQuery.Find(&leaveDocuments)

	log.Printf("DEBUG: Now=%v, Day=%d, Loc=%v", now, now.Day(), now.Location())

	return c.JSON(fiber.Map{
		"status": "success",
		"data": fiber.Map{
			"total_users":       countTotalUser(kelas, idSekolah), // Pastikan countTotalUser menerima parameter kelas
			"date_now":          now.Format("2006-01-02 15:04:05"),
			"total_hadir":       stats.TotalHadir,
			"total_tidak_hadir": stats.TotalTidakHadir,
			"total_alpa":        stats.TotalAlpa,
			"data_presensi":     presences,
			"leave_documents":   leaveDocuments,
			"head_tab":          headTab,
			"filter":            filter,
			"tab":               tab,
			"today_day_type":    todayDayType,
			"date_from":         dateFrom.Format("2006-01-02"),
			"date_to":           dateTo.Format("2006-01-02"),
			"kelas_filter":      kelas, // Opsional: kembalikan filter kelas ke frontend
		},
	})
}

// GetChart returns attendance stats for charts
func GetChart(c *fiber.Ctx) error {
	loc, _ := time.LoadLocation("Asia/Jakarta")
	now := time.Now().In(loc)
	monthStart := time.Date(now.Year(), now.Month(), 1, 0, 0, 0, 0, loc)
	monthEnd := monthStart.AddDate(0, 1, -1).Add(23*time.Hour + 59*time.Minute + 59*time.Second)

	type ChartData struct {
		Name              string `json:"name"`
		ProductiveDays    int    `json:"productive_days"`
		NonProductiveDays int    `json:"non_productive_days"`
	}

	var results []struct {
		Name        string
		StatusHari  string
		StatusCount int
	}

	config.DB.Table("presences").
        Select("school_members.name as name, presences.status_hari, count(distinct date(presences.time_masuk)) as status_count").
        Joins("join users on presences.id_user = users.id").
        Joins("join school_members on users.id_school_member = school_members.id").
        Where("presences.time_masuk BETWEEN ? AND ?", monthStart, monthEnd).
        Where("presences.status IN ?", []string{"Hadir", "Terlambat"}).
        Group("school_members.name, presences.status_hari").
        Scan(&results)

	dataMap := make(map[string]*ChartData)
	for _, r := range results {
		if _, ok := dataMap[r.Name]; !ok {
			dataMap[r.Name] = &ChartData{Name: r.Name}
		}
		if r.StatusHari == "Hari Produktif" {
			dataMap[r.Name].ProductiveDays = r.StatusCount
		} else if r.StatusHari == "Hari Non-Produktif" {
			dataMap[r.Name].NonProductiveDays = r.StatusCount
		}
	}

	var labels []string
	var productiveDays []int
	var nonProductiveDays []int

	for name, data := range dataMap {
		labels = append(labels, name)
		productiveDays = append(productiveDays, data.ProductiveDays)
		nonProductiveDays = append(nonProductiveDays, data.NonProductiveDays)
	}

	return c.JSON(fiber.Map{
		"labels":            labels,
		"productiveDays":    productiveDays,
		"nonProductiveDays": nonProductiveDays,
	})
}

func getDataRange(filter string, c *fiber.Ctx) (time.Time, time.Time) {
	loc, _ := time.LoadLocation("Asia/Jakarta")
	now := time.Now().In(loc)

	switch filter {
	case "Kemarin":
		yesterday := now.AddDate(0, 0, -1)
		return time.Date(yesterday.Year(), yesterday.Month(), yesterday.Day(), 0, 0, 0, 0, loc),
			time.Date(yesterday.Year(), yesterday.Month(), yesterday.Day(), 23, 59, 59, 0, loc)
	case "Minggu Ini":
		// Simplified start of week (Sunday)
		weekday := int(now.Weekday())
		start := now.AddDate(0, 0, -weekday)
		return time.Date(start.Year(), start.Month(), start.Day(), 0, 0, 0, 0, loc),
			time.Date(now.Year(), now.Month(), now.Day(), 23, 59, 59, 0, loc)
	case "Minggu Lalu":
		weekday := int(now.Weekday())
		lastWeekStart := now.AddDate(0, 0, -weekday-7)
		lastWeekEnd := lastWeekStart.AddDate(0, 0, 6)
		return time.Date(lastWeekStart.Year(), lastWeekStart.Month(), lastWeekStart.Day(), 0, 0, 0, 0, loc),
			time.Date(lastWeekEnd.Year(), lastWeekEnd.Month(), lastWeekEnd.Day(), 23, 59, 59, 0, loc)
	case "Bulan Ini":
		start := time.Date(now.Year(), now.Month(), 1, 0, 0, 0, 0, loc)
		return start, now.Add(23*time.Hour + 59*time.Minute + 59*time.Second)
	case "Bulan Lalu":
		lastMonth := now.AddDate(0, -1, 0)
		start := time.Date(lastMonth.Year(), lastMonth.Month(), 1, 0, 0, 0, 0, loc)
		end := start.AddDate(0, 1, -1).Add(23*time.Hour + 59*time.Minute + 59*time.Second)
		return start, end
	case "Tahun Ini":
		start := time.Date(now.Year(), 1, 1, 0, 0, 0, 0, loc)
		return start, now.Add(23*time.Hour + 59*time.Minute + 59*time.Second)
	case "Tahun Lalu":
		lastYear := now.AddDate(-1, 0, 0)
		start := time.Date(lastYear.Year(), 1, 1, 0, 0, 0, 0, loc)
		end := time.Date(lastYear.Year(), 12, 31, 23, 59, 59, 0, loc)
		return start, end
	case "Custom":
		startStr := c.Query("start")
		endStr := c.Query("end")
		layout := "2006-01-02"
		start, err1 := time.ParseInLocation(layout, startStr, loc)
		end, err2 := time.ParseInLocation(layout, endStr, loc)

		if err1 != nil || err2 != nil {
			// Fallback ke hari ini jika parsing gagal
			return time.Date(now.Year(), now.Month(), now.Day(), 0, 0, 0, 0, loc),
				time.Date(now.Year(), now.Month(), now.Day(), 23, 59, 59, 0, loc)
		}

		return time.Date(start.Year(), start.Month(), start.Day(), 0, 0, 0, 0, loc),
			time.Date(end.Year(), end.Month(), end.Day(), 23, 59, 59, 0, loc)
	default: // Hari ini
		y, m, d := now.Date()
		return time.Date(y, m, d, 0, 0, 0, 0, loc),
			time.Date(y, m, d, 23, 59, 59, 0, loc)
	}
}

func BulkDeleteUsers(c *fiber.Ctx) error {
	type Request struct {
		IDs []string `json:"ids"`
	}
	var req Request
	if err := c.BodyParser(&req); err != nil {
		return c.Status(400).JSON(fiber.Map{"status": "failed", "message": "Invalid request body"})
	}

	if len(req.IDs) == 0 {
		return c.Status(400).JSON(fiber.Map{"status": "failed", "message": "No IDs provided"})
	}

	if err := config.DB.Delete(&models.User{}, req.IDs).Error; err != nil {
		return c.Status(500).JSON(fiber.Map{"status": "failed", "message": "Failed to delete users"})
	}

	return c.JSON(fiber.Map{"status": "success", "message": "Users deleted successfully"})
}

func BulkDeleteMembers(c *fiber.Ctx) error {
	type Request struct {
		NoInduks []string `json:"no_induk_list"`
	}
	var req Request
	if err := c.BodyParser(&req); err != nil {
		return c.Status(400).JSON(fiber.Map{"status": "failed", "message": "Invalid request body"})
	}

	if len(req.NoInduks) == 0 {
		return c.Status(400).JSON(fiber.Map{"status": "failed", "message": "No Induk provided"})
	}

	if err := config.DB.Delete(&models.SchoolMember{}, "no_induk IN ?", req.NoInduks).Error; err != nil {
		return c.Status(500).JSON(fiber.Map{"status": "failed", "message": "Failed to delete members"})
	}

	return c.JSON(fiber.Map{"status": "success", "message": "Members deleted successfully"})
}
