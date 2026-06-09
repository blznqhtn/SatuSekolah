# 📖 Glosarium Istilah — Satu Sekolah Backend

Dokumen ini ditujukan untuk **developer frontend/mobile junior** agar bisa memahami istilah-istilah teknis yang sering muncul di dokumentasi, respons API, dan percakapan tim backend. Disusun dari A–Z.

---

## A

### Admin Fee (Biaya Layanan)
Biaya tambahan kecil yang dikenakan pada transaksi tertentu untuk menutup biaya operasional sistem.
- **Contoh:** Pembayaran via tap kartu RFID di kantin dikenakan biaya admin **Rp500** per transaksi.
- Biaya ini ditambahkan **otomatis oleh backend** — frontend tidak perlu menghitungnya sendiri.

### Auth (Authentication / Autentikasi)
Proses verifikasi identitas pengguna. Di Satu Sekolah, autentikasi dilakukan dengan:
1. Login → backend memberikan **JWT Token**.
2. Setiap request selanjutnya wajib menyertakan token tersebut di header `Authorization: Bearer <token>`.

### Authorization (Otorisasi)
Berbeda dari autentikasi. Ini adalah proses verifikasi **apa yang boleh dilakukan** oleh user yang sudah login. Diatur via **RBAC** dan **Permission**.

---

## B

### Bearer Token
Format pengiriman JWT Token di header HTTP.
```
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```
Frontend wajib menyisipkan ini di **setiap** request ke endpoint yang terproteksi (`/api/v1/...`).

### BOM (Bill of Materials / Resep)
Daftar bahan baku yang dibutuhkan untuk membuat 1 produk di kantin. Digunakan untuk menghitung **COGS** (Harga Pokok Produksi). Frontend kantin mungkin perlu menampilkan ini di halaman manajemen produk.

### Broadcast (Siaran/Pengumuman)
Fitur pengiriman pesan/pengumuman dari pihak sekolah ke audiens yang ditarget secara spesifik (misal: hanya siswa kelas 12 jurusan RPL, atau hanya orang tua yang belum bayar SPP).

---

## C

### CBA (Computer Based Assessment)
Ujian online berbasis komputer. Siswa mengerjakan soal melalui aplikasi. Soal bisa berupa pilihan ganda, checkbox, hingga soal tarik garis (matching). Ada sistem **time-lock** sehingga ujian tidak bisa dikerjakan di luar jadwal.

### Ciphertext
Data terenkripsi yang sudah tidak bisa dibaca tanpa kunci dekripsi. Di fitur chat E2EE, backend **hanya menyimpan ciphertext** — server tidak bisa membaca isi pesan sama sekali. Frontend yang mendekripsinya di sisi klien.

### COGS (Cost of Goods Sold / HPP)
Harga Pokok Produksi. Biaya total yang dikeluarkan untuk membuat 1 item menu (bahan baku, dll). Digunakan di laporan keuangan kantin untuk menghitung **Net Profit**.

---

## D

### Dynamic QR Code
Kode QR yang dibuat **per transaksi**, unik, dan hanya bisa dipindai oleh aplikasi Satu Sekolah (bukan kamera biasa atau aplikasi QR lain). Kode ini otomatis hangus setelah transaksi berhasil atau lewat 24 jam.

> ⚠️ **Catatan Frontend:** Jangan menampilkan QR ini sebagai gambar biasa. Tampilkan dengan instruksi bahwa hanya bisa di-scan lewat in-app scanner Satu Sekolah.

### Deadline / Tenggat
Batas waktu pengumpulan tugas, laporan PKL, dll. Setelah deadline, aksi upload otomatis dikunci oleh sistem.

---

## E

### E2EE (End-to-End Encryption)
Enkripsi ujung ke ujung. Isi pesan hanya bisa dibaca oleh pengirim dan penerima. Backend bertindak sebagai **"kurir buta"** — hanya meneruskan data terenkripsi tanpa bisa membacanya.
- Enkripsi/dekripsi dilakukan **di sisi frontend/mobile**, bukan di server.
- Algoritma yang digunakan: **AES-256-GCM**.
- Kunci enkripsi (Public/Private Key) dibuat dan disimpan di perangkat klien.

### Endpoint
URL spesifik di API yang menerima request tertentu.
- **Contoh:** `POST /api/v1/finance/invoices/pay-va` adalah endpoint untuk membayar tagihan via VA.

### Expires At / Kedaluwarsa
Waktu kapan sebuah kode/token tidak lagi berlaku. Sistem Satu Sekolah menerapkan ini pada:
- **Kode VA**: Hangus 24 jam setelah dibuat jika belum dibayar.
- **Kode QR Dinamis**: Hangus setelah transaksi sukses atau 24 jam.
- **JWT Token**: Hangus setelah durasi tertentu (frontend perlu refresh atau re-login).

