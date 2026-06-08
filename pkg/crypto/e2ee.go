package crypto

import (
	"crypto/rsa"
	"crypto/x509"
	"encoding/pem"
	"errors"
)

// ParsePublicKey parses a PEM encoded RSA public key.
// This is used to validate the client's public key before saving it to the `users` table for E2EE chats.
func ParsePublicKey(pubPEM string) (*rsa.PublicKey, error) {
	block, _ := pem.Decode([]byte(pubPEM))
	if block == nil {
		return nil, errors.New("failed to parse PEM block containing the public key")
	}

	pub, err := x509.ParsePKIXPublicKey(block.Bytes)
	if err != nil {
		return nil, err
	}

	switch pub := pub.(type) {
	case *rsa.PublicKey:
		return pub, nil
	default:
		return nil, errors.New("unknown type of public key")
	}
}

// IsValidPublicKey string is a convenience wrapper to check validity of a string based PEM
func IsValidPublicKey(pubPEM string) bool {
	_, err := ParsePublicKey(pubPEM)
	return err == nil
}
