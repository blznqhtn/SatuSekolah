package controllers

import (
	"bytes"
	"e-presence-backend/config"
	"e-presence-backend/models"
	"fmt"
	"io"
	"log"
	"net/http"
	"path/filepath"
	"strings"
	"time"

	"github.com/google/uuid"
	"github.com/jung-kurt/gofpdf"
)

func checkAndTriggerSP(userID string) {
	var user models.User
	if err := config.DB.Preload("SchoolMember.Sekolah.Setting").Preload("SchoolMember.Kelas").First(&user, "id = ?", userID).Error; err != nil {
		return
	}

	if user.SchoolMember == nil || user.SchoolMember.Sekolah.ID == uuid.Nil {
		return
	}

	sekolah := user.SchoolMember.Sekolah

	var setting models.Setting
	if sekolah.Setting != nil {
		setting = *sekolah.Setting
	}

	if !setting.SpEnabled {
		return
	}

	loc, _ := time.LoadLocation("Asia/Jakarta")
	if loc == nil {
		loc = time.UTC
	}
	now := time.Now().In(loc)

	// Count late entries for the current month
	var lateCount int64
	config.DB.Model(&models.LateEntry{}).
		Where("id_user = ? AND extract(month from time) = ? AND extract(year from time) = ?", user.ID, int(now.Month()), now.Year()).
		Count(&lateCount)

	// Add late presences that might not be in LateEntry (backup check)
	var presenceLateCount int64
	config.DB.Model(&models.Presence{}).
		Where("id_user = ? AND status = 'Terlambat' AND extract(month from time_masuk) = ? AND extract(year from time_masuk) = ?", user.ID, int(now.Month()), now.Year()).
		Count(&presenceLateCount)

	// We use max of both to ensure accuracy
	count := int(lateCount)
	if int(presenceLateCount) > count {
		count = int(presenceLateCount)
	}

	if count > 0 && count%setting.SpMaxLatePerMonth == 0 {
		var existingSPCount int64
		config.DB.Model(&models.SPRecord{}).
			Where("id_user = ? AND month = ? AND year = ? AND late_count = ?", user.ID, int(now.Month()), now.Year(), count).
			Count(&existingSPCount)

		if existingSPCount == 0 {
			generateAndSendSP(user, sekolah, setting, count)
		}
	}
}

