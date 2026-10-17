# Fitur dan Akses Berdasarkan Role (Role-Based Features)

Dokumen ini merangkum hak akses (API endpoint) apa saja yang tersedia untuk masing-masing peran (role) di dalam platform **Satu Sekolah**. Secara bawaan, tenant memiliki 4 role utama (`Admin`, `Staff`, `Parent`, `Student`). Khusus untuk `Staff`, role ini bersifat fleksibel dan dapat dikembangkan menjadi *custom role* (seperti `Guard`, `Librarian`, `Health Admin`, dll) yang masing-masing memiliki kombinasi *permission* yang unik karena tanggung jawab manajemen setiap staf berbeda-beda.

Semua endpoint dengan *prefix* `/api/v1/` membutuhkan JWT Token (kecuali bagian Publik).

> 🔒 **Enterprise-Grade Security Note:** 
> Seluruh unggahan *file* dari *role* manapun (seperti Siswa mengunggah tugas atau laporan PKL, Guru mengunggah materi Excel) secara *default* diproteksi oleh **Magic Bytes Validator**. Ini mencegah serangan unggahan skrip *malware* (misal `.php` atau `.js`) yang menyamar sebagai ekstensi PDF/Gambar/Excel. Sistem juga dilengkapi *rate limiter* anti *brute-force* pada akses login dan menggunakan 100% *Parameterized Queries* untuk mencegah celah kebocoran basis data (*SQL Injection*).

---

## 🌍 1. Publik (Tanpa Autentikasi)
Endpoint ini dapat diakses oleh siapa saja.

- `POST /users/login` — Login pengguna dan mendapatkan JWT.
- `POST /tenants/register` — Registrasi awal sekolah / tenant (biasanya dipanggil oleh frontend pendaftaran).
- `GET /public/schools` — Melihat daftar sekolah untuk *Orphan Parent* (Orang Tua yang belum terikat).
- `POST /webhooks/midtrans/ai-tokens` — Callback otomatis dari Midtrans setelah pembayaran paket AI selesai.
- `GET /health` — Memeriksa status server (Health Check).

---

## 🧑‍🤝‍🧑 2. Umum (Semua Role Terautentikasi)
Tersedia untuk `Student`, `Parent`, `Staff`, `Admin`, maupun *Custom Role*.

- **Profile & Tenant:**
  - `GET /users/profile` — Melihat profil dan saldo ledger pengguna yang login.
  - `GET /tenants/:id` — Melihat informasi detail tenant (sekolah).
- **Pembelajaran & Penilaian (LMS & CBA):**
  - `GET /academic/courses` — Melihat daftar mata pelajaran.
  - `POST /academic/courses` — **[Staff]** Membuat kursus baru.
  - `POST /academic/submissions` — **[Student]** Mengumpulkan tugas.
  - `POST /academic/assign-target` — **[Staff]** Menugaskan materi/kuis ke kelas, jurusan, atau role tertentu.
  - `GET /cba/quizzes` — Melihat kuis/ujian (Computer Based Assessment).
  - `POST /cba/quizzes` — **[Staff]** Membuat kuis baru.
  - `POST /cba/questions` — **[Staff]** Menambahkan soal dengan media (gambar/audio/video).
  - `POST /cba/options` — **[Staff]** Menambahkan opsi (pilihan ganda, checkbox, tarik garis).
  - `POST /cba/answers` — **[Student]** Menjawab kuis.
  - `GET /performance/records` — Melihat rekapitulasi nilai dan performa.
