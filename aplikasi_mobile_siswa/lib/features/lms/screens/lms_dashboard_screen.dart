import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:aplikasi_mobile_siswa/features/lms/controllers/lms_controller.dart';
import 'package:aplikasi_mobile_siswa/features/lms/screens/lms_course_detail_screen.dart';
import 'package:aplikasi_mobile_siswa/shared/widgets/premium_header.dart';

// Warna brand
const Color kPrimaryBlue = Color(0xFF055D97);
const Color kSuccessGreen = Color(0xFF10B981);
const Color kWarningOrange = Color(0xFFF59E0B);
const Color kBgColor = Color(0xFFF8FAFC);
const Color kTextDark = Color(0xFF0F172A);
const Color kTextMuted = Color(0xFF64748B);

class LMSDashboardScreen extends StatelessWidget {
  const LMSDashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final LMSController controller = Get.put(LMSController());
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));

    return Scaffold(
      backgroundColor: kBgColor,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ─── HEADER ──────────────────────────────────────────────
          PremiumHeader(
            title: 'LMS & Tugas',
            expandedHeight: 200,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.menu_book_rounded, color: Colors.white, size: 40),
                ),
                const SizedBox(height: 12),
                Text('Semester Ganjil 2025/2026', style: GoogleFonts.nunito(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
              ],
            ),
          ),

          // ─── PROGRESS STATS ──────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator(color: kPrimaryBlue)));
                }
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text('Tertunda', style: GoogleFonts.nunito(color: kTextMuted, fontSize: 11, fontWeight: FontWeight.w700)),
                            const SizedBox(height: 4),
                            Text('${controller.tugasTertunda.value}', style: GoogleFonts.nunito(color: kWarningOrange, fontSize: 20, fontWeight: FontWeight.w800)),
                          ],
                        ),
                      ),
                      Container(width: 1, height: 40, color: const Color(0xFFE2E8F0)),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text('Selesai', style: GoogleFonts.nunito(color: kTextMuted, fontSize: 11, fontWeight: FontWeight.w700)),
                            const SizedBox(height: 4),
                            Text('${controller.tugasSelesai.value}', style: GoogleFonts.nunito(color: kSuccessGreen, fontSize: 20, fontWeight: FontWeight.w800)),
                          ],
                        ),
                      ),
                      Container(width: 1, height: 40, color: const Color(0xFFE2E8F0)),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text('Rata-rata', style: GoogleFonts.nunito(color: kTextMuted, fontSize: 11, fontWeight: FontWeight.w700)),
                            const SizedBox(height: 4),
                            Text('${controller.rataRata.value}', style: GoogleFonts.nunito(color: kTextDark, fontSize: 20, fontWeight: FontWeight.w800)),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ─── TENGGAT WAKTU (DEADLINE) ───────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Tenggat Waktu Dekat', style: GoogleFonts.nunito(fontSize: 18, fontWeight: FontWeight.w800, color: kTextDark)),
                      Text('Lihat Semua', style: GoogleFonts.nunito(fontSize: 14, fontWeight: FontWeight.w700, color: kPrimaryBlue)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Obx(() {
                    if (controller.isLoading.value) return const SizedBox();
                    if (controller.mapelAktif.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.all(20),
                        child: Center(child: Text('Belum ada mata pelajaran', style: GoogleFonts.nunito(color: kTextMuted))),
                      );
                    }
                    return GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                        childAspectRatio: 0.82,
                      ),
                      itemCount: controller.mapelAktif.length,
                      itemBuilder: (context, index) {
                        final m = controller.mapelAktif[index];
                        // Convert hex string "#2563EB" to Color
                        String hexColor = m['color'].replaceAll('#', '0xFF');
                        Color color = Color(int.parse(hexColor));
                        
                        return GestureDetector(
                          onTap: () => Get.to(() => LMSCourseDetailScreen(courseId: m['id'].toString())),
                          child: _buildSubjectCard(
                            m['mata_pelajaran'], 
                            m['guru'], 
                            '${m['tugas_baru']} Tugas Baru', 
                            Icons.book_rounded, 
                            color
                          ),
                        );
                      },
                    );
                  }),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskCard({
    required String subject,
    required String title,
    required String deadline,
    required bool isUrgent,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isUrgent ? const Color(0xFFFECACA) : const Color(0xFFE2E8F0), width: isUrgent ? 1.5 : 1),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(14)),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(subject, style: GoogleFonts.nunito(fontSize: 12, fontWeight: FontWeight.w700, color: color)),
                const SizedBox(height: 4),
                Text(title, style: GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.w800, color: kTextDark)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.schedule_rounded, size: 14, color: isUrgent ? const Color(0xFFEF4444) : kTextMuted),
                    const SizedBox(width: 6),
                    Text(deadline, style: GoogleFonts.nunito(fontSize: 13, fontWeight: FontWeight.w700, color: isUrgent ? const Color(0xFFEF4444) : kTextMuted)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubjectCard(String title, String teacher, String count, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: color, size: 24),
          ),
          const Spacer(),
          Text(title, style: GoogleFonts.nunito(fontSize: 15, fontWeight: FontWeight.w800, color: kTextDark, height: 1.2), maxLines: 2, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 4),
          Text(teacher, style: GoogleFonts.nunito(fontSize: 12, fontWeight: FontWeight.w600, color: kTextMuted), maxLines: 1, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(8)),
            child: Text(count, style: GoogleFonts.nunito(fontSize: 11, fontWeight: FontWeight.w700, color: const Color(0xFF475569))),
          ),
        ],
      ),
    );
  }
}
