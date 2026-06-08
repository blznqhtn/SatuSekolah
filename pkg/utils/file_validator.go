package utils

import (
	"bytes"
	"errors"
	"io"
	"mime/multipart"
	"net/http"
	"strings"
)

// ValidateFileMagicBytes checks if the uploaded file's actual content type
// matches one of the allowed MIME types by inspecting its first 512 bytes (magic bytes).
// This prevents malicious scripts (e.g. PHP/JS) from being uploaded with fake extensions (e.g. .jpg).
func ValidateFileMagicBytes(fileHeader *multipart.FileHeader, allowedMimeTypes []string) error {
	file, err := fileHeader.Open()
	if err != nil {
		return err
	}
	defer file.Close()

	// Read first 512 bytes for sniffing
	buffer := make([]byte, 512)
	n, err := file.Read(buffer)
	if err != nil && err != io.EOF {
		return err
	}

	// Detect true content type
	contentType := http.DetectContentType(buffer[:n])

	// Clean up content type (e.g. "text/plain; charset=utf-8" -> "text/plain")
	cleanContentType := strings.Split(contentType, ";")[0]

	// Special check for CSV/XLSX/DOCX which sometimes appear as application/zip or application/octet-stream
	// For deeper enterprise apps, external lib like gabriel-vasile/mimetype might be better,
	// but for this standard approach we will manually allow them if explicitly in allowed list 
	// AND not a known dangerous script type.
	if isDangerousScript(cleanContentType) {
		return errors.New("malicious file script detected")
	}

	for _, allowed := range allowedMimeTypes {
		if cleanContentType == allowed {
			return nil
		}
		// Special pass for common document types that might be misidentified by basic DetectContentType
		if allowed == "application/pdf" && bytes.HasPrefix(buffer, []byte("%PDF-")) {
			return nil
		}
		if (allowed == "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet" || allowed == "application/vnd.openxmlformats-officedocument.wordprocessingml.document") &&
			(cleanContentType == "application/zip" || cleanContentType == "application/octet-stream") {
			// XLSX and DOCX are essentially ZIP files. We allow them if requested.
			return nil
		}
	}

	return errors.New("file content type not allowed: " + cleanContentType)
}

func isDangerousScript(mimeType string) bool {
	dangerous := []string{
		"text/html",
		"application/javascript",
		"application/x-javascript",
		"text/javascript",
		"application/x-httpd-php",
		"application/x-sh",
		"application/x-executable",
		"application/x-bat",
		"application/x-msdownload",
	}
	for _, d := range dangerous {
		if mimeType == d {
			return true
		}
	}
	return false
}
