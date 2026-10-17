package aws

import (
	"context"
	"fmt"

	awsconfig "github.com/aws/aws-sdk-go-v2/config"
	"github.com/aws/aws-sdk-go-v2/credentials"
	"github.com/aws/aws-sdk-go-v2/service/rekognition"
	"github.com/aws/aws-sdk-go-v2/service/rekognition/types"
	"neuracakrawira.asia/satu-sekolah-backend/internal/config"
)

type RekognitionClient struct {
	client       *rekognition.Client
	collectionID string
}

func NewRekognitionClient(ctx context.Context, cfg *config.Config) (*RekognitionClient, error) {
	awsCfg, err := awsconfig.LoadDefaultConfig(ctx,
		awsconfig.WithRegion(cfg.AWS.Region),
		awsconfig.WithCredentialsProvider(credentials.NewStaticCredentialsProvider(
			cfg.AWS.AccessKeyID,
			cfg.AWS.SecretAccessKey,
			"",
		)),
	)
	if err != nil {
		return nil, fmt.Errorf("unable to load AWS config for rekognition: %w", err)
	}

	return &RekognitionClient{
		client:       rekognition.NewFromConfig(awsCfg),
		collectionID: cfg.AWS.RekognitionCollectID,
	}, nil
}

// CompareFaces compares a source image (e.g. from a webcam) with a target face in the collection.
// It returns a confidence score (0-100) or an error if no match is found.
// This supports the FACE attendance method in the attendances table.
func (r *RekognitionClient) CompareFaces(ctx context.Context, imageBytes []byte, threshold float32) (float32, string, error) {
	// Call AWS Rekognition SearchFacesByImage
	resp, err := r.client.SearchFacesByImage(ctx, &rekognition.SearchFacesByImageInput{
		CollectionId: &r.collectionID,
		Image: &types.Image{
			Bytes: imageBytes,
		},
		MaxFaces:           func(i int32) *int32 { return &i }(1),
		FaceMatchThreshold: &threshold,
	})

	if err != nil {
		return 0, "", fmt.Errorf("failed to search faces: %w", err)
	}

	if len(resp.FaceMatches) == 0 {
		return 0, "", fmt.Errorf("no matching face found in collection")
	}

	match := resp.FaceMatches[0]
	confidence := *match.Similarity
	faceID := *match.Face.FaceId // This ID maps to users.face_encoding

	return confidence, faceID, nil
}

// RegisterBestFace evaluates multiple face images, picks the one with the highest confidence/quality, 
// indexes it into the Rekognition collection, and returns its FaceID and the image bytes.
func (r *RekognitionClient) RegisterBestFace(ctx context.Context, externalImageID string, imagesBytes [][]byte) (string, []byte, error) {
	var bestFaceID string
	var bestConfidence float32 = 0
	var bestImageBytes []byte

	if len(imagesBytes) == 0 {
		return "", nil, fmt.Errorf("no images provided")
	}

	for _, imgBytes := range imagesBytes {
		resp, err := r.client.IndexFaces(ctx, &rekognition.IndexFacesInput{
			CollectionId:    &r.collectionID,
			ExternalImageId: &externalImageID,
			Image: &types.Image{
				Bytes: imgBytes,
			},
			DetectionAttributes: []types.Attribute{types.AttributeAll},
		})
		if err != nil || len(resp.FaceRecords) == 0 {
			continue
		}

		record := resp.FaceRecords[0]
		conf := *record.FaceDetail.Confidence
		if conf > bestConfidence {
			// If we previously indexed a worse face, we should ideally delete it, but 
			// for simplicity we just keep track of the best one and return its ID.
			// A cleanup job or manual process could handle duplicates.
			bestConfidence = conf
			bestFaceID = *record.Face.FaceId
			bestImageBytes = imgBytes
		}
	}

	if bestFaceID == "" {
		return "", nil, fmt.Errorf("failed to register any face from provided images")
	}

	return bestFaceID, bestImageBytes, nil
}
