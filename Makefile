DB_URL_POSTGRES=postgresql://postgres:postgres@localhost:5432/satu_sekolah?sslmode=disable
DB_URL_MYSQL=mysql://root:root@tcp(localhost:3306)/satu_sekolah
DB_URL_SQLITE=sqlite3://satu_sekolah.db

# Defaults
DB_URL=$(DB_URL_MYSQL)
MIGRATION_DIR=migrations/mysql

migrate-up:
	migrate -path $(MIGRATION_DIR) -database "$(DB_URL)" -verbose up

migrate-down:
	migrate -path $(MIGRATION_DIR) -database "$(DB_URL)" -verbose down

migrate-create:
	migrate create -ext sql -dir $(MIGRATION_DIR) -seq $(name)

run:
	go run cmd/server/main.go

test:
	go test -v ./...

docker-up:
	docker-compose -f deployments/docker-compose.yml up -d --build

docker-down:
	docker-compose -f deployments/docker-compose.yml down
