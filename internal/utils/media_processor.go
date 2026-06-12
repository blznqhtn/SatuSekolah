package utils

import (
	"bytes"
	"fmt"
	"image/jpeg"
	"mime/multipart"
	"os"
	"os/exec"
	"path/filepath"
	"strings"

	"github.com/disintegration/imaging"
	"github.com/google/uuid"
)

// ==========================================
// FILE SIZE LIMITS
// ==========================================
const (
	MaxImageSize    = 5 * 1024 * 1024   // 5 MB
	MaxDocumentSize = 10 * 1024 * 1024  // 10 MB
	MaxAudioSize    = 20 * 1024 * 1024  // 20 MB
	MaxVideoSize    = 500 * 1024 * 1024 // 500 MB

	// JPEG quality for re-encoding. 92 = visually lossless, ~30-40% smaller than unoptimized JPEG
	ImageJPEGQuality = 92
)

// MediaCategory classifies a file by its MIME type.
type MediaCategory int

const (
	CategoryImage    MediaCategory = iota // jpg, jpeg, png, gif, bmp, tiff
	CategoryDocument                      // pdf, docx, xlsx, pptx
	CategoryAudio                         // mp3, wav, ogg, flac, aac
	CategoryVideo                         // mp4, mov, avi, mkv, webm
	CategoryOther
)

// ProcessResult holds the result after processing a file.
type ProcessResult struct {
	SavePath   string
	FileURL    string
	FinalSizeB int64
	OrigSizeB  int64
	Category   MediaCategory
	// Converted is true if format was changed (e.g. jpg → jpeg re-encoded, avi → mp4)
	Converted bool
}

// ==========================================
// PUBLIC ENTRY POINT
// ==========================================

// ProcessUpload validates size limits, compresses, and converts to a web-friendly format.
// baseDir  = local directory to save to  (e.g. "./uploads/media")
// baseURL  = public URL prefix           (e.g. "/files/media")
func ProcessUpload(fileHeader *multipart.FileHeader, baseDir, baseURL string) (*ProcessResult, error) {
	mime := fileHeader.Header.Get("Content-Type")
	category := classifyMIME(mime, fileHeader.Filename)

	// --- Size validation ---
	if err := validateSize(fileHeader.Size, category); err != nil {
		return nil, err
	}

	// Read raw bytes
	src, err := fileHeader.Open()
	if err != nil {
		return nil, fmt.Errorf("cannot open uploaded file: %w", err)
	}
	defer src.Close()
	var buf bytes.Buffer
	if _, err = buf.ReadFrom(src); err != nil {
		return nil, fmt.Errorf("cannot read uploaded file: %w", err)
	}
	rawBytes := buf.Bytes()

	var (
		outBytes  []byte
		ext       string
		converted bool
	)

	switch category {
	case CategoryImage:
		outBytes, ext, converted, err = processImage(rawBytes, fileHeader.Filename)
	case CategoryAudio:
		outBytes, ext, converted, err = processAudio(rawBytes, fileHeader.Filename)
	case CategoryVideo:
		outBytes, ext, converted, err = processVideo(rawBytes, fileHeader.Filename)
	default:
		// Documents and other: pass-through unchanged
		outBytes = rawBytes
		ext = strings.ToLower(filepath.Ext(fileHeader.Filename))
	}
	if err != nil {
		return nil, err
	}

	// Save to disk
	if err := os.MkdirAll(baseDir, 0755); err != nil {
		return nil, fmt.Errorf("cannot create upload dir: %w", err)
	}
	uniqueName := uuid.New().String() + ext
	savePath := filepath.Join(baseDir, uniqueName)
	fileURL := baseURL + "/" + uniqueName

	if err := os.WriteFile(savePath, outBytes, 0644); err != nil {
		return nil, fmt.Errorf("cannot write file: %w", err)
	}

	return &ProcessResult{
		SavePath:   savePath,
		FileURL:    fileURL,
		FinalSizeB: int64(len(outBytes)),
		OrigSizeB:  fileHeader.Size,
		Category:   category,
		Converted:  converted,
	}, nil
}

// ==========================================
// IMAGE PROCESSING
// ==========================================
// Strategy (pure-Go, no CGo):
//   - Decode with imaging (auto-orient, handles JPEG/PNG/GIF/BMP/TIFF)
//   - Re-encode as JPEG quality 92 (visually lossless, smaller file)
//   - PNG inputs with transparency are preserved as PNG (lossless, best compression level)
//   - Non-decodable formats pass through unchanged
// ==========================================

func processImage(raw []byte, filename string) ([]byte, string, bool, error) {
	origExt := strings.ToLower(filepath.Ext(filename))

	img, err := imaging.Decode(bytes.NewReader(raw), imaging.AutoOrientation(true))
	if err != nil {
		// Unknown / unsupported image format — pass through as-is
		return raw, origExt, false, nil
	}

	// Preserve PNG with alpha channel as optimised PNG (lossless)
	if origExt == ".png" {
		var buf bytes.Buffer
		if err := imaging.Encode(&buf, img, imaging.PNG, imaging.PNGCompressionLevel(9)); err != nil {
			return raw, origExt, false, nil
		}
		return buf.Bytes(), ".png", false, nil
	}

	// Everything else (JPEG, GIF, BMP, TIFF, WEBP…) → high-quality JPEG
	var buf bytes.Buffer
	if err := jpeg.Encode(&buf, img, &jpeg.Options{Quality: ImageJPEGQuality}); err != nil {
		return raw, origExt, false, nil
	}
	return buf.Bytes(), ".jpg", origExt != ".jpg" && origExt != ".jpeg", nil
}

