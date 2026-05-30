// =============================================================================
// api_config.dart — Konfigurasi URL Semua API SatuSekolah
// =============================================================================
// Ganti nilai URL sesuai environment Anda.
// Gunakan ngrok atau IP lokal (misal 192.168.x.x) agar bisa diakses dari HP.
// =============================================================================

class ApiConfig {
  // ─── Backend SatuSekolah (Go) ────────────────────────────────────────────
  // Digunakan untuk: login utama, profil, notifikasi
  static const String satuSekolahBase =
      'https://remold-nutshell-extortion.ngrok-free.dev';
  static const String satuSekolah = '$satuSekolahBase/api';

  // ─── SeHadir (Presensi) ──────────────────────────────────────────────────
  // Go + Fiber, port 8080.
  // Jalankan dari SeHadir-main/backend dengan: go run main.go
  static const String seHadirBase = 'http://192.168.1.10:8080';
  static const String seHadir = '$seHadirBase/api';

  // ─── AkuSehat (Kesehatan) ────────────────────────────────────────────────
  // Laravel + Sanctum, jalan di Laragon (Apache).
  static const String akuSehatBase = 'http://192.168.1.10/AkuSehat-Website/public';
  static const String akuSehat = '$akuSehatBase/api';

  // ─── LMS-Tels (LMS & Tugas) ──────────────────────────────────────────────
  // Laravel + Inertia, jalan di Laragon.
  // LMS menggunakan Web Session → diproxy melalui backend Go SatuSekolah.
  // Endpoint /api/lms/* di Go akan forward ke LMS ini.
  static const String lmsTelsBase = 'http://192.168.1.10/LMS-Tels-Main/public';
  static const String lmsTels = '$lmsTelsBase/api'; // Diproxy oleh Go

  // ─── Header Umum ─────────────────────────────────────────────────────────
  static Map<String, String> get ngrokHeaders => {
        'ngrok-skip-browser-warning': '69420',
        'Content-Type': 'application/json',
      };

  static Map<String, String> bearerHeaders(String token) => {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
        'ngrok-skip-browser-warning': '69420',
      };
}
