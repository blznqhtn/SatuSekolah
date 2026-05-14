package controllers

import (
	"bytes"
	"context"
	"e-presence-backend/config"
	"e-presence-backend/models"
	"encoding/base64"
	"fmt"
	"strconv"
	"strings"
	"time"

	"github.com/aws/aws-sdk-go-v2/aws"
	"github.com/aws/aws-sdk-go-v2/service/rekognition"
	"github.com/aws/aws-sdk-go-v2/service/rekognition/types"
	"github.com/aws/aws-sdk-go-v2/service/s3"
	"github.com/gofiber/fiber/v2"
	"github.com/google/uuid"
	"gorm.io/gorm/clause"
)

func decodeImage(b64 string) ([]byte, error) {
	if i := strings.Index(b64, ","); i != -1 {
		b64 = b64[i+1:]
	}
	return base64.StdEncoding.DecodeString(b64)
}

func RegisterFace(c *fiber.Ctx) error {
	type Request struct {
		IDUser     	uuid.UUID `json:"id_user"`
		FaceImages 	[]string  `json:"face_images"`
	}

	schoolID, errorSchool := getSchoolID(c)
	if errorSchool != nil {
		return c.Status(401).JSON(fiber.Map{"success": false, "message": "Sesi tidak valid"})
	}

	req := new(Request)
	if err := c.BodyParser(req); err != nil {
		return c.Status(400).JSON(fiber.Map{"success": false, "message": "Invalid request format"})
	}

	if len(req.FaceImages) == 0 {
		return c.Status(400).JSON(fiber.Map{"success": false, "message": "Tidak ada gambar yang dikirim"})
	}

	var bestImgBytes []byte
	var rekognitionOut *rekognition.IndexFacesOutput
	isFaceValid := false
	var lastAwsError string // Menyimpan error asli dari AWS

	// Cek maksimal 4 foto
	for i, b64Data := range req.FaceImages {
		imgBytes, err := decodeImage(b64Data)
		if err != nil {
			fmt.Printf("[DEBUG] Gagal decode base64 foto ke-%d: %v\n", i+1, err)
			continue
		}

		out, err := config.RekognitionClient.IndexFaces(context.TODO(), &rekognition.IndexFacesInput{
			CollectionId:    aws.String(config.RekognitionCollectionID),
			Image:           &types.Image{Bytes: imgBytes},
			ExternalImageId: aws.String(req.IDUser.String()),
			MaxFaces:        aws.Int32(1),
			QualityFilter:   types.QualityFilterAuto,
		})

		// Jika terjadi error dari server AWS
		if err != nil {
			fmt.Printf("[AWS ERROR] IndexFaces gagal pada foto ke-%d: %v\n", i+1, err)
			lastAwsError = err.Error()
			continue
		}

		// Jika AWS sukses merespons, tapi tidak mendeteksi wajah satupun
		if len(out.FaceRecords) == 0 {
			fmt.Printf("[AWS INFO] API sukses, tapi tidak ada wajah terdeteksi pada foto ke-%d\n", i+1)
			continue
		}

		// Jika berhasil lolos semua kriteria
		bestImgBytes = imgBytes
		rekognitionOut = out
		isFaceValid = true
		break
	}

	// Tampilkan error yang sesungguhnya jika gagal
	if !isFaceValid {
		errMsg := "Dari 4 percobaan, wajah tidak memenuhi standar AI."
		if lastAwsError != "" {
			errMsg = "AWS Error: " + lastAwsError // Mengembalikan error spesifik AWS ke frontend
		}
		return c.Status(400).JSON(fiber.Map{"success": false, "message": errMsg})
	}

	timestamp := time.Now().Format("20060102150405")
	fileName := fmt.Sprintf("%v/faces/%s_%s.jpg", schoolID, req.IDUser.String(), timestamp)

	_, err := config.S3Client.PutObject(context.TODO(), &s3.PutObjectInput{
		Bucket:      aws.String(config.S3Bucket),
		Key:         aws.String(fileName),
		Body:        bytes.NewReader(bestImgBytes),
		ContentType: aws.String("image/jpeg"),
	})

	if err != nil {
		fmt.Printf("[S3 ERROR] Gagal upload: %v\n", err)
		awsFaceID := *rekognitionOut.FaceRecords[0].Face.FaceId
		_, _ = config.RekognitionClient.DeleteFaces(context.TODO(), &rekognition.DeleteFacesInput{
			CollectionId: aws.String(config.RekognitionCollectionID),
			FaceIds:      []string{awsFaceID},
		})
		return c.Status(500).JSON(fiber.Map{"success": false, "message": "Gagal upload foto ke S3"})
	}

	faceUrl := config.S3BaseURL + "/" + fileName
	awsFaceID := *rekognitionOut.FaceRecords[0].Face.FaceId
	confidenceScore := float64(*rekognitionOut.FaceRecords[0].Face.Confidence)

	tx := config.DB.Begin()
	defer tx.Rollback()

	faceReg := models.FaceRegistration{
		FaceUrl:         faceUrl,
		AwsFaceID:       awsFaceID,
		Status:          "approved",
		ConfidenceScore: aws.Float64(confidenceScore),
	}

	if err := tx.Create(&faceReg).Error; err != nil {
		fmt.Printf("[DB ERROR] Gagal insert FaceRegistration: %v\n", err)
		return c.Status(500).JSON(fiber.Map{"success": false, "message": "Gagal menyimpan data ke database"})
	}

	if err := tx.Model(&models.User{}).Where("id_school_member = ?", req.IDUser).Update("face_id", faceReg.ID).Error; err != nil {
		fmt.Printf("[DB ERROR] Gagal update User face_id: %v\n", err)
		return c.Status(500).JSON(fiber.Map{"success": false, "message": "Gagal menghubungkan wajah ke user"})
	}

	tx.Commit()

	return c.JSON(fiber.Map{
		"success": true,
		"message": "Registrasi Face ID berhasil",
		"data": fiber.Map{
			"face_url": faceUrl,
		},
	})
}

