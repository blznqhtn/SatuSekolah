package controllers

import (
	"archive/zip"
	"context"
	"e-presence-backend/config"
	"e-presence-backend/models"
	"fmt"
	"os"
	"path/filepath"
	"strconv"
	"strings"
	"time"

	"github.com/gofiber/fiber/v2"
	"github.com/google/uuid"
	"github.com/xuri/excelize/v2"
	"gorm.io/gorm/clause"
)

type KelasInput struct {
	ID      string `json:"id"`
	Name    string `json:"name"`
	Jenjang string `json:"jenjang"`
}

type UpsertKelasRequest struct {
	Sekolah string       `json:"sekolah"`
	Kelas   []KelasInput `json:"kelas"`
}

func DownloadUserTemplate(c *fiber.Ctx) error {
	f := excelize.NewFile()
	defer f.Close()

	sheetName := "Template Members"
	f.SetSheetName("Sheet1", sheetName)

	headers := []string{
		"No Induk", "Nama", "Kelas", "Jenjang", "Alamat", "Nomor Telepon", "Nama File Foto",
	}

	for i, head := range headers {
		cell, _ := excelize.CoordinatesToCellName(i+1, 1)
		f.SetCellValue(sheetName, cell, head)
	}

	sample := []string{"123456789", "John Doe", "XII RPL 1", "XII", "Jl. Contoh No. 1", "081234567890", "john.jpg"}
	sample2 := []string{"987654321", "Jane Smith", "XI TKJ 2", "XI", "Jl. Contoh No. 2", "089876543210", "jane.jpg"}

	for i, val := range sample {
		cell, _ := excelize.CoordinatesToCellName(i+1, 2)
		f.SetCellValue(sheetName, cell, val)
	}
	for i, val := range sample2 {
		cell, _ := excelize.CoordinatesToCellName(i+1, 3)
		f.SetCellValue(sheetName, cell, val)
	}

	c.Set("Content-Type", "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet")
	c.Set("Content-Disposition", "attachment; filename=\"template-user.xlsx\"")

	if err := f.Write(c.Response().BodyWriter()); err != nil {
		return c.Status(500).JSON(fiber.Map{"status": "failed", "message": "Failed to generate template"})
	}

	return nil
}

