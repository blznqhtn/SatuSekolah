package ai

import (
	"bytes"
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"io"
	"net/http"
	"strings"

	"github.com/google/uuid"
	"neuracakrawira.asia/satu-sekolah-backend/internal/config"
	aiDomain "neuracakrawira.asia/satu-sekolah-backend/internal/modules/ai/domain"
)

// GeminiClient wraps calls to the Gemini API with tenant quota enforcement.
type GeminiClient struct {
	apiKey       string
	model        string
	defaultLimit int64
	aiRepo       aiDomain.AIRepository
}

// NewGeminiClient creates a GeminiClient that enforces quota before every API call.
func NewGeminiClient(cfg *config.Config, aiRepo aiDomain.AIRepository) *GeminiClient {
	return &GeminiClient{
		apiKey:       cfg.Gemini.APIKey,
		model:        cfg.Gemini.Model,
		defaultLimit: cfg.Gemini.DefaultTokenLimit,
		aiRepo:       aiRepo,
	}
}

// EstimateTokens provides a rough estimate: ~4 chars per token (industry standard for English).
// For Bahasa Indonesia, it's roughly similar. This is a conservative estimate.
func EstimateTokens(text string) int64 {
	return int64(len(text)/4) + 1
}

// CheckAndDeductQuota verifies that the tenant has enough tokens, then deducts them.
// If quota is insufficient, it returns an error immediately — the AI call is NOT made.
func (g *GeminiClient) CheckAndDeductQuota(ctx context.Context, tenantID uuid.UUID, estimatedInput, estimatedOutput int64) error {
	quota, err := g.aiRepo.GetQuota(ctx, tenantID)
	if err != nil {
		return fmt.Errorf("failed to get AI quota: %w", err)
	}
	if quota == nil {
		return errors.New("AI quota not initialized for this tenant. Please contact admin")
	}

	remainingInput := quota.TotalInputTokens - quota.InputTokensUsed
	remainingOutput := quota.TotalOutputTokens - quota.OutputTokensUsed
	
	if remainingInput < estimatedInput || remainingOutput < estimatedOutput {
		return fmt.Errorf("insufficient AI token quota. Input needed %d (rem: %d), Output needed %d (rem: %d). Please top up", estimatedInput, remainingInput, estimatedOutput, remainingOutput)
	}

	// Deduct tokens immediately (pre-pay model to prevent over-usage)
	return g.aiRepo.AddTokensUsed(ctx, tenantID, estimatedInput, estimatedOutput)
}

// GenerateResponse calls Gemini API with quota enforcement.
// It checks quota BEFORE the call and deducts estimated tokens.
func (g *GeminiClient) GenerateResponse(ctx context.Context, tenantID uuid.UUID, prompt string) (string, int64, error) {
	// 1. Estimate tokens (input + expected output)
	inputTokens := EstimateTokens(prompt)
	estimatedOutputTokens := inputTokens * 2 // Conservative: assume output is 2x input
	totalEstimate := inputTokens + estimatedOutputTokens

	// 2. Check and deduct quota BEFORE making the API call
	if err := g.CheckAndDeductQuota(ctx, tenantID, inputTokens, estimatedOutputTokens); err != nil {
		return "", 0, err
	}

	// 3. Call Gemini API
	apiURL := fmt.Sprintf("https://generativelanguage.googleapis.com/v1beta/models/%s:generateContent?key=%s", g.model, g.apiKey)

	reqBody := geminiRequestBody{
		Contents: []geminiContent{
			{
				Parts: []geminiPart{
					{Text: prompt},
				},
			},
		},
	}
	reqBytes, _ := json.Marshal(reqBody)

	httpReq, err := http.NewRequestWithContext(ctx, "POST", apiURL, bytes.NewBuffer(reqBytes))
	if err != nil {
		return "", 0, fmt.Errorf("failed to create request: %w", err)
	}
	httpReq.Header.Set("Content-Type", "application/json")

	client := &http.Client{}
	resp, err := client.Do(httpReq)
	if err != nil {
		return "", 0, fmt.Errorf("failed to call gemini api: %w", err)
	}
	defer resp.Body.Close()

	bodyBytes, err := io.ReadAll(resp.Body)
	if err != nil {
		return "", 0, fmt.Errorf("failed to read response: %w", err)
	}

	if resp.StatusCode != http.StatusOK {
		return "", 0, fmt.Errorf("gemini api returned error %d: %s", resp.StatusCode, string(bodyBytes))
	}

	var aiResp geminiResponseBody
	if err := json.Unmarshal(bodyBytes, &aiResp); err != nil {
		return "", 0, fmt.Errorf("failed to parse response: %w", err)
	}

	if len(aiResp.Candidates) == 0 || len(aiResp.Candidates[0].Content.Parts) == 0 {
		return "", 0, errors.New("gemini api returned empty response")
	}

	aiText := aiResp.Candidates[0].Content.Parts[0].Text
	return aiText, totalEstimate, nil
}

// Request & Response structs for Gemini API
type geminiRequestBody struct {
	Contents []geminiContent `json:"contents"`
}

type geminiResponseBody struct {
	Candidates []geminiCandidate `json:"candidates"`
}

type geminiCandidate struct {
	Content geminiContent `json:"content"`
}

type geminiContent struct {
	Parts []geminiPart `json:"parts"`
}

type geminiPart struct {
	Text string `json:"text"`
}

// GradeEssay uses Gemini to grade a student's essay with quota enforcement.
// Returns: score (0-100), feedback text, tokens used, error
func (g *GeminiClient) GradeEssay(ctx context.Context, tenantID uuid.UUID, studentAnswer, referenceAnswer string) (float64, string, int64, error) {
	prompt := fmt.Sprintf(`You are an expert Staff grading an essay.
Reference Answer: %s
Student Answer: %s

Provide a score (0-100) and brief feedback.
Format: SCORE|FEEDBACK`, referenceAnswer, studentAnswer)

	resp, tokensUsed, err := g.GenerateResponse(ctx, tenantID, prompt)
	if err != nil {
		return 0, "", 0, err
	}

	// Parse response
	parts := strings.Split(resp, "|")
	if len(parts) >= 2 {
		score := 0.0
		fmt.Sscanf(strings.TrimSpace(parts[0]), "%f", &score)
		return score, strings.TrimSpace(parts[1]), tokensUsed, nil
	}

	return 0, resp, tokensUsed, nil
}

func min(a, b int) int {
	if a < b {
		return a
	}
	return b
}