func generateAndSendSP(user models.User, sekolah models.Sekolah, setting models.Setting, lateCount int) {
	pdf := gofpdf.New("P", "mm", "A4", "")
	pdf.AddPage()

	if sekolah.Ikon != nil && *sekolah.Ikon != "" {
		resp, err := http.Get(*sekolah.Ikon)
		if err == nil && resp.StatusCode == 200 {
			defer resp.Body.Close()
			imgBytes, _ := io.ReadAll(resp.Body)
			
			// Detect format
			ext := strings.ToLower(filepath.Ext(*sekolah.Ikon))
			imgType := "JPG"
			if strings.Contains(ext, "png") {
				imgType = "PNG"
			}
			
			opt := gofpdf.ImageOptions{ImageType: imgType}
			pdf.RegisterImageOptionsReader("logo", opt, bytes.NewReader(imgBytes))
			pdf.ImageOptions("logo", 10, 10, 30, 0, false, opt, 0, "")
		}
	}

	pdf.SetFont("Arial", "B", 16)
	pdf.CellFormat(0, 10, sekolah.NamaSekolah, "", 1, "C", false, 0, "")
	pdf.SetFont("Arial", "", 10)
	if sekolah.Alamat != nil {
		pdf.CellFormat(0, 5, *sekolah.Alamat, "", 1, "C", false, 0, "")
	}
	pdf.Line(10, 45, 200, 45)
	
	pdf.Ln(15)

	spTitle := fmt.Sprintf("SURAT PERINGATAN %d", lateCount/setting.SpMaxLatePerMonth)
	pdf.SetFont("Arial", "B", 14)
	pdf.CellFormat(0, 10, spTitle, "", 1, "C", false, 0, "")
	pdf.Ln(5)

	pdf.SetFont("Arial", "", 12)
	pdf.CellFormat(0, 8, "Dengan hormat,", "", 1, "L", false, 0, "")
	pdf.CellFormat(0, 8, "Bersama surat ini, kami memberitahukan bahwa peserta didik:", "", 1, "L", false, 0, "")
	
	pdf.Ln(2)
	pdf.CellFormat(40, 8, "Nama", "", 0, "L", false, 0, "")
	pdf.CellFormat(0, 8, ": "+user.SchoolMember.Name, "", 1, "L", false, 0, "")

	kelasNama := "-"
	if user.SchoolMember.Kelas.ID != uuid.Nil {
		kelasNama = user.SchoolMember.Kelas.Name
	}
	pdf.CellFormat(40, 8, "Kelas", "", 0, "L", false, 0, "")
	pdf.CellFormat(0, 8, ": "+kelasNama, "", 1, "L", false, 0, "")
	
	pdf.CellFormat(40, 8, "Nomor Induk", "", 0, "L", false, 0, "")
	pdf.CellFormat(0, 8, ": "+user.SchoolMember.NoInduk, "", 1, "L", false, 0, "")

	pdf.Ln(5)

	template := "Telah tercatat melakukan keterlambatan sebanyak %d kali pada bulan ini. Kami harap partisipasi dan kerja sama dari Bapak/Ibu untuk memberikan bimbingan kepada peserta didik agar hadir tepat waktu."
	if setting.SpTemplate != nil && *setting.SpTemplate != "" {
		template = *setting.SpTemplate
	}

	bodyText := fmt.Sprintf(template, lateCount)
	pdf.MultiCell(0, 8, bodyText, "", "J", false)
	
	pdf.Ln(15)
	loc, _ := time.LoadLocation("Asia/Jakarta")
	if loc == nil { loc = time.UTC }
	
	tglFormat := time.Now().In(loc).Format("02 January 2006")
	pdf.CellFormat(0, 8, "Mengetahui,", "", 1, "R", false, 0, "")
	pdf.CellFormat(0, 8, tglFormat, "", 1, "R", false, 0, "")
	
	pdf.Ln(25)
	if sekolah.KepalaSekolah != nil {
		pdf.CellFormat(0, 8, *sekolah.KepalaSekolah, "", 1, "R", false, 0, "")
	}
	
	pdf.SetY(270)
	pdf.SetFont("Arial", "I", 8)
	pdf.CellFormat(0, 10, "Dibuat oleh sistem presensi digital - SeHadir", "", 0, "R", false, 0, "")

	var buf bytes.Buffer
	err := pdf.Output(&buf)
	if err != nil {
		log.Println("[SP ERR] Failed to generate SP PDF:", err)
		return
	}

	fileName := fmt.Sprintf("SP_%s_%s_%d.pdf", user.SchoolMember.NoInduk, time.Now().Format("200601021504"), lateCount)
	s3Key := "surat_peringatan/" + fileName

	docUrl, err := config.UploadToS3(&buf, s3Key, "application/pdf")
	if err != nil {
		log.Println("[SP ERR] Failed to upload PDF SP to S3:", err)
		return
	}

	phone := ""
	if user.SchoolMember.Nomor != nil {
		phone = *user.SchoolMember.Nomor
	}
	
	t := time.Now().In(loc)
	record := models.SPRecord{
		IDUser:    user.ID,
		LateCount: lateCount,
		Month:     int(t.Month()),
		Year:      t.Year(),
		SpMessage: "Dokumen SP terkirim via: " + docUrl,
		Sent:      true,
		SentAt:    &t,
		Phone:     &phone,
	}
	config.DB.Create(&record)

	msgText := fmt.Sprintf("Pemberitahuan Surat Peringatan (SP)\n\nYth. Bapak/Ibu,\nBerikut adalah dokumen Surat Peringatan untuk Ananda %s.\n\nHrp unduh dan tinjau melalui lampiran PDF berikut.", user.SchoolMember.Name)

	if setting.WhatsappNotificationEnabled && phone != "" {
		apiKey := ""
		if sekolah.ApikeyWhatsapp != nil {
			apiKey = *sekolah.ApikeyWhatsapp
		}
		go sendWhatsAppFile(phone, apiKey, msgText, docUrl)
	} else if sekolah.Email != nil && *sekolah.Email != "" {
		if user.Email != nil && *user.Email != "" {
			go func() {
				subject := fmt.Sprintf("Surat Peringatan Keterlambatan - %s", user.SchoolMember.Name)
				htmlBody := fmt.Sprintf("<p>%s</p><br><p><a href='%s'>Unduh Dokumen Surat Peringatan</a></p>", strings.ReplaceAll(msgText, "\n", "<br>"), docUrl)
				config.SendEmailWithReplyTo(*user.Email, *sekolah.Email, subject, htmlBody)
			}()
		}
	}
}

func sendWhatsAppFile(target, apiKey, message, fileUrl string) {
	if apiKey == "" {
		log.Println("[WA ERR] ApiKey is empty, cannot send whatsapp")
		return
	}

	url := "https://api.fonnte.com/send"
	payload := strings.NewReader("target=" + target + "&message=" + message + "&url=" + fileUrl)
	
	req, _ := http.NewRequest("POST", url, payload)
	req.Header.Add("Authorization", apiKey)
	req.Header.Add("Content-Type", "application/x-www-form-urlencoded")

	res, err := http.DefaultClient.Do(req)
	if err != nil {
		log.Printf("[WA ERR] Failed to send WA File to %s: %v\n", target, err)
		return
	}
	defer res.Body.Close()

	if res.StatusCode >= 200 && res.StatusCode < 300 {
		log.Printf("[WA OK] Success send WA File to %s\n", target)
	} else {
		log.Printf("[WA ERR] Failed to send WA File to %s, API Status: %d\n", target, res.StatusCode)
	}
}