---

## F

### Fee Type (Jenis Biaya)
Kategori tagihan yang dibuat oleh bendahara sekolah. Contoh: `SPP Bulanan`, `Uang Gedung`, `Uang Kegiatan`. Setiap invoice (tagihan siswa) terhubung ke satu fee type.

---

## G

### Gate Pass (Surat Izin Keluar)
Surat izin keluar sekolah secara digital. Siswa mengajukan → disetujui bertingkat (guru/kesiswaan) → satpam scan QR untuk verifikasi keluar dan kembali.

---

## H

### HMAC Signature
Tanda tangan kriptografis yang digunakan untuk verifikasi keaslian callback/webhook dari Midtrans. Backend memvalidasi ini sebelum memproses notifikasi pembayaran, agar tidak bisa dipalsukan oleh pihak luar.

### HTTP Method
Jenis operasi yang dilakukan pada sebuah endpoint:
| Method | Arti | Contoh |
|--------|------|--------|
| `GET` | Ambil data | Lihat tagihan |
| `POST` | Kirim/buat data baru | Bayar tagihan |
| `PATCH` | Update sebagian data | Ubah status pesanan |
| `PUT` | Update penuh | Ganti profil |
| `DELETE` | Hapus data | Hapus jenis pelanggaran |

---

## I

### Immutable Ledger
Riwayat transaksi yang **tidak bisa diedit atau dihapus**. Setiap transaksi keuangan di Satu Sekolah dicatat secara permanen di ledger untuk keperluan audit dan keamanan finansial.

### Invoice (Tagihan)
Dokumen tagihan resmi dari sekolah kepada siswa. Berisi nama tagihan, jumlah yang harus dibayar, status pembayaran, dan berbagai kode pembayaran.
- **Status Invoice:** `PENDING` → `PARTIAL` (dicicil) → `PAID` (lunas) / `EXPIRED` (kedaluwarsa).

### IoT (Internet of Things)
Perangkat fisik yang terhubung ke internet. Di Satu Sekolah, IoT digunakan untuk:
- **Mesin absensi** (face recognition / sidik jari).
- **Terminal RFID** untuk pembayaran kantin dan tagihan sekolah.

---

## J

### JWT (JSON Web Token)
Token keamanan berbentuk string panjang yang diberikan backend setelah login berhasil. Token ini berisi informasi terenkripsi tentang identitas user (User ID, Tenant ID, Role). Frontend wajib menyimpan dan mengirimkan token ini di setiap request.

```
eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjoiLi4uIn0.xxx
```

---

## K

### Kode RFID Bayar (RFID Payment Code)
Kode numerik **12 digit** yang di-generate sistem untuk setiap pesanan POS. Kasir mengetikkan kode ini di terminal IoT RFID agar mesin tahu tagihan mana yang harus dibayar saat pembeli tap kartu.

### Kode VA (Virtual Account 15 Digit)
Nomor rekening virtual sementara, **15 digit**, yang terikat ke 1 transaksi spesifik. Dibentuk dari 12 digit nomor akun + 3 digit unik.
- **Sekali pakai**: Setelah dibayar, kode langsung hangus.
- **Kedaluwarsa 24 jam**: Jika belum dibayar dalam 24 jam, kode otomatis tidak berlaku.
- **Auto-show nominal**: Saat user input VA di aplikasi, backend otomatis menampilkan nama tagihan & nominal — user tidak perlu ketik jumlah manual.

---

## L

### Ledger (Buku Besar / Riwayat Transaksi)
Catatan setiap transaksi keuangan masuk dan keluar dari dompet digital user. Bersifat *immutable* (tidak bisa diubah).

### Ledger-Based Wallet (Dompet Digital "Satu Pay")
Sistem dompet virtual Satu Sekolah yang berbasis pencatatan ledger. Saldo dihitung dari akumulasi semua transaksi kredit dikurangi debit, bukan dari satu angka saldo yang bisa langsung dimanipulasi.

---

## M

### Midtrans
Payment gateway pihak ketiga yang digunakan Satu Sekolah untuk menerima pembayaran eksternal (transfer bank, QRIS, GoPay, dll). Frontend menggunakan **Midtrans Snap** (pop-up pembayaran) yang di-trigger oleh Snap Token dari backend.

### Magic Bytes Validator
Sistem validasi file upload yang membaca **512 bytes pertama** dari file untuk memastikan tipe file aslinya, bukan hanya dari ekstensi nama file. Mencegah malware menyamar sebagai PDF atau gambar.

### Multi-Tenant / SaaS
Sistem di mana **satu aplikasi melayani banyak sekolah** sekaligus, masing-masing dengan data yang terisolasi. Tenant = 1 Sekolah. Setiap user terikat ke 1 tenant.