func ImportUserExcel(c *fiber.Ctx) error {
	file, err := c.FormFile("excel_file")
	if err != nil {
		return c.Status(400).JSON(fiber.Map{"status": "failed", "message": "Excel file is required"})
	}

	zipFileHeader, errZip := c.FormFile("zip_file")

	if file.Size > 5*1024*1024 {
		return c.Status(400).JSON(fiber.Map{"status": "failed", "message": "File maksimal 5MB"})
	}

	currentUserID, err := uuid.Parse(c.Locals("uid").(string))
	if err != nil {
		return c.Status(400).JSON(fiber.Map{"status": "failed", "message": "Invalid user context"})
	}

	var currentUser models.User
	if err := config.DB.WithContext(c.Context()).Preload("SchoolMember").First(&currentUser, currentUserID).Error; err != nil {
		return c.Status(403).JSON(fiber.Map{"status": "failed", "message": "Sesi user tidak valid"})
	}

	if currentUser.SchoolMember == nil {
		return c.Status(403).JSON(fiber.Map{"status": "failed", "message": "User admin tidak terkait dengan sekolah manapun"})
	}

	schoolID := currentUser.SchoolMember.IDSekolah

	if errZip == nil {
		zipFile, _ := zipFileHeader.Open()
		defer zipFile.Close()

		reader, err := zip.NewReader(zipFile, zipFileHeader.Size)
		if err == nil {
			for _, f := range reader.File {
				if f.FileInfo().IsDir() || strings.HasPrefix(f.Name, ".") || strings.Contains(f.Name, "__MACOSX") {
					continue
				}

				rc, errOpen := f.Open()
				if errOpen != nil {
					continue
				}

				fileName := filepath.Base(f.Name)
				s3Key := fmt.Sprintf("%s/profile/%s", schoolID.String(), fileName)

				contentType := "image/jpeg"
				lowerName := strings.ToLower(fileName)
				if strings.HasSuffix(lowerName, ".png") {
					contentType = "image/png"
				}

				_, uploadErr := config.UploadToS3(rc, s3Key, contentType)
				if uploadErr != nil {
					fmt.Printf("Gagal upload foto %s: %v\n", fileName, uploadErr)
				}
				rc.Close()
			}
		}
	}

	tempPath := filepath.Join(os.TempDir(), fmt.Sprintf("import_%d.xlsx", time.Now().UnixNano()))
	if err := c.SaveFile(file, tempPath); err != nil {
		return c.Status(500).JSON(fiber.Map{"status": "failed", "message": "Failed save file"})
	}
	defer os.Remove(tempPath)

	f, err := excelize.OpenFile(tempPath)
	if err != nil {
		return c.Status(400).JSON(fiber.Map{"status": "failed", "message": "Invalid Excel"})
	}
	defer f.Close()

	rows, err := f.Rows(f.GetSheetList()[0])
	if err != nil {
		return c.Status(400).JSON(fiber.Map{"status": "failed", "message": "Gagal membaca sheet"})
	}

	kelasCache := make(map[string]uuid.UUID)
	var existingKelas []models.Kelas
	config.DB.WithContext(c.Context()).Where("id_sekolah = ?", schoolID).Find(&existingKelas)
	for _, k := range existingKelas {
		kelasCache[k.Name] = k.ID
	}

	tx := config.DB.WithContext(c.Context()).Begin()
	defer tx.Rollback()

	var successCount, failCount int
	isHeader := true

	for rows.Next() {
		row, _ := rows.Columns()

		if isHeader {
			isHeader = false
			continue
		}

		if len(row) < 3 {
			continue
		}

		noInduk := strings.TrimSpace(row[0])
		name := strings.TrimSpace(row[1])
		kelasName := strings.TrimSpace(row[2])

		if noInduk == "" || name == "" || kelasName == "" {
			failCount++
			continue
		}

		var jenjang string
		var alamatPtr, nomorPtr, fotoProfilePtr *string

		if len(row) > 3 && strings.TrimSpace(row[3]) != "" {
			jenjang = strings.TrimSpace(row[3])
		}

		if len(row) > 4 && strings.TrimSpace(row[4]) != "" {
			alamat := strings.TrimSpace(row[4])
			alamatPtr = &alamat
		}

		if len(row) > 5 && strings.TrimSpace(row[5]) != "" {
			nomor := strings.TrimSpace(row[5])
			nomorPtr = &nomor
		}

		if len(row) > 6 && strings.TrimSpace(row[6]) != "" {
			namaFile := strings.TrimSpace(row[6])
			urlFoto := fmt.Sprintf("%s/%s/profile/%s", config.S3BaseURL, schoolID.String(), namaFile)
			fotoProfilePtr = &urlFoto
		}

		kelasID, exists := kelasCache[kelasName]
		if !exists {
			newKelas := models.Kelas{
				Name:      kelasName,
				IDSekolah: schoolID,
				Jenjang:   jenjang,
			}
			if err := tx.Create(&newKelas).Error; err == nil {
				kelasID = newKelas.ID
				kelasCache[kelasName] = kelasID
			}
		}

		member := models.SchoolMember{
			NoInduk:     noInduk,
			Name:        name,
			IDKelas:     kelasID,
			IDSekolah:   schoolID,
			Alamat:      alamatPtr,
			Nomor:       nomorPtr,
			FotoProfile: fotoProfilePtr,
		}

		if err := tx.Where("no_induk = ? AND id_sekolah = ?", noInduk, schoolID).
			Assign(member).
			FirstOrCreate(&member).Error; err != nil {
			failCount++
		} else {
			successCount++
		}
	}

	tx.Commit()

	return c.JSON(fiber.Map{
		"status":  "success",
		"message": fmt.Sprintf("Import selesai: %d sukses, %d gagal", successCount, failCount),
	})
}

func ListMemberPhotos(c *fiber.Ctx) error {
	currentUserID := c.Locals("uid").(string)
	var sekolahID uuid.UUID

	if err := config.DB.WithContext(c.Context()).
		Table("users").
		Select("school_members.id_sekolah").
		Joins("JOIN school_members ON school_members.id = users.id_school_member").
		Where("users.id = ?", currentUserID).
		Scan(&sekolahID).Error; err != nil {
		return c.Status(500).JSON(fiber.Map{"status": "failed", "message": "Gagal mengambil data sekolah"})
	}

	var photos []string

	// Sangat hemat memori karena GORM hanya akan membuat Array of Strings,
	// bukan Array of Structs berukuran besar.
	if err := config.DB.WithContext(c.Context()).
		Model(&models.SchoolMember{}).
		Where("id_sekolah = ? AND foto_profile IS NOT NULL", sekolahID).
		Pluck("foto_profile", &photos).Error; err != nil {
		return c.Status(500).JSON(fiber.Map{"status": "failed", "message": "Gagal mengambil data foto"})
	}

	return c.JSON(fiber.Map{
		"status": "success",
		"data":   photos,
	})
}

