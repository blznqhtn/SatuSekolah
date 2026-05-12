package config

import (
	"context"
	"log"
	"io"
	"os"
	"strconv"

	"github.com/aws/aws-sdk-go-v2/config"
	"github.com/aws/aws-sdk-go-v2/service/rekognition"
	"github.com/aws/aws-sdk-go-v2/service/s3"
)

// ==========================================
// GLOBAL AWS CLIENTS (SINGLETON) 
// ==========================================
var (
	S3Client                *s3.Client
	RekognitionClient       *rekognition.Client
	S3Bucket                string
	S3BaseURL               string
	RekognitionCollectionID string
)

func InitAWS() {
	region := os.Getenv("AWS_DEFAULT_REGION")
	if region == "" {
		region = "ap-southeast-1"
	}

	cfg, err := config.LoadDefaultConfig(context.TODO(),
		config.WithRegion(region),
	)

	if err != nil {
		log.Fatalf("[AWS FATAL] Gagal memuat konfigurasi AWS: %v", err)
	}

	usePathStyle, _ := strconv.ParseBool(os.Getenv("AWS_USE_PATH_STYLE_ENDPOINT"))

	S3Client = s3.NewFromConfig(cfg, func(o *s3.Options) {
		o.UsePathStyle = usePathStyle
	})

	S3Bucket = os.Getenv("AWS_BUCKET")
	S3BaseURL = "https://" + S3Bucket + ".s3." + region + ".amazonaws.com"

	RekognitionClient = rekognition.NewFromConfig(cfg)
	
	collectionID := os.Getenv("AWS_REKOGNITION_COLLECTION")
	if collectionID == "" {
		collectionID = "sehadir_faces_collection" 
	}
	RekognitionCollectionID = collectionID

	log.Println("[🚀 SERVER] AWS S3 & Rekognition berhasil diinisialisasi")
}

// ==========================================
// HELPERS
// ==========================================

func UploadToS3(file io.Reader, key string, contentType string) (string, error) {
	_, err := S3Client.PutObject(context.TODO(), &s3.PutObjectInput{
		Bucket:      &S3Bucket,
		Key:         &key,
		Body:        file,
		ContentType: &contentType,
	})
	if err != nil {
		return "", err
	}

	url := S3BaseURL + "/" + key
	return url, nil
}

func DeleteFromS3(key string) error {
	_, err := S3Client.DeleteObject(context.TODO(), &s3.DeleteObjectInput{
		Bucket: &S3Bucket,
		Key:    &key,
	})
	return err
}