- **Kehidupan Sekolah & Administrasi:**
  - `POST /attendance/check-in` — Melakukan absensi.
  - `GET /health/records` — Melihat catatan kesehatan pribadi (TB, BB, HB, Mata, Gigi, Pendengaran).
  - `GET /communication/announcements` — Melihat pengumuman sekolah.
  
  - `GET /communication/contacts` — Melihat daftar kontak yang bisa dichat beserta *Public Key*-nya (Difilter dinamis berdasarkan role: siswa melihat teman seangkatan, orang tua melihat relasi anak, staf melihat semua).
  - `GET /chat/:room_id/history` — Melihat riwayat pesan terenkripsi (*raw ciphertext*). Server bertindak sebagai **Kurir Buta** (hanya meneruskan), seluruh proses enkripsi dan dekripsi murni dilakukan di sisi perangkat klien (*True E2EE*).
  - `WS /ws/chat/:room_id` — Terhubung ke WebSocket untuk chat *real-time* (dengan *Payload-Based Authentication* untuk mencegah *token hijacking*).
  - `GET /portfolio/items` — Melihat portofolio karya.
- **Kesehatan Reproduksi (Female Only):**
  - `POST /health/cycles/start` — Memulai siklus haid (bisa mendapatkan saran AI jika modul `HEALTH` aktif).
  - `POST /health/cycles/stop` — Menghentikan siklus haid (diblokir jika > 7 hari, harus via petugas UKS).
- **Fasilitas Tambahan & Pendaftaran:**
  - `GET /library/books` — Mengakses katalog buku (Perpustakaan Digital).
  - `GET /inventory/items` — Melihat daftar inventaris barang sekolah.
  - `GET /career/vacancies` — Melihat lowongan PKL / Bursa Kerja (untuk SMK).
  - `GET /spmb/batches` — Melihat gelombang pendaftaran murid baru.
  - `POST /spmb/register` — Mengirim formulir pendaftaran SPMB.
  - `POST /spmb/registrations/:id/reregister` — Membayar daftar ulang (Re-Register) anak.
- **Dompet Digital (Web3 Ledger) & Tagihan:**
  - `POST /finance/ledger/transaction` — Melakukan transaksi ledger atau transfer (menggunakan PIN Hash).
  - `GET /finance/invoices` — Melihat histori tagihan (SPP, Kegiatan, dll).
  - `POST /finance/invoices/:id/pay` — Membayar tagihan menggunakan PIN Hash via pemotongan Ledger.

---

## 🍔 3. Kantin Digital (Cashless POS Ecosystem)
Akses modul kantin dibagi menjadi **Kasir/Pemilik** (Owner) dan **Pembeli** (Buyer). Seluruh transaksi nirtunas dan menggunakan otorisasi **PIN Hash**.

### 🏪 Kasir / Pemilik Kantin (Staff dengan `MANAGE_CANTEEN`)

**Manajemen Toko & Produk:**
- `POST /canteen/shop` — Mendaftarkan toko kantin baru.
- `PUT /canteen/shop` — Mengubah pengaturan toko, termasuk mengaktifkan **Layanan Delivery** dan biaya antar.
- `POST /canteen/items` — Menambahkan menu lengkap beserta foto, stok, dan **Resep/Bahan Baku (BOM/COGS)** opsional untuk menghitung Harga Pokok Produksi.
- `POST /canteen/discounts` — Membuat diskon untuk produk spesifik atau seluruh toko:
  - Tipe: `PERCENTAGE` atau `FIXED_AMOUNT`.
  - Batas waktu (Start/End Date) untuk *Flash Sale*.
  - Batas kuota pemakaian (`max_uses`).

**Sistem POS Kasir (Point of Sale):**

Kasir kantin berperan sebagai operator transaksi langsung. Alur POS:
1. **Masukkan NISN Pembeli** *(opsional — jika diisi, transaksi akan terhubung ke rekam kesehatan siswa untuk pemantauan gizi/pola makan)*.
2. **Pilih item** yang dibeli dari daftar menu aktif — harga otomatis terakumulasi.
3. **Pilih metode pembayaran**:

   - 📱 **Dynamic QR** — Sistem meng-generate QR unik per transaksi. QR ini **hanya bisa dipindai melalui aplikasi Satu Sekolah** (bukan aplikasi QR umum). QR otomatis kedaluwarsa begitu transaksi berhasil.
   
   - 🏦 **Transfer Saldo Akun (Virtual Account Internal)** — Sistem meng-generate nomor rekening virtual dinamis (format: `{account_number pembeli}{angka acak}`, maks. 15 karakter). Pembeli tinggal mengirim saldo dari menu *Transfer* di aplikasi menggunakan nomor ini. Nomor **otomatis tidak valid** setelah transaksi berhasil *atau* lebih dari 24 jam.
   
   - 📳 **Tap Kartu RFID** — Kasir menekan *Selesai*, sistem meng-generate **kode bayar** unik. Kasir mengetikkan kode tersebut di **terminal IoT RFID**. Pembeli menempelkan kartu RFID → memasukkan PIN → jika saldo mencukupi *(harga + Rp500 biaya layanan)*, saldo otomatis terpotong dan transaksi langsung tercatat di riwayat Ledger kedua pihak.