func GetSchoolMembers(c *fiber.Ctx) error {
	search := c.Query("search")
	kelasIDStr := c.Query("kelas_id")
	methodType := c.Query("method")
	page, _ := strconv.Atoi(c.Query("page", "1"))
	perPage := 10

	uidLocals := c.Locals("uid")
	if uidLocals == nil {
		return c.Status(fiber.StatusUnauthorized).JSON(fiber.Map{
			"status":  "failed",
			"message": "Unauthorized: Sesi tidak valid atau telah berakhir",
		})
	}

	var schoolID uuid.UUID

	if schoolID == uuid.Nil {
		schoolIDStr, _ := getSchoolID(c)
		schoolID, _ = uuid.Parse(schoolIDStr)
	}

	if schoolID == uuid.Nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
			"status":  "failed",
			"message": "Gagal memverifikasi identitas sekolah pengguna",
		})
	}

	type MemberWithFaceStatus struct {
		models.SchoolMember
		HasFaceID bool `json:"has_face_id"`
	}

	var results []MemberWithFaceStatus
	var total int64

	q := config.DB.WithContext(c.Context()).
		Table("school_members").
		Select("school_members.*, "+
			"CASE WHEN fr.status = 'approved' THEN true ELSE false END as has_face_id")

	if methodType == "face_registration" {
		q = q.Joins("INNER JOIN users u ON u.id_school_member = school_members.id").
			Joins("LEFT JOIN face_registrations fr ON fr.id = u.face_id")
	} else {
		q = q.Joins("LEFT JOIN users u ON u.id_school_member = school_members.id").
			Joins("LEFT JOIN face_registrations fr ON fr.id = u.face_id")
	}

	q = q.Where("school_members.id_sekolah = ?", schoolID).
		Order("school_members.no_induk ASC")

	if search != "" {
		searchParam := "%" + search + "%"
		q = q.Where("(school_members.name ILIKE ? OR school_members.no_induk ILIKE ?)", searchParam, searchParam)
	}

	if kelasIDStr != "" && kelasIDStr != "all" {
		kelasID, _ := uuid.Parse(kelasIDStr)
		q = q.Where("school_members.id_kelas = ?", kelasID)
	}

	q.Count(&total)

	offset := (page - 1) * perPage
	err := q.Offset(offset).
		Limit(perPage).
		Preload("Kelas").
		Preload("Sekolah").
		Find(&results).Error

	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
			"status":  "failed",
			"message": "Gagal mengambil data anggota sekolah",
		})
	}

	return c.JSON(fiber.Map{
		"status": "success",
		"data": fiber.Map{
			"members":  results,
			"total":    total,
			"page":     page,
			"per_page": perPage,
		},
	})
}

func GetMemberById(c *fiber.Ctx) error {
	id := c.Params("id")
	var schoolMember models.SchoolMember

	if err := config.DB.WithContext(c.Context()).Preload("Kelas").Where("id = ?", id).First(&schoolMember).Error; err != nil {
		return c.Status(fiber.StatusNotFound).JSON(fiber.Map{
			"status":  "failed",
			"message": "Member tidak ditemukan",
		})
	}

	return c.JSON(fiber.Map{
		"status": "success",
		"data":   schoolMember,
	})
}

