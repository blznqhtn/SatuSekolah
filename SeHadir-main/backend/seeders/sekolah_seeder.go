package seeders

import (
	"e-presence-backend/models"
	"time"

	"golang.org/x/crypto/bcrypt"
	"gorm.io/gorm"
)

func SeedSekolah(db *gorm.DB) error {
	sekolah := models.Sekolah{
		NamaSekolah:   "SMK Negeri 1 Jakarta",
		NPSN:          stringPtr("20123456"),
		KepalaSekolah: stringPtr("Dr. Ahmad Sanusi"),
		Alamat:        stringPtr("Jl. Budi Utomo No.7, Sawah Besar, Jakarta Pusat"),
		Email:         stringPtr("info@smkn1jkt.sch.id"),
	}

	if err := db.Where(models.Sekolah{NPSN: sekolah.NPSN}).Assign(sekolah).FirstOrCreate(&sekolah).Error; err != nil {
		return err
	}

	kelas := models.Kelas{
		IDSekolah: sekolah.ID,
		Name:      "XII RPL 1",
		Jenjang:   "XII",
	}

	if err := db.Where(models.Kelas{Name: kelas.Name, IDSekolah: sekolah.ID}).Assign(kelas).FirstOrCreate(&kelas).Error; err != nil {
		return err
	}

	member := models.SchoolMember{
		IDSekolah: sekolah.ID,
		IDKelas:   kelas.ID,
		Name:      "KADAVI RADITYA ALVINO",
		NoInduk:   "232410012",
		Nomor:     stringPtr("08123456789"),
	}

	if err := db.Where(models.SchoolMember{NoInduk: member.NoInduk}).Assign(member).FirstOrCreate(&member).Error; err != nil {
		return err
	}

	hashedPassword, _ := bcrypt.GenerateFromPassword([]byte("password123"), bcrypt.DefaultCost)
	lastMembership := time.Date(2099, 6, 12, 0, 0, 0, 0, time.UTC)

	user := models.User{
		IDSchoolMember: member.ID,
		Username:       "kadaviradityaa",
		Email:          stringPtr("kadavi@example.com"),
		Password:       string(hashedPassword),
		Role:           "admin",
		StatusBan:      "active",
		Membership:     "true",
		LastMembership: &lastMembership,
	}

	// Cek apakah user sudah ada berdasarkan username atau IDSchoolMember
	if err := db.Where("username = ? OR id_school_member = ?", user.Username, user.IDSchoolMember).
		Assign(user).FirstOrCreate(&user).Error; err != nil {
		return err
	}

	return nil
}

// Helper untuk menangani pointer string
func stringPtr(s string) *string {
	return &s
}
