# Sistem Hak Akses (Permissions)

Dokumen ini berisi daftar lengkap hak akses (*permissions*) yang tersedia dalam sistem ERP "Satu Sekolah".
Sistem menggunakan pendekatan Role-Based Access Control (RBAC) yang sangat fleksibel. Permission ini dapat diberikan kepada *Custom Role* manapun oleh Administrator. Admin selalu memiliki semua permission.

## Daftar Permission

| Permission ID | Nama Permission         | Akses Yang Diberikan & Fitur yang Dicakup                                |
|---------------|-------------------------|-------------------------------------------------------------------------|
| `p-001`       | `MANAGE_ATTENDANCE`     | **Fitur Absensi & KBM:** Melakukan bypass kehadiran siswa, melihat rekap kehadiran seluruh sekolah, dan mengatur jadwal libur. |
| `p-002`       | `MANAGE_LMS`            | **Fitur E-Learning:** Kelola seluruh konten pembelajaran, menyetujui materi/modul baru, dan memantau tugas siswa (biasanya untuk Kurikulum). |
| `p-003`       | `MANAGE_FINANCE`        | **Fitur Keuangan (Ledger & Billing):** Membuat (generate) tagihan SPP massal, memonitor transaksi Web3 Ledger, mengatur kantin, & laporan keuangan. |
| `p-004`       | `MANAGE_LIBRARY`        | **Fitur Perpustakaan:** Kelola buku fisik, menyetujui peminjaman buku, denda keterlambatan otomatis, dan katalog E-Journal (termasuk Jurnal PKL). |
| `p-005`       | `MANAGE_CBA`            | **Fitur Ujian (CBA):** Buat & kelola kuis/ujian online, bank soal, dan pemantauan ujian *live* (Computer Based Assessment). |
| `p-006`       | `MANAGE_HEALTH`         | **Fitur UKS:** Akses rekam medis siswa, input data pemeriksaan gigi/mata/TB/BB, serta *force-stop* siklus haid dan peminjaman pita haid. |
| `p-007`       | `MANAGE_INVENTORY`      | **Fitur Inventaris:** Kelola keluar-masuk barang sekolah (aset), pencatatan peminjaman barang oleh siswa/staf. |
| `p-008`       | `MANAGE_SPMB`           | **Fitur PPDB/SPMB:** Menerima/menolak pendaftaran murid baru, set jadwal ujian masuk, dan validasi daftar ulang (re-register). |
| `p-009`       | `MANAGE_ROLES_PERMISSIONS`| **Fitur RBAC:** Membuat *custom role* baru (seperti "Staf Perpus", "Penjaga Gerbang") & mengatur kombinasi *permission* di atas per role. |
| `p-010`       | `MANAGE_USERS`          | **Fitur Akun Pengguna:** Aktivasi akun baru, nonaktifkan akun (suspend), ganti password/PIN user lain, & *upgrade* akun (misal: pendaftar jadi guru). |
| `p-011`       | `MANAGE_VIOLATIONS`     | **Fitur Kedisiplinan:** Mencatat pelanggaran, melihat skor penalti, mengatur jenis & bobot pelanggaran (biasanya untuk Guru BK / Kesiswaan). |
| `p-012`       | `MANAGE_AI`             | **Fitur Kontrol AI:** Menghidupkan/mematikan fitur AI (Gemini) per modul (Kantin, UKS, Raport) & atur batas kuota token harian/bulanan. |
| `p-013`       | `MANAGE_BKK`            | **Fitur Karir & PKL (BKK):** Membuat lowongan kerja publik/lokal, me-review lamaran, & melihat portofolio kandidat pelamar (HR/BKK). |
| `p-014`       | `MANAGE_PKG`            | **Fitur Penilaian Kinerja Guru (E-Kinerja):** Membuat periode penilaian PKG, menambah indikator & bobot penilaian, dan mengevaluasi/memberikan skor bukti kinerja (Kepala Sekolah/Asesor). |
| `p-015`       | `MANAGE_PKL`            | **Fitur Prakerin / PKL (Hubin):** Mengatur penempatan informasi PKL untuk siswa/kelas, publikasi info PKL bursa, pelaporan monitoring lapangan (PDF/foto), assign mentor jurnal ke siswa, mengelola pengumpulan akhir final jurnal (approve/reject), dan menetapkan batas minimal bimbingan. |
| `p-016`       | `MANAGE_CANTEEN`        | **Fitur Kantin Digital:** Mengatur toko (Shop), menambah menu makanan & resep (BOM), mengatur diskon toko, & memproses pesanan (Pemilik Kantin). |
| `p-017`       | `MANAGE_GATEPASS`       | **Fitur Surat Izin Keluar (Gate Pass):** Menyetujui/menolak permohonan izin keluar siswa (Approver/Wali Kelas/Kesiswaan) dan melakukan scan QR Keluar/Kembali (Satpam/Guard). |
| `p-018`       | `MANAGE_COMMUNICATION`  | **Fitur Pengumuman (Broadcast):** Membuat, mengedit, & mempublikasikan pengumuman sekolah/broadcasting ke seluruh pengguna atau segmen spesifik (Humas/Admin). |
| `p-019`       | `MANAGE_MENTOR`         | **Fitur Pembimbing Jurnal PKL:** Me-review pengumpulan jurnal berkala dari siswa bimbingannya (max 5 file PDF/Word/Excel), membuat jadwal bimbingan sendiri, serta memberi status approve/reject pada jurnal (akses ditutup untuk siswa jika lewat tenggat/approved, tapi dibuka kembali jika direject). |

---

*Catatan: Semua permission di atas disuntikkan (seeded) secara default saat inisialisasi awal database (`schema.up.sql`).*
