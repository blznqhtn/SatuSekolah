# Daftar Fitur & Penjelasan Sistem Backend "Satu Sekolah"

Backend "Satu Sekolah" dirancang sebagai sistem ERP terpadu untuk sekolah (Multi-Tenant/SaaS), yang mencakup fungsionalitas akademik, administrasi, hingga operasional harian sekolah. Berikut adalah penjabaran detail fitur-fitur yang sudah terimplementasi beserta fungsinya:

## 1. Manajemen Inti & Hak Akses (Core & RBAC)
Fitur ini menjadi pondasi seluruh aplikasi, memungkinkan aplikasi dijalankan dalam skala besar.
- **Manajemen Tenant (Sekolah)**: Memungkinkan aplikasi digunakan oleh banyak sekolah secara bersamaan (SaaS) tanpa saling tumpang tindih data.
- **RBAC (Role-Based Access Control)**: Memiliki 4 role utama (`Admin`, `Staff`, `Student`, `Parent`). Khusus untuk `Staff`, dilengkapi dengan pengaturan hak akses (permissions) secara dinamis (role fleksibel) karena setiap staf memiliki tanggung jawab manajemen yang berbeda-beda. Contoh permission untuk staf: `MANAGE_VIOLATIONS`, `MANAGE_AI`, `MANAGE_FINANCE`.
- **Manajemen Akun & Autentikasi**: Sistem login, profil pengguna, dan keamanan otorisasi berbasis JWT.

## 2. Akademik, Pembelajaran & Penilaian (LMS & Raport)
Sistem manajemen pembelajaran digital untuk mendukung KBM (Kegiatan Belajar Mengajar):
- **Manajemen Kursus & Modul**: Guru dapat membuat mata pelajaran dan membagikan materi (modul) ke siswa.
- **Pengumpulan Tugas**: Siswa dapat mengupload hasil pekerjaan/tugas secara digital untuk dinilai guru.
- **Computer Based Assessment (CBA)**: Ujian online mandiri dengan dukungan soal kaya media (gambar/audio/video) dan tipe soal kompleks seperti pencocokan (tarik garis).
- **Raport Digital & Leaderboard**: Generate Excel template nilai, proses upload massal oleh wali kelas, serta perankingan (leaderboard) instan berdasarkan kelas, jurusan, maupun keseluruhan angkatan.

## 3. Keuangan & Tagihan Digital (Billing & E-Wallet "Satu Pay")
Sistem ini menggunakan dompet virtual (*Ledger-based Wallet*) bernama **Satu Pay** untuk setiap siswa. Setiap transaksi finansial — baik pembayaran tagihan, pemindahan saldo, maupun pembelian — **wajib menggunakan PIN 6 Digit** sebagai validasi identitas.
- **Top-Up & Transaksi Tercatat**: Semua uang masuk dan keluar memiliki jejak (*immutable ledger*) yang tidak bisa dimanipulasi.
- **Tagihan Sekolah (SPP/Uang Gedung)**: Bendahara sekolah membuat tagihan *(invoice)* massal secara otomatis, bisa ditarget ke kelas, jurusan, atau siswa individual.
- **Pembayaran Tagihan via Virtual Account Internal 15 Digit (Cashless Penuh)**:
  - Bendahara menyodorkan kode VA 15 digit kepada siswa (generasi kode: 12 digit nomor akun sekolah + 3 digit unik per transaksi).
  - Siswa mengetikkan VA di aplikasi, sistem **otomatis menampilkan nama tagihan dan nominal** tanpa perlu ketik jumlah secara manual (karena VA sekali pakai, sudah terikat ke 1 invoice).
  - Setelah siswa memasukkan PIN, saldo langsung dipotong dan tagihan lunas instan.
  - **Kode VA otomatis hangus** setelah dibayar, dan secara otomatis kedaluwarsa **24 jam** setelah dibuat jika belum dibayar.
- **Pembayaran Eksternal (Midtrans Gateway)**: Jika siswa/orang tua tidak memiliki saldo internal yang cukup, mereka bisa membayar tagihan melalui *Payment Gateway* Midtrans (QRIS, Virtual Account Bank, GoPay, dsb).
  - **Arsitektur Keamanan Midtrans**: Menggunakan pendekatan *Backend-Calculated*. Backend menghitung nominal final, meminta *Snap Token* ke server Midtrans, lalu mengembalikannya ke Frontend. Validasi sukses dilakukan sepenuhnya melalui *Webhook* Midtrans dengan verifikasi *HMAC Signature*, mencegah manipulasi dari sisi frontend.
