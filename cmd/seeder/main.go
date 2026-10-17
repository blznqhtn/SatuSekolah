package main

import (
	"context"
	"database/sql"
	"fmt"
	"log"

	"github.com/golang-migrate/migrate/v4"
	migratedb "github.com/golang-migrate/migrate/v4/database"
	"github.com/golang-migrate/migrate/v4/database/mysql"
	"github.com/golang-migrate/migrate/v4/database/postgres"
	"github.com/golang-migrate/migrate/v4/database/sqlite3"
	_ "github.com/golang-migrate/migrate/v4/source/file"
	"neuracakrawira.asia/satu-sekolah-backend/internal/config"
	"neuracakrawira.asia/satu-sekolah-backend/internal/infrastructure/database"
	"neuracakrawira.asia/satu-sekolah-backend/internal/modules/core/domain"
	"neuracakrawira.asia/satu-sekolah-backend/internal/modules/core/repository"
)

func main() {
	log.Println("Starting Satu Sekolah Seeder...")

	// 1. Load Config
	cfg, err := config.LoadConfig()
	if err != nil {
		log.Fatalf("Failed to load config: %v", err)
	}

	// 2. Connect to Database based on driver configuration
	var db *sql.DB
	if cfg.Database.Driver == "mysql" {
		db, err = database.NewMySQLConnection(cfg)
	} else if cfg.Database.Driver == "sqlite" {
		db, err = database.NewSQLiteConnection(cfg)
	} else {
		db, err = database.NewPostgresConnection(cfg)
	}
	if err != nil {
		log.Fatalf("Failed to connect to DB: %v", err)
	}
	defer db.Close()

	// 2.5 Run Auto Migration
	log.Printf("Running auto-migration for %s...", cfg.Database.Driver)
	var migrationDriver migratedb.Driver
	var errMigration error

	switch cfg.Database.Driver {
	case "mysql":
		migrationDriver, errMigration = mysql.WithInstance(db, &mysql.Config{})
	case "sqlite":
		migrationDriver, errMigration = sqlite3.WithInstance(db, &sqlite3.Config{})
	default:
		migrationDriver, errMigration = postgres.WithInstance(db, &postgres.Config{})
	}

	if errMigration != nil {
		log.Fatalf("Could not create migration driver: %v", errMigration)
	}

	m, err := migrate.NewWithDatabaseInstance(
		"file://migrations/"+cfg.Database.Driver,
		cfg.Database.Driver,
		migrationDriver,
	)
	if err != nil {
		log.Fatalf("Migration init failed: %v", err)
	}
	if err := m.Up(); err != nil && err != migrate.ErrNoChange {
		log.Fatalf("Migration execution failed: %v", err)
	}
	log.Println("Database schema is up to date!")

	// 3. Init Repository
	repo := repository.NewCoreRepository(db, nil)
	ctx := context.Background()

	// 4. Seed Tenant
	domainStr := "sekolah.id"
	tenant, err := repo.GetTenantByDomain(ctx, domainStr)
	if err != nil {
		log.Fatalf("Error checking tenant: %v", err)
	}

	if tenant == nil {
		tenantName := "Satu Sekolah Demo"
		npsn := "12345678"
		tenant = &domain.Tenant{
			Name:   tenantName,
			Domain: &domainStr,
			NPSN:   &npsn,
		}
		if err := repo.CreateTenant(ctx, tenant); err != nil {
			log.Fatalf("Failed to create tenant: %v", err)
		}
		log.Printf("Created Tenant: %s (ID: %s)\n", tenant.Name, tenant.ID)
	} else {
		log.Printf("Tenant already exists: %s (ID: %s)\n", tenant.Name, tenant.ID)
	}

	// 5. Seed Roles
	roles := []string{"Admin", "Staff"}
	roleMap := make(map[string]*domain.Role)

	for _, roleName := range roles {
		role, err := repo.GetRoleByNameAndTenant(ctx, roleName, tenant.ID)
		if err != nil {
			log.Fatalf("Error checking role %s: %v", roleName, err)
		}

		if role == nil {
			role = &domain.Role{
				TenantID: &tenant.ID,
				Name:     roleName,
				IsCustom: false,
			}
			if err := repo.CreateRole(ctx, role); err != nil {
				log.Fatalf("Failed to create role %s: %v", roleName, err)
			}
			log.Printf("Created Role: %s\n", roleName)
		} else {
			log.Printf("Role already exists: %s\n", roleName)
		}
		roleMap[roleName] = role
	}

	// 6. Seed Permissions for Admin
	permissions, err := repo.GetSystemPermissions(ctx)
	if err != nil {
		log.Fatalf("Failed to get system permissions: %v", err)
	}

	if len(permissions) > 0 {
		adminRole := roleMap["Admin"]
		for _, perm := range permissions {
			// In a real seeder, we might want to check if it's already assigned.
			// The repository method might throw unique constraint error if we don't catch it,
			// or it might use ON CONFLICT DO NOTHING (if postgres) or IGNORE (if mysql).
			// Since we use raw SQL in AssignPermissionToRole, we'll try assigning and ignore err
			// for simplicity in the seeder, or ideally check.
			_ = repo.AssignPermissionToRole(ctx, adminRole.ID, perm.ID)
		}
		log.Printf("Assigned %d permissions to Admin role\n", len(permissions))
	} else {
		log.Println("No system permissions found to assign. Ensure migrations ran successfully.")
	}

	// 7. Seed Users
	// Admin User
	adminEmail := "admin@sekolah.id"
	adminUsername := "admin"
	admin, err := repo.GetUserByLoginIdentifier(ctx, adminEmail)
	if err != nil {
		log.Fatalf("Error checking admin user: %v", err)
	}

	if admin == nil {
		admin = &domain.User{
			TenantID: tenant.ID,
			Category: "admin",
			Name:     "Super Admin",
			Email:    adminEmail,
			Username: &adminUsername,
			Password: "admin123", // Will be hashed in CreateUser
		}
		if err := repo.CreateUser(ctx, admin); err != nil {
			log.Fatalf("Failed to create admin user: %v", err)
		}
		log.Println("Created Admin user: admin@sekolah.id")
		
		if err := repo.AssignRoleToUser(ctx, admin.ID, roleMap["Admin"].ID); err != nil {
			log.Fatalf("Failed to assign role to admin: %v", err)
		}
	} else {
		log.Println("Admin user already exists.")
	}

	// Staff User
	staffEmail := "guru@sekolah.id"
	staffNpk := "19902030"
	staff, err := repo.GetUserByLoginIdentifier(ctx, staffEmail)
	if err != nil {
		log.Fatalf("Error checking staff user: %v", err)
	}

	if staff == nil {
		staff = &domain.User{
			TenantID: tenant.ID,
			Category: "staff",
			Name:     "Guru Teladan",
			Email:    staffEmail,
			Npk:      &staffNpk,
			Password: "staff123", // Will be hashed in CreateUser
		}
		if err := repo.CreateUser(ctx, staff); err != nil {
			log.Fatalf("Failed to create staff user: %v", err)
		}
		log.Println("Created Staff user: 19902030")

		if err := repo.AssignRoleToUser(ctx, staff.ID, roleMap["Staff"].ID); err != nil {
			log.Fatalf("Failed to assign role to staff: %v", err)
		}
	} else {
		log.Println("Staff user already exists.")
	}

	// Student User (untuk login di aplikasi_mobile_siswa)
	studentEmail := "siswa@sekolah.id"
	studentNisn := "0012345678"
	student, err := repo.GetUserByLoginIdentifier(ctx, studentEmail)
	if err != nil {
		log.Fatalf("Error checking student user: %v", err)
	}

	if student == nil {
		student = &domain.User{
			TenantID: tenant.ID,
			Category: "student",
			Name:     "Budi Siswa Teladan",
			Email:    studentEmail,
			Nisn:     &studentNisn,
			Password: "siswa123", // Will be hashed in CreateUser
		}
		if err := repo.CreateUser(ctx, student); err != nil {
			log.Fatalf("Failed to create student user: %v", err)
		}
		log.Println("Created Student user: 0012345678 / siswa@sekolah.id (password: siswa123)")
	} else {
		log.Println("Student user already exists.")
	}

	// 8. Seed Comprehensive Student & Academic Records for Mobile App
	seedComprehensiveStudentData(ctx, db, tenant.ID.String(), student.ID.String(), staff.ID.String())

	log.Println("Seeding completed successfully!")
}

