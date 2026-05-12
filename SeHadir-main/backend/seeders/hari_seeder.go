package seeders

import (
	"e-presence-backend/models"

	"gorm.io/gorm"
	"gorm.io/gorm/clause"
)

func SeedHari(db *gorm.DB) error {
	var sekolah models.Sekolah

	if err := db.Where("npsn = ?", "20123456").First(&sekolah).Error; err != nil {
		return err
	}

	hari := models.Hari{
		IDSekolah: sekolah.ID,
		Bulan:     4,
		Tahun:     2026,

		HariProduktif: models.StringArray{
			"1", "2",
			"6", "7", "8", "9", "10", "12",
			"13", "14", "15", "16", "17",
			"20", "21", "22", "23", "24",
			"27", "28", "29", "30",
		},

		HariTambahan: models.StringArray{},

		HariLibur: models.StringArray{
			"3",
			"4", "5",
			"11",
			"18", "19",
			"25", "26",
		},
	}

	return db.Clauses(clause.OnConflict{
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
	}).Create(&hari).Error
}