- **Pembelian Token AI via Midtrans**: Integrasi webhook untuk pembelian paket kuota AI bagi sekolah secara otomatis.

## 4. Kantin Digital (Digital Canteen & POS) Enterprise-Grade
Mendigitalisasi transaksi di lingkungan sekolah agar menjadi *cashless ecosystem*, dilengkapi dengan fitur setingkat *Enterprise* untuk memaksimalkan profitabilitas pemilik kantin.
- **Pendaftaran Tenant Kantin & Manajemen Resep (BOM)**: Pemilik toko/kantin dapat membuka lapak, menambah menu jualan, dan memasukkan *Bill of Materials* (Resep/Bahan Baku) untuk makanan. Fitur ini memungkinkan sistem menghitung harga pokok produksi (Cost of Goods Sold/COGS).
- **Manajemen Diskon Cerdas**: Pemilik kantin dapat menerapkan diskon untuk produk spesifik atau seluruh toko. Diskon dapat diatur dengan batas waktu (Start/End Date) dan batas kuota (*Max Uses*), sangat cocok untuk *Flash Sale* jam istirahat.
- **Sistem Pembayaran POS Kasir Dinamis (Nirtunai)**: Saat kasir menekan *Checkout*, **sistem langsung meng-generate ketiga kode pembayaran sekaligus** dalam satu langkah:
  - **Dynamic QR**: Di-generate per transaksi dan hanya dapat dipindai oleh aplikasi internal Satu Sekolah. Pembeli scan → masukkan PIN → bayar.
  - **Transfer Virtual Account Internal 15 Digit**: Kode VA unik yang terikat ke 1 pesanan, otomatis kedaluwarsa **24 jam**. Pembeli ketik VA di aplikasi → nominal tampil otomatis → masukkan PIN → bayar.
  - **Tap Kartu RFID**: Perangkat IoT menampilkan tagihan di layar → pembeli tap kartu → mesin meminta PIN → saldo dipotong langsung.
- **Ganti Metode Pembayaran Tanpa Hambatan**: Karena semua kode di-generate serentak, kasir bisa mengganti metode pembayaran (misal dari RFID ke Transfer) kapan saja **tanpa loading ulang atau generate kode baru**. Kode yang lama tetap valid hingga pesanan dibayar atau kedaluwarsa 24 jam.
- **Opsi Pengiriman (Delivery) & Pick-Up**: Selain mengambil sendiri (Pick-up), siswa bisa meminta pesanan diantar (Delivery) ke kelas/lokasi tertentu. Biaya antar dihitung *per-checkout* (bukan per-item).
- **Pre-order Terjadwal**: Siswa bisa memesan makanan dari aplikasi (Self-Service) jauh-jauh hari (Pre-order Date & Time) untuk meminimalisir antrean panjang.
- **Laporan Finansial Canggih & AI Insight**: *Financial Report* harian/bulanan dengan *Gross Profit*, *Total Cost*, dan *Net Profit*. Didukung oleh **Business AI Insight** yang secara otomatis menganalisis performa bulanan dan memberikan saran *actionable* (aktif jika modul `CANTEEN` AI diaktifkan oleh admin).

## 5. Administrasi & Kesiswaan
Otomatisasi perizinan dan pendisiplinan murid.
- **Gate Pass (Surat Izin Keluar)**: Siswa mengajukan izin keluar sekolah, yang akan melewati *approval* (persetujuan) bertingkat (misal: Guru -> Kesiswaan). Proses keluar dan kembali diverifikasi menggunakan pemindaian QR oleh Satpam.
- **Sistem Poin Pelanggaran (Violations)**: Mencatat pelanggaran siswa/guru (termasuk upload bukti foto) dan secara otomatis mengkalkulasi poin hukuman. Terintegrasi dengan mesin absensi di mana jika siswa terlambat, sistem akan otomatis menginjeksi poin telat.

## 6. Kesehatan & UKS (Unit Kesehatan Sekolah)
Modul untuk memantau kesehatan warga sekolah secara preventif.
- **Rekam Medis**: Pencatatan riwayat kesehatan rutin (TB, BB, HB, Kesehatan Mata/Gigi) yang juga bisa dianalisa oleh sistem AI untuk mendeteksi anomali (aktif jika modul `HEALTH` AI diaktifkan oleh admin).
- **Siklus Haid & Peminjaman Pita**: Siswi dapat memantau siklus haid secara privat. Jika siswi sedang haid (sehingga tidak ikut shalat berjamaah), mereka dapat meminjam "pita tanda haid" ke petugas UKS. UKS memonitor siswi yang "overdue" (telat mengembalikan pita lebih dari 7 hari) untuk mencegah penyalahgunaan alasan haid.