---

## N

### NISN (Nomor Induk Siswa Nasional)
Nomor identifikasi unik untuk setiap siswa di Indonesia. Di sistem kantin POS, kasir bisa memasukkan NISN pembeli (opsional) agar transaksi tercatat di riwayat gizi/kesehatan siswa tersebut.

---

## P

### P2P Transfer (Peer-to-Peer)
Transfer saldo langsung antar pengguna di dalam aplikasi Satu Sekolah, tanpa melalui bank. Wajib menggunakan PIN.

### Payload
Data yang dikirim dalam body sebuah HTTP request (biasanya format JSON).
```json
{
  "va": "123456789012345",
  "pin": "123456"
}
```

### Permission
Hak akses spesifik yang dimiliki seorang staff. Contoh:
- `MANAGE_FINANCE` → bisa kelola tagihan dan laporan keuangan.
- `MANAGE_CANTEEN` → bisa operasikan kasir kantin.
- `MANAGE_AI` → bisa atur modul dan limit AI.

### PIN (Personal Identification Number)
Kode keamanan **6 digit** yang wajib dimasukkan user untuk mengonfirmasi setiap transaksi finansial (bayar tagihan, transfer saldo, checkout kantin, dsb). PIN di-hash di sisi backend — backend **tidak menyimpan PIN asli**.

> ⚠️ **Catatan Frontend Penting:** Setiap aksi yang menyangkut uang/saldo WAJIB memunculkan dialog input PIN sebelum request dikirim ke backend.

### PKG (Penilaian Kinerja Guru)
Sistem evaluasi kinerja guru/staf secara digital. Guru mengupload bukti kerja, kepala sekolah memberi nilai berdasarkan indikator. Beberapa aksi (seperti upload laporan monitoring PKL, update inventaris) secara otomatis mengisi PKG guru yang bersangkutan.

### PKL (Praktik Kerja Lapangan)
Program magang wajib bagi siswa SMK. Sistem Satu Sekolah mengelola seluruh alurnya: penetapan tempat PKL, bimbingan jurnal (E2EE), monitoring lapangan, hingga laporan akhir yang auto-masuk ke Perpustakaan Digital.

### POS (Point of Sale)
Mode transaksi kasir langsung. Kasir memasukkan item yang dibeli, sistem meng-generate kode pembayaran, dan pembeli membayar menggunakan metode yang dipilih (QR, RFID, atau VA).

### Public Key / Private Key (Kunci Publik / Kunci Privat)
Pasangan kunci kriptografi yang digunakan di sistem E2EE chat:
- **Public Key**: Dibagikan ke semua. Digunakan untuk mengenkripsi pesan yang akan dikirim ke pemilik kunci.
- **Private Key**: Rahasia, hanya ada di perangkat pemilik. Digunakan untuk mendekripsi pesan yang diterima.
- Keduanya dibuat **di sisi frontend/mobile**, bukan oleh server.

---

## Q

### QRIS (Quick Response Code Indonesian Standard)
Standar QR Code nasional Indonesia yang bisa dibayar dari berbagai aplikasi e-wallet (GoPay, OVO, Dana, dll). Di Satu Sekolah, QRIS digunakan melalui integrasi **Midtrans** untuk pembayaran eksternal.

---

## R

### RBAC (Role-Based Access Control)
Sistem hak akses berdasarkan role/jabatan. User hanya bisa mengakses fitur yang sesuai perannya.
- Role utama: `Admin`, `Staff`, `Student`, `Parent`.
- Staff bisa punya permission tambahan: `MANAGE_FINANCE`, `MANAGE_CANTEEN`, `MANAGE_VIOLATIONS`, dsb.

### Rate Limiting (Anti Brute-Force)
Pembatasan jumlah request dalam rentang waktu tertentu. Di endpoint login, maksimal **5 percobaan per menit per IP**. Setelah itu, request akan ditolak sementara. Frontend perlu menampilkan pesan error yang ramah kepada user.

### RFID (Radio Frequency Identification)
Teknologi identifikasi tanpa kontak fisik menggunakan gelombang radio. Di Satu Sekolah, kartu RFID digunakan untuk:
- **Absensi**: Tap kartu di mesin → presensi tercatat.
- **Pembayaran kantin/tagihan**: Tap kartu di terminal IoT → saldo terpotong setelah konfirmasi PIN.

---

## S

### Satu Pay
Nama dompet digital internal Satu Sekolah. Setiap pengguna memiliki saldo Satu Pay yang bisa digunakan untuk membayar tagihan sekolah, belanja di kantin, membayar denda perpustakaan, dll.

### Snap Token
Token sementara yang diberikan oleh Midtrans kepada backend Satu Sekolah. Frontend menggunakan token ini untuk memunculkan pop-up pembayaran Midtrans (Snap UI). Token ini memiliki masa berlaku singkat.

