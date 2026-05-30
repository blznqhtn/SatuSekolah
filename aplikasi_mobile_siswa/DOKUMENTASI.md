# 📚 Dokumentasi Kode SatuSekolah — Aplikasi Mobile Siswa

> Dokumen ini menjelaskan struktur proyek, fungsi tiap file, dan catatan penting untuk pengembang.

---

## 🗂️ Struktur Folder

```
lib/
├── main.dart                          # Entry point aplikasi
├── core/
│   └── services/
│       └── notification_service.dart  # Layanan push notification lokal
└── features/                          # Fitur-fitur aplikasi (feature-first architecture)
    ├── auth/
    │   └── screens/login_screen.dart  # Halaman login
    ├── dashboard/
    │   └── screens/
    │       ├── main_wrapper_screen.dart   # Wrapper utama (bottom nav)
    │       ├── home_screen.dart           # Tab Beranda
    │       ├── akademik_screen.dart       # Tab Akademik (real-time jadwal)
    │       └── notification_screen.dart  # Halaman notifikasi
    ├── academic/
    │   └── screens/
    │       ├── academic_calendar_screen.dart         # Kalender akademik
    │       ├── extracurricular_screen.dart           # Daftar ekskul
    │       ├── extracurricular_registration_screen.dart  # Form daftar ekskul
    │       ├── counseling_screen.dart                # Konseling BK
    │       ├── counseling_booking_screen.dart        # Form booking konseling
    │       ├── student_permit_screen.dart            # Perizinan siswa
    │       ├── permit_submission_screen.dart         # Form ajukan izin
    │       └── academic_announcement_screen.dart     # Semua pengumuman
    ├── schedule/
    │   └── screens/schedule_screen.dart  # Jadwal pelajaran (tab per hari)
    ├── report_card/
    │   └── screens/report_card_screen.dart  # Rapor digital & Leaderboard
    ├── evaluation/
    │   └── screens/
    │       ├── evaluation_list_screen.dart  # Daftar penilaian
    │       └── evaluation_form_screen.dart  # Form penilaian
    ├── library/
    │   └── screens/library_screen.dart  # E-Perpus (search, filter, bookmark, detail, rating)
    ├── career/
    │   └── screens/
    │       ├── career_screen.dart          # Tab PKL & Lowongan Kerja (alumni)
    │       ├── pkl_requirement_screen.dart # Detail persyaratan PKL dari Hubin
    │       └── saved_jobs_screen.dart      # Daftar PKL/loker tersimpan (wishlist)
    ├── violation/
    │   └── screens/violation_screen.dart  # Catatan pelanggaran & hukuman BK
    └── profile/
        └── screens/profile_screen.dart   # Profil siswa + sub-halaman pengaturan
```

---

## 🔑 File Kunci & Penjelasannya

### `main.dart`
- Entry point aplikasi Flutter
- Menginisialisasi `NotificationService` sebelum `runApp()`
- Menggunakan `GetMaterialApp` dari package GetX

### `main_wrapper_screen.dart`
- Wrapper utama yang mengelola **Bottom Navigation Bar** dengan 4 tab: Beranda, Akademik, Aktivitas, Profil
- Menggunakan `GetX` untuk state management tab aktif
- Menampilkan floating bottom nav dengan efek glassmorphism

### `akademik_screen.dart` ⭐
- Layar akademik utama dengan **real-time class tracking** (menggunakan `dart:async Timer`)
- Memiliki model `ClassItem` untuk representasi data kelas
- Mendeteksi kelas yang **sedang berlangsung** (badge LIVE) vs **kelas berikutnya** (badge Berikutnya)
- Grid 4 layanan: Kalender, Ekskul, Konseling BK, Perizinan
- Pengumuman bisa diklik → `AnnouncementDetailScreen`

### `library_screen.dart` ⭐
- E-Perpustakaan digital dengan fitur lengkap:
  - **Search real-time** berdasarkan judul & penulis
  - **Filter kategori** (chip: Fiksi, Sains, Sejarah, Teknologi, dll)
  - **Bookmark buku** (ikon di pojok kanan bawah cover)
  - **`SavedBooksScreen`** — halaman buku tersimpan (diakses via ikon bookmark di AppBar)
  - **`BookDetailScreen`** — detail buku dengan bookmark, baca, ulasan

