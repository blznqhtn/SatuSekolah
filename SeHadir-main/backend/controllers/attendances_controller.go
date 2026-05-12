package controllers

import (
    "e-presence-backend/config"
    "e-presence-backend/models"
    "errors"
    "fmt"
	"log"
    "net/http"
    "os"
    "strconv"
    "strings"
    "time"

    "github.com/gofiber/fiber/v2"
    "github.com/google/uuid"
    "github.com/redis/go-redis/v9"
    "gorm.io/gorm"
    "gorm.io/gorm/clause"
)

type PresensiRequest struct {
    ID       string `json:"id" validate:"required"`
    SchoolID string `json:"id_sekolah" validate:"required"`
    Mode     string `json:"mode" validate:"required"`
}

type UserResponse struct {
	ID           string `json:"id"`
	Username     string `json:"username"`
	SchoolMember *struct {
		Name     string `json:"name"`
		NoInduk  string `json:"no_induk"`
		Kelas    *struct {
			Name string `json:"name"`
		} `json:"kelas,omitempty"`
	} `json:"school_member,omitempty"`
}

func Presensi(c *fiber.Ctx) error {
	var req PresensiRequest

	contentType := string(c.Request().Header.ContentType())
	if strings.Contains(contentType, "multipart/form-data") ||
		strings.Contains(contentType, "application/x-www-form-urlencoded") {
		req.ID = c.FormValue("id")
		req.SchoolID = c.FormValue("id_sekolah")
		req.Mode = c.FormValue("mode")
	} else {
		if err := c.BodyParser(&req); err != nil {
			return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{
				"status":  "failed",
				"message": "Format request tidak valid.",
			})
		}
	}

	if req.ID == "" || req.SchoolID == "" || req.Mode == "" {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{
			"status":  "failed",
			"message": "ID, id_sekolah, dan mode wajib diisi.",
		})
	}

	rfid := strings.TrimSpace(req.ID)
	mode := strings.ToLower(req.Mode)

	// Redis rate limiting
	if config.RDB != nil {
		lockKey := fmt.Sprintf("lock:presensi:%s", rfid)
		errLock := config.RDB.SetArgs(config.Ctx, lockKey, "1", redis.SetArgs{
			Mode: "NX",
			TTL:  3 * time.Second,
		}).Err()

		if errLock != nil && !errors.Is(errLock, redis.Nil) {
			log.Println("Redis lock error:", errLock)
		} else if errLock == nil {
			// lock acquired
		} else {
			return c.Status(fiber.StatusOK).JSON(fiber.Map{
				"status":  "failed",
				"message": "Tunggu 3 detik sebelum melakukan tap kembali.",
			})
		}
	}

	tx := config.DB.WithContext(c.Context()).Begin()
	defer func() {
		if r := recover(); r != nil {
			tx.Rollback()
		}
	}()

	// Fetch user
	var user models.User
	if err := tx.Clauses(clause.Locking{Strength: "UPDATE"}).
		Preload("SchoolMember.Kelas").
		Where("rfid_id = ?", rfid).
		First(&user).Error; err != nil {
		tx.Rollback()
		return c.Status(fiber.StatusOK).JSON(fiber.Map{
			"status":  "failed",
			"message": "Kartu RFID tidak terdaftar.",
		})
	}

	profileUrl := "/images/default.jpg"
	if user.SchoolMember != nil && user.SchoolMember.FotoProfile != nil && *user.SchoolMember.FotoProfile != "" {
		profileUrl = *user.SchoolMember.FotoProfile
	}

	if user.Role != "user" {
		tx.Rollback()
		return c.Status(fiber.StatusOK).JSON(fiber.Map{
			"status":  "success",
			"message": "Tes Scan Berhasil (" + user.Role + ")",
			"data":    user,
			"profile": profileUrl,
		})
	}

	if user.SchoolMember == nil {
		tx.Rollback()
		return c.Status(fiber.StatusOK).JSON(fiber.Map{
			"status":  "failed",
			"message": "Data siswa tidak lengkap / tidak terhubung ke sekolah.",
		})
	}

	// Timezone
	loc, err := time.LoadLocation("Asia/Jakarta")
	if err != nil {
		log.Println("⚠️ Gagal load timezone Asia/Jakarta, pakai UTC")
		loc = time.UTC
	}
	now := time.Now().In(loc)
	todayFullDate := now.Format("2006-01-02")

	// Cek kalender akademik
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

	var sekolah models.Sekolah
	baseURL := os.Getenv("BASE_URL")

	if err := tx.Where("id = ?", req.SchoolID).First(&sekolah).Error; err == nil {
		if sekolah.Website != nil && *sekolah.Website != "" {
			baseURL = *sekolah.Website
			baseURL = strings.TrimSuffix(baseURL, "/")
		}
	}

	containsDate := func(slice []string, target string) bool {
		for _, d := range slice {
			if d == target {
				return true
			}
		}
		return false
	}

	if containsDate(hari.HariLibur, todayFullDate) {
		tx.Commit()
		return c.Status(fiber.StatusOK).JSON(fiber.Map{
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

	token := uuid.New().String()

	var presence models.Presence
	errPresence := tx.Where("id_user = ? AND DATE(time_masuk) = ?", user.ID, todayFullDate).
		First(&presence).Error

	switch mode {
	case "masuk":
		if errPresence == nil {
			tx.Rollback()
			return c.Status(fiber.StatusOK).JSON(fiber.Map{
				"status":  "failed",
				"message": "Anda sudah tercatat hadir hari ini.",
				"data":    user,
				"profile": profileUrl,
			})
		}

		if isProductive {
			// batasJamStr := strings.TrimSpace(os.Getenv("BATAS_TERLAMBAT_JAM"))
			// batasMenitStr := strings.TrimSpace(os.Getenv("BATAS_TERLAMBAT_MENIT"))
			batasJamStr := strings.TrimSpace("01")
			batasMenitStr := strings.TrimSpace("00")
			if batasJamStr == "" {
				batasJamStr = "7"
			}
			if batasMenitStr == "" {
				batasMenitStr = "0"
			}
			batasJam, _ := strconv.Atoi(batasJamStr)
			batasMenit, _ := strconv.Atoi(batasMenitStr)

			batasTerlambat := time.Date(now.Year(), now.Month(), now.Day(),
				batasJam, batasMenit, 0, 0, now.Location())

			// LOG DEBUGGING
			log.Printf("⏰ Waktu sekarang: %s", now.Format("15:04:05"))
			log.Printf("⏰ Batas terlambat: %s (ENV: JAM=%d, MENIT=%d)", batasTerlambat.Format("15:04"), batasJam, batasMenit)

			if now.After(batasTerlambat) {
				log.Println("🚨 TERLAMBAT")
				late := models.LateEntry{
					IDUser: user.ID,
					Time:   now,
					Type:   "Presensi Masuk",
					Token:  token,
				}
				if err := tx.Create(&late).Error; err != nil {
					tx.Rollback()
					return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
						"status":  "failed",
						"message": "Gagal mencatat keterlambatan.",
					})
				}

				tx.Commit()

				// Di dalam blok terlambat, bangun response ringkas
				userResp := UserResponse{
					ID:       user.ID.String(),
					Username: user.Username,
				}
				if user.SchoolMember != nil {
					userResp.SchoolMember = &struct {
						Name     string `json:"name"`
						NoInduk  string `json:"no_induk"`
						Kelas    *struct {
							Name string `json:"name"`
						} `json:"kelas,omitempty"`
					}{
						Name:    user.SchoolMember.Name,
						NoInduk: user.SchoolMember.NoInduk,
					}
					if user.SchoolMember.Kelas.ID != uuid.Nil {
						userResp.SchoolMember.Kelas = &struct {
							Name string `json:"name"`
						}{
							Name: user.SchoolMember.Kelas.Name,
						}
					}
				}

				return c.Status(fiber.StatusOK).JSON(fiber.Map{
					"status":       "late",
					"message":      "Anda terlambat, silakan isi alasan pada QR Code berikut.",
					"redirect_url": fmt.Sprintf("%s/forms/late/arrival?token=%s", baseURL, token),
					"data":         userResp,
					"profile":      profileUrl,
				})
			}

			// TEPAT WAKTU
			log.Println("✅ TEPAT WAKTU")
			newPresence := models.Presence{
				IDUser:     user.ID,
				TimeMasuk:  now,
				Status:     "Hadir",
				StatusHari: "Hari Produktif",
			}
			if err := tx.Create(&newPresence).Error; err != nil {
				tx.Rollback()
				return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
					"status":  "failed",
					"message": "Gagal menyimpan presensi.",
				})
			}
			tx.Commit()
			go finalizePresensiEffects(user.ID.String())

			return c.Status(fiber.StatusOK).JSON(fiber.Map{
				"status":  "success",
				"message": "Presensi masuk berhasil. Selamat belajar!",
				"data":    user,
				"profile": profileUrl,
			})

		} else if isAdditional {
			late := models.LateEntry{
				IDUser: user.ID,
				Time:   now,
				Type:   "Presensi Masuk",
				Token:  token,
			}
			if err := tx.Create(&late).Error; err != nil {
				tx.Rollback()
				return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
					"status":  "failed",
					"message": "Gagal mencatat entri.",
				})
			}
			tx.Commit()
			return c.Status(fiber.StatusOK).JSON(fiber.Map{
				"status":       "non_productive",
				"message":      "Kegiatan tambahan terdeteksi, silakan isi form.",
				"redirect_url": fmt.Sprintf("%s/forms/special/attendance?token=%s", baseURL, token),
				"data":         user,
				"profile":      profileUrl,
			})
		}

	case "keluar":
		if errors.Is(errPresence, gorm.ErrRecordNotFound) {
			tx.Rollback()
			return c.Status(fiber.StatusOK).JSON(fiber.Map{
				"status":  "failed",
				"message": "Anda belum melakukan absen masuk hari ini.",
				"data":    user,
				"profile": profileUrl,
			})
		}

		if presence.TimeKeluar != nil {
			tx.Rollback()
			return c.Status(fiber.StatusOK).JSON(fiber.Map{
				"status":  "failed",
				"message": "Anda sudah melakukan absen keluar sebelumnya.",
				"data":    user,
				"profile": profileUrl,
			})
		}

		if isProductive {
			maxJam, _ := strconv.Atoi(strings.TrimSpace(getEnv("JAM_PULANG_MAX_JAM", "16")))
			maxMenit, _ := strconv.Atoi(strings.TrimSpace(getEnv("JAM_PULANG_MAX_MENIT", "30")))
			realJam, _ := strconv.Atoi(strings.TrimSpace(getEnv("JAM_PULANG_REAL_JAM", "15")))
			realMenit, _ := strconv.Atoi(strings.TrimSpace(getEnv("JAM_PULANG_REAL_MENIT", "30")))

			jamPulangMax := time.Date(now.Year(), now.Month(), now.Day(),
				maxJam, maxMenit, 0, 0, now.Location())
			jamPulangCepat := time.Date(now.Year(), now.Month(), now.Day(),
				realJam, realMenit, 0, 0, now.Location())

			if now.After(jamPulangMax) {
				late := models.LateEntry{
					IDUser: user.ID,
					Time:   now,
					Type:   "Presensi Keluar",
					Token:  token,
				}
				tx.Create(&late)
				tx.Commit()
				return c.Status(fiber.StatusOK).JSON(fiber.Map{
					"status":       "late",
					"redirect_url": fmt.Sprintf("%s/forms/late/departure?token=%s", baseURL, token),
					"message":      "Waktu operasional berakhir, silakan isi alasan pulang terlambat.",
					"data":         user,
					"profile":      profileUrl,
				})
			} else if now.Before(jamPulangCepat) {
				late := models.LateEntry{
					IDUser: user.ID,
					Time:   now,
					Type:   "Presensi Keluar",
					Token:  token,
				}
				tx.Create(&late)
				tx.Commit()
				return c.Status(fiber.StatusOK).JSON(fiber.Map{
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
				return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
					"status":  "failed",
					"message": "Gagal update absen keluar.",
				})
			}
			tx.Commit()
			go finalizePresensiEffects(user.ID.String())

			return c.Status(fiber.StatusOK).JSON(fiber.Map{
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

			return c.Status(fiber.StatusOK).JSON(fiber.Map{
				"status":  "success",
				"message": "Absensi pulang kegiatan tambahan berhasil.",
				"data":    user,
				"profile": profileUrl,
			})
		}
	}

	tx.Rollback()
	return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{
		"status":  "failed",
		"message": "Mode presensi tidak dikenal.",
	})
}