### SaaS (Software as a Service)
Model bisnis di mana satu platform melayani banyak pelanggan (dalam kasus ini: banyak sekolah) via internet. Setiap sekolah punya datanya sendiri yang terisolasi.

### SPMB (Seleksi Penerimaan Murid Baru)
Proses penerimaan siswa baru secara digital: formulir pendaftaran online → verifikasi berkas → tes seleksi → pengumuman → daftar ulang.

### Status Pesanan Kantin
Siklus hidup sebuah pesanan kantin:
```
PENDING → PREPARING → READY → DELIVERING → COMPLETED
```
atau bisa berakhir di:
```
PENDING → CANCELED (jika kedaluwarsa / dibatalkan)
```

### Status Tagihan (Invoice Status)
Siklus hidup sebuah tagihan sekolah:
```
PENDING → PARTIAL (dicicil) → PAID (lunas)
```
atau:
```
PENDING → EXPIRED (kedaluwarsa, belum dibayar)
```

---

## T

### Tenant
Satu unit sekolah dalam sistem multi-tenant Satu Sekolah. Setiap sekolah yang mendaftar adalah 1 tenant. Data antar tenant sepenuhnya terisolasi.

### Time-Lock
Mekanisme pembatasan akses berdasarkan waktu. Contoh di CBA: siswa tidak bisa membuka soal ujian sebelum jam mulai, dan tidak bisa submit setelah waktu habis.

### Token AI / AI Quota
Kuota penggunaan API Gemini AI yang dimiliki sekolah. Digunakan setiap kali fitur AI dipanggil (analisis kesehatan, insight bisnis kantin, dsb). Bisa dibeli tambahan via Midtrans.

### Transfer Account (Nomor VA Internal)
Lihat **Kode VA (Virtual Account 15 Digit)**.

---

## U

### UKS (Unit Kesehatan Sekolah)
Layanan kesehatan di sekolah. Di Satu Sekolah, petugas UKS bisa mencatat rekam medis siswa, memantau peminjaman pita haid, dan memonitor daftar siswa yang overdue.

---

## W

### Wallet / Dompet
Lihat **Satu Pay**.

### Webhook
Callback otomatis yang dikirim oleh sistem pihak ketiga (seperti Midtrans) ke backend kita ketika suatu event terjadi (misal: pembayaran berhasil). Frontend tidak perlu mengurus ini langsung — backend yang memproses dan memperbarui status di database.

### WebSocket
Protokol komunikasi dua arah (real-time) antara frontend dan backend. Digunakan untuk fitur chat real-time. Berbeda dari HTTP biasa yang hanya satu arah per request.

---

## 💡 Tips untuk Developer Frontend Junior

> [!TIP]
> **PIN selalu wajib untuk transaksi uang.** Sebelum mengirim request ke endpoint pembayaran apapun (bayar tagihan, checkout kantin, transfer saldo), selalu tampilkan dialog input PIN terlebih dahulu.

> [!TIP]
> **VA 15 digit = auto-fetch.** Saat user mengetikkan VA di form, langsung hit `GET /finance/invoices/va/:va` atau `GET /canteen/order/va/:va` secara real-time (debounce 500ms) untuk menampilkan nama tagihan dan nominal otomatis — user tidak perlu mengetik jumlah sendiri.

> [!TIP]
> **Semua kode pembayaran sudah ada sejak order dibuat.** Saat kasir berhasil membuat pesanan POS (`POST /canteen/pos/order`), respons sudah mengandung `dynamic_qr_code`, `rfid_payment_code`, dan `transfer_target_account` sekaligus. Frontend hanya perlu menampilkan kode yang relevan berdasarkan `payment_method` yang dipilih, dan cukup update `payment_method` jika kasir ingin ganti (tidak perlu request ulang ke backend untuk kode baru).

> [!IMPORTANT]
> **JWT Token harus disertakan di semua request.** Simpan token di secure storage (bukan `localStorage` biasa untuk web) dan sertakan di header `Authorization: Bearer <token>` setiap request ke `/api/v1/...`.

> [!NOTE]
> **Ciphertext di chat = normal.** Jangan kaget jika respons API chat hanya berisi deretan karakter acak. Itu memang ciphertext yang harus didekripsi oleh frontend menggunakan Private Key yang disimpan di perangkat user.

---

## 🌐 Kosakata Bahasa Inggris & Jargon Teknis

Bagian ini menjelaskan kata/frasa bahasa Inggris yang sering muncul di dunia pemrograman — terutama di dokumentasi, kode sumber, dan percakapan sesama programmer. Disusun alfabetis.

---

### API (Application Programming Interface)
**Arti:** Antarmuka Program Aplikasi

