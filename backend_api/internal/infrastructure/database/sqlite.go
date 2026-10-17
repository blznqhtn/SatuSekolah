package database

import (
	"database/sql"
	"fmt"

	_ "github.com/mattn/go-sqlite3"
	"neuracakrawira.asia/satu-sekolah-backend/internal/config"
)

// NewSQLiteConnection establishes a connection to a SQLite database.
func NewSQLiteConnection(cfg *config.Config) (*sql.DB, error) {
	if cfg.Database.SQLitePath == "" {
		return nil, fmt.Errorf("SQLite path (SQLITE_DB_PATH) is not configured")
	}

	db, err := sql.Open("sqlite3", cfg.Database.SQLitePath)
	if err != nil {
		return nil, err
	}

	if err := db.Ping(); err != nil {
		return nil, err
	}

	return db, nil
}