- `POST /canteen/pos/create-order` — Kasir membuat pesanan POS (NISN opsional + daftar item).
- `POST /canteen/pos/select-payment` — Kasir memilih metode pembayaran dan sistem meng-generate kode/QR/nomor virtual yang sesuai.
- `GET /canteen/pos/order-status/:id` — Kasir memantau status pembayaran secara real-time.
- `PATCH /canteen/orders/:id/status` — Memperbarui status pesanan: `PREPARING` → `READY` → `DELIVERING` → `COMPLETED`.
- `GET /canteen/reports/financial?start=&end=` — Laporan keuangan: *Gross Revenue*, *Total COGS*, *Net Profit*.
- `GET /canteen/reports/insight?month=` — **AI Business Insight** bulanan *(hanya aktif jika modul `CANTEEN` AI dinyalakan)*.

### 🛍️ Pembeli Mandiri (Siswa / Staff / Orang Tua — Pesan dari Aplikasi)
- `POST /canteen/cart` — Menambahkan makanan ke keranjang belanja.
- `POST /canteen/checkout` — Membayar pesanan keranjang dengan pilihan:
  - **Metode pengambilan**: *Pickup* (ambil sendiri) atau *Delivery* (antar ke lokasi).
  - **Waktu pesan**: Langsung atau *Pre-order* (pesan untuk tanggal/jam tertentu).
  - **Metode bayar**: Pemotongan saldo Ledger langsung (otorisasi **PIN**).

---

## 🎫 4. Surat Izin Keluar (Gate Pass)
Menggunakan mekanisme approval bertingkat dan *Dual QR*.

### 👨‍🎓 Siswa (Student)
- `POST /gatepass/request` — Mengajukan permohonan izin keluar (jam & alasan).

### 👨‍🏫 Approver (Staff / Wali Kelas / Kesiswaan)
- `POST /gatepass/:id/approve` — Memberikan persetujuan atau menolak izin pada jenjang tier masing-masing.

### 💂 Satpam (Guard / Security)
- `POST /gatepass/scan-exit` — Memindai QR Keluar dari siswa. (Status menjadi `EXITED`, dan siswa menerima Return QR).
- `POST /gatepass/scan-return` — Memindai QR Kembali dari siswa saat masuk gerbang kembali. (Status menjadi `RETURNED`).

---

## 👑 5. Administrator Sekolah & Kepsek (Admin / Evaluator)
Hak akses eksklusif untuk konfigurasi tingkat tinggi (Super Administrator Tenant) dan manajemen Staff (Guru/Karyawan).

- **Penilaian Kinerja Staff (Guru/Karyawan) (PKG):**
  - `POST /pkg/periods` — Membuat periode penilaian (contoh: Semester Ganjil 2026).
  - `POST /pkg/indicators` — Menambahkan indikator penilaian beserta bobotnya.
  - `POST /pkg/evaluations` — Memberikan nilai pada dokumen bukti yang diunggah Staff (Guru/Karyawan).
  - `GET /pkg/average` — Melihat Rata-rata Kinerja Staff (Guru/Karyawan) (*Fair Average* yang mengabaikan indikator yang tidak relevan).