## 7. Kepegawaian & Kinerja (Penilaian Kinerja Guru/PKG)
- **Manajemen Evaluasi Staff**: Guru dapat mengupload dokumen portofolio kerjanya (seperti RPP, Piagam), lalu Kepala Sekolah/Asesor akan mengevaluasi dan memberikan skor berdasar indikator pada periode berjalan.
- **Fair Average Calculation**: Kalkulasi performa yang adil untuk staf sesuai indikator yang hanya berkaitan dengan tupoksinya. Guru tidak akan dihukum nilainya untuk indikator yang tidak wajib baginya.

## 8. Penerimaan Murid Baru (SPMB)
- Manajemen pendaftaran siswa baru secara digital sepenuhnya, mulai dari pembuatan formulir pendaftaran *online*, persetujuan verifikasi berkas, penjadwalan tes seleksi/wawancara, hingga tahapan daftar ulang (*re-register*) jika siswa dinyatakan lolos seleksi.

## 9. Inventaris & Perpustakaan
- **Manajemen Sarana Prasarana (Inventaris)**: 
  - Seluruh sarana dan prasarana sekolah dicatat kondisinya secara berkala oleh staf pengelola (`MANAGE_INVENTORY`).
  - Publik (Siswa, Orang Tua, dan Guru lain) dapat melihat daftar lengkap fasilitas yang dimiliki sekolah melalui akses data super-cepat yang didukung oleh **Caching Versioning**.
  - **Otomasi PKG**: Setiap kali staf inventaris melaporkan pembaruan kondisi atau stok barang (dengan melampirkan foto bukti), laporan tersebut akan secara otomatis **diinjeksi langsung ke sistem E-Kinerja (PKG)** mereka pada periode berjalan, meniadakan beban kerja dua kali (input laporan berulang).
- **Perpustakaan Digital**: Katalog buku fisik maupun e-book digital. Untuk buku fisik terdapat pengaturan lama masa peminjaman, peringatan *overdue*, dan denda keterlambatan terintegrasi pemotongan otomatis dari dompet digital. Untuk buku digital terdapat sistem *one-time purchase* atau *subscription*.
- **E-Journal & Publikasi Ilmiah**: Perpustakaan juga menjadi pusat arsip jurnal-jurnal ilmiah hasil penelitian maupun laporan PKL siswa yang sudah di-ACC.

## 10. Bursa Kerja, PKL Terpadu & Portofolio (Fitur Unggulan SMK)
Sistem ini memfasilitasi kebutuhan esensial sekolah kejuruan (SMK) dengan ekosistem Praktik Kerja Lapangan (PKL) yang *end-to-end*:
- **Manajemen Bursa Kerja Khusus (BKK) / Job Portal Lintas Sekolah**: 
  - Sekolah bisa mempublikasikan lowongan kerja, magang, atau PKL dari industri.
  - Lowongan memiliki pengaturan visibilitas: `Local` (hanya terlihat oleh siswa di sekolah tersebut) atau `Public` (terlihat oleh semua siswa di seluruh jaringan sekolah pengguna platform).
  - Target pelamar yang fleksibel: Tidak hanya siswa, BKK juga bisa menargetkan lowongan untuk merekrut `TEACHER` (Guru) atau `STAFF`, di mana pendaftar dari luar (seperti Orang Tua atau publik) bisa melamar.
  - Alur status lamaran transparan: `APPLIED` → `REVIEWED` → `INTERVIEW` → `ACCEPTED` / `REJECTED`.
- **Pembagian Tugas: Hubin/Admin (MANAGE_PKL) vs Guru Pembimbing (MANAGE_MENTOR)**:
  - `MANAGE_PKL`: Berwenang menetapkan informasi tempat PKL untuk siswa (bisa individu atau per-kelas), mengatur syarat minimal jumlah bimbingan jurnal, menugaskan Guru Pembimbing (Mentor) ke siswa, serta menerima pelaporan *monitoring* lapangan (berupa foto/PDF kunjungan ke perusahaan).
  - `MANAGE_MENTOR`: Diberikan kepada guru yang bertugas me-review jurnal mingguan/berkala yang disubmit siswa bimbingannya. Mentor berhak mengatur jadwal tanggal bimbingannya sendiri.