"Jembatan" yang memungkinkan dua sistem berkomunikasi. Saat frontend mengirim request ke backend, itulah yang disebut *memanggil API*.

> **Analogi:** Seperti menu di restoran. Kamu (frontend) memesan dari menu (API), dapur (backend) memasaknya, lalu hasilnya dikembalikan ke kamu.

---

### Array
**Arti:** Larik / Daftar Berurutan

Kumpulan nilai dalam satu variabel, ditulis dalam tanda kurung siku `[]`.
```json
["PENDING", "PARTIAL", "PAID", "EXPIRED"]
```

---

### Asynchronous (Async)
**Arti:** Tidak Sinkron / Berjalan di Latar Belakang

Proses yang berjalan tanpa menghentikan eksekusi kode lain. Request ke API berjalan di background, dan kode lanjutan dieksekusi setelah respons kembali (via `await` / `.then()`).

> **Lawan kata:** *Synchronous (Sync)* = harus menunggu proses selesai dulu baru lanjut ke baris berikutnya.

---

### Backend
**Arti:** Sisi Server / Lapisan Belakang

Bagian aplikasi yang berjalan di server — tidak terlihat langsung oleh pengguna. Bertugas mengolah data, menyimpan ke database, menjalankan logika bisnis, dan merespons request dari frontend.

> **Di proyek ini:** Backend Satu Sekolah ditulis dengan **Go (Golang)** dan menggunakan framework **Fiber**.

---

### Body (Request Body)
**Arti:** Isi / Badan Request

Data yang dikirimkan frontend ke backend sebagai isi request, biasanya dalam format JSON. Berbeda dari *header* (metadata) dan *query string* (parameter URL).
```json
{
  "va": "123456789012345",
  "pin": "123456"
}
```

---

### Boolean
**Arti:** Nilai Benar/Salah

Tipe data yang hanya bisa bernilai `true` (benar) atau `false` (salah).
```json
{ "is_preorder": false, "can_installment": true }
```

---

### Cache / Caching
**Arti:** Simpanan Sementara / Penyimpanan Kilat

Teknik menyimpan hasil proses yang sering diakses ke memori sementara agar tidak perlu dihitung/diambil dari database setiap saat — membuat respons API jadi jauh lebih cepat.

> **Contoh di proyek ini:** Data inventaris sekolah di-*cache*, sehingga ribuan siswa yang membuka halaman inventaris bersamaan tidak membebani database.

---

### Callback
**Arti:** Fungsi Balik / Dipanggil Belakangan

Fungsi yang dikirim sebagai argumen ke fungsi lain, dan akan dieksekusi setelah proses tertentu selesai.

> **Dalam konteks API:** Webhook Midtrans yang memberi tahu backend bahwa pembayaran berhasil adalah *callback* — Midtrans "menelepon balik" server setelah transaksi selesai di pihaknya.

---

### Ciphertext
**Arti:** Data Terenkripsi / Teks Tersandi

Data asli yang sudah diubah menjadi kode acak menggunakan algoritma enkripsi — tidak bisa dibaca tanpa kunci yang tepat.

```
Plaintext  : "Halo, apa kabar?"
Ciphertext : "U2FsdGVkX1+vXfg..." (contoh, hasil bervariasi)
```

> **Lawan kata:** *Plaintext* = data asli yang belum dienkripsi dan masih bisa dibaca normal.

---

### Credential
**Arti:** Kredensial / Data Bukti Identitas

Informasi yang digunakan untuk membuktikan identitas. Contoh: username + password saat login, atau JWT Token saat mengakses API.

---

### Debounce
**Arti:** Tunda Eksekusi / Jeda Setelah Ketik Berhenti

Teknik menunda eksekusi fungsi sampai pengguna berhenti melakukan aksi selama waktu tertentu. Digunakan pada kolom pencarian atau input real-time agar API tidak dibanjiri request di setiap ketikan.

> **Contoh di proyek ini:** Saat user mengetikkan VA 15 digit, tunggu **500ms** setelah user berhenti mengetik, *baru* kirim request ke API untuk auto-fetch tagihan.

---

### Decode / Encode
**Arti:** Dekode = Kembalikan Format / Enkode = Ubah Format

- **Encode:** Mengubah data dari satu format ke format lain (misal: teks biasa → Base64).
- **Decode:** Mengembalikan data ke format aslinya.

> ⚠️ Encode **bukan** enkripsi. Decode bisa dilakukan siapa saja tanpa kunci rahasia.

---

### Decrypt / Encrypt
**Arti:** Dekripsi = Buka Kunci / Enkripsi = Kunci Data

- **Encrypt (Enkripsi):** Mengubah data asli (*plaintext*) menjadi data acak (*ciphertext*) menggunakan kunci rahasia.
- **Decrypt (Dekripsi):** Mengembalikan *ciphertext* ke *plaintext* menggunakan kunci yang benar.

