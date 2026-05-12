package seeders

import (
	"e-presence-backend/models"
	"time"

	"golang.org/x/crypto/bcrypt"
	"gorm.io/gorm"
)

func SeedDummyData(db *gorm.DB) error {
	var sekolah models.Sekolah
	if err := db.Where("npsn = ?", "20123456").First(&sekolah).Error; err != nil {
		return err
	}

	var kelasX models.Kelas
	if err := db.Where("name = ?", "X RPL 1").First(&kelasX).Error; err != nil {
		return err
	}

	var kelasXI models.Kelas
	if err := db.Where("name = ?", "XI RPL 1").First(&kelasXI).Error; err != nil {
		return err
	}

	hashedPassword, _ := bcrypt.GenerateFromPassword([]byte("password123"), bcrypt.DefaultCost)
	lastMembership := time.Now().AddDate(1, 0, 0)
	now := time.Now()
	yesterday := now.AddDate(0, 0, -1)

	type DummyData struct {
		Name     string
		NoInduk  string
		Username string
		Kelas    models.Kelas
		RFID     string
		Status   string
		Tgl      time.Time
	}

	dummies := []DummyData{
		{"Budi Santoso", "10001", "budisantoso", kelasX, "RFID001", "Hadir", now},
		{"Sari Indah", "10002", "sariindah", kelasX, "RFID002", "Sakit", now},
		{"Andi Pratama", "10003", "andipratama", kelasXI, "RFID003", "Terlambat", now},
		{"Rina Wijaya", "10004", "rinawijaya", kelasXI, "RFID004", "Alpa", now},
		{"Joko Susilo", "10005", "jokosusilo", kelasX, "RFID005", "Izin", yesterday},
		{"Citra Lestari", "10006", "citralestari", kelasXI, "RFID006", "Hadir", yesterday},
	}

	for _, d := range dummies {
		member := models.SchoolMember{
			IDSekolah: sekolah.ID,
			IDKelas:   d.Kelas.ID,
			Name:      d.Name,
			NoInduk:   d.NoInduk,
			Nomor:     stringPtr("0811000000" + d.NoInduk),
		}

		if err := db.Where(models.SchoolMember{NoInduk: member.NoInduk}).Assign(member).FirstOrCreate(&member).Error; err != nil {
			return err
		}

		user := models.User{
			IDSchoolMember: member.ID,
			RfidID:         stringPtr(d.RFID),
			Username:       d.Username,
			Email:          stringPtr(d.Username + "@example.com"),
			Password:       string(hashedPassword),
			Role:           "user",
			StatusBan:      "active",
			Membership:     "true",
			LastMembership: &lastMembership,
		}

		if err := db.Where("username = ? OR id_school_member = ?", user.Username, user.IDSchoolMember).Assign(user).FirstOrCreate(&user).Error; err != nil {
			return err
		}

		waktuKeluar := d.Tgl.Add(8 * time.Hour)
		presence := models.Presence{
			IDUser:       user.ID,
			TimeMasuk:    d.Tgl,
			TimeKeluar:   &waktuKeluar,
			Status:       d.Status,
			StatusHari:   "Hari Produktif",
			StatusKeluar: stringPtr("Tepat Waktu"),
		}

		if d.Status == "Alpa" || d.Status == "Sakit" || d.Status == "Izin" {
			presence.TimeKeluar = nil
			presence.StatusKeluar = nil
		}
		if d.Status == "Terlambat" {
			presence.AlasanDatangTelat = stringPtr("Macet di jalan akibat hujan")
		}

		// Delete exist presence of the day
		startOfDay := time.Date(d.Tgl.Year(), d.Tgl.Month(), d.Tgl.Day(), 0, 0, 0, 0, d.Tgl.Location())
		endOfDay := startOfDay.AddDate(0, 0, 1)
		db.Where("id_user = ? AND time_masuk >= ? AND time_masuk < ?", user.ID, startOfDay, endOfDay).Delete(&models.Presence{})

		db.Create(&presence)
	}

	return nil
}
