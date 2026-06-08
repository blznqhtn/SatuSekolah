package crypto

import (
	"crypto/hmac"
	"crypto/sha256"
	"encoding/hex"
	"fmt"
)

// GenerateLedgerHash creates a cryptographically secure HMAC-SHA256 hash for ledger chaining.
// The secret is loaded from env LEDGER_HMAC_SECRET so the hash cannot be forged externally.
//
// Formula: HMAC-SHA256(secret, previousHash | amount | timestamp | id)
//
// WARNING: The 'secret' parameter must come from config.LedgerConfig.HMACSecret.
// This value MUST NEVER change after going to production, or all existing hash chains will be invalidated.
func GenerateLedgerHash(secret, previousHash string, amount float64, timestamp string, id string) string {
	data := fmt.Sprintf("%s|%.2f|%s|%s", previousHash, amount, timestamp, id)
	mac := hmac.New(sha256.New, []byte(secret))
	mac.Write([]byte(data))
	return hex.EncodeToString(mac.Sum(nil))
}

// VerifyLedgerHash verifies if the currentHash is valid for the given inputs and secret.
// Use this to audit ledger integrity — if it returns false, the record has been tampered with.
func VerifyLedgerHash(secret, previousHash string, amount float64, timestamp string, id string, currentHash string) bool {
	expected := GenerateLedgerHash(secret, previousHash, amount, timestamp, id)
	return hmac.Equal([]byte(expected), []byte(currentHash))
}