- **Laporan Tingkat Lanjut (Export PDF/Excel):**
  - `GET /reports/attendance` — Laporan absensi siswa dan Staff (Guru/Karyawan) (Format: JSON, PDF, Excel).
  - `GET /reports/financial` — Laporan mutasi uang masuk/keluar dari dompet ledger (Format: JSON, PDF, Excel).
  - `GET /reports/academic` — Laporan rata-rata nilai siswa per kuis/modul (Format: JSON, PDF, Excel).

- **Konfigurasi UKS (Sub-Role Staff Kesehatan):**
  - `POST /admin/health/settings` — Menugaskan Staff sebagai Petugas UKS (Health Admin).
  - `POST /health/cycles/force-stop` — (Memerlukan izin `MANAGE_HEALTH`) Memberhentikan paksa indikator haid siswa.
  
- **Sistem Penerimaan Murid Baru (SPMB) - (`MANAGE_SPMB`):**
  - `PATCH /spmb/registrations/:id/approve` — Menyetujui pendaftaran dan mengatur jadwal tes ujian seleksi calon siswa baru.

- **Tagihan Keuangan (Finance & Billing) - (`MANAGE_FINANCE`):**
  - `POST /finance/fees/generate` — Meng-generate tagihan massal untuk spesifik kelas atau jurusan.

- **Manajemen Inventaris (Sarana Prasarana) - (`MANAGE_INVENTORY`):**
  - `POST /inventory/items` — Menambahkan barang sarana prasarana baru ke sekolah.
  - `POST /inventory/items/:id/reports` — Melaporkan kondisi barang dan memicu *auto-submit* ke E-Kinerja staf tersebut.

- **Konfigurasi Gate Pass:**
  - `POST /gatepass/settings` — Mengatur rantai *approver* (Tier 1-3) dan `main_approver`.
  - `GET /gatepass/settings` — Melihat konfigurasi *approver* yang aktif saat ini.

- **Manajemen AI Token (Admin Only):**
  - `GET /admin/ai/quota/:tenant_id` — Mengecek sisa Kuota Token Input & Output (Gemini API) untuk sekolah.
  - `POST /admin/ai/buy-tokens` — Melakukan pemesanan / top-up paket Token AI ($10 per 1 Juta Token) via Midtrans.

---

## 🤖 6. Manajemen Fitur AI (`MANAGE_AI` Permission)
Endpoint ini dapat diakses oleh **Admin** (selalu) atau **Staf yang memiliki permission `MANAGE_AI`** (dapat didelegasikan oleh Admin, misalnya ke Operator TI). Ini memungkinkan pengelolaan AI tanpa harus memberikan akses Admin penuh.

- `GET /admin/ai/modules` — Melihat daftar seluruh modul yang mendukung AI, beserta status aktif, batas penggunaan, dan statistik penggunaan harian/bulanan.
- `PUT /admin/ai/modules/:module` — Mengaktifkan/menonaktifkan AI untuk modul tertentu dan mengatur limit:
  - `is_active`: `true`/`false` — Toggle AI on/off.
  - `daily_limit`: Batas maksimal penggunaan AI per hari (0 = tidak dibatasi).
  - `monthly_limit`: Batas maksimal penggunaan AI per bulan (0 = tidak dibatasi).
- `GET /admin/ai/modules/:module/status` — Mengecek status real-time modul tertentu (apakah diizinkan, berapa sudah terpakai hari ini/bulan ini).

### Kode Modul AI yang Tersedia:
| Kode Modul       | Fitur Terkait            | Fungsi AI                                                  |
|------------------|--------------------------|------------------------------------------------------------|
| `HEALTH`         | UKS / Rekam Medis        | Analisis anomali kesehatan & saran siklus reproduksi       |
| `CANTEEN`        | Kantin Digital           | Business insight bulanan & saran profitabilitas kantin     |
| `ACADEMIC_REPORT`| Raport Digital           | Generasi narasi/komentar raport otomatis                   |
| `VIOLATIONS`     | Kesiswaan / Pelanggaran  | Analisis pola pelanggaran & rekomendasi pembinaan          |
| `LIBRARY`        | Perpustakaan Digital     | Rekomendasi buku berdasarkan riwayat & minat baca          |
| `PKL`            | PKL / Bimbingan Jurnal   | Umpan balik otomatis & analisis perkembangan jurnal PKL    |

