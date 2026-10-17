# Satu Sekolah Monorepo

Struktur monorepo proyek Satu Sekolah:

- **`frontend_web/`**: Aplikasi Web Frontend berbasis Next.js, React, Tailwind CSS, dan TypeScript.
- **`backend_api/`**: RESTful Backend API berbasis Golang Fiber v2, PostgreSQL, dan Redis.

---

## Panduan Menjalankan Proyek

### 1. Frontend Web (`frontend_web/`)
```bash
cd frontend_web
npm install
npm run dev
```
Website dapat diakses melalui `http://localhost:3000`.

### 2. Backend API (`backend_api/`)
```bash
cd backend_api
go run ./cmd/server
```
API server berjalan di port `8080` (atau sesuai konfigurasi di `.env`).