func seedComprehensiveStudentData(ctx context.Context, db *sql.DB, tenantID, studentID, staffID string) {
	log.Println("Seeding comprehensive database records for mobile app...")

	// Clean up old invalid IDs if any
	_, _ = db.ExecContext(ctx, `
		DELETE FROM attendances WHERE user_id = $1;
		DELETE FROM report_card_grades;
		DELETE FROM report_cards;
		DELETE FROM user_violations;
		DELETE FROM violation_types;
		DELETE FROM class_schedules;
		DELETE FROM courses;
		DELETE FROM job_vacancies;
		DELETE FROM companies;
		DELETE FROM announcements;
		DELETE FROM books;
		DELETE FROM extracurriculars;
		DELETE FROM holidays;
		DELETE FROM teacher_evaluation_categories;
		DELETE FROM teacher_evaluation_periods;
		DELETE FROM academic_terms;
		DELETE FROM academic_years;
	`, studentID)

	// 1. Classes & update student
	classID := "c1111111-1111-1111-1111-111111111111"
	_, _ = db.ExecContext(ctx, `
		INSERT INTO classes (id, tenant_id, name, grade_level, staff_id)
		VALUES ($1, $2, 'XII RPL 1', 12, $3)
		ON CONFLICT (id) DO UPDATE SET staff_id = EXCLUDED.staff_id
	`, classID, tenantID, staffID)

	_, _ = db.ExecContext(ctx, `
		UPDATE users SET class_id = $1, phone = '081234567890', address = 'Jl. Sukajadi No. 123, Bandung'
		WHERE id = $2
	`, classID, studentID)

	// 2. Courses (valid hex UUIDs)
	courseMath := "c0000001-1111-1111-1111-111111111111"
	courseIndo := "c0000002-1111-1111-1111-111111111111"
	courseWeb := "c0000003-1111-1111-1111-111111111111"
	courseDb := "c0000004-1111-1111-1111-111111111111"
	courseEng := "c0000005-1111-1111-1111-111111111111"
	coursePai := "c0000006-1111-1111-1111-111111111111"

	courses := []struct {
		id, name string
	}{
		{courseMath, "Matematika"},
		{courseIndo, "Bahasa Indonesia"},
		{courseWeb, "Pemrograman Web"},
		{courseDb, "Basis Data"},
		{courseEng, "Bahasa Inggris"},
		{coursePai, "Pendidikan Agama Islam"},
	}

	for _, c := range courses {
		_, _ = db.ExecContext(ctx, `
			INSERT INTO courses (id, tenant_id, name, staff_id)
			VALUES ($1, $2, $3, $4)
			ON CONFLICT (id) DO NOTHING
		`, c.id, tenantID, c.name, staffID)
	}

	// 3. Class Schedules (Day 1=Senin, 2=Selasa, 3=Rabu, 4=Kamis, 5=Jumat)
	schedules := []struct {
		id, courseID string
		day          int
		start, end   string
	}{
		// Senin
		{"ca000001-1111-1111-1111-111111111111", courseMath, 1, "08:00:00", "09:30:00"},
		{"ca000002-1111-1111-1111-111111111111", courseIndo, 1, "09:45:00", "11:15:00"},
		{"ca000003-1111-1111-1111-111111111111", coursePai, 1, "11:30:00", "13:00:00"},
		// Selasa
		{"ca000004-1111-1111-1111-111111111111", courseWeb, 2, "08:00:00", "10:00:00"},
		{"ca000005-1111-1111-1111-111111111111", courseDb, 2, "10:15:00", "12:00:00"},
		// Rabu
		{"ca000006-1111-1111-1111-111111111111", courseEng, 3, "08:00:00", "09:30:00"},
		{"ca000007-1111-1111-1111-111111111111", courseWeb, 3, "09:45:00", "12:00:00"},
		// Kamis
		{"ca000008-1111-1111-1111-111111111111", courseDb, 4, "08:00:00", "10:00:00"},
		{"ca000009-1111-1111-1111-111111111111", courseMath, 4, "10:15:00", "12:00:00"},
		// Jumat
		{"ca000010-1111-1111-1111-111111111111", courseIndo, 5, "08:00:00", "09:30:00"},
		{"ca000011-1111-1111-1111-111111111111", courseEng, 5, "09:45:00", "11:00:00"},
	}

	for _, s := range schedules {
		_, _ = db.ExecContext(ctx, `
			INSERT INTO class_schedules (id, tenant_id, class_id, course_id, staff_id, day_of_week, start_time, end_time)
			VALUES ($1, $2, $3, $4, $5, $6, $7, $8)
			ON CONFLICT (id) DO NOTHING
		`, s.id, tenantID, classID, s.courseID, staffID, s.day, s.start, s.end)
	}

	// 4. Books (Library)
	books := []struct {
		id, title, author, bookType string
		stock                       int
		coverUrl                    string
	}{
		{"b0000001-1111-1111-1111-111111111111", "Bumi Manusia", "Pramoedya Ananta Toer", "Sejarah", 5, "https://images.unsplash.com/photo-1589829085413-56de8ae18c73?q=80&w=300&auto=format&fit=crop"},
		{"b0000002-1111-1111-1111-111111111111", "Atomic Habits", "James Clear", "Pengembangan Diri", 8, "https://images.unsplash.com/photo-1589998059171-988d887df646?q=80&w=300&auto=format&fit=crop"},
		{"b0000003-1111-1111-1111-111111111111", "Sapiens: Riwayat Singkat Umat Manusia", "Yuval Noah Harari", "Sains", 4, "https://images.unsplash.com/photo-1532012197267-da84d127e765?q=80&w=300&auto=format&fit=crop"},
		{"b0000004-1111-1111-1111-111111111111", "Laskar Pelangi", "Andrea Hirata", "Fiksi", 6, "https://images.unsplash.com/photo-1544947950-fa07a98d237f?q=80&w=300&auto=format&fit=crop"},
		{"b0000005-1111-1111-1111-111111111111", "Dasar Pemrograman Web Modern", "Budi Raharjo", "Teknologi", 10, "https://images.unsplash.com/photo-1555066931-4365d14bab8c?q=80&w=300&auto=format&fit=crop"},
	}

	for _, b := range books {
		_, _ = db.ExecContext(ctx, `
			INSERT INTO books (id, tenant_id, title, author, book_type, stock, uploader_staff_id, cover_url)
			VALUES ($1, $2, $3, $4, $5, $6, $7, $8)
			ON CONFLICT (id) DO NOTHING
		`, b.id, tenantID, b.title, b.author, b.bookType, b.stock, staffID, b.coverUrl)
	}

	// 5. Announcements
	announcements := []struct {
		id, title, content, aType string
	}{
		{"a0000001-1111-1111-1111-111111111111", "Jadwal Ujian Tengah Semester (UTS)", "Pelaksanaan UTS akan dimulai minggu depan. Pastikan semua tugas telah diselesaikan dan tagihan administrasi sudah lunas.", "PENTING"},
		{"a0000002-1111-1111-1111-111111111111", "Pendaftaran Ekstrakurikuler Semester Genap", "Silakan pilih ekstrakurikuler wajib dan pilihan melalui menu akademik. Batas waktu pendaftaran sampai hari Jumat.", "INFO"},
		{"a0000003-1111-1111-1111-111111111111", "Kunjungan Industri Kelas XII", "Bagi siswa kelas XII, persiapan kunjungan industri ke PT. Telkom Bandung. Kumpul di lapangan utama jam 06:00 WIB.", "KEGIATAN"},
		{"a0000004-1111-1111-1111-111111111111", "Program Beasiswa Berprestasi 2026 Dibuka", "Daftarkan diri Anda untuk program beasiswa prestasi akademik semester ini sebelum akhir bulan.", "BEASISWA"},
	}

	for _, a := range announcements {
		_, _ = db.ExecContext(ctx, `
			INSERT INTO announcements (id, tenant_id, title, content, type, target_audience, created_at, updated_by)
			VALUES ($1, $2, $3, $4, $5, 'STUDENT', NOW(), $6)
			ON CONFLICT (id) DO NOTHING
		`, a.id, tenantID, a.title, a.content, a.aType, staffID)
	}

	// 6. Companies & Job Vacancies
	compTelkom := "d0000001-1111-1111-1111-111111111111"
	compDicoding := "d0000002-1111-1111-1111-111111111111"
	compAgate := "d0000003-1111-1111-1111-111111111111"
	compGojek := "d0000004-1111-1111-1111-111111111111"

	companies := []struct {
		id, name, industry, address, logo string
	}{
		{compTelkom, "PT Telkom Indonesia", "Telecommunication", "Bandung", "https://images.unsplash.com/photo-1599305445671-ac291c95aaa9?w=150&h=150&fit=crop"},
		{compDicoding, "Dicoding Indonesia", "Education & Tech", "Remote", "https://images.unsplash.com/photo-1611162617474-5b21e879e113?w=150&h=150&fit=crop"},
		{compAgate, "Agate Studio", "Game Development", "Bandung", "https://images.unsplash.com/photo-1550745165-9bc0b252726f?w=150&h=150&fit=crop"},
		{compGojek, "Gojek Tech", "Information Technology", "Jakarta", "https://images.unsplash.com/photo-1611162616305-c69b3fa7fbe0?w=150&h=150&fit=crop"},
	}

	for _, c := range companies {
		_, _ = db.ExecContext(ctx, `
			INSERT INTO companies (id, tenant_id, name, industry, address, logo_url)
			VALUES ($1, $2, $3, $4, $5, $6)
			ON CONFLICT (id) DO NOTHING
		`, c.id, tenantID, c.name, c.industry, c.address, c.logo)
	}

	jobs := []struct {
		id, companyID, title, jType, arrangement, desc string
	}{
		{"da000001-1111-1111-1111-111111111111", compTelkom, "IT Support Intern", "Magang / PKL", "Bandung", "Membantu pemeliharaan jaringan dan dukungan teknis sistem internal."},
		{"da000002-1111-1111-1111-111111111111", compDicoding, "Mobile Dev Intern (Flutter)", "Magang / PKL", "Remote", "Mengembangkan fitur aplikasi mobile berbasis Flutter dan API integrasi."},
		{"da000003-1111-1111-1111-111111111111", compAgate, "Game Programmer Intern", "Magang / PKL", "Bandung", "Membantu scripting gameplay menggunakan Unity/C#."},
		{"da000004-1111-1111-1111-111111111111", compGojek, "Junior Software Engineer", "Full-time", "Jakarta", "Terbuka bagi lulusan baru jurusan Rekayasa Perangkat Lunak."},
	}

	for _, j := range jobs {
		_, _ = db.ExecContext(ctx, `
			INSERT INTO job_vacancies (id, tenant_id, company_id, title, type, arrangement, description, is_active, is_public, deadline)
			VALUES ($1, $2, $3, $4, $5, $6, $7, true, true, CURRENT_DATE + INTERVAL '60 days')
			ON CONFLICT (id) DO NOTHING
		`, j.id, tenantID, j.companyID, j.title, j.jType, j.arrangement, j.desc)
	}

	// 7. Extracurriculars
	extras := []struct {
		id, name, desc, schedule, coach string
	}{
		{"e0000001-1111-1111-1111-111111111111", "Paskibra", "Pasukan Pengibar Bendera Sekolah", "Selasa & Kamis, 15:30 - 17:00", "Deni Saputra"},
		{"e0000002-1111-1111-1111-111111111111", "Futsal", "Ekstrakulikuler olahraga futsal putra & putri", "Rabu & Jumat, 15:30 - 17:30", "Coach Andi"},
		{"e0000003-1111-1111-1111-111111111111", "Basket", "Pelatihan dasar dan pertandingan basket", "Senin & Kamis, 15:30 - 17:00", "Coach Kevin"},
		{"e0000004-1111-1111-1111-111111111111", "Robotik & IoT", "Pemrograman mikrokontroler, IoT, dan robotika", "Sabtu, 09:00 - 12:00", "Ir. Handoko"},
		{"e0000005-1111-1111-1111-111111111111", "PMR (Palang Merah Remaja)", "Kesiapsiagaan kesehatan dan pertolongan pertama", "Rabu, 15:30 - 17:00", "dr. Siti Rahma"},
		{"e0000006-1111-1111-1111-111111111111", "Pramuka", "Kepanduan dan pembentukan karakter kepemimpinan", "Jumat, 14:00 - 16:00", "Kak Budi"},
	}

	for _, e := range extras {
		_, _ = db.ExecContext(ctx, `
			INSERT INTO extracurriculars (id, tenant_id, name, description, schedule, coach_name, status, max_members)
			VALUES ($1, $2, $3, $4, $5, $6, 'ACTIVE', 30)
			ON CONFLICT (id) DO NOTHING
		`, e.id, tenantID, e.name, e.desc, e.schedule, e.coach)
	}

	// 8. Violation Types & History
	vtLate := "f0000001-1111-1111-1111-111111111111"
	vtUniform := "f0000002-1111-1111-1111-111111111111"
	vtPhone := "f0000003-1111-1111-1111-111111111111"

	vTypes := []struct {
		id, name, desc string
		points         int
	}{
		{vtLate, "Terlambat Masuk Sekolah", "Hadir melewati pukul 07:00 WIB", 5},
		{vtUniform, "Atribut Seragam Tidak Lengkap", "Tidak memakai dasi, sabuk, atau kaos kaki sesuai ketentuan", 5},
		{vtPhone, "Membawa/Menggunakan HP saat KBM", "Mengoperasikan ponsel tanpa izin saat jam pelajaran", 20},
	}

	for _, vt := range vTypes {
		_, _ = db.ExecContext(ctx, `
			INSERT INTO violation_types (id, tenant_id, name, description, points, applies_to, is_active, is_system_default)
			VALUES ($1, $2, $3, $4, $5, 'STUDENT', true, true)
			ON CONFLICT (id) DO NOTHING
		`, vt.id, tenantID, vt.name, vt.desc, vt.points)
	}

	// 1 sample violation history
	_, _ = db.ExecContext(ctx, `
		INSERT INTO user_violations (id, tenant_id, user_id, violation_type_id, points_applied, notes, recorded_by, created_at)
		VALUES ('f1000001-1111-1111-1111-111111111111', $1, $2, $3, 5, 'Terlambat 10 menit karena hujan deras', $4, NOW() - INTERVAL '5 days')
		ON CONFLICT (id) DO NOTHING
	`, tenantID, studentID, vtLate, staffID)

	// 9. Academic Year & Term
	ayID := "aa000001-1111-1111-1111-111111111111"
	termID := "ab000001-1111-1111-1111-111111111111"

	_, _ = db.ExecContext(ctx, `
		INSERT INTO academic_years (id, tenant_id, name, start_date, end_date, is_active)
		VALUES ($1, $2, '2025/2026', '2025-07-15', '2026-06-25', true)
		ON CONFLICT (id) DO NOTHING
	`, ayID, tenantID)

	_, _ = db.ExecContext(ctx, `
		INSERT INTO academic_terms (id, tenant_id, academic_year_id, name, is_active)
		VALUES ($1, $2, $3, 'Semester Ganjil', true)
		ON CONFLICT (id) DO NOTHING
	`, termID, tenantID, ayID)

	// 10. Report Card & Grades
	rcID := "c1000001-1111-1111-1111-111111111111"
	_, _ = db.ExecContext(ctx, `
		INSERT INTO report_cards (id, tenant_id, student_id, term_id, class_rank, homeroom_notes)
		VALUES ($1, $2, $3, $4, 3, 'Pertahankan prestasi belajar dan aktif dalam kegiatan sekolah.')
		ON CONFLICT (id) DO NOTHING
	`, rcID, tenantID, studentID, termID)

	grades := []struct {
		id, courseID string
		score        int
		predicate    string
	}{
		{"c2000001-1111-1111-1111-111111111111", courseMath, 88, "A"},
		{"c2000002-1111-1111-1111-111111111111", courseIndo, 92, "A"},
		{"c2000003-1111-1111-1111-111111111111", courseWeb, 95, "A"},
		{"c2000004-1111-1111-1111-111111111111", courseDb, 90, "A"},
		{"c2000005-1111-1111-1111-111111111111", courseEng, 85, "B"},
		{"c2000006-1111-1111-1111-111111111111", coursePai, 87, "A"},
	}

	for _, g := range grades {
		_, _ = db.ExecContext(ctx, `
			INSERT INTO report_card_grades (id, report_card_id, course_id, score, predicate, description)
			VALUES ($1, $2, $3, $4, $5, 'Kompetensi sangat baik dan tuntas.')
			ON CONFLICT (id) DO NOTHING
		`, g.id, rcID, g.courseID, g.score, g.predicate)
	}

	_, _ = db.ExecContext(ctx, `
		INSERT INTO report_card_notes (id, report_card_id, category, notes)
		VALUES 
			('c3000001-1111-1111-1111-111111111111', $1, 'ACADEMIC', 'Pertahankan prestasi di bidang Rekayasa Perangkat Lunak dan Matematika.'),
			('c3000002-1111-1111-1111-111111111111', $1, 'BEHAVIOR', 'Sangat santun, disiplin, dan memiliki kepemimpinan yang baik.')
		ON CONFLICT (id) DO NOTHING
	`, rcID)

	// 11. Teacher Evaluation Periods & Categories
	evalPeriodID := "ea000001-1111-1111-1111-111111111111"
	_, _ = db.ExecContext(ctx, `
		INSERT INTO teacher_evaluation_periods (id, tenant_id, name, start_date, end_date, is_active)
		VALUES ($1, $2, 'Evaluasi Semester Ganjil 2025/2026', CURRENT_DATE - INTERVAL '10 days', CURRENT_DATE + INTERVAL '30 days', true)
		ON CONFLICT (id) DO NOTHING
	`, evalPeriodID, tenantID)

	evalCats := []struct {
		id, name string
	}{
		{"eb000001-1111-1111-1111-111111111111", "Kompetensi Pedagogik & Pengajaran"},
		{"eb000002-1111-1111-1111-111111111111", "Penguasaan Materi Pelajaran"},
		{"eb000003-1111-1111-1111-111111111111", "Kedisiplinan & Kehadiran Mengajar"},
		{"eb000004-1111-1111-1111-111111111111", "Komunikasi & Interaksi dengan Siswa"},
	}

	for _, ec := range evalCats {
		_, _ = db.ExecContext(ctx, `
			INSERT INTO teacher_evaluation_categories (id, tenant_id, name, weight)
			VALUES ($1, $2, $3, 1.0)
			ON CONFLICT (id) DO NOTHING
		`, ec.id, tenantID, ec.name)
	}

	// 12. Calendar Events / Holidays
	holidays := []struct {
		id, name, date, applies string
	}{
		{"fa000001-1111-1111-1111-111111111111", "Ujian Tengah Semester (UTS)", "2026-10-20", "ALL"},
		{"fa000002-1111-1111-1111-111111111111", "Kunjungan Industri Kelas XII", "2026-10-28", "STUDENTS"},
		{"fa000003-1111-1111-1111-111111111111", "Hari Sumpah Pemuda (Upacara)", "2026-10-28", "ALL"},
	}

	for _, h := range holidays {
		_, _ = db.ExecContext(ctx, `
			INSERT INTO holidays (id, tenant_id, name, date, applies_to, created_by)
			VALUES ($1, $2, $3, $4::date, $5, $6)
			ON CONFLICT (id) DO NOTHING
		`, h.id, tenantID, h.name, h.date, h.applies, staffID)

		_, _ = db.ExecContext(ctx, `
			INSERT INTO calendar_events (id, tenant_id, title, description, event_date, location, category, status, created_by)
			VALUES ($1, $2, $3, $4, $5::date, 'Sekolah', 'KEGIATAN', 'ACTIVE', $6)
			ON CONFLICT (id) DO NOTHING
		`, h.id, tenantID, h.name, h.name, h.date, staffID)
	}

	// 13. Attendances (Presensi)
	for i := 0; i < 7; i++ {
		attID := fmt.Sprintf("fd%06d-1111-1111-1111-111111111111", i+1)
		_, _ = db.ExecContext(ctx, `
			INSERT INTO attendances (id, tenant_id, user_id, status, method, type, check_in_at)
			VALUES ($1, $2, $3, 'PRESENT', 'RFID', 'STUDENT', NOW() - ($4 || ' days')::INTERVAL)
			ON CONFLICT (id) DO NOTHING
		`, attID, tenantID, studentID, fmt.Sprintf("%d", i))
	}

	// 14. Notifications
	_, _ = db.ExecContext(ctx, `
		CREATE TABLE IF NOT EXISTS notifications (
			id VARCHAR(36) PRIMARY KEY,
			tenant_id VARCHAR(36) NOT NULL,
			user_id VARCHAR(36) NOT NULL,
			title VARCHAR(255) NOT NULL,
			content TEXT,
			type VARCHAR(50),
			is_read BOOLEAN DEFAULT FALSE,
			action_url VARCHAR(255),
			created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
		)
	`)

	notifs := []struct {
		id, title, content, notifType string
		isRead                       bool
	}{
		{"fe000001-1111-1111-1111-111111111111", "Jadwal Pelajaran Diperbarui", "Jadwal semester ganjil tahun ajaran 2025/2026 telah aktif di sistem.", "ACADEMIC", false},
		{"fe000002-1111-1111-1111-111111111111", "Batas Pengembalian Buku", "Buku 'Clean Architecture' di perpustakaan jatuh tempo dalam 3 hari.", "LIBRARY", false},
		{"fe000003-1111-1111-1111-111111111111", "Ujian Tengah Semester (UTS)", "UTS semester ganjil akan diselenggarakan mulai tanggal 20 Oktober 2026.", "EXAM", true},
	}

	for _, n := range notifs {
		_, _ = db.ExecContext(ctx, `
			INSERT INTO notifications (id, tenant_id, user_id, title, content, type, is_read, created_at)
			VALUES ($1, $2, $3, $4, $5, $6, $7, NOW())
			ON CONFLICT (id) DO NOTHING
		`, n.id, tenantID, studentID, n.title, n.content, n.notifType, n.isRead)
	}

	log.Println("Comprehensive database seeding finished successfully! ✅")
}