// Helper getEnv tetap
func getEnv(key, fallback string) string {
    if value, ok := os.LookupEnv(key); ok {
        return value
    }
    return fallback
}

func finalizePresensiEffects(userID string) {
	// 1. Invalidate Cache Dashboard User Spesifik
	invalidateUserDashboardCache(userID)
	// 2. Invalidate Versi Cache Analitik (Admin Dashboard)
	incrementAttendanceCacheVersion()

	// 3. Send Notification Email/WhatsApp
	sendAttendanceNotification(userID)

	// 4. Periksa Late Threshold & Sistem SP Otomatis
	go checkAndTriggerSP(userID)
}

func sendAttendanceNotification(userID string) {
	var user models.User
	if err := config.DB.Preload("SchoolMember.Sekolah.Setting").Preload("SchoolMember.Kelas").First(&user, "id = ?", userID).Error; err != nil {
		return
	}

	if user.SchoolMember == nil || user.SchoolMember.Sekolah.ID == uuid.Nil {
		return
	}

	sekolah := user.SchoolMember.Sekolah
	
	// Ensure setting is configured
	var setting models.Setting
	if sekolah.Setting != nil {
		setting = *sekolah.Setting
	}

	// get the latest presence today
	var presence models.Presence
	loc, _ := time.LoadLocation("Asia/Jakarta")
	if loc == nil {
		loc = time.UTC
	}
	currentTime := time.Now().In(loc)
	todayStr := currentTime.Format("2006-01-02")
	
	if err := config.DB.Where("id_user = ? AND DATE(time_masuk) = ?", userID, todayStr).First(&presence).Error; err != nil {
		return
	}

	var action string
	var absTime time.Time
	
	if presence.TimeKeluar != nil && presence.TimeKeluar.In(loc).Format("2006-01-02") == todayStr {
		action = "Keluar"
		absTime = presence.TimeKeluar.In(loc)
	} else {
		action = "Masuk"
		absTime = presence.TimeMasuk.In(loc)
	}

	waktuStr := absTime.Format("15:04:05")
	tglStr := absTime.Format("02 Jan 2006")
	
	alasan := "-"
	if action == "Masuk" {
		if presence.AlasanDatangTelat != nil && *presence.AlasanDatangTelat != "" {
			alasan = *presence.AlasanDatangTelat
		} else if presence.AlasanDatang != nil && *presence.AlasanDatang != "" {
			alasan = *presence.AlasanDatang
		}
	} else {
		if presence.AlasanPulangTelat != nil && *presence.AlasanPulangTelat != "" {
			alasan = *presence.AlasanPulangTelat
		} else if presence.AlasanPulangDuluan != nil && *presence.AlasanPulangDuluan != "" {
			alasan = *presence.AlasanPulangDuluan
		}
	}

	kelasNama := "-"
	if user.SchoolMember.Kelas.ID != uuid.Nil && user.SchoolMember.Kelas.Name != "" {
		kelasNama = user.SchoolMember.Kelas.Name
	}

	sekolahNama := "-"
	if sekolah.NamaSekolah != "" {
		sekolahNama = sekolah.NamaSekolah
	}

	var msgBody string
	baseTemplate := "🏢 *PRESENSI DIGITAL - SEHADIR*\n" +
		"        _Powered by RaaDeveloperz_\n\n" +
		"Yth. Bapak/Ibu,\n" +
		"Berikut adalah informasi presensi %s untuk peserta didik:\n\n" +
		"🏫 *Institusi*: %s\n" +
		"👤 *Nama*: %s\n" +
		"🎓 *Kelas*: %s\n" +
		"🔖 *No Induk*: %s\n\n" +
		"📅 *Tanggal*: %s\n" +
		"⏰ *Waktu*: %s WIB\n" +
		"📊 *Status*: *%s*\n"

	if alasan != "-" {
		baseTemplate += "📝 *Keterangan*: " + alasan + "\n\n"
	} else {
		baseTemplate += "\n"
	}

	baseTemplate += "==========================\n" +
		"⚠️ *PEMBERITAHUAN*\n" +
		"Pesan ini dikirim secara otomatis oleh sistem SeHadir. " +
		"Mohon untuk tidak membalas pesan ini dikarenakan nomor ini hanya ditujukan " +
		"sebagai pusat pengiriman notifikasi (No-Reply).\n\n" +
		"Terima kasih atas perhatiannya."

	msgBody = fmt.Sprintf(baseTemplate, strings.ToLower(action), sekolahNama, user.SchoolMember.Name, kelasNama, user.SchoolMember.NoInduk, tglStr, waktuStr, presence.Status)

	// RULES:
	// Jika WhatsappEnabled == true -> Kirim WA ke SchoolMember.Nomor (wali/murid) menggunakan API Key milik Sekolah
	// Jika false -> Kirim Email ke Sekolah.Email dengan Reply-To Sekolah.Email
	if setting.WhatsappNotificationEnabled && user.SchoolMember.Nomor != nil && *user.SchoolMember.Nomor != "" {
		apiKey := ""
		if sekolah.ApikeyWhatsapp != nil {
			apiKey = *sekolah.ApikeyWhatsapp
		}
		go sendWhatsAppMessage(*user.SchoolMember.Nomor, apiKey, msgBody)
	} else {
		if sekolah.Email != nil && *sekolah.Email != "" {
			go func() {
				subject := fmt.Sprintf("Notifikasi Presensi %s - %s", action, user.SchoolMember.Name)
				config.SendEmailWithReplyTo(*sekolah.Email, *sekolah.Email, subject, msgBody)
			}()
		}
	}
}

func sendWhatsAppMessage(target, apiKey, message string) {
	if apiKey == "" {
		log.Println("[WA ERR] ApiKey is empty, cannot send whatsapp")
		return
	}

	url := "https://api.fonnte.com/send"
	payload := strings.NewReader("target=" + target + "&message=" + message)
	
	req, _ := http.NewRequest("POST", url, payload)
	req.Header.Add("Authorization", apiKey)
	req.Header.Add("Content-Type", "application/x-www-form-urlencoded")

	res, err := http.DefaultClient.Do(req)
	if err != nil {
		log.Printf("[WA ERR] Failed to send WA to %s: %v\n", target, err)
		return
	}
	defer res.Body.Close()

	if res.StatusCode >= 200 && res.StatusCode < 300 {
		log.Printf("[WA OK] Success send WA to %s\n", target)
	} else {
		log.Printf("[WA ERR] Failed to send WA to %s, API Status: %d\n", target, res.StatusCode)
	}
}