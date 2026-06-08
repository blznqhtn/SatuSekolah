package config

import (
	"github.com/spf13/viper"
)

// Config holds all application configuration loaded from environment variables.
type Config struct {
	App      AppConfig
	Database DBConfig
	Redis    RedisConfig
	AWS      AWSConfig
	Gemini   GeminiConfig
	Ledger   LedgerConfig
	Midtrans MidtransConfig
	JWT      JWTConfig
}

type AppConfig struct {
	Port          string
	Env           string
	// EncryptionKey must be exactly 32 characters; used for AES-256-GCM encryption of S3 URLs, chats, journals etc.
	EncryptionKey string
	CacheDriver   string // "redis" or "database"
}

type JWTConfig struct {
	Secret string
}

type DBConfig struct {
	Driver   string
	Host     string
	Port     string
	User       string
	Password   string
	DBName     string
	SSLMode    string
	SQLitePath string
}

type RedisConfig struct {
	Host       string
	Port       string
	Password   string
	DB         int
	TTLSeconds int
}

type AWSConfig struct {
	Region               string
	AccessKeyID          string
	SecretAccessKey      string
	S3Bucket             string
	RekognitionCollectID string
}

type GeminiConfig struct {
	APIKey           string
	Model            string
	DefaultTokenLimit int64
}

// LedgerConfig holds the HMAC secret for Web3 ledger hash chaining.
// WARNING: This secret MUST NEVER change after going to production.
type LedgerConfig struct {
	HMACSecret string
}

type MidtransConfig struct {
	ServerKey            string
	ClientKey            string
	IsProduction         bool
	PricePerMillionToken int64
}

// LoadConfig reads configuration from the .env file and environment variables.
func LoadConfig() (*Config, error) {
	viper.AddConfigPath("./")
	viper.SetConfigName(".env")
	viper.SetConfigType("env")
	viper.AutomaticEnv()

	// Ignore error if .env file not found (e.g., in production, env vars are set directly)
	_ = viper.ReadInConfig()

	cfg := &Config{}

	cfg.App.Port = viper.GetString("APP_PORT")
	if cfg.App.Port == "" {
		cfg.App.Port = "8080"
	}
	cfg.App.Env = viper.GetString("APP_ENV")
	cfg.App.EncryptionKey = viper.GetString("APP_ENCRYPTION_KEY")
	cfg.App.CacheDriver = viper.GetString("CACHE_DRIVER")
	if cfg.App.CacheDriver == "" {
		cfg.App.CacheDriver = "database"
	}

	cfg.JWT.Secret = viper.GetString("JWT_SECRET")

	cfg.Database.Driver = viper.GetString("DB_DRIVER")
	if cfg.Database.Driver == "" {
		cfg.Database.Driver = "postgres"
	}
	cfg.Database.Host = viper.GetString("DB_HOST")
	cfg.Database.Port = viper.GetString("DB_PORT")
	cfg.Database.User = viper.GetString("DB_USER")
	cfg.Database.Password = viper.GetString("DB_PASSWORD")
	cfg.Database.DBName = viper.GetString("DB_NAME")
	cfg.Database.SSLMode = viper.GetString("DB_SSLMODE")
	if cfg.Database.SSLMode == "" {
		cfg.Database.SSLMode = "disable"
	}
	cfg.Database.SQLitePath = viper.GetString("SQLITE_DB_PATH")
	if cfg.Database.SQLitePath == "" {
		cfg.Database.SQLitePath = "./satu_sekolah.db"
	}

	cfg.Redis.Host = viper.GetString("REDIS_HOST")
	cfg.Redis.Port = viper.GetString("REDIS_PORT")
	cfg.Redis.Password = viper.GetString("REDIS_PASSWORD")
	cfg.Redis.DB = viper.GetInt("REDIS_DB")
	cfg.Redis.TTLSeconds = viper.GetInt("REDIS_TTL_SECONDS")
	if cfg.Redis.TTLSeconds == 0 {
		cfg.Redis.TTLSeconds = 300
	}

	cfg.AWS.Region = viper.GetString("AWS_REGION")
	cfg.AWS.AccessKeyID = viper.GetString("AWS_ACCESS_KEY_ID")
	cfg.AWS.SecretAccessKey = viper.GetString("AWS_SECRET_ACCESS_KEY")
	cfg.AWS.S3Bucket = viper.GetString("AWS_S3_BUCKET")
	cfg.AWS.RekognitionCollectID = viper.GetString("AWS_REKOGNITION_COLLECTION_ID")

	cfg.Gemini.APIKey = viper.GetString("GEMINI_API_KEY")
	cfg.Gemini.Model = viper.GetString("GEMINI_MODEL")
	if cfg.Gemini.Model == "" {
		cfg.Gemini.Model = "gemini-2.5-flash"
	}
	cfg.Gemini.DefaultTokenLimit = viper.GetInt64("AI_DEFAULT_TOKEN_LIMIT")
	if cfg.Gemini.DefaultTokenLimit == 0 {
		cfg.Gemini.DefaultTokenLimit = 2_000_000
	}

	// CRITICAL: The HMAC secret for immutable ledger hash chaining.
	cfg.Ledger.HMACSecret = viper.GetString("LEDGER_HMAC_SECRET")

	cfg.Midtrans.ServerKey = viper.GetString("MIDTRANS_SERVER_KEY")
	cfg.Midtrans.ClientKey = viper.GetString("MIDTRANS_CLIENT_KEY")
	cfg.Midtrans.IsProduction = viper.GetBool("MIDTRANS_IS_PRODUCTION")
	cfg.Midtrans.PricePerMillionToken = viper.GetInt64("MIDTRANS_PRICE_PER_MILLION_TOKEN")
	if cfg.Midtrans.PricePerMillionToken == 0 {
		cfg.Midtrans.PricePerMillionToken = 10
	}

	return cfg, nil
}