func CreateSchoolMember(c *fiber.Ctx) error {
	noInduk := c.FormValue("no_induk")
	name := c.FormValue("name")
	kelasIDStr := c.FormValue("id_kelas")
	sekolahIDStr := c.FormValue("sekolah")
	alamat := strings.TrimSpace(c.FormValue("alamat"))
	schoolID, errAuth := getSchoolID(c)

	if errAuth != nil {
		return c.Status(fiber.StatusUnauthorized).JSON(fiber.Map{
			"status":  "failed",
			"message": "Sesi tidak valid",
		})
	}

	if noInduk == "" || name == "" || kelasIDStr == "" || sekolahIDStr == "" {
		return c.Status(fiber.StatusUnprocessableEntity).JSON(fiber.Map{
			"status":  "failed",
			"message": "No Induk, Nama, Kelas, dan Sekolah tidak boleh kosong",
		})
	}

	idKelas, err := uuid.Parse(kelasIDStr)
	if err != nil {
		return c.Status(400).JSON(fiber.Map{"status": "failed", "message": "Format ID Kelas tidak valid"})
	}

	idSekolah, err := uuid.Parse(sekolahIDStr)
	if err != nil {
		return c.Status(400).JSON(fiber.Map{"status": "failed", "message": "Format ID Sekolah tidak valid"})
	}

	var alamatPtr *string
	if alamat != "" {
		alamatPtr = &alamat
	}

	tx := config.DB.WithContext(c.Context()).Begin()

	var kelas models.Kelas
	if err := tx.Where("id = ? AND id_sekolah = ?", idKelas, idSekolah).First(&kelas).Error; err != nil {
		tx.Rollback()
		return c.Status(400).JSON(fiber.Map{"status": "failed", "message": "Kelas tidak valid"})
	}

	var fotoProfile *string
	var s3KeyToDelete string
	var isNewUpload bool

	fileHeader, err := c.FormFile("photo")

	if err == nil {
		if fileHeader.Size > 2*1024*1024 {
			tx.Rollback()
			return c.Status(400).JSON(fiber.Map{"status": "failed", "message": "Max 2MB"})
		}

		ext := strings.ToLower(filepath.Ext(fileHeader.Filename))
		if ext != ".jpg" && ext != ".jpeg" && ext != ".png" {
			tx.Rollback()
			return c.Status(400).JSON(fiber.Map{"status": "failed", "message": "Format harus jpg/png"})
		}

		file, _ := fileHeader.Open()
		defer file.Close()

		key := "profile/" + uuid.New().String() + ext

		url, err := config.UploadToS3(file, key, fileHeader.Header.Get("Content-Type"))
		if err != nil {
			tx.Rollback()
			return c.Status(500).JSON(fiber.Map{"status": "failed", "message": "Upload gagal"})
		}

		fotoProfile = &url
		s3KeyToDelete = key
		isNewUpload = true
	} else {
		existingPhoto := c.FormValue("existing_photo")
		if existingPhoto != "" {
			newUrl := fmt.Sprintf("%s/%s/profile/%s", config.S3BaseURL, schoolID, existingPhoto)
			fotoProfile = &newUrl
		}
	}

	member := models.SchoolMember{
		NoInduk:     noInduk,
		Name:        name,
		IDKelas:     idKelas,
		IDSekolah:   idSekolah,
		Alamat:      alamatPtr,
		FotoProfile: fotoProfile,
	}

	if err := tx.Create(&member).Error; err != nil {
		tx.Rollback()
		if isNewUpload && s3KeyToDelete != "" {
			_ = config.DeleteFromS3(s3KeyToDelete)
		}
		return c.Status(400).JSON(fiber.Map{"status": "failed", "message": "Nomor Induk sudah digunakan atau terjadi kesalahan sistem"})
	}

	if fotoProfile != nil {
		ctx := context.Background()
		iter := config.RDB.Scan(ctx, 0, fmt.Sprintf("s3:photos:profile:%s:*", idSekolah.String()), 0).Iterator()
		for iter.Next(ctx) {
			config.RDB.Del(ctx, iter.Val())
		}
	}

	tx.Commit()

	return c.JSON(fiber.Map{
		"status":  "success",
		"message": "Member sekolah berhasil ditambahkan",
		"data":    member,
	})
}