- **Bimbingan Jurnal PKL (E2EE & Time Lock)**:
  - Siswa dapat mengunggah jurnal (maksimal 5 file PDF/Word/Excel) ke sistem.
  - Sistem memiliki logika *Time-Lock*: Jika jadwal belum dimulai, siswa tidak bisa upload. Jika melebihi tanggal jadwal atau jurnal sudah di-*Approve* mentor, akses upload terkunci bagi siswa (namun mentor tetap bisa melihat dan mereview-nya).
  - Jika jurnal di-*Reject* (ditolak) oleh mentor, akses akan dibuka kembali agar siswa dapat memperbarui jurnal meskipun sudah melewati tenggat waktu jadwal.
  - Jurnal yang disubmit diamankan sepenuhnya dengan algoritma **E2EE AES-256-GCM**, di mana backend hanya menyimpan *ciphertext*. Data hanya dapat didekripsi dan dibaca oleh siswa pengirim dan guru pembimbing.
- **Laporan Akhir (Final Report) Otomatis ke Perpustakaan**:
  - Terdapat tenggat waktu *(deadline)* pengumpulan Laporan Akhir PKL.
  - Setelah laporan diunggah oleh siswa, Divisi Hubungan Industri (Hubin) bertugas memverifikasi.
  - Jika laporan akhir di-*Approve*, sistem secara otomatis akan meneruskan *softcopy* laporan tersebut ke Perpustakaan Digital sebagai Koleksi `E-Journal`, sehingga bisa dibaca oleh siswa angkatan berikutnya sebagai referensi.
- **Monitoring Hubin & Otomasi E-Kinerja (PKG)**:
  - Saat Guru Hubin melaporkan hasil kunjungannya *(Monitoring Lapangan PKL)* berupa foto atau PDF, sistem *backend* akan langsung mencari **Indikator PKG "Monitoring PKL"** pada periode E-Kinerja berjalan. 
  - File laporan monitoring tersebut akan langsung diinjeksi *(auto-submit)* sebagai dokumen Penilaian Kinerja Guru (PKG) bagi guru Hubin bersangkutan, sehingga guru tidak perlu repot kerja dua kali melakukan upload ulang laporannya untuk kebutuhan penilaian kinerjanya.
- **Student Portfolio (Profil ala LinkedIn)**:
  - Pengguna (Siswa/Guru/Staff) dapat membangun portofolio pencapaian yang struktur datanya mirip LinkedIn, meliputi: Ringkasan (Summary), CV, Pengalaman (Experiences), Pendidikan (Educations), Proyek (Projects), Keahlian (Skills), dan Sertifikat (Certificates).
  - **Import Otomatis dari LinkedIn**: Pengguna cukup mengunduh PDF profil LinkedIn mereka ("Save to PDF" dari LinkedIn) dan mengunggahnya. Sistem via AI/Parser otomatis mengekstrak Keahlian, Pengalaman, dan Pendidikan tanpa perlu input manual.
  - Portofolio ini secara otomatis terlampir saat melamar lowongan di BKK, memudahkan pihak HR/Admin me-review kandidat secara komprehensif.

## 11. Komunikasi & IoT Terintegrasi
- **Absensi Pintar**: Catatan presensi siswa terintegrasi ke sistem dan mesin absensi fisik (seperti IoT gate *Face Recognition* / sidik jari).
- **Penyiaran (Broadcast)**: Layaknya mading digital, sekolah bisa menyiarkan pengumuman ke audiens spesifik (misal: "Hanya untuk orang tua kelas 12 jurusan RPL", atau "Hanya untuk siswa yang belum bayar SPP").
- **WebSocket Chat (True E2EE)**: Komunikasi *real-time* berbasis WebSocket. Sistem mengimplementasikan **True End-to-End Encryption** layaknya WhatsApp/Signal, di mana backend berperan sepenuhnya sebagai **Kurir Buta** (hanya menyimpan *ciphertext* tanpa bisa membaca isinya). 
  - Kunci enkripsi (*Public/Private Key*) di-generate murni di sisi perangkat klien (*Frontend/Mobile*).
  - Fitur ini dilengkapi dengan **Daftar Kontak (Contact List) Dinamis** yang secara otomatis memfilter visibilitas kontak sesuai peran:
    - **Siswa** hanya melihat teman satu angkatan (kelas) dan Staf/Guru.
    - **Orang Tua** hanya melihat anaknya, teman sekelas anaknya, *orang tua teman anaknya*, serta Staf/Guru.
    - **Staf / Admin** memiliki visibilitas ke seluruh pengguna (Siswa, Orang Tua, Staf).

## 12. Manajemen AI (AI Feature Control) 🤖
Sistem AI terintegrasi di berbagai fitur platform, dengan kontrol penuh di tangan Administrator Sekolah atau staf yang memiliki permission `MANAGE_AI`.