### `career_screen.dart` ⭐
- Layar Karir & PKL dengan 2 tab:
  - **Informasi PKL**: banner info, search, filter → `PklRequirementScreen`
  - **Lowongan Alumni**: search & filter lowongan kerja
- Fitur **wishlist/bookmark** loker → `SavedJobsScreen`
- Filter menggunakan **BottomSheet** (Lokasi & Tipe)

### `report_card_screen.dart`
- Rapor digital per semester (tab: Rapor Digital vs Leaderboard)
- Leaderboard menampilkan ranking paralel antar jurusan
- Nama panjang ditangani dengan `TextOverflow.ellipsis` + `Expanded`

### `notification_service.dart`
- Singleton service untuk **push notification lokal**
- Package: `flutter_local_notifications`
- Channel Android dengan sound + vibration (priority HIGH)
- Method siap pakai: `showAnnouncementNotification()`, `showClassReminderNotification()`, `showLibraryNotification()`

### `profile_screen.dart`
- Profil siswa dengan status kehadiran & poin pelanggaran
- Menu navigasi ke sub-halaman:
  - `EditProfileScreen` — form edit nama, email, HP, alamat
  - `ChangePasswordScreen` — ganti kata sandi dengan toggle show/hide
  - `SchoolRulesScreen` — tata tertib & poin pelanggaran per kategori
  - `ContactScreen` — kontak Hubin, BK, TU
  - `FaqScreen` — FAQ dengan `ExpansionTile`

---

## 📦 Dependencies Utama

| Package | Fungsi |
|---|---|
| `get` | State management, navigasi, snackbar |
| `intl` | Format tanggal & waktu |
| `carousel_slider` | Banner/slider di beranda |
| `flutter_local_notifications` | Push notification lokal (suara + vibrasi) |

---

## 🎨 Design System

| Token | Nilai |
|---|---|
| Primary Blue | `#055D97` |
| Background | `#F8FAFC` (Slate 50) |
| Text Dark | `#0F172A` (Slate 900) |
| Text Medium | `#64748B` (Slate 500) |
| Border | `#E2E8F0` (Slate 200) |
| Font | `Inter` (Google Fonts) |

---

## ⚠️ Catatan Penting

> [!WARNING]
> Setelah menambahkan package baru (`flutter pub add`), selalu lakukan **full restart** (`flutter run`) bukan hanya hot reload.

> [!NOTE]
> Data yang digunakan saat ini masih **dummy/statis**. Untuk produksi, ganti dengan integrasi API backend (Laravel/Node.js).

> [!TIP]
> Jika ada error `overflow` pada teks, bungkus widget `Text` dengan `Expanded` dan tambahkan `maxLines: 1, overflow: TextOverflow.ellipsis`.

---

## 🔑 Akun Pengujian (Login Google)

Sistem telah di-seed dengan akun riil untuk pengujian integrasi Google Login. Seluruh akun di bawah ini telah di-set sebagai **Siswa** (`student`) agar Anda bisa menguji coba fitur Akademik, Rapor Digital, dan Leaderboard:

- `keciltikus29@gmail.com` (Siswa Tikus Kecil)
- `muhammadadrisela28@gmail.com` (Muhammad Adris Ela)
- `azikaper886@gmail.com` (Azi Kaper)
- `butterflybirubiru@gmail.com` (Guru Biru)
- `bankbrialfamidi@gmail.com` (Admin Keuangan)

*(Gunakan salah satu dari akun Google di atas pada saat memilih akun di layar Google Sign-In)*

---

## 🔮 Rencana Pengembangan

- [ ] Integrasi API Backend (ganti semua data dummy)
- [ ] Persistensi data wishlist dengan `GetStorage`
- [ ] Push notification dari server (FCM)
- [ ] Fitur absensi digital dengan RFID
- [ ] Dark mode support
