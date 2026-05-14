package config

import (
	"crypto/tls"
	"log"
	"os"
	"strconv"
	"strings"

	"gopkg.in/gomail.v2"
)

func SendEmail(to, subject, body string) error {
	return SendEmailWithReplyTo(to, "", subject, body)
}

func SendEmailWithReplyTo(to, replyTo, subject, body string) error {
	host := os.Getenv("SMTP_HOST")
	portStr := os.Getenv("SMTP_PORT")
	user := os.Getenv("SMTP_USER")
	pass := os.Getenv("SMTP_PASS")
	
	senderName := os.Getenv("SMTP_SENDER_NAME")
	if senderName == "" {
		senderName = "SeHadir System" 
	}

	port, err := strconv.Atoi(portStr)
	if err != nil {
		// Default port TLS jika gagal diparsing
		port = 465 
	}

	m := gomail.NewMessage()
	
	m.SetHeader("From", m.FormatAddress(user, senderName))
	m.SetHeader("To", to)
	if replyTo != "" {
		m.SetHeader("Reply-To", replyTo)
	}
	m.SetHeader("Subject", subject)

	if _, err := os.Stat("logo_raadeveloperz.png"); err == nil {
		m.Embed("logo_raadeveloperz.png")
	}

	htmlBody := strings.ReplaceAll(body, "\n", "<br>")
	
	htmlTemplate := `
		<div style="font-family: 'Segoe UI', Arial, sans-serif; max-width: 650px; margin: 0 auto; border: 1px solid #e0e4e8; border-radius: 8px; box-shadow: 0 4px 6px rgba(0,0,0,0.05); background-color: #ffffff;">
			<div style="background-color: #1a365d; color: #ffffff; padding: 25px; border-top-left-radius: 8px; border-top-right-radius: 8px; text-align: center;">
				<img src="cid:logo_raadeveloperz.png" alt="SeHadir Logo" style="max-height: 60px; margin-bottom: 10px; border-radius: 4px;">
				<h2 style="margin: 0; font-size: 24px; font-weight: 600; letter-spacing: 0.5px;">SeHadir</h2>
				<p style="margin: 5px 0 0 0; font-size: 14px; color: #bbd3ea;">Enterprise Presence Management System</p>
			</div>
			<div style="padding: 30px; color: #2d3748;">
				<h3 style="color: #2b6cb0; border-bottom: 2px solid #e2e8f0; padding-bottom: 10px; margin-top: 0;">` + subject + `</h3>
				<div style="font-size: 15px; line-height: 1.6; margin-top: 20px;">
					` + htmlBody + `
				</div>
			</div>
			<div style="background-color: #f7fafc; padding: 20px; text-align: center; border-bottom-left-radius: 8px; border-bottom-right-radius: 8px; border-top: 1px solid #e0e4e8;">
				<p style="margin: 0; font-size: 12px; color: #718096; line-height: 1.5;">
					Pesan ini dikirim secara otomatis oleh sistem <strong>SeHadir</strong>.<br>
					`
	if replyTo != "" {
		htmlTemplate += `Anda dapat membalas email ini secara langsung ke institusi Anda.`
	} else {
		htmlTemplate += `Mohon untuk tidak membalas pesan ini.`
	}
	
	htmlTemplate += `
				</p>
				<p style="margin: 15px 0 0 0; font-size: 11px; color: #a0aec0;">
					Powered by <strong>RaaDeveloperz</strong> &copy; 2026
				</p>
			</div>
		</div>
	`

	m.SetBody("text/html", htmlTemplate)

	d := gomail.NewDialer(host, port, user, pass)

	// (Ubah menjadi false jika sudah naik ke Production AWS dengan SSL resmi)
	d.TLSConfig = &tls.Config{InsecureSkipVerify: true}

	if err := d.DialAndSend(m); err != nil {
		log.Printf("[EMAIL ERROR] Gagal mengirim email ke %s: %v\n", to, err)
		return err
	}

	log.Printf("[EMAIL SUCCESS] Email terkirim ke %s\n", to)
	return nil
}