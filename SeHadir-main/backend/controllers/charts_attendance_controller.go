package controllers

import (
	"encoding/json"
	"fmt"
	"math"
	"strconv"
	"time"

	"e-presence-backend/config"

	"github.com/gofiber/fiber/v2"
)

// ==========================================
// HELPER: ATTENDANCE CACHE VERSIONING
// ==========================================
func incrementAttendanceCacheVersion() {
	config.RDB.Incr(config.Ctx, "attendance_version")
}

func getAttendanceCacheVersion() string {
	version, err := config.RDB.Get(config.Ctx, "attendance_version").Result()
	if err != nil {
		config.RDB.Set(config.Ctx, "attendance_version", "1", 0)
		return "1"
	}
	return version
}

// ==========================================
// DTOs & Structs
// ==========================================

type AttendanceResult struct {
	ID                string  `json:"id"`
	Name              string  `json:"name"`
	Class             string  `json:"class"`
	ProductiveDays    int     `json:"productive_days"`
	NonProductiveDays int     `json:"non_productive_days"`
	Percentage        float64 `json:"percentage"`
	Comparison        float64 `json:"comparison"`
}

type HariRecord struct {
	HariProduktif string `gorm:"column:hari_produktif"`
	HariTambahan  string `gorm:"column:hari_tambahan"`
}

type PreviousAttendance struct {
	ID             string `gorm:"column:id"`
	ProductiveDays int    `gorm:"column:productive_days"`
}

func GetAttendanceData(c *fiber.Ctx) error {
	now := time.Now()

	monthStr := c.Query("bulan", strconv.Itoa(int(now.Month())))
	yearStr := c.Query("tahun", strconv.Itoa(now.Year()))
	class := c.Query("kelas", "all")
	search := c.Query("search", "")
	pageStr := c.Query("page", "1")
	page, _ := strconv.Atoi(pageStr)
	perPage := 10
	idSekolah, errSekolah := getSchoolID(c)
	if errSekolah != nil {
		return c.Status(fiber.StatusUnauthorized).JSON(fiber.Map{
			"status":  "failed",
			"message": errSekolah.Error(),
		})
	}

	currentVersion := getAttendanceCacheVersion()
	
	cacheKey := fmt.Sprintf("attendance:v%s:m:%s:y:%s:c:%s:s:%s:p:%s", 
		currentVersion, monthStr, yearStr, class, search, pageStr)

	cachedData, err := config.RDB.Get(config.Ctx, cacheKey).Result()
	if err == nil {
		c.Type("json")
		return c.SendString(cachedData)
	}

	month, _ := strconv.Atoi(monthStr)
	year, _ := strconv.Atoi(yearStr)

	startOfMonth := time.Date(year, time.Month(month), 1, 0, 0, 0, 0, time.Local)
	endOfMonth := startOfMonth.AddDate(0, 1, -1).Add(23*time.Hour + 59*time.Minute + 59*time.Second)

	totalProductiveDays := getProductiveDaysCount(c, month, year)

    db := config.DB.WithContext(c.Context()).Table("presences").
        Joins("JOIN users ON presences.id_user = users.id").
        Joins("JOIN school_members ON users.id_school_member = school_members.id").
        Joins("JOIN kelas ON school_members.id_kelas = kelas.id").
        Where("presences.time_masuk BETWEEN ? AND ?", startOfMonth, endOfMonth).
        Where("presences.status IN ?", []string{"Hadir", "Terlambat"}).
        Where("school_members.id_sekolah = ?", idSekolah)

    if class != "all" {
        db = db.Where("kelas.name = ?", class)
    }

    if search != "" {
        db = db.Where("school_members.name ILIKE ?", "%"+search+"%")
    }

    var totalData int64
    db.Select("COUNT(DISTINCT users.id)").Count(&totalData)

    db = db.Select(`
            users.id, 
            school_members.name as name, 
            kelas.name as class,
            COUNT(DISTINCT CASE WHEN presences.status_hari = 'Hari Produktif' THEN DATE(presences.time_masuk) END) as productive_days,
            COUNT(DISTINCT CASE WHEN presences.status_hari = 'Hari Non-Produktif' THEN DATE(presences.time_masuk) END) as non_productive_days
        `).
        Group("users.id, school_members.name, kelas.name").
        Order("school_members.name ASC")

	var results []AttendanceResult
	offset := (page - 1) * perPage
	
	if err := db.Offset(offset).Limit(perPage).Find(&results).Error; err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
			"status": "failed",
			"message": "Gagal memproses data absensi",
		})
	}

	if len(results) == 0 {
		return sendEmptyResponseAndCache(c, cacheKey, month, year, totalProductiveDays, page, perPage, totalData)
	}

	var userIDs []string
	for _, res := range results {
		userIDs = append(userIDs, res.ID)
	}

	prevMonth := month - 1
	prevYear := year
	if prevMonth < 1 {
		prevMonth = 12
		prevYear--
	}

	startOfPrev := time.Date(prevYear, time.Month(prevMonth), 1, 0, 0, 0, 0, time.Local)
	endOfPrev := startOfPrev.AddDate(0, 1, -1).Add(23*time.Hour + 59*time.Minute + 59*time.Second)

	totalProductiveDaysLastMonth := getProductiveDaysCount(c, prevMonth, prevYear)

	var prevResults []PreviousAttendance
	config.DB.WithContext(c.Context()).Table("presences").
		Select("users.id, COUNT(DISTINCT CASE WHEN presences.status_hari = 'Hari Produktif' THEN DATE(presences.time_masuk) END) as productive_days").
		Joins("JOIN users ON presences.id_user = users.id").
		Where("presences.time_masuk BETWEEN ? AND ?", startOfPrev, endOfPrev).
		Where("presences.status IN ?", []string{"Hadir", "Terlambat"}).
		Where("users.id IN ?", userIDs). 
		Group("users.id").
		Find(&prevResults)

	prevDataMap := make(map[string]int)
	for _, p := range prevResults {
		prevDataMap[p.ID] = p.ProductiveDays
	}

	chartLabels := make([]string, 0, len(results))
	chartProd := make([]int, 0, len(results))
	chartNonProd := make([]int, 0, len(results))

	for i, res := range results {
		prevCount := prevDataMap[res.ID]

		var pctNow float64
		if totalProductiveDays > 0 {
			pctNow = math.Round((float64(res.ProductiveDays) / float64(totalProductiveDays)) * 100)
		}

		var pctLast float64
		if totalProductiveDaysLastMonth > 0 {
			pctLast = math.Round((float64(prevCount) / float64(totalProductiveDaysLastMonth)) * 100)
		}

		results[i].Percentage = pctNow
		results[i].Comparison = pctNow - pctLast

		chartLabels = append(chartLabels, res.Name)
		chartProd = append(chartProd, res.ProductiveDays)
		chartNonProd = append(chartNonProd, res.NonProductiveDays)
	}

	response := fiber.Map{
		"status": "success",
		"data": fiber.Map{
			"attendanceData":      results,
			"totalProductiveDays": totalProductiveDays,
			"currentMonth":        month,
			"currentYear":         year,
			"chartData": fiber.Map{
				"labels":            chartLabels,
				"productiveDays":    chartProd,
				"nonProductiveDays": chartNonProd,
			},
			"meta": fiber.Map{
				"current_page": page,
				"per_page":     perPage,
				"total_data":   totalData,
				"total_pages":  int(math.Ceil(float64(totalData) / float64(perPage))),
			},
		},
	}

	responseBytes, errMarshal := json.Marshal(response)
	if errMarshal == nil {
		config.RDB.Set(config.Ctx, cacheKey, responseBytes, 24*time.Hour)
	}

	return c.JSON(response)
}