func AuthenticateFace(c *fiber.Ctx) error {
	type Request struct {
		FaceData string `json:"face_data"`
	}

	req := new(Request)
	if err := c.BodyParser(req); err != nil {
		return c.Status(400).JSON(fiber.Map{"success": false, "message": "Invalid request"})
	}

	if req.FaceData == "" {
		return c.Status(400).JSON(fiber.Map{"success": false, "message": "Gambar tidak boleh kosong"})
	}

	imgBytes, err := decodeImage(req.FaceData)
	if err != nil {
		return c.Status(400).JSON(fiber.Map{"success": false, "message": "Gambar tidak valid"})
	}

	searchOut, err := config.RekognitionClient.SearchFacesByImage(context.TODO(), &rekognition.SearchFacesByImageInput{
		CollectionId:       aws.String(config.RekognitionCollectionID),
		Image:              &types.Image{Bytes: imgBytes},
		MaxFaces:           aws.Int32(1),
		FaceMatchThreshold: aws.Float32(90.0),
	})

	if err != nil || len(searchOut.FaceMatches) == 0 {
		return c.Status(401).JSON(fiber.Map{"success": false, "message": "Wajah tidak dikenali"})
	}

	matchedUserID := *searchOut.FaceMatches[0].Face.ExternalImageId

	var user models.User
	if err := config.DB.Where("id = ?", matchedUserID).First(&user).Error; err != nil {
		return c.Status(404).JSON(fiber.Map{"success": false, "message": "User tidak ditemukan"})
	}

	if user.StatusBan != "active" {
		return c.Status(fiber.StatusForbidden).JSON(fiber.Map{
			"success": false,
			"message": "Akun Anda telah dibekukan, silahkan hubungi admin",
		})
	}

	sessionID := generateRandomString(32)

	accessToken, err := generateAccessToken(user, sessionID)
	if err != nil {
		return c.Status(500).JSON(fiber.Map{
			"success": false,
			"message": "Gagal generate access token",
		})
	}

	refreshToken, hashed := generateRefreshToken()

	if config.RDB != nil {
		key := "session:" + sessionID

		config.RDB.HSet(config.Ctx, key, map[string]interface{}{
			"token":   hashed,
			"user_id": user.ID.String(),
			"ip":      c.IP(),
			"agent":   c.Get("User-Agent"),
		})
		config.RDB.Expire(config.Ctx, key, 7*24*time.Hour)
	}

	return c.JSON(fiber.Map{
		"success":       true,
		"message":       "Autentikasi wajah berhasil",
		"access_token":  accessToken,
		"refresh_token": refreshToken,
		"session_id":    sessionID,
		"uid":           user.ID,
		"role":          user.Role,
	})
}