// ==========================================
// AUDIO PROCESSING  (→ .opus via ffmpeg, fallback raw)
// ==========================================
// Opus at 192 kbps VBR is perceptually transparent (indistinguishable from source)
// and typically 30-50% smaller than 320 kbps MP3.
// ==========================================

func processAudio(raw []byte, filename string) ([]byte, string, bool, error) {
	origExt := strings.ToLower(filepath.Ext(filename))

	// Already a web-native lossless-friendly format
	if origExt == ".opus" || origExt == ".ogg" {
		return raw, origExt, false, nil
	}

	outBytes, ok := ffmpegConvert(raw, origExt, ".opus", []string{
		"-c:a", "libopus",
		"-b:a", "192k",
		"-vbr", "on",
		"-compression_level", "10",
	})
	if ok {
		return outBytes, ".opus", true, nil
	}

	// ffmpeg not available — pass through unchanged
	return raw, origExt, false, nil
}

// ==========================================
// VIDEO PROCESSING  (→ .mp4 / H.264 via ffmpeg, fallback raw)
// ==========================================
// CRF 20 with libx264 slow preset = visually lossless (most viewers cannot tell
// the difference from CRF 18, yet file is noticeably smaller).
// +faststart moves MP4 atoms to the front for instant browser streaming.
// ==========================================

func processVideo(raw []byte, filename string) ([]byte, string, bool, error) {
	origExt := strings.ToLower(filepath.Ext(filename))

	// Already web-native
	if origExt == ".mp4" || origExt == ".webm" {
		return raw, origExt, false, nil
	}

	outBytes, ok := ffmpegConvert(raw, origExt, ".mp4", []string{
		"-c:v", "libx264",
		"-crf", "20",
		"-preset", "slow",
		"-c:a", "aac",
		"-b:a", "192k",
		"-movflags", "+faststart",
	})
	if ok {
		return outBytes, ".mp4", true, nil
	}

	return raw, origExt, false, nil
}

// ==========================================
// HELPERS
// ==========================================

// ffmpegConvert pipes rawBytes through ffmpeg and returns the output bytes.
// Returns (nil, false) if ffmpeg is not on PATH or conversion fails.
func ffmpegConvert(raw []byte, inExt, outExt string, args []string) ([]byte, bool) {
	if _, err := exec.LookPath("ffmpeg"); err != nil {
		return nil, false
	}

	tmpIn, err := os.CreateTemp("", "satu-sekolah-in-*"+inExt)
	if err != nil {
		return nil, false
	}
	defer os.Remove(tmpIn.Name())
	if _, err := tmpIn.Write(raw); err != nil {
		return nil, false
	}
	tmpIn.Close()

	tmpOut, err := os.CreateTemp("", "satu-sekolah-out-*"+outExt)
	if err != nil {
		return nil, false
	}
	tmpOutName := tmpOut.Name()
	tmpOut.Close()
	os.Remove(tmpOutName) // ffmpeg will create it
	defer os.Remove(tmpOutName)

	cmdArgs := []string{"-y", "-i", tmpIn.Name()}
	cmdArgs = append(cmdArgs, args...)
	cmdArgs = append(cmdArgs, tmpOutName)

	cmd := exec.Command("ffmpeg", cmdArgs...)
	if err := cmd.Run(); err != nil {
		return nil, false
	}

	outBytes, err := os.ReadFile(tmpOutName)
	if err != nil || len(outBytes) == 0 {
		return nil, false
	}
	return outBytes, true
}

// classifyMIME maps a MIME type or filename extension to a MediaCategory.
func classifyMIME(mimeType, filename string) MediaCategory {
	mime := strings.ToLower(strings.Split(mimeType, ";")[0])
	ext := strings.ToLower(filepath.Ext(filename))

	switch {
	case strings.HasPrefix(mime, "image/"):
		return CategoryImage
	case strings.HasPrefix(mime, "audio/"):
		return CategoryAudio
	case strings.HasPrefix(mime, "video/"):
		return CategoryVideo
	case mime == "application/pdf",
		mime == "application/msword",
		mime == "application/vnd.openxmlformats-officedocument.wordprocessingml.document",
		mime == "application/vnd.ms-excel",
		mime == "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
		mime == "application/vnd.ms-powerpoint",
		mime == "application/vnd.openxmlformats-officedocument.presentationml.presentation":
		return CategoryDocument
	}

	// Fallback: classify by extension
	switch ext {
	case ".jpg", ".jpeg", ".png", ".gif", ".bmp", ".tiff", ".webp":
		return CategoryImage
	case ".mp3", ".wav", ".ogg", ".flac", ".aac", ".opus", ".m4a":
		return CategoryAudio
	case ".mp4", ".mov", ".avi", ".mkv", ".webm", ".flv", ".wmv":
		return CategoryVideo
	case ".pdf", ".doc", ".docx", ".xls", ".xlsx", ".ppt", ".pptx":
		return CategoryDocument
	}
	return CategoryOther
}

// validateSize checks file size against category-specific limits.
func validateSize(size int64, category MediaCategory) error {
	var maxSize int64
	var label string
	switch category {
	case CategoryImage:
		maxSize, label = MaxImageSize, "image"
	case CategoryDocument:
		maxSize, label = MaxDocumentSize, "document"
	case CategoryAudio:
		maxSize, label = MaxAudioSize, "audio"
	case CategoryVideo:
		maxSize, label = MaxVideoSize, "video"
	default:
		return nil // no limit for CategoryOther
	}
	if size > maxSize {
		return fmt.Errorf("%s file too large: maximum allowed is %d MB (received %.1f MB)",
			label, maxSize/1024/1024, float64(size)/1024/1024)
	}
	return nil
}