### Modul yang mendukung AI:
| Kode Modul       | Digunakan Di                  | Fungsi AI                                                             |
|------------------|-------------------------------|-----------------------------------------------------------------------|
| `HEALTH`         | UKS / Rekam Medis             | Analisis anomali kesehatan & saran kesehatan reproduksi               |
| `CANTEEN`        | Kantin Digital                | Business insight bulanan & saran peningkatan profitabilitas kantin    |
| `ACADEMIC_REPORT`| Raport Digital                | Generasi narasi/komentar raport otomatis oleh AI                      |
| `VIOLATIONS`     | Kesiswaan / Pelanggaran       | Analisis pola pelanggaran & rekomendasi tindakan pembinaan            |
| `LIBRARY`        | Perpustakaan Digital          | Rekomendasi buku berdasarkan riwayat & minat baca                     |
| `PKL`            | PKL / Bimbingan Jurnal        | Umpan balik otomatis & analisis perkembangan jurnal siswa PKL         |

### Kontrol AI per Modul:
- **Toggle On/Off**: Setiap modul AI dapat diaktifkan atau dinonaktifkan secara terpisah. Misalnya, hanya mengaktifkan `CANTEEN` dan `HEALTH` AI tanpa mengaktifkan yang lain.
- **Batas Penggunaan Harian (`daily_limit`)**: Batasi berapa kali AI dipanggil per hari untuk modul tertentu. `0` = tidak dibatasi.
- **Batas Penggunaan Bulanan (`monthly_limit`)**: Batasi total penggunaan AI per bulan per modul. `0` = tidak dibatasi. Counter harian auto-reset setiap hari baru; counter bulanan auto-reset setiap bulan baru.
- **Kuota Token Global**: Semua penggunaan AI secara keseluruhan dibatasi oleh total kuota *Gemini API Token* yang dimiliki sekolah, yang dapat ditambah melalui pembelian via Midtrans.

### Siapa yang bisa mengatur AI?
- **Admin Sekolah** (role `Admin`) — selalu bisa mengakses semua pengaturan AI.
- **Staf dengan Permission `MANAGE_AI`** — Admin dapat mendelegasikan hak pengaturan AI kepada staf tertentu (misal: Operator TI Sekolah), tanpa harus memberikan akses Admin penuh.

## 13. Keamanan Tingkat Lanjut (Enterprise-Grade Security) & Optimasi
Sistem backend dirancang tahan terhadap serangan siber masa kini dan memiliki optimasi memori untuk *scaling* puluhan ribu *user*:
- **Anti-Malware Upload (Magic Bytes Validator)**: Aplikasi tidak sekadar memeriksa ekstensi *file* (seperti `.pdf` atau `.jpg`). Sebelum *file* (misal: Excel nilai, PDF laporan PKL) disimpan, sistem akan membaca **512 bytes** pertama dari file untuk memverifikasi MIME Type aslinya (*sniffing*). Ini memblokir total serangan injeksi skrip berbahaya (misal *PHP/JS script*) yang menyamar dengan ekstensi dokumen.
- **Anti-Brute Force (Rate Limiting)**: Rute sensitif seperti *Login* dilindungi lapisan *Fiber Limiter Middleware*. Batas toleransi adalah **5 upaya masuk per menit per Alamat IP**, mencegah bot melakukan tebakan kata sandi membabi buta.
- **Secure WebSocket Payload Auth**: Koneksi obrolan *Real-Time* menggunakan model **Payload-Based Authentication** yang kekinian. JWT Token tidak dikirim terbuka di parameter URL (menghindari *Token Hijacking* via proxy/log), melainkan dikirim sebagai *payload JSON* pada pertukaran pesan (handshake) pertama. Backend memberi toleransi 10 detik atau koneksi otomatis diputus (dropped).
- **Anti-SQL Injection (100% Prepared Statements)**: Seluruh baris kode akses *database* di aplikasi secara eksklusif menggunakan sistem variabel berparameter (`$1`, `$2`, `?`), menutup celah modifikasi *SQL Query* oleh pihak luar secara permanen.
- **Database Engine Offloading (Materialized Views)**: Komputasi kompleks yang rakus CPU (seperti *Leaderboard Ranking* jutaan nilai rapor menggunakan klausa `RANK() OVER`) tidak lagi diolah di *layer backend aplikasi*. Perhitungannya didelegasikan langsung ke tingkat terendah mesin *database* (melalui PostgreSQL/MySQL/SQLite *View*), menghemat penggunaan memori RAM secara radikal dan menghasilkan respons waktu (latency) sangat cepat.