func FaceAttendance(c *fiber.Ctx) error {
	type Request struct {
		FaceData string `json:"face_data"`
		SchoolID string `json:"id_sekolah"`
		Mode     string `json:"mode"`
	}

	req := new(Request)
	if err := c.BodyParser(req); err != nil {
		return c.Status(400).JSON(fiber.Map{"status": "failed", "message": "Invalid request"})
	}

	if req.FaceData == "" {
		return c.Status(400).JSON(fiber.Map{"status": "failed", "message": "Gambar tidak boleh kosong"})
	}

	imgBytes, err := decodeImage(req.FaceData)
	if err != nil {
		return c.Status(400).JSON(fiber.Map{"status": "failed", "message": "Gambar tidak valid"})
	}

	searchOut, err := config.RekognitionClient.SearchFacesByImage(context.TODO(), &rekognition.SearchFacesByImageInput{
		CollectionId:       aws.String(config.RekognitionCollectionID),
		Image:              &types.Image{Bytes: imgBytes},
		MaxFaces:           aws.Int32(1),
		FaceMatchThreshold: aws.Float32(90.0),
	})

	if err != nil || len(searchOut.FaceMatches) == 0 {
		return c.Status(401).JSON(fiber.Map{"status": "failed", "message": "Wajah tidak dikenali"})
	}

	matchedUserID := *searchOut.FaceMatches[0].Face.ExternalImageId

	tx := config.DB.Begin()
	defer func() {
		if r := recover(); r != nil {
			tx.Rollback()
		}
	}()

	// Load user beserta data school member (sama seperti Presensi)
	var user models.User
	if err := tx.Clauses(clause.Locking{Strength: "UPDATE"}).
		Preload("SchoolMember.Kelas").
		Where("id_school_member = ?", matchedUserID).
		First(&user).Error; err != nil {
		tx.Rollback()
		return c.Status(404).JSON(fiber.Map{"status": "failed", "message": "User tidak ditemukan"})
	}

	profileUrl := "/images/default.jpg"
	if user.SchoolMember != nil && user.SchoolMember.FotoProfile != nil && *user.SchoolMember.FotoProfile != "" {
		profileUrl = *user.SchoolMember.FotoProfile
	}

	if user.Role != "user" {
		tx.Rollback()
		return c.Status(200).JSON(fiber.Map{
			"status":  "success",
			"message": "Tes Scan Berhasil (" + user.Role + ")",
			"data":    user,
			"profile": profileUrl,
		})
	}

	if user.SchoolMember == nil {
		tx.Rollback()
		return c.Status(400).JSON(fiber.Map{"status": "failed", "message": "Data siswa tidak lengkap / tidak terhubung ke sekolah."})
	}

	// Timezone
	loc, errTZ := time.LoadLocation("Asia/Jakarta")
	if errTZ != nil {
		loc = time.UTC
	}
	now := time.Now().In(loc)
	todayFullDate := now.Format("2006-01-02")
	mode := strings.ToLower(req.Mode)

	// Load kalender akademik
	var hari models.Hari
	errHari := tx.Where("id_sekolah = ? AND bulan = ? AND tahun = ?",
		req.SchoolID, int(now.Month()), now.Year()).First(&hari).Error
	if errHari != nil {
		hari = models.Hari{
			HariProduktif: []string{},
			HariTambahan:  []string{},
			HariLibur:     []string{},
		}
	}

	// Load sekolah untuk baseURL
	var sekolah models.Sekolah
	baseURL := getEnv("BASE_URL", "")
	if err := tx.Where("id = ?", req.SchoolID).First(&sekolah).Error; err == nil {
		if sekolah.Website != nil && *sekolah.Website != "" {
			baseURL = strings.TrimSuffix(*sekolah.Website, "/")
		}
	}

	token := uuid.New().String()

	containsDate := func(slice []string, target string) bool {
		for _, d := range slice {
			if d == target {
				return true
			}
		}
		return false
	}

	// Cek hari libur
	if containsDate(hari.HariLibur, todayFullDate) {
		tx.Commit()
		return c.Status(200).JSON(fiber.Map{
			"status":  "libur",
			"message": "Hari ini adalah hari libur sekolah.",
			"data":    user,
			"profile": profileUrl,
		})
	}

	isProductive := containsDate(hari.HariProduktif, todayFullDate)
	isAdditional := containsDate(hari.HariTambahan, todayFullDate)
	if !isProductive && !isAdditional {
		isProductive = true
	}

	// Cek presensi hari ini
	var presence models.Presence
	errPresence := tx.Clauses(clause.Locking{Strength: "UPDATE"}).
		Where("id_user = ? AND DATE(time_masuk) = ?", user.ID, todayFullDate).
		First(&presence).Error

	if mode == "masuk" {
		if errPresence == nil {
			tx.Rollback()
			return c.Status(200).JSON(fiber.Map{
				"status":  "failed",
				"message": "Sudah melakukan presensi masuk hari ini.",
				"data":    user,
				"profile": profileUrl,
			})
		}

		// ===== PRESENSI MASUK =====
		if isProductive {
			batasJam, _ := strconv.Atoi(strings.TrimSpace(getEnv("JAM_MASUK_BATAS_JAM", "01")))
			batasMenit, _ := strconv.Atoi(strings.TrimSpace(getEnv("JAM_MASUK_BATAS_MENIT", "00")))
			batasTerlambat := time.Date(now.Year(), now.Month(), now.Day(),
				batasJam, batasMenit, 0, 0, now.Location())

			if now.After(batasTerlambat) {
				// TERLAMBAT
				late := models.LateEntry{IDUser: user.ID, Time: now, Type: "Presensi Masuk", Token: token}
				if err := tx.Create(&late).Error; err != nil {
					tx.Rollback()
					return c.Status(500).JSON(fiber.Map{"status": "failed", "message": "Gagal mencatat keterlambatan."})
				}
				tx.Commit()
				return c.Status(200).JSON(fiber.Map{
					"status":       "late",
					"message":      "Anda terlambat, silakan isi alasan pada QR Code berikut.",
					"redirect_url": fmt.Sprintf("%s/forms/late/arrival?token=%s", baseURL, token),
					"data":         user,
					"profile":      profileUrl,
				})
			}

			// TEPAT WAKTU
			newPresence := models.Presence{
				IDUser:     user.ID,
				TimeMasuk:  now,
				Status:     "Hadir",
				StatusHari: "Hari Produktif",
			}
			if err := tx.Create(&newPresence).Error; err != nil {
				tx.Rollback()
				return c.Status(500).JSON(fiber.Map{"status": "failed", "message": "Gagal menyimpan presensi."})
			}
			tx.Commit()
			go finalizePresensiEffects(user.ID.String())
			return c.Status(200).JSON(fiber.Map{
				"status":  "success",
				"message": "Presensi masuk berhasil. Selamat belajar!",
				"data":    user,
				"profile": profileUrl,
			})

		} else if isAdditional {
			late := models.LateEntry{IDUser: user.ID, Time: now, Type: "Presensi Masuk", Token: token}
			if err := tx.Create(&late).Error; err != nil {
				tx.Rollback()
				return c.Status(500).JSON(fiber.Map{"status": "failed", "message": "Gagal mencatat entri."})
			}
			tx.Commit()
			return c.Status(200).JSON(fiber.Map{
				"status":       "non_productive",
				"message":      "Kegiatan tambahan terdeteksi, silakan isi form.",
				"redirect_url": fmt.Sprintf("%s/forms/special/attendance?token=%s", baseURL, token),
				"data":         user,
				"profile":      profileUrl,
			})
		}
	} else if mode == "keluar" {
		if errPresence != nil {
			tx.Rollback()
			return c.Status(200).JSON(fiber.Map{
				"status":  "failed",
				"message": "Anda belum melakukan presensi masuk hari ini.",
				"data":    user,
				"profile": profileUrl,
			})
		}

		if presence.TimeKeluar != nil {
			tx.Rollback()
			return c.Status(200).JSON(fiber.Map{
				"status":  "failed",
				"message": "Sudah melakukan presensi keluar hari ini.",
				"data":    user,
				"profile": profileUrl,
			})
		}

		// ===== PRESENSI KELUAR =====
		if isProductive {
			maxJam, _ := strconv.Atoi(strings.TrimSpace(getEnv("JAM_PULANG_MAX_JAM", "16")))
			maxMenit, _ := strconv.Atoi(strings.TrimSpace(getEnv("JAM_PULANG_MAX_MENIT", "30")))
			realJam, _ := strconv.Atoi(strings.TrimSpace(getEnv("JAM_PULANG_REAL_JAM", "15")))
			realMenit, _ := strconv.Atoi(strings.TrimSpace(getEnv("JAM_PULANG_REAL_MENIT", "30")))

			jamPulangMax := time.Date(now.Year(), now.Month(), now.Day(), maxJam, maxMenit, 0, 0, now.Location())
			jamPulangCepat := time.Date(now.Year(), now.Month(), now.Day(), realJam, realMenit, 0, 0, now.Location())

			if now.After(jamPulangMax) {
				late := models.LateEntry{IDUser: user.ID, Time: now, Type: "Presensi Keluar", Token: token}
				tx.Create(&late)
				tx.Commit()
				return c.Status(200).JSON(fiber.Map{
					"status":       "late",
					"redirect_url": fmt.Sprintf("%s/forms/late/departure?token=%s", baseURL, token),
					"message":      "Waktu operasional berakhir, silakan isi alasan pulang terlambat.",
					"data":         user,
					"profile":      profileUrl,
				})
			} else if now.Before(jamPulangCepat) {
				late := models.LateEntry{IDUser: user.ID, Time: now, Type: "Presensi Keluar", Token: token}
				tx.Create(&late)
				tx.Commit()
				return c.Status(200).JSON(fiber.Map{
					"status":       "early",
					"redirect_url": fmt.Sprintf("%s/forms/early/departure?token=%s", baseURL, token),
					"message":      "Belum jam pulang, silakan isi alasan pulang awal.",
					"data":         user,
					"profile":      profileUrl,
				})
			}

			statusKeluar := "Tepat Waktu"
			updateData := models.Presence{
				TimeKeluar:   &now,
				StatusKeluar: &statusKeluar,
				StatusHari:   "Hari Produktif",
			}
			if err := tx.Model(&presence).Updates(updateData).Error; err != nil {
				tx.Rollback()
				return c.Status(500).JSON(fiber.Map{"status": "failed", "message": "Gagal update absen keluar."})
			}
			tx.Commit()
			go finalizePresensiEffects(user.ID.String())
			return c.Status(200).JSON(fiber.Map{
				"status":  "success",
				"message": "Presensi keluar berhasil. Hati-hati di jalan!",
				"data":    user,
				"profile": profileUrl,
			})

		} else if isAdditional {
			statusKeluar := "Tepat Waktu"
			updateData := models.Presence{
				TimeKeluar:   &now,
				StatusKeluar: &statusKeluar,
				StatusHari:   "Hari Non-Produktif",
			}
			tx.Model(&presence).Updates(updateData)
			tx.Commit()
			go finalizePresensiEffects(user.ID.String())
			return c.Status(200).JSON(fiber.Map{
				"status":  "success",
				"message": "Absensi pulang kegiatan tambahan berhasil.",
				"data":    user,
				"profile": profileUrl,
			})
		}
	}

	tx.Rollback()
	return c.Status(400).JSON(fiber.Map{"status": "failed", "message": "Gagal memproses presensi."})
}

