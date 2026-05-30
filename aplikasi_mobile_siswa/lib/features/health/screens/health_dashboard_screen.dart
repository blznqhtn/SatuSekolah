import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:aplikasi_mobile_siswa/features/health/controllers/health_controller.dart';
import 'package:aplikasi_mobile_siswa/features/health/screens/health_update_screen.dart';
import 'package:aplikasi_mobile_siswa/features/health/screens/health_uks_request_screen.dart';
import 'package:aplikasi_mobile_siswa/features/health/screens/health_menstruation_screen.dart';
import 'package:aplikasi_mobile_siswa/features/health/screens/health_pita_screen.dart';
import 'package:aplikasi_mobile_siswa/shared/widgets/premium_header.dart';

// Warna brand
const Color kPrimaryBlue = Color(0xFF055D97);
const Color kHealthRed = Color(0xFFEF4444);
const Color kDangerRed = Color(0xFFEF4444);
const Color kHealthBg = Color(0xFFF8FAFC);
const Color kTextDark = Color(0xFF0F172A);
const Color kTextMuted = Color(0xFF64748B);

class HealthDashboardScreen extends StatelessWidget {
  const HealthDashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final HealthController controller = Get.put(HealthController());
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));

    return Scaffold(
      backgroundColor: kHealthBg,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ─── HEADER ──────────────────────────────────────────────
          PremiumHeader(
            title: 'AkuSehat',
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
                  child: const Icon(Icons.monitor_heart_rounded, color: Colors.white, size: 40),
                ),
                const SizedBox(height: 12),
                Text('Monitoring Kesehatan Siswa', style: GoogleFonts.nunito(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
              ],
            ),
          ),

          // ─── ID CARD KESEHATAN ──────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator(color: kPrimaryBlue)));
                }
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 8)),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Info Fisik
                      Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Expanded(child: _buildHealthStat('Tinggi', '${controller.tinggiBadan.value}', 'cm', Icons.height)),
                                Container(width: 1, height: 40, color: const Color(0xFFE2E8F0)),
                                Expanded(child: _buildHealthStat('Berat', '${controller.beratBadan.value}', 'kg', Icons.monitor_weight_outlined)),
                              ],
                            ),
                            const SizedBox(height: 24),
                            Container(height: 1, width: double.infinity, color: const Color(0xFFE2E8F0)),
                            const SizedBox(height: 24),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Expanded(child: _buildHealthStat('BMI', '${controller.bmi.value.toStringAsFixed(1)}', controller.bmiStatus.value, Icons.speed)),
                                Container(width: 1, height: 40, color: const Color(0xFFE2E8F0)),
                                Expanded(child: _buildHealthStat('Hb Darah', '${controller.hemoglobin.value}', 'g/dL', Icons.bloodtype_rounded)),
                              ],
                            ),
                          ],
                        ),
                      ),
                      // Aksi UKS & Update Fisik
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        decoration: const BoxDecoration(
                          color: Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: () => Get.to(() => const HealthUpdateScreen()),
                                    icon: const Icon(Icons.edit_rounded, size: 16),
                                    label: FittedBox(fit: BoxFit.scaleDown, child: Text('Update Data', style: GoogleFonts.nunito(fontWeight: FontWeight.w700, fontSize: 12))),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: kPrimaryBlue,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                      elevation: 0,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: () => Get.to(() => const HealthUksRequestScreen()),
                                    icon: const Icon(Icons.medical_services_rounded, size: 16),
                                    label: FittedBox(fit: BoxFit.scaleDown, child: Text('Ke UKS', style: GoogleFonts.nunito(fontWeight: FontWeight.w700, fontSize: 12))),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: kDangerRed,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                      elevation: 0,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            if (controller.jenisKelamin.value == 'P') ...[
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      onPressed: () {
                                        controller.fetchMenstruationData();
                                        Get.to(() => const HealthMenstruationScreen());
                                      },
                                      icon: const Icon(Icons.water_drop_rounded, size: 16, color: Color(0xFFEC4899)),
                                      label: FittedBox(fit: BoxFit.scaleDown, child: Text('Siklus Haid', style: GoogleFonts.nunito(fontWeight: FontWeight.w700, fontSize: 12, color: const Color(0xFFEC4899)))),
                                      style: OutlinedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(vertical: 12),
                                        side: const BorderSide(color: Color(0xFFEC4899)),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      onPressed: () {
                                        controller.fetchPitaData();
                                        Get.to(() => const HealthPitaScreen());
                                      },
                                      icon: const Icon(Icons.favorite_rounded, size: 16, color: Color(0xFFEC4899)),
                                      label: FittedBox(fit: BoxFit.scaleDown, child: Text('Pinjam Pita', style: GoogleFonts.nunito(fontWeight: FontWeight.w700, fontSize: 12, color: const Color(0xFFEC4899)))),
                                      style: OutlinedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(vertical: 12),
                                        side: const BorderSide(color: Color(0xFFEC4899)),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
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
                  const SizedBox(height: 12),

                  // ─── RIWAYAT KESEHATAN & UKS ────────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Riwayat UKS', style: GoogleFonts.nunito(fontSize: 18, fontWeight: FontWeight.w800, color: kTextDark)),
                      Text('Semua', style: GoogleFonts.nunito(fontSize: 14, fontWeight: FontWeight.w700, color: kPrimaryBlue)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Obx(() {
                    if (controller.isLoading.value) return const SizedBox();
                    if (controller.riwayatUks.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.all(20),
                        child: Center(child: Text('Belum ada riwayat kunjungan UKS', style: GoogleFonts.nunito(color: kTextMuted))),
                      );
                    }
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: EdgeInsets.zero,
                      itemCount: controller.riwayatUks.length,
                      itemBuilder: (context, index) {
                        final riwayat = controller.riwayatUks[index];
                        return _buildHistoryCard(
                          date: '${riwayat['tanggal']} • ${riwayat['waktu']} WIB',
                          diagnosis: riwayat['keluhan'],
                          action: riwayat['tindakan'],
                          handledBy: 'Petugas UKS',
                          icon: Icons.healing_rounded,
                          color: const Color(0xFF3B82F6),
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

  Widget _buildHealthStat(String label, String value, String unit, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: const Color(0xFF64748B), size: 24),
        const SizedBox(height: 8),
        Text(label, style: GoogleFonts.nunito(color: const Color(0xFF64748B), fontSize: 12, fontWeight: FontWeight.w700)),
        const SizedBox(height: 4),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(value, style: GoogleFonts.nunito(color: const Color(0xFF0F172A), fontSize: 20, fontWeight: FontWeight.w800)),
              const SizedBox(width: 2),
              Text(unit, style: GoogleFonts.nunito(color: const Color(0xFF64748B), fontSize: 12, fontWeight: FontWeight.w700)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHistoryCard({
    required String date,
    required String diagnosis,
    required String action,
    required String handledBy,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8, offset: const Offset(0, 4))],
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: Text(diagnosis, style: GoogleFonts.nunito(fontSize: 15, fontWeight: FontWeight.w800, color: kTextDark), maxLines: 2, overflow: TextOverflow.ellipsis)),
                    const SizedBox(width: 8),
                    Text(date, style: GoogleFonts.nunito(fontSize: 12, fontWeight: FontWeight.w700, color: kTextMuted)),
                  ],
                ),
                const SizedBox(height: 6),
                Text(action, style: GoogleFonts.nunito(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF475569), height: 1.4)),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(Icons.medical_services_rounded, size: 14, color: Color(0xFF94A3B8)),
                    const SizedBox(width: 6),
                    Text('Petugas: $handledBy', style: GoogleFonts.nunito(fontSize: 12, fontWeight: FontWeight.w700, color: const Color(0xFF94A3B8))),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