---

## 👨‍🏫 7. Fitur Khusus Staff (Guru/Karyawan) (Staff Only)
Selain fitur umum, Staff (Guru/Karyawan) memiliki akses tambahan untuk manajemen kelas dan evaluasi dirinya sendiri.

- **Penilaian Kinerja Staff (Guru/Karyawan) (Self-Service):**
  - `POST /pkg/submissions` — Mengunggah dokumen bukti kinerja (Sertifikat, RPP, Dokumentasi).
  - `GET /pkg/submissions` — Melihat status evaluasi dokumen yang telah diunggah.

---

## 🏥 8. Petugas UKS (Health Admin — Sub-Role Staff)
Staff yang ditugaskan oleh Admin sebagai petugas kesehatan melalui `POST /admin/health/settings`.

- **Pencatatan Kesehatan:**
  - `POST /health/records` — Mencatat data kesehatan siswa/Staff (TB, BB, HB, Pendengaran, Mata, Gigi).
- **Pemantauan Siklus Haid & Peminjaman Pita:**
  - `GET /health/watchlist` — Melihat daftar siswa perempuan dengan siklus haid > 7 hari (OVERDUE).
  - `POST /health/force-stop` — Menghentikan paksa siklus haid & mengembalikan pita (beserta sanksi jika perlu).

---

## 🎀 9. Peminjaman Pita Haid (Khusus Siswi)
Fitur khusus untuk siswi perempuan. Staff perempuan **tidak dapat** meminjam pita.

- `POST /health/ribbons/borrow` — Meminjam pita haid (syarat: siklus haid harus aktif, maksimal 1 pita).
- Jika pita belum dikembalikan dalam 7 hari, status menjadi `OVERDUE` dan siswi **tidak bisa** menghentikan siklus atau mengembalikan pita sendiri.
- Petugas UKS harus menangani pengembalian pita secara manual melalui `POST /health/force-stop`.

---

## ⚖️ 10. Kesiswaan / Manajemen Pelanggaran (Staff dengan Akses `MANAGE_VIOLATIONS`)
Staff yang memiliki izin `MANAGE_VIOLATIONS` dapat mengelola poin pelanggaran siswa maupun staf lain.

- **Konfigurasi Jenis Pelanggaran:**
  - `GET /violations/types` — Melihat daftar pelanggaran beserta poinnya.
  - `POST /violations/types` — Membuat jenis pelanggaran baru.
  - `PATCH /violations/types/:id/toggle` — Mengaktifkan/menonaktifkan jenis pelanggaran.
  - `DELETE /violations/types/:id` — Menghapus jenis pelanggaran.
- **Pencatatan Pelanggaran:**
  - `POST /violations/record` — Mencatat pelanggaran user. Wajib menyertakan bukti foto dan bisa memilih lebih dari satu jenis pelanggaran sekaligus.
- **Riwayat Pelanggaran:**
  - `GET /violations/users/:user_id` — Melihat riwayat pelanggaran dan total poin hukuman milik siswa atau staf tertentu.
  
> ⚠️ **Catatan Sistem:** Jika siswa/staf mengisi form alasan terlambat absen, sistem akan *otomatis* mencatat pelanggaran "LATE_ATTENDANCE" sesuai role mereka, dengan poin default (dapat diubah nominal poinnya, namun jenis pelanggarannya tidak bisa dihapus).

---

## 📋 Daftar Semua Permission Sistem

Sistem ini memiliki 18 hak akses (permission) yang sepenuhnya *role-based* dan granular (misal: `MANAGE_AI`, `MANAGE_BKK`, `MANAGE_PKG`, dll). 

Untuk melihat daftar lengkap beserta penjelasan masing-masing *permission*, silakan merujuk ke dokumen:
👉 **[SYSTEM_PERMISSIONS.md](SYSTEM_PERMISSIONS.md)**