func CheckFaceRegistration(c *fiber.Ctx) error {
	userID := c.Params("user_id")
	var user models.User
	
	if err := config.DB.Select("face_id").Where("id = ?", userID).First(&user).Error; err != nil {
		return c.Status(404).JSON(fiber.Map{"success": false, "message": "User tidak ditemukan"})
	}

	hasRegistration := user.FaceID != nil

	return c.JSON(fiber.Map{
		"has_registration": hasRegistration,
		"status":           "approved",
	})
}

func ResetFace(c *fiber.Ctx) error {
	nomorInduk := c.Params("nomor_induk")
	schoolIDStr, errorSchool := getSchoolID(c)
	if errorSchool != nil {
		return c.Status(401).JSON(fiber.Map{"success": false, "message": "Sesi tidak valid"})
	}

	tx := config.DB.Begin()
	defer tx.Rollback()

	var member models.SchoolMember
	if err := tx.Where("no_induk = ? AND id_sekolah = ?", nomorInduk, schoolIDStr).First(&member).Error; err != nil {
		return c.Status(404).JSON(fiber.Map{"success": false, "message": "Data siswa tidak ditemukan"})
	}

	var user models.User
	if err := tx.Where("id_school_member = ?", member.ID).First(&user).Error; err != nil {
		return c.Status(404).JSON(fiber.Map{"success": false, "message": "Akun pengguna tidak ditemukan"})
	}

	if user.FaceID == nil {
		return c.Status(400).JSON(fiber.Map{"success": false, "message": "Siswa ini belum memiliki Face ID"})
	}

	var faceReg models.FaceRegistration
	if err := tx.Where("id = ?", user.FaceID).First(&faceReg).Error; err != nil {
		return c.Status(404).JSON(fiber.Map{"success": false, "message": "Data registrasi wajah tidak ditemukan di database"})
	}

	_, errReko := config.RekognitionClient.DeleteFaces(context.TODO(), &rekognition.DeleteFacesInput{
		CollectionId: aws.String(config.RekognitionCollectionID),
		FaceIds:      []string{faceReg.AwsFaceID},
	})
	if errReko != nil {
		fmt.Printf("[AWS WARNING] Gagal menghapus dari Rekognition (mungkin sudah terhapus): %v\n", errReko)
	}

	s3Key := strings.Replace(faceReg.FaceUrl, config.S3BaseURL+"/", "", 1)
	_, errS3 := config.S3Client.DeleteObject(context.TODO(), &s3.DeleteObjectInput{
		Bucket: aws.String(config.S3Bucket),
		Key:    aws.String(s3Key),
	})
	if errS3 != nil {
		fmt.Printf("[S3 WARNING] Gagal menghapus foto dari S3: %v\n", errS3)
	}

	if err := tx.Model(&user).Updates(map[string]interface{}{"face_id": nil}).Error; err != nil {
		fmt.Printf("[DB ERROR] Gagal set null face_id: %v\n", err)
		return c.Status(500).JSON(fiber.Map{"success": false, "message": "Gagal memutuskan relasi wajah di database"})
	}

	// 8. Hapus record dari tabel face_registrations
	if err := tx.Delete(&faceReg).Error; err != nil {
		fmt.Printf("[DB ERROR] Gagal delete FaceRegistration: %v\n", err)
		return c.Status(500).JSON(fiber.Map{"success": false, "message": "Gagal menghapus data wajah di database"})
	}

	tx.Commit()

	return c.JSON(fiber.Map{
		"success": true,
		"message": "Face ID berhasil dihapus sepenuhnya",
	})
}