func UpdateSchoolMember(c *fiber.Ctx) error {
	schoolID, errAuth := getSchoolID(c)
	if errAuth != nil {
		return c.Status(fiber.StatusUnauthorized).JSON(fiber.Map{
			"status":  "failed",
			"message": "Sesi tidak valid",
		})
	}

	idStr := c.Params("id")
	id, err := uuid.Parse(idStr)
	if err != nil {
		return c.Status(400).JSON(fiber.Map{
			"status":  "failed",
			"message": "Format ID tidak valid",
		})
	}

	tx := config.DB.WithContext(c.Context()).Begin()
	defer tx.Rollback()

	var member models.SchoolMember
	if err := tx.Clauses(clause.Locking{Strength: "UPDATE"}).
		Where("id = ? AND id_sekolah = ?", id, schoolID).
		First(&member).Error; err != nil {
		return c.Status(404).JSON(fiber.Map{
			"status":  "failed",
			"message": "Data tidak ditemukan atau akses ditolak",
		})
	}

	name := c.FormValue("name")
	kelasIDStr := c.FormValue("id_kelas")
	alamat := strings.TrimSpace(c.FormValue("alamat"))
	newNoInduk := c.FormValue("no_induk")

	if name != "" {
		member.Name = name
	}

	if newNoInduk != "" {
		member.NoInduk = newNoInduk
	}

	if kelasIDStr != "" {
		idKelas, err := uuid.Parse(kelasIDStr)
		if err != nil {
			return c.Status(400).JSON(fiber.Map{
				"status":  "failed",
				"message": "Format ID kelas tidak valid",
			})
		}

		var kelas models.Kelas
		if err := tx.Where("id = ? AND id_sekolah = ?", idKelas, schoolID).First(&kelas).Error; err != nil {
			return c.Status(400).JSON(fiber.Map{
				"status":  "failed",
				"message": "Kelas tidak valid untuk sekolah ini",
			})
		}
		member.IDKelas = idKelas
	}

	if alamat == "" {
		member.Alamat = nil
	} else {
		member.Alamat = &alamat
	}

	fileHeader, err := c.FormFile("photo")
	if err == nil {
		if fileHeader.Size > 2*1024*1024 {
			return c.Status(400).JSON(fiber.Map{
				"status":  "failed",
				"message": "Ukuran foto maksimal 2MB",
			})
		}

		ext := strings.ToLower(filepath.Ext(fileHeader.Filename))
		if ext != ".jpg" && ext != ".jpeg" && ext != ".png" {
			return c.Status(400).JSON(fiber.Map{
				"status":  "failed",
				"message": "Format foto harus jpg, jpeg, atau png",
			})
		}

		file, _ := fileHeader.Open()
		defer file.Close()

		newKey := fmt.Sprintf("%s/profile/%s%s", schoolID, uuid.New().String(), ext)

		url, err := config.UploadToS3(file, newKey, fileHeader.Header.Get("Content-Type"))
		if err != nil {
			return c.Status(500).JSON(fiber.Map{
				"status":  "failed",
				"message": "Gagal mengunggah foto ke storage",
			})
		}

		member.FotoProfile = &url

		ctx := context.Background()
		iter := config.RDB.Scan(ctx, 0, fmt.Sprintf("s3:photos:profile:%s:*", schoolID), 0).Iterator()
		for iter.Next(ctx) {
			config.RDB.Del(ctx, iter.Val())
		}
	} else {
		existingPhoto := c.FormValue("existing_photo")
		fmt.Println("DEBUG: existing_photo received =", existingPhoto)

		if existingPhoto != "" {
			// Cek jika yang dikirim adalah nama file (bukan URL lengkap)
			if !strings.HasPrefix(existingPhoto, "http") {
				// Gunakan url.PathEscape jika nama file mengandung spasi
				newUrl := fmt.Sprintf("%s/%s/profile/%s", config.S3BaseURL, schoolID, existingPhoto)
				member.FotoProfile = &newUrl
			} else {
				// Jika dikirim URL lengkap, pastikan URL-nya bersih
				member.FotoProfile = &existingPhoto
			}
		}
	}

	if err := tx.Save(&member).Error; err != nil {
		return c.Status(400).JSON(fiber.Map{
			"status":  "failed",
			"message": "Gagal menyimpan perubahan. Nomor Induk mungkin sudah digunakan.",
		})
	}

	if err := tx.Commit().Error; err != nil {
		return c.Status(500).JSON(fiber.Map{
			"status":  "failed",
			"message": "Terjadi kesalahan saat finalisasi data",
		})
	}

	return c.JSON(fiber.Map{
		"status":  "success",
		"message": "Data member berhasil diperbarui",
		"data":    member,
	})
}

