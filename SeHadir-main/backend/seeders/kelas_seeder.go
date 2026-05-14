package seeders

import (
	"e-presence-backend/models"

	"gorm.io/gorm"
)

func SeedKelas(db *gorm.DB) error {
	// Temukan sekolah yang sudah ada (diseed oleh SeedSekolah)
	var sekolah models.Sekolah
	if err := db.Where("npsn = ?", "20123456").First(&sekolah).Error; err != nil {
		return err
	}

	daftarKelas := []models.Kelas{
		{IDSekolah: sekolah.ID, Name: "X RPL 1", Jenjang: "X"},
		{IDSekolah: sekolah.ID, Name: "X RPL 2", Jenjang: "X"},
		{IDSekolah: sekolah.ID, Name: "XI RPL 1", Jenjang: "XI"},
		{IDSekolah: sekolah.ID, Name: "XI RPL 2", Jenjang: "XI"},
		{IDSekolah: sekolah.ID, Name: "XII RPL 2", Jenjang: "XII"}, // XII RPL 1 sudah ada dari sekolah_seeder
	}

	for _, k := range daftarKelas {
		if err := db.Where(models.Kelas{Name: k.Name, IDSekolah: sekolah.ID}).Assign(k).FirstOrCreate(&k).Error; err != nil {
			return err
		}
	}

	return nil
}