> **Di proyek ini:** Chat E2EE menggunakan enkripsi **AES-256-GCM**. Hanya pengirim dan penerima yang punya kunci — server pun tidak bisa membaca isi pesan.

---

### Default
**Arti:** Bawaan / Nilai Awal Otomatis

Nilai yang digunakan secara otomatis jika tidak ada nilai lain yang diberikan.

> **Contoh:** Metode pengiriman pesanan kantin secara *default* adalah `PICKUP` jika field `delivery_method` tidak diisi.

---

### Deploy / Deployment
**Arti:** Penerapan / Peluncuran Aplikasi ke Server

Proses memindahkan kode dari komputer developer ke server agar bisa diakses pengguna nyata. Proyek ini di-*deploy* menggunakan **Docker** dan **Docker Compose**.

---

### Deprecated
**Arti:** Usang / Tidak Direkomendasikan Lagi

Fitur atau endpoint yang masih berfungsi tetapi sudah tidak dianjurkan untuk digunakan karena akan dihapus di versi mendatang. Biasanya ada pengganti yang lebih baik.

---

### Endpoint
**Arti:** Titik Akses / Alamat Spesifik API

URL tertentu yang digunakan frontend untuk berkomunikasi dengan backend. Setiap endpoint melayani satu tujuan spesifik.
```
GET  /api/v1/finance/invoices         → ambil daftar tagihan
POST /api/v1/finance/invoices/pay-va  → bayar tagihan via VA
```

---

### Environment Variable (`.env`)
**Arti:** Variabel Lingkungan / Konfigurasi Rahasia

Konfigurasi sensitif (password database, API key, secret JWT) yang disimpan di file `.env` — terpisah dari kode dan **tidak boleh di-commit ke Git/GitHub** karena berisi data rahasia.

---

### Error Handling
**Arti:** Penanganan Kesalahan

Cara program merespons error. Di Satu Sekolah, semua error dikembalikan dalam format JSON:
```json
{ "error": "kode VA tidak valid atau tagihan tidak ditemukan" }
```
Frontend harus selalu mengecek respons error dan menampilkan pesan yang ramah kepada user — jangan tampilkan pesan error mentah dari backend langsung ke layar pengguna.

---

### Field
**Arti:** Kolom / Properti Data

Satu atribut dalam sebuah objek data JSON. Contoh: dalam objek tagihan, `invoice_name`, `total_amount`, dan `status` masing-masing adalah sebuah *field*.

---

### Flag
**Arti:** Penanda / Tanda Kondisi

Nilai boolean (`true`/`false`) yang digunakan sebagai penanda.
```json
{ "is_preorder": true, "can_installment": false }
```

---

### Frontend
**Arti:** Sisi Klien / Tampilan Pengguna

Bagian aplikasi yang dilihat dan digunakan langsung oleh pengguna — bisa berupa web (browser) atau aplikasi mobile (Android/iOS).

---

### Generate
**Arti:** Membuat / Menghasilkan Secara Otomatis

Proses membuat sesuatu secara otomatis oleh sistem, tanpa input manual.

> **Contoh:** Saat kasir menekan *Checkout*, backend secara otomatis *generate* kode QR, kode RFID, dan VA 15 digit sekaligus dalam satu langkah.

---

### Hash / Hashing
**Arti:** Penyandian Satu Arah / Sidik Jari Data

Proses mengubah data (misal: PIN atau password) menjadi string acak dengan panjang tetap yang **tidak bisa dikembalikan** ke bentuk aslinya. Berbeda dari enkripsi.

```
PIN asli : "123456"
Hash     : "$2a$10$N9qo8uLOick..." (bcrypt — tidak bisa dibalik!)
```

> **Di proyek ini:** Backend menyimpan *hash* PIN, bukan PIN aslinya. Saat user input PIN, backend me-*hash* input dan membandingkan hasilnya dengan hash yang tersimpan.

---

### Header (HTTP Header)
**Arti:** Kepala Request / Metadata

Informasi tambahan yang dikirim bersama setiap HTTP request, di luar body. Yang paling penting untuk frontend:
```
Authorization: Bearer <JWT_TOKEN>
Content-Type: application/json
```

---

### Idempotent
**Arti:** Aman Diulang / Hasil Sama Meski Diulang

Sifat operasi yang menghasilkan hasil sama meskipun dieksekusi berkali-kali.

> **Perhatian:** `GET` selalu idempotent (membaca saja). `POST` untuk bayar tagihan **bukan** idempotent — jangan panggil dua kali atau saldo bisa terpotong ganda!

---

### Integer
**Arti:** Bilangan Bulat

Tipe data angka tanpa desimal. Contoh: `150000`, `3`, `0`.