// ==========================================
// Helper Functions
// ==========================================

func getProductiveDaysCount(c *fiber.Ctx, month, year int) int {
	var hari HariRecord
	idSekolah, errSchool := getSchoolID(c)
	if errSchool != nil {
		return 0
	}

	err := config.DB.WithContext(c.Context()).Table("hari").
		Where("bulan = ? AND tahun = ? AND id_sekolah = ?", month, year, idSekolah).
		First(&hari).Error

	if err != nil {
		return 0
	}

	var prodDays []string
	if hari.HariProduktif != "" {
		json.Unmarshal([]byte(hari.HariProduktif), &prodDays)
	}

	return len(prodDays)
}

func sendEmptyResponseAndCache(c *fiber.Ctx, cacheKey string, month, year, totalProductiveDays, page, perPage int, totalData int64) error {
	response := fiber.Map{
		"status": "success",
		"data": fiber.Map{
			"attendanceData":      []AttendanceResult{},
			"totalProductiveDays": totalProductiveDays,
			"currentMonth":        month,
			"currentYear":         year,
			"chartData": fiber.Map{
				"labels":            []string{},
				"productiveDays":    []int{},
				"nonProductiveDays": []int{},
			},
			"meta": fiber.Map{
				"current_page": page,
				"per_page":     perPage,
				"total_data":   totalData,
				"total_pages":  int(math.Ceil(float64(totalData) / float64(perPage))),
			},
		},
	}

	responseBytes, _ := json.Marshal(response)
	config.RDB.Set(config.Ctx, cacheKey, responseBytes, 24*time.Hour)

	return c.JSON(response)
}