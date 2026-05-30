import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:aplikasi_mobile_siswa/features/auth/controllers/auth_controller.dart';
import 'package:aplikasi_mobile_siswa/features/evaluation/screens/evaluation_list_screen.dart';
import 'package:aplikasi_mobile_siswa/features/library/screens/library_screen.dart';
import 'package:aplikasi_mobile_siswa/features/violation/screens/violation_screen.dart';
import 'package:aplikasi_mobile_siswa/features/schedule/screens/schedule_screen.dart';
import 'package:aplikasi_mobile_siswa/features/report_card/screens/report_card_screen.dart';
import 'package:aplikasi_mobile_siswa/features/career/screens/career_screen.dart';
import 'package:aplikasi_mobile_siswa/features/dashboard/screens/notification_screen.dart';
import 'package:aplikasi_mobile_siswa/features/lms/screens/lms_dashboard_screen.dart';
import 'package:aplikasi_mobile_siswa/features/health/screens/health_dashboard_screen.dart';
import 'package:aplikasi_mobile_siswa/features/attendance/screens/attendance_screen.dart';
import 'package:aplikasi_mobile_siswa/shared/widgets/premium_header.dart';

// Warna brand utama SatuSekolah
const kPrimary   = Color(0xFF055D97);
const kBg        = Color(0xFFF8FAFC); // Selaraskan dengan Profil
const kTextDark  = Color(0xFF0F172A);
const kTextMuted = Color(0xFF64748B);

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  String _getGreeting() {
    final h = DateTime.now().hour;
    if (h < 11) return 'Selamat Pagi ☀️';
    if (h < 15) return 'Selamat Siang 🌤️';
    if (h < 18) return 'Selamat Sore 🌅';
    return 'Selamat Malam 🌙';
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));
    final AuthController auth = Get.find<AuthController>();

    return Scaffold(
      backgroundColor: kBg,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ─── HEADER PREMIUM ──────────────────────────────────
          PremiumHeader(
            title: 'Beranda',
            expandedHeight: 180,
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 20),
                  child: Obx(() {
                    final user = auth.userData.value;
                    final nama = user['nama']?.toString() ?? 'Siswa';
                    final kelas = user['kelas']?.toString() ?? '';
                    final jurusan = user['jurusan']?.toString() ?? '';
                    final foto = user['foto']?.toString() ?? '';
                    final info = [kelas, jurusan].where((s) => s.isNotEmpty).join(' • ');

                    return Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Avatar
                            Container(
                              width: 64, height: 64,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white.withOpacity(0.3), width: 3),
                                boxShadow: [
                                  BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 12, offset: const Offset(0, 6)),
                                ],
                                image: DecorationImage(
                                  image: foto.isNotEmpty
                                      ? NetworkImage(foto) as ImageProvider
                                      : NetworkImage('https://ui-avatars.com/api/?name=${Uri.encodeComponent(nama)}&background=E2E8F0&color=0F172A&bold=true&size=200'),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(_getGreeting(), style: GoogleFonts.nunito(color: Colors.white.withOpacity(0.85), fontSize: 13, fontWeight: FontWeight.w700)),
                                const SizedBox(height: 2),
                                Text(nama, style: GoogleFonts.nunito(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800, letterSpacing: -0.5)),
                              ],
                            )),
                          ]
                        ),
                        const SizedBox(height: 16),
                        if (info.isNotEmpty)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              const Icon(Icons.school_rounded, color: Colors.white70, size: 14),
                              const SizedBox(width: 6),
                              Flexible(
                                child: Text(
                                  info, 
                                  style: GoogleFonts.nunito(color: Colors.white70, fontWeight: FontWeight.w700, fontSize: 13),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                      ],
                    );
                  }),
                ),
              ],
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ─── CAROUSEL PENGUMUMAN (GLASSMORPHISM) ────────────────
                  CarouselSlider(
                    options: CarouselOptions(
                      height: 160,
                      autoPlay: true,
                      enlargeCenterPage: true,
                      viewportFraction: 1.0,
                      autoPlayInterval: const Duration(seconds: 5),
                    ),
                    items: [
                      _buildBannerItem('https://images.unsplash.com/photo-1523050854058-8df90110c9f1?q=80&w=600&auto=format&fit=crop', 'Beasiswa 2026 Dibuka 🎓', 'Daftarkan diri untuk program beasiswa prestasi.'),
                      _buildBannerItem('https://images.unsplash.com/photo-1509062522246-3755977927d7?q=80&w=600&auto=format&fit=crop', 'Ujian Tengah Semester 📚', 'Persiapkan diri untuk UTS mulai 15 Oktober.'),
                    ],
                  ),
                  const SizedBox(height: 28),

                  // ─── AKSES CEPAT (PREMIUM ICONS) ─────────────────────────
                  Text('Menu Utama', style: GoogleFonts.nunito(fontSize: 18, fontWeight: FontWeight.w800, color: kTextDark)),
                  const SizedBox(height: 8),
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2, 
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 2.2, // Membuatnya berbentuk horizontal pill/card
                    children: [
                      _buildMenuCard(Icons.menu_book_rounded, 'LMS & Tugas', const Color(0xFF3B82F6), const Color(0xFFEFF6FF), () => Get.to(() => const LMSDashboardScreen())),
                      _buildMenuCard(Icons.monitor_heart_rounded, 'Kesehatan', const Color(0xFFEF4444), const Color(0xFFFEF2F2), () => Get.to(() => const HealthDashboardScreen())),
                      _buildMenuCard(Icons.fact_check_rounded, 'Presensi', const Color(0xFF10B981), const Color(0xFFECFDF5), () => Get.to(() => const AttendanceScreen())),
                      _buildMenuCard(Icons.warning_rounded, 'Poin Siswa', const Color(0xFFF97316), const Color(0xFFFFF7ED), () => Get.to(() => const ViolationScreen())),
                      _buildMenuCard(Icons.local_library_rounded, 'Perpus', const Color(0xFFF59E0B), const Color(0xFFFFFBEB), () => Get.to(() => const LibraryScreen())),
                      _buildMenuCard(Icons.calendar_month_rounded, 'Jadwal', const Color(0xFF8B5CF6), const Color(0xFFF5F3FF), () => Get.to(() => const ScheduleScreen())),
                      _buildMenuCard(Icons.assignment_ind_rounded, 'Rapor Siswa', const Color(0xFF06B6D4), const Color(0xFFECFEFF), () => Get.to(() => const ReportCardScreen())),
                      _buildMenuCard(Icons.work_rounded, 'Karir & PKL', const Color(0xFFF97316), const Color(0xFFFFF7ED), () => Get.to(() => const CareerScreen())),
                      _buildMenuCard(Icons.rate_review_rounded, 'Kinerja', const Color(0xFF64748B), const Color(0xFFF8FAFC), () => Get.to(() => const EvaluationListScreen())),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String value, String label, IconData icon, Color color, Color bgColor) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(value, style: GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.w800, color: color)),
          const SizedBox(height: 2),
          Text(label, style: GoogleFonts.nunito(fontSize: 10, fontWeight: FontWeight.w700, color: const Color(0xFF475569)), textAlign: TextAlign.center, maxLines: 1),
        ],
      ),
    );
  }

  Widget _buildMenuCard(IconData icon, String label, Color color, Color bg, VoidCallback? onTap) {
    return GestureDetector(
      onTap: onTap ?? () {},
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.1)),
          boxShadow: [BoxShadow(color: color.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 4))],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label, 
                style: GoogleFonts.nunito(fontSize: 13, fontWeight: FontWeight.w800, color: kTextDark),
                maxLines: 2, 
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBannerItem(String url, String title, String sub) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 15, offset: const Offset(0, 8))],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(fit: StackFit.expand, children: [
          Image.network(url, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(color: kPrimary)),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [Colors.black.withOpacity(0.7), Colors.transparent], begin: Alignment.bottomCenter, end: Alignment.topCenter),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(mainAxisAlignment: MainAxisAlignment.end, crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
                child: Text('INFO PENTING', style: GoogleFonts.nunito(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1)),
              ),
              const SizedBox(height: 8),
              Text(title, style: GoogleFonts.nunito(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 18)),
              const SizedBox(height: 4),
              Text(sub, style: GoogleFonts.nunito(color: Colors.white.withOpacity(0.9), fontSize: 13, fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
            ]),
          ),
        ]),
      ),
    );
  }
}
