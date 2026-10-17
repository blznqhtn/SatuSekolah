package main

import (
	"database/sql"
	"log"
	"os"
	"os/signal"
	"syscall"

	"github.com/golang-migrate/migrate/v4"
	migratedb "github.com/golang-migrate/migrate/v4/database"
	"github.com/golang-migrate/migrate/v4/database/mysql"
	"github.com/golang-migrate/migrate/v4/database/postgres"
	"github.com/golang-migrate/migrate/v4/database/sqlite3"
	_ "github.com/golang-migrate/migrate/v4/source/file"
	"neuracakrawira.asia/satu-sekolah-backend/internal/config"
	"neuracakrawira.asia/satu-sekolah-backend/internal/delivery/http"
	"neuracakrawira.asia/satu-sekolah-backend/internal/infrastructure/database"
)

func main() {
	// 1. Load Configuration
	cfg, err := config.LoadConfig()
	if err != nil {
		log.Fatalf("Failed to load config: %v", err)
	}

	// 2. Initialize Database Connection based on Driver
	var db *sql.DB
	if cfg.Database.Driver == "mysql" {
		db, err = database.NewMySQLConnection(cfg)
		if err != nil {
			log.Fatalf("Failed to open MySQL database connection: %v", err)
		}
		log.Println("Successfully connected to MySQL Database!")
	} else if cfg.Database.Driver == "sqlite" {
		db, err = database.NewSQLiteConnection(cfg)
		if err != nil {
			log.Fatalf("Failed to open SQLite database connection: %v", err)
		}
		log.Println("Successfully connected to SQLite Database!")
	} else {
		db, err = database.NewPostgresConnection(cfg)
		if err != nil {
			log.Fatalf("Failed to open PostgreSQL database connection: %v", err)
		}
		log.Println("Successfully connected to PostgreSQL Database!")
	}
	defer db.Close()

	// 2.5 Run Auto Migration
	log.Printf("Running auto-migration for %s...", cfg.Database.Driver)
	var migrationDriver migratedb.Driver
	var errMigration error

	switch cfg.Database.Driver {
	case "mysql":
		migrationDriver, errMigration = mysql.WithInstance(db, &mysql.Config{})
	case "sqlite":
		migrationDriver, errMigration = sqlite3.WithInstance(db, &sqlite3.Config{})
	default:
		migrationDriver, errMigration = postgres.WithInstance(db, &postgres.Config{})
	}

	if errMigration != nil {
		log.Fatalf("Could not create migration driver: %v", errMigration)
	}

	m, err := migrate.NewWithDatabaseInstance(
		"file://migrations/"+cfg.Database.Driver,
		cfg.Database.Driver,
		migrationDriver,
	)
	if err != nil {
		log.Fatalf("Migration init failed: %v", err)
	}
	if err := m.Up(); err != nil && err != migrate.ErrNoChange {
		log.Fatalf("Migration execution failed: %v", err)
	}
	log.Println("Database schema is up to date!")

	// 3. Setup Fiber Router
	app := http.SetupRouter(db, cfg)

	// 3. Start Server with Graceful Shutdown
	go func() {
		log.Println("Starting Server on port 8080...")
		if err := app.Listen(":8080"); err != nil {
			log.Fatalf("Failed to start server: %v", err)
		}
	}()

	// Wait for interrupt signal to gracefully shutdown the server
	quit := make(chan os.Signal, 1)
	signal.Notify(quit, os.Interrupt, syscall.SIGTERM)
	<-quit

	log.Println("Gracefully shutting down server...")
	if err := app.Shutdown(); err != nil {
		log.Fatalf("Server Shutdown Failed:%+v", err)
	}
	log.Println("Server exiting")
}