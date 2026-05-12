package seeders

import (
	"fmt"
	"gorm.io/gorm"
)

func Run(db *gorm.DB) {
	fmt.Println("========================================")
	fmt.Println("🚀 Seeding database...")

	err := SeedSekolah(db)
	if err != nil {
		fmt.Printf("❌ Error seeding sekolah: %v\n", err)
	}
	
	err = SeedHari(db)
	if err != nil {
		fmt.Printf("❌ Error seeding hari: %v\n", err)
	}
	
	err = SeedKelas(db)
	if err != nil {
		fmt.Printf("❌ Error seeding kelas, memastikan data tambahan untuk filter kelas hadir di dashboard: %v\n", err)
	}

	err = SeedDummyData(db)
	if err != nil {
		fmt.Printf("❌ Error seeding dummy data (users & presences): %v\n", err)
	}

	if err != nil {
		fmt.Printf("❌ Error seeding database: %v\n", err)
	} else {
		fmt.Println("✅ Seeding completed successfully!")
	}

	fmt.Println("========================================")
}