package controllers

import (
	"e-presence-backend/config"
	"e-presence-backend/models"
	"fmt"
	"strings"
	"time"

	"github.com/gofiber/fiber/v2"
	"github.com/xuri/excelize/v2"
	"gorm.io/gorm"
)

func ExportPresence(c *fiber.Ctx) error {
	filter := c.Query("filter", "Hari ini")
	tab := c.Query("tab", "all")
	dateFromStr := c.Query("date_from")
	dateToStr := c.Query("date_to")
	kelas := c.Query("kelas", "")

	dateFrom, dateTo := getDateRangeForExport(filter, dateFromStr, dateToStr)

	f := excelize.NewFile()
	defer f.Close()

	sheetName := "Presensi"
	f.SetSheetName("Sheet1", sheetName)

	sw, err := f.NewStreamWriter(sheetName)
	if err != nil {
		return c.Status(500).JSON(fiber.Map{"status": "failed", "message": "Gagal inisialisasi stream excel"})
	}

	// Tulis Header (Baris 1)
	headers := []interface{}{"No", "No Induk", "Nama", "Waktu Masuk", "Waktu Keluar", "Status", "Status Hari", "Alasan"}
	if err := sw.SetRow("A1", headers); err != nil {
		return c.Status(500).JSON(fiber.Map{"status": "failed", "message": "Gagal menulis header excel"})
	}

	query := config.DB.WithContext(c.Context()).
		Model(&models.Presence{}).
		Preload("User.SchoolMember").
		Where("presences.time_masuk BETWEEN ? AND ?", dateFrom, dateTo).
		Order("presences.time_masuk ASC")

	if kelas != "" {
		query = query.Joins("JOIN users ON users.id = presences.id_user").
			Joins("JOIN school_members ON school_members.id = users.id_school_member").
			Joins("JOIN kelas ON kelas.id = school_members.id_kelas").
			Where("kelas.id = ?", kelas)
	}

	switch strings.ToLower(strings.TrimSpace(tab)) {
	case "hadir":
		query = query.Where("presences.status IN ?", []string{"Hadir", "Terlambat"})
	case "izin":
		query = query.Where("presences.status = ?", "Izin")
	case "sakit":
		query = query.Where("presences.status = ?", "Sakit")
	case "alpa":
		query = query.Where("presences.status = ?", "Alpa")
	}

	var presences []models.Presence
	rowNum := 2 // Mulai dari baris ke-2 (karena baris 1 adalah header)
	counter := 1

	err = query.FindInBatches(&presences, 1000, func(tx *gorm.DB, batch int) error {
		for _, p := range presences {
			noInduk := "-"
			nama := "-"

			// Proteksi Nil-Pointer
			if p.User != nil && p.User.SchoolMember != nil {
				noInduk = p.User.SchoolMember.NoInduk
				nama = p.User.SchoolMember.Name
			}

			waktuMasuk := p.TimeMasuk.Format("2006-01-02 15:04:05")
			waktuKeluar := "-"
			if p.TimeKeluar != nil {
				waktuKeluar = p.TimeKeluar.Format("2006-01-02 15:04:05")
			}

			alasan := "-"
			if p.AlasanDatangTelat != nil {
				alasan = *p.AlasanDatangTelat
			} else if p.AlasanDatang != nil {
				alasan = *p.AlasanDatang
			}

			rowData := []interface{}{
				counter, noInduk, nama, waktuMasuk, waktuKeluar, p.Status, p.StatusHari, alasan,
			}

			// Tulis 1 Baris secara Streaming
			cellName, _ := excelize.CoordinatesToCellName(1, rowNum)
			if err := sw.SetRow(cellName, rowData); err != nil {
				return err // Batalkan proses jika gagal nulis
			}

			rowNum++
			counter++
		}
		return nil
	}).Error

	if err != nil {
		return c.Status(500).JSON(fiber.Map{"status": "failed", "message": "Gagal mengambil data dari database"})
	}

	if err := sw.Flush(); err != nil {
		return c.Status(500).JSON(fiber.Map{"status": "failed", "message": "Gagal menyelesaikan stream excel"})
	}

	fileName := fmt.Sprintf("Presensi_%s_%s.xlsx", tab, time.Now().Format("20060102_150405"))
	c.Set("Content-Type", "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet")
	c.Set("Content-Disposition", fmt.Sprintf("attachment; filename=\"%s\"", fileName))

	if err := f.Write(c.Response().BodyWriter()); err != nil {
		return c.Status(500).JSON(fiber.Map{"status": "failed", "message": "Gagal mengunduh file export"})
	}

	return nil
}

func getDateRangeForExport(filter, from, to string) (time.Time, time.Time) {
	now := time.Now()
	loc := now.Location()
	startOfDay := time.Date(now.Year(), now.Month(), now.Day(), 0, 0, 0, 0, loc)
	endOfDay := time.Date(now.Year(), now.Month(), now.Day(), 23, 59, 59, 0, loc)

	switch strings.ToLower(strings.TrimSpace(filter)) {
	case "custom":
		if from != "" && to != "" {
			// Cegah error tanggal silent
			if f, err := time.Parse("2006-01-02", from); err == nil {
				if t, err2 := time.Parse("2006-01-02", to); err2 == nil {
					return f, time.Date(t.Year(), t.Month(), t.Day(), 23, 59, 59, 0, loc)
				}
			}
		}
	case "kemarin":
		yesterday := now.AddDate(0, 0, -1)
		startOfDay = time.Date(yesterday.Year(), yesterday.Month(), yesterday.Day(), 0, 0, 0, 0, loc)
		endOfDay = time.Date(yesterday.Year(), yesterday.Month(), yesterday.Day(), 23, 59, 59, 0, loc)
	case "minggu ini":
		startOfWeek := now.AddDate(0, 0, -int(now.Weekday()))
		startOfDay = time.Date(startOfWeek.Year(), startOfWeek.Month(), startOfWeek.Day(), 0, 0, 0, 0, loc)
	case "minggu lalu":
		lastWeek := now.AddDate(0, 0, -int(now.Weekday())-7)
		startOfDay = time.Date(lastWeek.Year(), lastWeek.Month(), lastWeek.Day(), 0, 0, 0, 0, loc)
		endOfDay = startOfDay.AddDate(0, 0, 6).Add(23*time.Hour + 59*time.Minute + 59*time.Second)
	case "bulan ini":
		startOfDay = time.Date(now.Year(), now.Month(), 1, 0, 0, 0, 0, loc)
	case "bulan lalu":
		lastMonth := now.AddDate(0, -1, 0)
		startOfDay = time.Date(lastMonth.Year(), lastMonth.Month(), 1, 0, 0, 0, 0, loc)
		endOfDay = startOfDay.AddDate(0, 1, -1).Add(23*time.Hour + 59*time.Minute + 59*time.Second)
	case "tahun ini":
		startOfDay = time.Date(now.Year(), 1, 1, 0, 0, 0, 0, loc)
	case "tahun lalu":
		lastYear := now.AddDate(-1, 0, 0)
		startOfDay = time.Date(lastYear.Year(), 1, 1, 0, 0, 0, 0, loc)
		endOfDay = time.Date(lastYear.Year(), 12, 31, 23, 59, 59, 0, loc)
	}

	return startOfDay, endOfDay
}