> **Lawan kata:** *Float* = bilangan desimal, misal `150000.50`, `3.14`.

---

### JSON (JavaScript Object Notation)
**Arti:** Format Data Standar Web

Format pertukaran data yang paling umum digunakan antara frontend dan backend. Mudah dibaca manusia dan mudah diproses mesin.
```json
{
  "status": "PAID",
  "total_amount": 150000,
  "invoice_name": "SPP Bulan Juni 2026"
}
```

---

### Latency
**Arti:** Latensi / Waktu Tunda

Waktu yang dibutuhkan dari saat request dikirim sampai respons diterima. Semakin kecil latency, semakin cepat terasa aplikasinya di mata pengguna.

---

### Middleware
**Arti:** Lapisan Tengah / Penjaga Gerbang

Kode yang berjalan *antara* request masuk dan handler yang memproses — seperti "pos pemeriksaan" sebelum request diproses.

> **Contoh di proyek ini:**
> - **JWT Middleware:** Cek apakah token valid sebelum request diteruskan.
> - **RBAC Middleware:** Cek apakah user punya permission yang dibutuhkan.
> - **Rate Limiter:** Cek apakah user sudah melewati batas 5 request/menit di endpoint login.

---

### Nullable
**Arti:** Boleh Kosong / Bisa Tidak Ada Nilainya

Field yang nilainya boleh `null` (tidak ada). Di JSON Satu Sekolah, field nullable biasanya hanya muncul di respons jika memang ada nilainya (ditandai `omitempty` di kode backend).

> **Contoh:** Field `dynamic_qr_code` di respons tagihan hanya ada jika tagihan tersebut memang memiliki kode QR.

---

### Object
**Arti:** Objek / Data Terstruktur

Kumpulan data berupa pasangan *key-value* (nama: nilai), dibungkus dalam kurung kurawal `{}`.
```json
{
  "id": "550e8400-e29b-41d4-a716-446655440000",
  "invoice_name": "SPP Bulan Juni",
  "status": "PENDING"
}
```

---

### Pagination
**Arti:** Paginasi / Pembagian Halaman

Teknik membagi data besar menjadi beberapa "halaman" agar tidak semua data dimuat sekaligus — lebih hemat bandwidth dan lebih cepat. Biasanya ada parameter `page` dan `limit` di URL.

---

### Payload
**Arti:** Muatan / Data yang Dikirim

Data yang dikirim dalam body sebuah HTTP request.
```json
{
  "va": "123456789012345",
  "pin": "123456"
}
```

---

### Plaintext
**Arti:** Teks Biasa / Data Asli Sebelum Dienkripsi

Data yang belum dienkripsi — masih bisa dibaca secara normal oleh siapa saja.

> **Lawan kata:** *Ciphertext* = data yang sudah dienkripsi dan tidak bisa dibaca tanpa kunci.

---

### Prefix
**Arti:** Awalan / Bagian Paling Depan

Bagian awal dari sebuah string/teks.

> **Contoh di proyek ini:**
> - Semua endpoint berawalan (prefix) `/api/v1/` — ini menandakan versi API.
> - Kode QR Dinamis diawali dengan `QR-` lalu diikuti UUID: `QR-xxxxxxxx-xxxx-...`.
> - Endpoint IoT memakai prefix `/api/v1/iot/`.

---

### Query String
**Arti:** Parameter URL / Konfigurasi Request via URL

Parameter tambahan yang ditempel di akhir URL setelah tanda `?`, dipisah dengan `&`.
```
GET /canteen/reports/financial?start=2026-06-01&end=2026-06-30
                                ↑ query string dimulai dari sini
```

---

### Refactor
**Arti:** Perbaikan Kode Tanpa Mengubah Fungsi

Proses merapikan atau merestrukturisasi kode agar lebih mudah dibaca dan dipelihara — tanpa mengubah perilaku/fungsi aplikasi yang sudah ada.

---

### Request
**Arti:** Permintaan

Pesan yang dikirim frontend ke backend. Terdiri dari: method (GET/POST/dll), URL, header, dan body.

---

### Response
**Arti:** Respons / Jawaban

Pesan balasan dari backend ke frontend setelah memproses request. Berisi: status code (misal `200 OK`, `400 Bad Request`) dan body data atau pesan error.

---

### Route
**Arti:** Rute / Pemetaan URL

Aturan yang mendefinisikan "URL mana ditangani oleh fungsi apa". Di proyek ini, semua rute didefinisikan di file `router.go`.

---

### Schema
**Arti:** Skema / Struktur Database

Definisi struktur data — tabel apa saja yang ada di database, kolom apa di setiap tabel, dan tipe datanya. File skema ada di folder `migrations/` di proyek ini.

---

### Single-Use
**Arti:** Sekali Pakai

Kode atau token yang hanya bisa digunakan satu kali — setelah dipakai, langsung tidak berlaku lagi.