func DeleteSchoolMember(c *fiber.Ctx) error {
	schoolID, errAuth := getSchoolID(c)
	if errAuth != nil {
		return c.Status(fiber.StatusUnauthorized).JSON(fiber.Map{"status": "failed", "message": "Sesi tidak valid"})
	}

	idStr := c.Params("id")
	id, err := uuid.Parse(idStr)
	if err != nil {
		return c.Status(400).JSON(fiber.Map{"status": "failed", "message": "Format ID tidak valid"})
	}

	tx := config.DB.WithContext(c.Context()).Begin()

	var member models.SchoolMember
	if err := tx.Where("id = ? AND id_sekolah = ?", id, schoolID).First(&member).Error; err != nil {
		tx.Rollback()
		return c.Status(404).JSON(fiber.Map{"status": "failed", "message": "Data tidak ditemukan atau akses ditolak"})
	}

	if err := tx.Delete(&member).Error; err != nil {
		tx.Rollback()
		return c.Status(500).JSON(fiber.Map{"status": "failed", "message": "Gagal menghapus data member sekolah"})
	}

	tx.Commit()

	return c.JSON(fiber.Map{
		"status":  "success",
		"message": "Member sekolah berhasil dihapus",
	})
}

func DeleteMultipleMembers(c *fiber.Ctx) error {
	schoolID, errAuth := getSchoolID(c)
	if errAuth != nil {
		return c.Status(fiber.StatusUnauthorized).JSON(fiber.Map{"status": "failed", "message": "Sesi tidak valid"})
	}

	var req struct {
		IDs []string `json:"ids"`
	}
	if err := c.BodyParser(&req); err != nil || len(req.IDs) == 0 {
		return c.Status(400).JSON(fiber.Map{"status": "failed", "message": "Format request tidak valid atau ID kosong"})
	}

	tx := config.DB.WithContext(c.Context()).Begin()
	defer tx.Rollback()

	var members []models.SchoolMember
	if err := tx.Where("id_sekolah = ? AND id IN ?", schoolID, req.IDs).Find(&members).Error; err != nil {
		return c.Status(500).JSON(fiber.Map{"status": "failed", "message": "Gagal mencari data member"})
	}

	if err := tx.Where("id_sekolah = ? AND id IN ?", schoolID, req.IDs).Delete(&models.SchoolMember{}).Error; err != nil {
		return c.Status(500).JSON(fiber.Map{"status": "failed", "message": "Gagal menghapus data member"})
	}

	tx.Commit()

	return c.JSON(fiber.Map{
		"status":  "success",
		"message": fmt.Sprintf("%d data member berhasil dihapus", len(members)),
	})
}

func UpsertKelas(c *fiber.Ctx) error {
	schoolID, errAuth := getSchoolID(c)
	if errAuth != nil {
		return c.Status(fiber.StatusUnauthorized).JSON(fiber.Map{"status": "failed", "message": "Sesi tidak valid"})
	}

	schoolUUID, err := uuid.Parse(schoolID)
	if err != nil {
		return c.Status(400).JSON(fiber.Map{"status": "failed", "message": "Format ID sekolah tidak valid"})
	}

	var req UpsertKelasRequest
	if err := c.BodyParser(&req); err != nil {
		return c.Status(400).JSON(fiber.Map{"status": "failed", "message": "Invalid request"})
	}

	if req.Sekolah != schoolID && schoolID != "global_school" {
		return c.Status(403).JSON(fiber.Map{"status": "failed", "message": "Akses ditolak"})
	}

	tx := config.DB.Begin()

	var receivedIDs []string

	for _, k := range req.Kelas {
		name := strings.TrimSpace(k.Name)
		jenjang := strings.TrimSpace(k.Jenjang)

		if name == "" || jenjang == "" {
			continue
		}

		if k.ID != "" {
			receivedIDs = append(receivedIDs, k.ID)

			var existing models.Kelas
			if err := tx.Where("id = ? AND id_sekolah = ?", k.ID, schoolUUID).First(&existing).Error; err == nil {
				existing.Name = name
				existing.Jenjang = jenjang
				tx.Save(&existing)
			}
		} else {
			newKelas := models.Kelas{
				IDSekolah: schoolUUID,
				Name:      name,
				Jenjang:   jenjang,
			}

			tx.Create(&newKelas)

			receivedIDs = append(receivedIDs, newKelas.ID.String())
		}
	}

	if len(receivedIDs) > 0 {
		tx.Where("id_sekolah = ? AND id NOT IN ?", schoolID, receivedIDs).Delete(&models.Kelas{})
	} else {
		tx.Where("id_sekolah = ?", schoolID).Delete(&models.Kelas{})
	}

	tx.Commit()

	return c.JSON(fiber.Map{
		"status":  "success",
		"message": "Data kelas berhasil disinkronisasi",
	})
}
