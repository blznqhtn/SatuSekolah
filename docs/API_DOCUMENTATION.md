# 📚 Dokumentasi API — Satu Sekolah Backend

> **Versi:** 1.0  
> **Base URL:** `http://localhost:8080/api/v1`  
> **Arsitektur:** Modular Monolith (DDD) — Web2 dengan Prinsip Keamanan Web3  
> **Framework:** Go Fiber v2 + (PostgreSQL/MySQL/Sqlite) + Redis

---

## 📑 Daftar Isi

1. [Autentikasi & Otorisasi](#1-autentikasi--otorisasi)
2. [Pendaftaran Tenant & Admin](#2-pendaftaran-tenant--admin)
3. [Sistem Keuangan (Wallet Ledger)](#3-sistem-keuangan-wallet-ledger)
4. [AI Token Quota](#4-ai-token-quota)
5. [Kantin Digital](#5-kantin-digital-digital-canteen)
6. [Surat Izin Keluar (Gate Pass)](#6-surat-izin-keluar-gate-pass)
7. [Unit Kesehatan Sekolah (UKS)](#7-unit-kesehatan-sekolah-uks)
8. [CBA — Computer Based Assessment (Ujian)](#8-cba--computer-based-assessment-ujian)
9. [Daftar Seluruh Endpoint](#9-daftar-seluruh-endpoint)
10. [Skema Biaya Transaksi](#10-skema-biaya-transaksi)
11. [Arsitektur Keamanan](#11-arsitektur-keamanan)
12. [Hubungan Orang Tua & Anak (SPMB)](#12-hubungan-orang-tua--anak-spmb)
13. [Komunikasi (WebSocket Chat E2EE)](#13-komunikasi-websocket-chat-e2ee)
14. [Modul Inventaris (Sarana & Prasarana)](#14-modul-inventaris-sarana--prasarana)
15. [Batasan Akses Admin](#15-batasan-akses-admin)

---

## 1. Autentikasi & Otorisasi

### Login
```
POST /api/v1/users/login
```

**Body:**
```json
{
  "email": "admin@smktelesandi.sch.id",
  "password": "secret123"
}
```

**Response (200):**
```json
{
  "token": "eyJhbGciOiJIUzI1NiIs...",
  "user": {
    "id": "uuid",
    "name": "Admin Telesandi",
    "category": "admin",
    "tenant_id": "uuid"
  }
}
```

> **Catatan:** Semua endpoint (kecuali `/tenants/register`, `/users/login`, dan `/webhooks/*`) memerlukan header `Authorization: Bearer <token>`.

---

## 2. Pendaftaran Tenant & Admin

### Mendaftarkan Sekolah Baru + Akun Admin

Endpoint ini dipanggil oleh **web utama** saat pelanggan membeli service. Sistem akan mengeksekusi **5 operasi dalam 1 Database Transaction** (atomik):

1. ✅ Buat data Sekolah (Tenant)
2. ✅ Buat 4 Role bawaan: Admin, Staff, Student, Parent (dengan `is_custom = false`)
3. ✅ Ambil ID Role "Admin"
4. ✅ Buat User dengan kategori `admin`
5. ✅ Assign Role Admin ke User tersebut

> ℹ️ Sub-role/divisi kustom lainnya (seperti divisi untuk role Staff dengan `is_custom = true`) akan dibuat oleh admin dari dalam dashboard sekolah setelah masuk.

```
POST /api/v1/tenants/register
```

**Body:**
```json
{
  "tenant_name": "SMK Telesandi",
  "tenant_domain": "smktelesandi.sch.id",
  "admin_name": "Budi Santoso",
  "admin_email": "admin@smktelesandi.sch.id",
  "admin_password": "hashed_or_plaintext_password"
}
```

**Response (201):**
```json
{
  "message": "Tenant and Admin successfully created",
  "data": {
    "id": "c8f0e5a7-...",
    "name": "SMK Telesandi",
    "domain": "smktelesandi.sch.id",
    "created_at": "2026-06-01T12:00:00Z"
  }
}
```

> ⚠️ Jika terjadi error di langkah manapun (misal email admin sudah terdaftar), **seluruh operasi di-rollback**. Tidak akan ada data "yatim" (tenant tanpa admin).

---

## 3. Sistem Keuangan (Wallet Ledger)

Wallet Satu Sekolah menggunakan konsep **Immutable Ledger** terinspirasi blockchain. Setiap transaksi memiliki hash kriptografi yang saling berantai.

### 3.1 Top-up Saldo

User melakukan top-up via Midtrans (QRIS/VA/Debit). Biaya admin **dipotong dari nominal top-up**, bukan dibebankan sebagai tambahan.

```
POST /api/v1/finance/ledger/transaction
```

**Contoh Skenario:**
```
User A topup Rp 300.000 via Debit Card
├── Fee Gateway (flat)  : Rp 4.000
├── Margin Platform     : Rp 1.000
├── Total Fee           : Rp 5.000
└── Saldo Diterima      : Rp 295.000 (CREDIT)
```

**Record di Database:**
```json
{
  "transaction_type": "CREDIT",
  "amount": 295000,
  "fee": 5000,
  "reference_type": "TOPUP",
  "previous_hash": "abc123...",
  "current_hash": "def456..."
}
```

### 3.2 Penarikan Saldo (ke Rekening/DANA/dll)
```
POST /api/v1/finance/withdraw
```

### 3.3 Pembayaran Tagihan Sekolah (Internal VA 15-Digit)
Siswa dapat menggunakan saldo *Satu Sekolah* mereka untuk melunasi tagihan (SPP/dll) tanpa potong admin bank. Kasir keuangan menyodorkan kode VA 15 digit.
```
GET /api/v1/finance/invoices/va/:va
POST /api/v1/finance/invoices/pay-va
```
`GET` untuk mengambil nama tagihan secara otomatis di HP siswa. `POST` untuk eksekusi bayar memotong saldo (memerlukan `pin`). Kode VA akan otomatis hangus setelah lunas.

Penarikan menggunakan **Midtrans IRIS**. Fee dihitung terpisah dan ditambahkan ke total potongan.

```
POST /api/v1/finance/ledger/transaction
```

**Contoh Skenario:**
```
User A tarik Rp 200.000 ke rekening BCA
├── Saldo Dipotong (Amount) : Rp 200.000
├── Fee IRIS (flat)     : Rp 5.000
├── Margin Platform 5%  : Rp 10.000
├── Total Fee           : Rp 15.000
└── Diterima di Rekening: Rp 185.000
```

**Record di Database:**
```json
{
  "transaction_type": "DEBIT",
  "amount": 200000,
  "fee": 15000,
  "reference_type": "WITHDRAWAL"
}
```

### 3.3 Transfer Internal (P2P)

Transfer antar akun di dalam platform. **GRATIS tanpa biaya admin**.

Berlaku untuk semua kombinasi:
- 👨‍🎓 Siswa → Siswa
- 👨‍🎓 Siswa → 👨‍🏫 Guru
- 👨‍🏫 Guru → 👨‍🏫 Guru
- 👩‍👧 Orang Tua → Anak (Child)
- 👩‍👧 Orang Tua → 👨‍🏫 Guru
- 👨‍🏫 Guru → 👩‍👧 Orang Tua
- 💰 Penggajian (PAYROLL)

```
POST /api/v1/finance/transfer
```

**Body:**
```json
{
  "tenant_id": "uuid",
  "sender_id": "uuid-parent",
  "receiver_id": "uuid-child",
  "amount": 50000
}
```

**Proses Internal (1 DB Transaction, 2 Ledger Entries):**
```
Sender  → DEBIT  Rp 50.000 (Fee: 0) | ref: TRANSFER_OUT | ref_id: receiver_id
Receiver → CREDIT Rp 50.000 (Fee: 0) | ref: TRANSFER_IN  | ref_id: sender_id
```

---

## 4. Manajemen AI (Kuota & Kontrol Fitur)

Setiap sekolah (Tenant) mendapatkan **1 Juta token input & 1 Juta token output gratis** saat pertama kali mendaftar. Token ini digunakan untuk fitur AI menggunakan model Gemini. Seluruh penggunaan dikontrol melalui endpoint modul AI.

### 4.1 Kontrol Modul AI & Limit

Mengizinkan admin atau peran dengan permission `MANAGE_AI` untuk mengaktifkan AI per-modul (contoh: `HEALTH`, `CANTEEN`) dan mengatur limit penggunaannya harian/bulanan.

```
GET /api/v1/admin/ai/modules
PUT /api/v1/admin/ai/modules/:module
GET /api/v1/admin/ai/modules/:module/status
```

### 4.2 Cek Sisa Kuota Global

```
GET /api/v1/admin/ai/quota/:tenant_id
```

**Response (200):**
```json
{
  "data": {
    "tenant_id": "uuid",
    "total_input_tokens": 1000000,
    "input_tokens_used": 150000,
    "input_tokens_remaining": 850000,
    "total_output_tokens": 1000000,
    "output_tokens_used": 50000,
    "output_tokens_remaining": 950000
  }
}
```

### 4.3 Beli Paket Token (via Midtrans)

Harga: **$10 per 1 Juta token (Masing-masing untuk Input & Output)**. Minimal pembelian 1 paket.

```
POST /api/v1/admin/ai/buy-tokens
```

**Body:**
```json
{
  "tenant_id": "uuid",
  "packages": 3
}
```

**Response (200):**
```json
{
  "message": "Checkout created",
  "data": {
    "packages": 3,
    "total_input_added": 3000000,
    "total_output_added": 3000000,
    "price_usd": 30,
    "price_idr": 450000,
    "price_formatted": "Rp 450.000"
  }
}
```

### 4.4 Pemotongan Kuota Otomatis

Setiap kali fitur AI digunakan (LMS, Kantin, Kesehatan), sistem di backend akan mengestimasi token Input dan Output yang akan digunakan. Jika kuota *Input* atau *Output* tidak mencukupi, permintaan akan langsung ditolak (tanpa menghubungi Gemini API), sehingga biaya terkontrol 100%.

### 4.5 Webhook Pembayaran Token (Midtrans Callback)

```
POST /api/v1/webhooks/midtrans/ai-tokens
```

Dipanggil otomatis oleh Midtrans setelah pembayaran berhasil. Kuota tenant akan bertambah secara instan.

> **Filosofi:** Biaya penggunaan Gemini API adalah tanggung jawab Tenant. Platform tidak menanggung kelebihan pemakaian. Tenant bisa top-up kapan saja.

---

## 5. Kantin Digital (Digital Canteen)

Kantin Digital memungkinkan Ibu Kantin membuka toko, siswa memesan makanan via keranjang (Pre-order/Antar/POS statis), dan melakukan pembayaran langsung memotong saldo wallet Web3 yang divalidasi dengan PIN.

### 5.1 Owner: Membuka Toko & Menambah Item
```
POST /api/v1/canteen/shop
POST /api/v1/canteen/items
POST /api/v1/canteen/discounts
```
Masing-masing toko mendapat `static_qr_code` unik yang bisa dicetak untuk POS di kantin.

### 5.2 Buyer: Checkout Keranjang (Pre-order / Delivery)
```
POST /api/v1/canteen/checkout
```
Membutuhkan `pin` wallet pengguna. Jika `is_delivery` true, tambahan `delivery_fee` akan dipotong.

### 5.3 Cashier: Buat Pesanan POS
```
POST /api/v1/canteen/pos/order
```
Kasir (Kantin) membuat pesanan baru dan memilih metode pembayaran (contoh: `RFID`). Sistem akan menghasilkan **3 kode sekaligus** secara otomatis: `dynamic_qr_code`, `rfid_payment_code`, dan `transfer_target_account` (VA 15 Digit). Semua kode valid selama 24 jam.

### 5.3.1 Cashier: Ganti Metode Pembayaran
```
PATCH /api/v1/canteen/pos/orders/:id/payment-method
```
Jika siswa ingin mengubah cara bayar, kasir memanggil endpoint ini (misal mengganti dari `RFID` ke `TRANSFER`). **Sistem tidak akan me-generate kode baru**, melainkan memunculkan kode yang sudah dicetak sejak pesanan dibuat.

### 5.4 Buyer: Bayar POS (QR Dinamis)
```
POST /api/v1/canteen/pay-dynamic-qr
```
Pembeli melakukan scan kode QR dinamis yang dihasilkan kasir dan memasukkan `pin`. Saldo terpotong dan masuk ke Ledger Ibu Kantin secara real-time.

### 5.5 IoT: Bayar POS (RFID & Mesin IoT)
```
GET /api/v1/iot/canteen/order/:rfidPaymentCode
POST /api/v1/iot/canteen/pay-rfid
```
Mesin IoT pertama akan memanggil endpoint `GET` untuk menampilkan tagihan di layar mesin. Setelah pembeli menempelkan kartu (tap) dan memasukkan PIN di mesin, mesin memanggil endpoint `pay-rfid`. Pembayaran RFID dikenakan biaya admin Rp500.

### 5.6 Buyer: Bayar POS (Virtual Account Kantin 15 Digit)
```
GET /api/v1/canteen/order/va/:va
POST /api/v1/canteen/pay-va
```
Siswa yang ingin membayar dengan metode *Transfer In-App* mengetikkan VA 15-digit yang diberikan kasir. Sistem merespon dengan nominal pasti, dan siswa memasukkan PIN untuk memotong saldo. VA otomatis hangus setelah dibayar.
```
Pembeli menggunakan fitur transfer saldo biasa. Jika memasukkan nomor rekening VA Kantin (15 digit: rekening kantin + kode unik), sistem akan mendeteksi otomatis dan membayarkan pesanan kantin tanpa biaya admin tambahan.

### 5.7 Owner: Laporan Keuangan & Insight AI
```
GET /api/v1/canteen/reports/financial?start=YYYY-MM-DD&end=YYYY-MM-DD
GET /api/v1/canteen/reports/insight?month=YYYY-MM
```
`financial` mengembalikan *Gross Profit*, *Total Cost* (Modal Bahan Baku), dan *Net Profit* secara presisi.
`insight` menggunakan AI untuk menganalisa performa penjualan dan memberikan rekomendasi aksi bisnis (hanya aktif jika modul AI `CANTEEN` dinyalakan).

---

## 6. Surat Izin Keluar (Gate Pass)

Sistem perizinan keluar siswa dengan validasi bertingkat (multilevel approval) dan kode QR ganda ala MRT.

### 6.1 Admin: Konfigurasi Approver
```
POST /api/v1/admin/gatepass/settings
```
Mengatur hingga 3 jenjang approver (misal: Walas -> TU -> Kesiswaan), plus 1 `main_approver` yang bisa *override* (menyetujui tier mana pun) jika berhalangan.

### 6.2 Student: Pengajuan Izin
```
POST /api/v1/gatepass/request
```
Mengisi jam keluar, jam kembali, dan alasan. Menghasilkan status `PENDING`.

### 6.3 Approver: Proses Izin
```
POST /api/v1/gatepass/:id/approve
```
Tier level otomatis disesuaikan dengan role. Jika seluruh tier tuntas disetujui, tiket keluar (`exit_qr_token`) dibuat.

### 6.4 Guard: Scan Keluar (Tap-In)
```
POST /api/v1/gatepass/scan-exit
```
Jika valid, tiket keluar dinonaktifkan, status berubah menjadi `EXITED`, dan tiket kembali (`return_qr_token`) digenerate di aplikasi siswa.

### 6.5 Guard: Scan Kembali (Tap-Out)
```
POST /api/v1/gatepass/scan-return
```
Jika valid, status berubah menjadi `RETURNED`. Jika melewati `expected_return_time`, cron job akan mengubah status menjadi `OVERDUE` dan memicu notifikasi.

---

## 7. Unit Kesehatan Sekolah (UKS)

Sistem UKS Lanjutan yang mencakup pencatatan kesehatan lengkap (TB, BB, HB, Pendengaran, Mata, Gigi), pemantauan siklus haid, dan peminjaman pita haid untuk siswi.

### 7.1 Admin: Konfigurasi Petugas UKS
```
POST /api/v1/admin/health/settings
```
**Body:**
```json
{
  "health_admin_user_id": "uuid-guru-yang-ditugaskan"
}
```
Menugaskan seorang guru sebagai Petugas UKS (Sub-Role). Hanya Admin yang bisa mengatur ini.

### 7.2 Petugas UKS: Pencatatan Kesehatan
```
POST /api/v1/health/records
```
**Body:**
```json
{
  "user_id": "uuid-pasien-siswa-atau-guru",
  "record_type": "CHECKUP",
  "height": 165.5,
  "weight": 55.0,
  "hearing": "Normal",
  "vision": "Minus 1",
  "dental": "Gigi berlubang 1",
  "hemoglobin": 12.5,
  "notes": "Kondisi umum baik"
}
```
Hanya bisa dilakukan oleh guru yang ditugaskan sebagai Petugas UKS. Pasien bisa siswa maupun guru.

### 7.3 User: Lihat Riwayat Kesehatan
```
GET /api/v1/health/records
```
Menampilkan seluruh riwayat pemeriksaan kesehatan pengguna yang login.

### 7.4 Female User: Mulai Siklus Haid
```
POST /api/v1/health/cycles/start
```
**Body:**
```json
{
  "symptoms": "Kram perut, pusing ringan"
}
```
Jika modul AI `HEALTH` aktif di `ai_module_settings`, sistem Gemini akan memberikan saran kesehatan otomatis.

### 7.5 Female User: Hentikan Siklus Haid
```
POST /api/v1/health/cycles/stop
```
**⚠️ PENTING:** Jika siklus sudah berjalan > 7 hari, pengguna **tidak bisa** menghentikannya sendiri. Status berubah menjadi `BLOCKED_OVERDUE` dan harus dihentikan oleh Petugas UKS melalui force-stop.

### 7.6 Siswi: Pinjam Pita Haid
```
POST /api/v1/health/ribbons/borrow
```
**Syarat:**
- Harus memiliki siklus haid `ONGOING`.
- Maksimal 1 pita per siswi.
- Guru perempuan **tidak boleh** meminjam pita.

### 7.7 Petugas UKS: Lihat Daftar Overdue
```
GET /api/v1/health/watchlist
```
Menampilkan daftar siswi dan guru perempuan yang siklusnya > 7 hari beserta pita yang belum dikembalikan.

### 7.8 Petugas UKS: Hentikan Paksa Siklus & Pita
```
POST /api/v1/health/force-stop
```
**Body:**
```json
{
  "cycle_id": "uuid-siklus",
  "sanction_notes": "Diminta membawa pembalut cadangan ke sekolah"
}
```
Menghentikan siklus haid dan mengembalikan pita secara paksa, dengan opsi memberikan sanksi/catatan.

---

## 8. Academic & LMS

#### 8.1. Create Course
- **URL**: `/api/v1/academic/courses`

---

## 9. Daftar Seluruh Endpoint

### 🔓 Public (Tanpa Auth)
| Method | Endpoint | Deskripsi |
|--------|----------|-----------|
| `POST` | `/tenants/register` | Daftarkan sekolah + admin |
| `POST` | `/users/login` | Login & dapatkan JWT |
| `GET`  | `/public/schools` | Daftar sekolah untuk pendaftaran baru |
| `GET`  | `/health` | Health check server |
| `POST` | `/webhooks/midtrans/ai-tokens` | Callback Midtrans |

### 🔐 Admin Only (`/admin/...`)
| Method | Endpoint | Deskripsi |
|--------|----------|-----------|
| `GET`  | `/admin/ai/quota/:tenant_id` | Lihat sisa kuota AI global |
| `POST` | `/admin/ai/buy-tokens` | Beli paket token AI |
| `GET`  | `/admin/ai/modules` | Lihat daftar & status AI per modul |
| `PUT`  | `/admin/ai/modules/:module` | Toggle & set limit penggunaan AI |
| `GET`  | `/admin/ai/modules/:module/status` | Cek sisa kuota AI spesifik modul |
| `POST` | `/admin/health/settings` | Assign Petugas UKS |
| `POST` | `/admin/pkg/periods` | Buat periode PKG |
| `POST` | `/admin/pkg/indicators` | Buat indikator PKG |
| `POST` | `/admin/pkg/evaluations` | Evaluasi submission PKG |
| `GET`  | `/admin/pkg/average` | Rata-rata kinerja guru |

### 👤 Authenticated Users
| Method | Endpoint | Deskripsi |
|--------|----------|-----------|
| `GET`  | `/users/profile` | Profil user |
| `GET`  | `/tenants/:id` | Profil sekolah |
| `GET`  | `/finance/ledger/history` | Riwayat transaksi wallet |
| `POST` | `/finance/transfer` | Transfer saldo P2P (wajib PIN) |
| `GET`  | `/academic/courses` | Daftar mata pelajaran |
| `POST` | `/academic/courses` | Buat kursus baru |
| `POST` | `/academic/modules` | Buat modul kursus |
| `POST` | `/academic/submissions` | Kumpulkan tugas |
| `POST` | `/academic/assign-target` | Tugaskan ke kelas/jurusan |
| `GET`  | `/cba/quizzes` | Daftar kuis/ujian |
| `POST` | `/cba/quizzes` | Buat kuis CBA |
| `POST` | `/cba/questions` | Tambah soal (media) |
| `POST` | `/cba/options` | Tambah opsi soal |
| `POST` | `/cba/answers` | Jawab kuis |
| `POST` | `/attendance/check-in` | Presensi masuk |
| `GET`  | `/health/records` | Riwayat kesehatan |
| `POST` | `/health/records` | Catat kesehatan (UKS) |
| `POST` | `/health/cycles/start` | Mulai siklus haid |
| `POST` | `/health/cycles/stop` | Hentikan siklus haid |
| `POST` | `/health/ribbons/borrow` | Pinjam pita haid |
| `GET`  | `/health/watchlist` | Daftar overdue (UKS) |
| `GET`  | `/permissions` | Lihat daftar *permissions* |
| `GET`  | `/finance/ledger/history` | Riwayat transaksi wallet (PDF) |
| `GET`  | `/finance/midtrans/client-key` | Dapatkan Midtrans client key |
| `GET`  | `/violations/types` | Daftar jenis poin pelanggaran |
| `POST` | `/violations/types` | Buat jenis pelanggaran baru |
| `PATCH`| `/violations/types/:id/toggle` | Aktifkan/nonaktifkan jenis |
| `DELETE`| `/violations/types/:id` | Hapus jenis pelanggaran |
| `POST` | `/violations/record` | Catat pelanggaran pada user |
| `GET`  | `/violations/users/:user_id` | Riwayat poin pelanggaran user |
| `POST` | `/health/force-stop` | Hentikan paksa (UKS) |
| `POST` | `/pkg/submissions` | Upload bukti PKG |
| `GET`  | `/pkg/submissions` | Status evaluasi PKG |
| `GET`  | `/reports/attendance` | Laporan presensi |
| `GET`  | `/reports/financial` | Laporan keuangan |
| `GET`  | `/reports/academic` | Laporan akademik |
| `GET`  | `/library/books` | Katalog buku |
| `GET`  | `/career/vacancies/local` | Lowongan kerja di sekolah ini (lokal) |
| `GET`  | `/career/vacancies/public` | Lowongan kerja publik (lintas sekolah) |
| `POST` | `/career/vacancies` | Buat lowongan (BKK/Admin) |
| `POST` | `/career/vacancies/:id/apply` | Melamar pekerjaan |
| `GET`  | `/career/applications/my` | Riwayat lamaran saya |
| `GET`  | `/career/vacancies/:id/applications` | Daftar pelamar (BKK/Admin) |
| `PATCH`| `/career/applications/:appId/review` | Review lamaran (BKK/Admin) |
| `GET`  | `/performance/records` | Kinerja guru |
| `GET`  | `/communication/announcements` | Pengumuman |
| `GET`  | `/communication/contacts` | Daftar kontak untuk chat (filter per role + public key E2EE) |
| `GET`  | `/chat/:room_id/history` | Riwayat pesan obrolan (ciphertext, dekripsi di client) |
| `WS`   | `/ws/chat/:room_id` | Koneksi WebSocket real-time (auth via payload pertama) |
| `PUT`  | `/users/profile/public-key` | Upload public key E2EE device baru |
| `GET`  | `/inventory/items` | Inventaris sarana prasarana sekolah (cached) |
| `POST` | `/inventory/items` | Tambah barang inventaris (MANAGE_INVENTORY) |
| `POST` | `/inventory/items/:id/reports` | Laporkan kondisi barang & auto-submit PKG |
| `GET`  | `/portfolio/` | Lihat portfolio lengkap (LinkedIn style) |
| `PUT`  | `/portfolio/` | Update summary & CV URL |
| `POST` | `/portfolio/experiences` | Tambah pengalaman kerja |
| `POST` | `/portfolio/import/linkedin` | Import portfolio dari PDF LinkedIn |
| `GET`  | `/spmb/batches` | Lihat gelombang SPMB |
| `POST` | `/spmb/register` | Kirim form pendaftaran SPMB |
| `PATCH`| `/spmb/registrations/:id/approve` | Setujui pendaftaran (Admin) |
| `POST` | `/spmb/registrations/:id/reregister` | Bayar daftar ulang |
| `POST` | `/finance/fees/generate` | Generate tagihan massal (Keuangan) |
| `GET`  | `/finance/invoices` | Lihat daftar tagihan |
| `GET`  | `/finance/invoices/va/:va` | **Auto-fetch tagihan via VA 15 digit** (preview, tanpa PIN) |
| `POST` | `/finance/invoices/pay-va` | **Bayar tagihan via VA 15 digit** (wajib PIN, VA hangus setelah lunas) |
| `POST` | `/finance/invoices/pay-dynamic-qr` | Bayar tagihan via QR Dinamis (wajib PIN) |
| `POST` | `/finance/invoices/:id/pay-cash` | Bayar tunai via Midtrans Snap (Admin Keuangan) |
| `GET`  | `/finance/reports/invoices` | Rekap laporan tagihan (Admin Keuangan) |
| `GET`  | `/iot/finance/invoice/:code` | Info tagihan untuk mesin RFID (IoT) |
| `POST` | `/iot/finance/pay-rfid` | Bayar tagihan via Tap RFID (IoT) |
| `POST` | `/canteen/shop` | Buat toko kantin (Kantin) |
| `POST` | `/canteen/items` | Tambah menu toko (Kantin) |
| `POST` | `/canteen/discounts` | Buat diskon harga (Kantin) |
| `POST` | `/canteen/cart` | Tambah ke keranjang (Pembeli) |
| `POST` | `/canteen/checkout` | Checkout keranjang, saldo terpotong (wajib PIN) |
| `POST` | `/canteen/pos/order` | **Buat pesanan POS — generate semua kode sekaligus** (Kasir) |
| `PATCH`| `/canteen/pos/orders/:id/payment-method` | **Ganti metode pembayaran** tanpa generate ulang (Kasir) |
| `POST` | `/canteen/pay-dynamic-qr` | Bayar pesanan kantin via QR (wajib PIN, Pembeli) |
| `GET`  | `/canteen/order/va/:va` | **Auto-fetch pesanan kantin via VA 15 digit** (preview, tanpa PIN) |
| `POST` | `/canteen/pay-va` | **Bayar pesanan kantin via VA 15 digit** (wajib PIN, VA hangus setelah lunas) |
| `GET`  | `/iot/canteen/order/:code` | Ambil info tagihan mesin IoT (IoT Kantin) |
| `POST` | `/iot/canteen/pay-rfid` | Bayar via RFID Tap + PIN (IoT Kantin) |
| `PATCH`| `/canteen/orders/:id/status` | Update status pesanan (Kasir) |
| `GET`  | `/canteen/reports/financial` | Laporan laba/rugi (Kantin) |
| `GET`  | `/canteen/reports/insight` | Saran AI untuk kantin (Kantin) |
| `GET`  | `/cba/time` | Waktu server (CBA) |
| `POST` | `/cba/folders` | Buat folder ujian (CBA) |
| `GET`  | `/cba/folders` | Daftar folder (CBA) |
| `PUT`  | `/cba/folders/:id/refresh-token` | Refresh token folder (CBA) |
| `POST` | `/cba/folders/:id/verify-token` | Verifikasi token (CBA — Siswa) |
| `GET`  | `/cba/folders/:id/exams` | Ujian hari ini (CBA — Siswa) |
| `POST` | `/cba/exams` | Buat ujian (CBA) |
| `POST` | `/cba/exam-questions` | Tambah soal (CBA) |
| `POST` | `/cba/exam-options` | Tambah pilihan jawaban (CBA) |
| `POST` | `/cba/exams/:id/join` | Masuk waiting room (CBA — Siswa) |
| `POST` | `/cba/exams/:id/start` | Mulai ujian (CBA — Siswa) |
| `GET`  | `/cba/exams/:id/questions` | Ambil soal + state (CBA — Siswa) |
| `POST` | `/cba/exams/:id/answers` | Simpan jawaban (CBA — Siswa) |
| `POST` | `/cba/exams/:id/submit` | Submit ujian (CBA — Siswa) |

---

## 8. CBA — Computer Based Assessment (Ujian)

Modul ujian berbasis komputer (CBT) berstandar UTBK/SNBT. Login menggunakan akun yang sama dengan portal siswa (NISN/Email + Password). Waktu ujian menggunakan **waktu server** sepenuhnya — mengubah jam di perangkat siswa tidak berpengaruh.

### 8.1 Waktu Server
```
GET /api/v1/cba/time
```
**Response:**
```json
{ "server_time": "2026-06-06T14:30:00Z", "unix": 1749220200 }
```

### 8.2 Manajemen Folder (MANAGE_CBA)

Folder = kategori ujian, misal "Ujian Tengah Semester", "Ulangan Harian".

```
POST  /api/v1/cba/folders              — Buat folder
GET   /api/v1/cba/folders              — Lihat semua folder
PUT   /api/v1/cba/folders/:id/refresh-token  — Refresh token (5 menit)
POST  /api/v1/cba/folders/:id/verify-token   — Verifikasi token (siswa)
GET   /api/v1/cba/folders/:id/exams    — Ujian hari ini di folder
```

**Mekanisme Token:**
- Token terdiri dari 6 karakter alfanumerik (contoh: `A3F9C2`)
- Dibuat otomatis oleh sistem, berlaku **5 menit**, lalu di-*refresh* kembali
- Token berlaku untuk banyak siswa (shared per folder)
- Digunakan hanya untuk verifikasi awal akses folder — setelah itu siswa bisa melihat daftar ujian hari ini

**Body buat folder:**
```json
{ "name": "Ujian Tengah Semester", "description": "UTS Genap 2025/2026" }
```

**Body verify token:**
```json
{ "token": "A3F9C2" }
```

### 8.3 Manajemen Ujian (MANAGE_CBA)

```
POST /api/v1/cba/exams              — Buat ujian
POST /api/v1/cba/exam-questions     — Tambah soal
POST /api/v1/cba/exam-options       — Tambah pilihan jawaban
```

**Body buat ujian:**
```json
{
  "folder_id": "uuid",
  "title": "UTS Matematika Kelas X",
  "terms_and_conditions": "Dilarang melihat catatan...",
  "start_time": "2026-06-07T08:00:00Z",
  "end_time": "2026-06-07T09:30:00Z",
  "waiting_room_open_minutes": 5,
  "show_results": false
}
```

> **`show_results: false`** — Nilai disembunyikan dari siswa. Guru/Admin yang menentukan kapan nilai diumumkan.

**Status ujian (dihitung realtime dari waktu server):**
| Status | Kondisi |
|--------|----------|
| `NOT_STARTED` | Sebelum `start_time - waiting_room_open_minutes` |
| `WAITING_ROOM` | Dalam window waiting room (T-5 menit s/d start) |
| `ONGOING` | Antara `start_time` dan `end_time` |
| `ENDED` | Setelah `end_time` |

### 8.4 Alur Siswa (UTBK-Style)

```
1. GET  /cba/time                      — Sync waktu server di frontend
2. POST /cba/folders/:id/verify-token  — Masukkan token dari pengawas
3. GET  /cba/folders/:id/exams         — Lihat daftar ujian hari ini
4. POST /cba/exams/:id/join            — Masuk Waiting Room + baca syarat
   ↳ Akan menunggu 1 menit countdown sebelum tombol "Mulai" aktif
5. POST /cba/exams/:id/start           — Mulai ujian (server-time gated)
6. GET  /cba/exams/:id/questions       — Ambil soal + state jawaban saat ini
   ↳ Response termasuk: StudentProfile (panel kiri), Questions + Options
7. POST /cba/exams/:id/answers         — Simpan/update jawaban (per soal)
   ↳ Gunakan is_doubt: true untuk fitur "Ragu-ragu"
8. POST /cba/exams/:id/submit          — Submit manual
   ↳ Jika waktu habis, sistem auto-submit secara serentak di background
```

**Body save answer:**
```json
{
  "session_id": "uuid",
  "question_id": "uuid",
  "option_id": "uuid",
  "is_doubt": false
}
```

**Response GET questions (panel tengah + kanan + kiri):**
```json
{
  "student": {
    "name": "Budi Santoso",
    "nisn": "1234567890",
    "photo_url": "",
    "major_name": "Teknik Komputer & Jaringan",
    "class_name": "X TKJ 1"
  },
  "questions": [
    {
      "id": "uuid",
      "order_index": 1,
      "question_type": "MULTIPLE_CHOICE",
      "question_text": "Berapa hasil dari 2 + 2?",
      "options": [
        { "id": "uuid", "option_text": "3" },
        { "id": "uuid", "option_text": "4" }
      ],
      "student_option_id": "uuid-jawaban-terpilih",
      "is_doubt": false,
      "is_answered": true
    }
  ]
}
```

**Response submit:**
```json
{ "message": "Exam submitted successfully", "status": "SUBMITTED", "score": 87.5 }
// Jika show_results: false:
{ "message": "Exam submitted successfully", "status": "SUBMITTED", "note": "Your results will be announced by the teacher." }
```

### 8.5 Auto-Submit Serentak

Background goroutine berjalan setiap **30 detik** dan secara otomatis men-submit semua sesi ujian yang `status = ONGOING` dan waktu server sudah melampaui `end_time`. Ini memastikan seluruh siswa selesai ujian **secara serentak** pada waktu yang ditentukan, tidak peduli kapan mereka mulai mengerjakan.

---

## 10. Skema Biaya Transaksi

| Jenis Transaksi | Biaya Gateway | Margin Platform | Total Fee | Saldo Terpengaruh |
|-----------------|---------------|-----------------|-----------|-------------------|
| **Top-up** (QRIS/VA/Debit) | Rp 4.000 | Rp 1.000 | **Rp 5.000** | Dipotong dari nominal topup |
| **Tarik Saldo** (IRIS) | Rp 5.000 | 5% dari nominal | **Rp 5.000 + 5%** | Ditambahkan ke potongan saldo |
| **Transfer P2P** (Internal) | Rp 0 | Rp 0 | **GRATIS** | Langsung pindah |
| **Beli Token AI** | Via Midtrans | - | **$10/1M token** | Tidak lewat wallet |

---

## 11. Arsitektur Keamanan

### 11.1 Immutable Ledger (Hash Chaining)

Setiap transaksi wallet di-hash menggunakan **HMAC-SHA256** dengan secret key dari environment variable (`LEDGER_HMAC_SECRET`).

```
current_hash = HMAC-SHA256(
    secret,
    previous_hash | amount | timestamp | id
)
```

**Jaminan Keamanan:**
- ❌ Transaksi tidak bisa di-edit (Append-Only)
- ❌ Transaksi tidak bisa dihapus
- ❌ Jika 1 record diubah, seluruh chain sesudahnya akan invalid
- ❌ Tanpa `LEDGER_HMAC_SECRET`, hash tidak bisa dipalsukan

### 11.2 True End-to-End Encryption (E2EE) — Pesan Chat

Sistem chat kini menggunakan model **True E2EE** layaknya WhatsApp/Signal. Backend berperan sebagai **kurir buta** — ia **tidak pernah** dapat membaca isi pesan.

**Cara kerja:**
1. Saat login pertama di *device* baru, klien men-*generate* pasangan kunci kriptografi (RSA-OAEP / X25519) **di dalam device**.
2. Klien meng-*upload* **Public Key** ke server via `PUT /users/profile/public-key`.
3. Saat akan mengirim pesan, pengirim mengambil **public key milik penerima** dari daftar kontak (`GET /communication/contacts`).
4. Klien pengirim mengenkripsi pesan menggunakan **public key penerima** di device-nya, lalu mengirim *ciphertext* ke server.
5. Server menyimpan dan mem-*broadcast* ciphertext **apa adanya** tanpa membuka atau mengubahnya.
6. Hanya penerima yang memegang **private key** (tersimpan di device lokal) yang bisa mendekripsi pesan.

> 🔒 **Bahkan jika server backend diretas sepenuhnya, isi pesan chat tetap tidak bisa dibaca.**

> 📖 Untuk panduan implementasi frontend lengkap beserta *code sample* JavaScript:
> lihat [`docs/E2EE_FRONTEND_INTEGRATION.md`](./E2EE_FRONTEND_INTEGRATION.md)

---

## 12. Hubungan Orang Tua & Anak (SPMB)

### Alur Pendaftaran Siswa Baru

```
1. Orang Tua mendaftar di Global App
2. Orang Tua memilih sekolah & gelombang SPMB
3. Orang Tua membayar formulir pendaftaran (via Midtrans → Wallet Ledger)
4. Admin sekolah me-review dan meng-ACCEPT pendaftaran
5. ✅ Sistem OTOMATIS:
   ├── Membuat akun siswa baru (users.category = 'student')
   ├── Mengisi users.parent_id = ID Orang Tua
   ├── Set enrollment_status = 'CANDIDATE'
   └── Generate invoice Daftar Ulang otomatis
6. Setelah Daftar Ulang LUNAS:
   ├── enrollment_status berubah ke 'ACTIVE'
   └── Siswa bisa akses LMS, Jadwal, Kantin, dll.
```

### Parent-Child Binding

Satu orang tua bisa memiliki beberapa anak (`users.parent_id` = self-relation).

**Saat bayar tagihan atau transfer saldo:**
1. Orang tua login ke aplikasi
2. Pilih anak yang dituju (`GET /users/children`)
3. Pilih jenis transaksi (Bayar SPP, Transfer Saldo Kantin, dll.)
4. Konfirmasi PIN 6 digit (`users.pin_hash`)

**Transfer tanpa batasan:**
- Orang Tua → Anak (saldo kantin)
- Anak → Anak lain (antar siswa)
- Siapapun → Siapapun (layaknya bank digital)
- Semuanya **GRATIS** tanpa biaya admin

---

## 13. Komunikasi (WebSocket Chat — True E2EE)

Modul chat menggunakan model **True End-to-End Encryption** layaknya WhatsApp/Signal. Backend adalah **kurir buta**: hanya meneruskan ciphertext tanpa bisa membaca isi pesan. Untuk detail implementasi di sisi *frontend*, lihat [`docs/E2EE_FRONTEND_INTEGRATION.md`](./E2EE_FRONTEND_INTEGRATION.md).

### 13.1 Upload Public Key (E2EE Setup)
```
PUT /api/v1/users/profile/public-key
```
**Auth:** JWT Required  
**Deskripsi:** Upload public key perangkat pengguna ke server. Dipanggil **setiap login di perangkat baru** setelah key pair di-generate di sisi klien.

**Body:**
```json
{ "public_key": "<Base64 SPKI public key>" }
```

### 13.2 Daftar Kontak + Public Key
```
GET /api/v1/communication/contacts
```
**Auth:** JWT Required  
**Deskripsi:** Mengembalikan daftar kontak beserta `public_key` masing-masing, digunakan pengirim untuk mengenkripsi pesan di sisi klien sebelum dikirim. Kontak difilter berdasarkan peran:
- **Siswa**: Teman satu kelas dan seluruh staf.
- **Orang Tua**: Anak mereka, teman anak, orang tua teman anak, dan seluruh staf.
- **Staf / Admin**: Semua pengguna satu tenant.

**Response:**
```json
{
  "data": {
    "students": [ { "id": "...", "name": "...", "public_key": "..." } ],
    "parents":  [ ... ],
    "staff":    [ ... ]
  }
}
```

### 13.3 Riwayat Obrolan (Ciphertext)
```
GET /api/v1/chat/:room_id/history
```
**Auth:** JWT Required  
**Deskripsi:** Mengembalikan riwayat pesan dalam bentuk *raw ciphertext*. **Server tidak mendekripsi.** Klien bertanggung jawab mendekripsi setiap pesan menggunakan *private key* yang tersimpan di perangkat.

### 13.4 WebSocket Chat Real-Time
```
WS /ws/chat/:room_id
```
**Deskripsi:** Koneksi *full-duplex* untuk chat *real-time*. Tidak ada token di URL.

**Protokol Autentikasi (Payload-Based Auth):**  
Setelah koneksi WS terbuka, klien **WAJIB** mengirim pesan pertama berupa:
```json
{ "type": "auth", "token": "<JWT Token>" }
```
Jika berhasil, server membalas:
```json
{ "type": "auth_ok" }
```
Jika gagal (token salah/expired), server mengirim pesan error lalu menutup koneksi:
```json
{ "error": "invalid or expired token", "code": 4003 }
```
**Timeout:** Server menunggu maksimal **10 detik** untuk pesan auth. Jika tidak ada, koneksi diputus.

**Format pesan chat (setelah auth):**
```json
{ "type": "message", "content": "<Base64-ciphertext>" }
```

---

## 14. Modul Inventaris (Sarana & Prasarana)

Modul ini mengelola pencatatan sarana dan prasarana sekolah. Modul ini terintegrasi langsung dengan sistem **Caching** untuk mempercepat akses baca ke publik, serta memiliki integrasi otomasi dengan **Penilaian Kinerja Guru/Staf (PKG)**.

### 14.1 Daftar Inventaris (Publik)
```
GET /api/v1/inventory/items
```
**Deskripsi:** Mengembalikan daftar barang, kondisi, dan stok di sekolah. Dapat diakses oleh semua pengguna. Sistem menggunakan **Redis / Memory Cache** (dengan *Cache Invalidation*) untuk memastikan *endpoint* ini berkinerja tinggi.

### 14.2 Kelola Inventaris & Auto-Submit PKG (Khusus `MANAGE_INVENTORY`)
```
POST /api/v1/inventory/items
POST /api/v1/inventory/items/:id/reports
```
**Deskripsi:** Staf pengelola dapat menambah barang dan membuat laporan pembaruan kondisi barang (rusak/baik).
**Otomasi PKG:** Saat staf memanggil *endpoint* pelaporan kondisi (`/reports`) beserta `document_url` (foto bukti), *backend* akan **secara otomatis men-submit dokumen tersebut** ke dalam E-Kinerja (PKG) staf yang bersangkutan pada indikator *"Laporan Inventaris"*.

---

## 15. Batasan Akses Admin

Admin sekolah memiliki akses penuh ke manajemen, **TETAPI** dibatasi secara teknis dari data sensitif:

### ✅ Admin BISA:
| Aksi | Endpoint/Modul |
|------|----------------|
| Membuat akun guru/karyawan | `/admin/users/create` |
| Menonaktifkan akun | `/admin/users/deactivate` |
| Mengatur role & permission | `/admin/roles/*` |
| Mengelola konfigurasi sekolah | `/admin/settings/*` |
| Mengelola perangkat presensi | `/admin/attendance/devices` |
| Melihat log & audit trail | `/admin/audit-logs` |
| Reset password user | `/admin/users/reset-password` |
| Melihat statistik sistem | `/admin/dashboard` |
| Mengelola kuota AI | `/admin/ai/quota/*` |

### ❌ Admin TIDAK BISA:
| Pembatasan | Mekanisme Teknis |
|------------|------------------|
| Mengubah transaksi wallet | Tabel `wallet_ledgers` adalah **Append-Only** (tidak ada SQL `UPDATE`/`DELETE`) |
| Mengubah nilai tervalidasi | `student_answers.ai_score` bersifat read-only setelah di-set oleh AI |
| Membaca pesan terenkripsi | Field `encrypted_content` dienkripsi RSA — admin hanya melihat ciphertext |
| Mengubah audit trail | Audit log bersifat **Append-Only** (sama seperti ledger) |
| Menghapus histori transaksi | Tidak ada fungsi `DELETE` di `LedgerRepository` |

---

## 📎 Environment Variables

Semua konfigurasi disimpan di file `.env`. Referensi lengkap ada di file `.env.example`.

| Variable | Contoh | Keterangan |
|----------|--------|------------|
| `LEDGER_HMAC_SECRET` | `random64chars...` | 🔴 **JANGAN PERNAH DIGANTI** setelah production |
| `GEMINI_API_KEY` | `AIza...` | API Key Google Gemini |
| `MIDTRANS_SERVER_KEY` | `SB-Mid-server-...` | Server key Midtrans |
| `AI_DEFAULT_TOKEN_LIMIT` | `2000000` | Kuota default per tenant baru |
| `REDIS_TTL_SECONDS` | `300` | Cache expiry (5 menit) |

---

> 🏗️ **Catatan Developer:** Dokumentasi ini akan terus diperbarui seiring penambahan endpoint baru. Untuk kontribusi, pastikan setiap endpoint baru memiliki entry di tabel routing dan test case yang sesuai.