> **Contoh di proyek ini:** Kode VA 15 digit bersifat *single-use* — setelah tagihan dibayar, kode VA tersebut langsung hangus dan tidak bisa dipakai lagi untuk transaksi apapun.

---

### Status Code (HTTP Status Code)
**Arti:** Kode Status HTTP / Kode Respons

Angka 3 digit yang menunjukkan hasil dari sebuah request. Yang paling umum:

| Kode | Arti | Contoh Situasi |
|------|------|----------------|
| `200` | OK — Berhasil | Data berhasil diambil |
| `201` | Created — Berhasil dibuat | Pesanan baru berhasil dibuat |
| `400` | Bad Request — Request salah | PIN tidak valid |
| `401` | Unauthorized — Belum login | JWT Token tidak ada/kadaluwarsa |
| `403` | Forbidden — Tidak punya akses | Role tidak punya permission ini |
| `404` | Not Found — Data tidak ditemukan | VA tidak ditemukan |
| `500` | Internal Server Error — Error di server | Bug di backend |

---

### String
**Arti:** Teks / Rangkaian Karakter

Tipe data berupa teks, selalu diapit tanda kutip di JSON.
```json
{ "status": "PENDING", "invoice_name": "SPP Bulan Juni" }
```

---

### Suffix
**Arti:** Akhiran / Bagian Paling Belakang

Bagian akhir dari sebuah string/teks.

> **Contoh di proyek ini:** VA 15 digit = 12 digit nomor akun kantin + **3 digit suffix unik** (acak). Suffix inilah yang membedakan setiap VA meskipun dari kantin yang sama di transaksi yang berbeda.

---

### Timestamp
**Arti:** Cap Waktu / Waktu Kejadian

Informasi waktu yang mencatat kapan sesuatu terjadi. Hampir semua data di Satu Sekolah punya field `created_at` dan `updated_at`.

```json
{
  "created_at": "2026-06-09T10:30:00Z",
  "updated_at": "2026-06-09T14:22:15Z"
}
```

> ⚠️ **Catatan Frontend:** Huruf `Z` di akhir = UTC (Waktu Universal). Untuk tampilkan ke user, konversi ke WIB (UTC+7) = tambah 7 jam.

---

### Token
**Arti:** Token / Kunci Sementara

String unik yang digunakan sebagai tanda identitas atau otorisasi sementara. Punya masa berlaku.

> **Jenis token di proyek ini:**
> - **JWT Token** — autentikasi user ke semua endpoint API.
> - **Snap Token** — memunculkan pop-up pembayaran Midtrans.
> - **AI Token** — kuota penggunaan fitur AI oleh sekolah.

---

### UUID (Universally Unique Identifier)
**Arti:** Pengenal Unik Universal

String identifikasi unik 36 karakter yang di-*generate* secara acak. Digunakan sebagai ID untuk hampir semua data di Satu Sekolah.

```
Format: xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
Contoh: 550e8400-e29b-41d4-a716-446655440000
```

> Jangan tampilkan UUID mentah ke pengguna. Gunakan nama atau label yang lebih ramah.

---

### Validate / Validation
**Arti:** Validasi / Pemeriksaan Kebenaran Data

Proses memeriksa apakah data sudah benar, lengkap, dan sesuai format sebelum diproses lebih lanjut.

- **Frontend validation:** Cek di sisi user sebelum request dikirim (field tidak boleh kosong, PIN harus tepat 6 digit angka, dsb).
- **Backend validation:** Cek ulang di server — jangan pernah hanya andalkan validasi frontend, karena orang bisa bypass UI dan kirim request langsung.

---

### Webhook
**Arti:** Notifikasi Otomatis dari Sistem Lain

Mekanisme di mana sistem eksternal (misal: Midtrans) secara otomatis mengirim HTTP POST ke server kita saat suatu event terjadi — tanpa kita perlu terus-menerus menanya (*polling*).

> **Analogi:** Seperti memesan ojol. Kamu tidak perlu terus nelpon driver tanya "sudah sampai mana?". Driver yang menghubungi kamu saat pesanan tiba — itulah *webhook*.

---

### Wildcard / Parameter Dinamis
**Arti:** Karakter Bebas / Pengganti Nilai Dinamis

Di URL endpoint, bagian yang diawali `:` adalah *wildcard* — nilainya diganti dengan data aktual saat request dilakukan.

```
/api/v1/finance/invoices/va/:va
                              ↑ :va diganti VA aktual, misal: 123456789012345
/api/v1/tenants/:id
                   ↑ :id diganti UUID tenant aktual
```

---

*📝 Dokumen ini terus diperbarui. Jika ada istilah yang belum ada di sini atau kurang jelas, silakan tanyakan ke tim backend!*
