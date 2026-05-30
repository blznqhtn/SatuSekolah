import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:aplikasi_mobile_siswa/features/attendance/controllers/attendance_controller.dart';
import 'package:aplikasi_mobile_siswa/features/attendance/screens/attendance_checkin_screen.dart';
import 'package:aplikasi_mobile_siswa/features/attendance/screens/attendance_permit_screen.dart';
import 'package:aplikasi_mobile_siswa/features/attendance/screens/attendance_rfid_screen.dart';
import 'package:aplikasi_mobile_siswa/shared/widgets/premium_header.dart';

// Warna brand
const Color kPrimary = Color(0xFF055D97);
const Color kPrimaryBlue = Color(0xFF055D97);
const Color kSuccessGreen = Color(0xFF10B981);
const Color kWarningOrange = Color(0xFFF59E0B);
const Color kDangerRed = Color(0xFFEF4444);
const Color kBgColor = Color(0xFFF8FAFC);
const Color kTextDark = Color(0xFF0F172A);
const Color kTextMuted = Color(0xFF64748B);

class AttendanceScreen extends StatelessWidget {
  const AttendanceScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final AttendanceController controller = Get.put(AttendanceController());
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
            title: 'SeHadir',
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
                  child: const Icon(Icons.fact_check_rounded, color: Colors.white, size: 40),
                ),
                const SizedBox(height: 12),
                Text('Sistem Presensi Digital', style: GoogleFonts.nunito(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
              ],
            ),
          ),

          // ─── KARTU KEHADIRAN ─────────────────────────────────────
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
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
                    ],
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: const BoxDecoration(
                          color: Color(0xFF0F172A),
                          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Kehadiran', style: GoogleFonts.nunito(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w600)),
                                  Text('${controller.persentaseKehadiran.value}%', style: GoogleFonts.nunito(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800)),
                                ],
                              ),
                            ),
                            Container(width: 1, height: 30, color: Colors.white.withOpacity(0.2)),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text('Hadir', style: GoogleFonts.nunito(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w600)),
                                  Text('${controller.rekap['hadir'] ?? 0}', style: GoogleFonts.nunito(color: kSuccessGreen, fontSize: 15, fontWeight: FontWeight.w800)),
                                ],
                              ),
                            ),
                            Container(width: 1, height: 30, color: Colors.white.withOpacity(0.2)),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text('Izin', style: GoogleFonts.nunito(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w600)),
                                  Text('${(controller.rekap['izin'] ?? 0) + (controller.rekap['sakit'] ?? 0)}', style: GoogleFonts.nunito(color: kWarningOrange, fontSize: 15, fontWeight: FontWeight.w800)),
                                ],
                              ),
                            ),
                            Container(width: 1, height: 30, color: Colors.white.withOpacity(0.2)),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text('Alfa', style: GoogleFonts.nunito(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w600)),
                                  Text('${controller.rekap['alfa'] ?? 0}', style: GoogleFonts.nunito(color: kDangerRed, fontSize: 15, fontWeight: FontWeight.w800)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: () => Get.to(() => const AttendancePermitScreen()),
                                    icon: const Icon(Icons.assignment_rounded, size: 16),
                                    label: FittedBox(fit: BoxFit.scaleDown, child: Text('Izin', style: GoogleFonts.nunito(fontWeight: FontWeight.w700, fontSize: 13))),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: const Color(0xFF0F172A),
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: () => Get.to(() => const AttendanceCheckInScreen()),
                                    icon: const Icon(Icons.fingerprint_rounded, size: 16),
                                    label: FittedBox(fit: BoxFit.scaleDown, child: Text(controller.statusHariIni.value == 'Sudah Check-in' ? 'Check-out' : 'Check-In', style: GoogleFonts.nunito(fontWeight: FontWeight.w700, fontSize: 13))),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: kPrimary,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                      elevation: 0,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              child: TextButton.icon(
                                onPressed: () => Get.to(() => const AttendanceRfidScreen()),
                                icon: const Icon(Icons.contactless_rounded, size: 18),
                                label: Text('Kartu RFID Digital Saya', style: GoogleFonts.nunito(fontWeight: FontWeight.w800, fontSize: 14)),
                                style: TextButton.styleFrom(
                                  foregroundColor: kPrimaryBlue,
                                  backgroundColor: const Color(0xFFEFF6FF),
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                              ),
                            ),
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
                  const SizedBox(height: 32),

                  // ─── RIWAYAT PRESENSI MINGGU INI ────────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Riwayat Bulan Ini', style: GoogleFonts.nunito(fontSize: 18, fontWeight: FontWeight.w800, color: kTextDark)),
                      Text('Filter', style: GoogleFonts.nunito(fontSize: 14, fontWeight: FontWeight.w700, color: kPrimaryBlue)),
                    ],
                  ),
                  Obx(() {
                    if (controller.isLoading.value) return const SizedBox();
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: EdgeInsets.zero,
                      itemCount: controller.riwayatMingguan.length,
                      itemBuilder: (context, index) {
                        final item = controller.riwayatMingguan[index];
                        Color stColor = kSuccessGreen;
                        if (item['status'] == 'Izin') stColor = kWarningOrange;
                        if (item['status'] == 'Sakit') stColor = const Color(0xFF3B82F6);
                        if (item['status'] == 'Alfa') stColor = kDangerRed;
                        return _buildAttendanceCard(
                          date: '${item['hari']}, ${item['tanggal']}',
                          timeIn: item['check_in'],
                          timeOut: item['check_out'],
                          status: item['status'],
                          statusColor: stColor,
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

  Widget _buildAttendanceCard({
    required String date,
    required String timeIn,
    required String timeOut,
    required String status,
    required Color statusColor,
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
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Text(date.split(',')[0], style: GoogleFonts.nunito(fontSize: 12, fontWeight: FontWeight.w700, color: kTextMuted)),
                const SizedBox(height: 2),
                Text(date.split(' ')[1], style: GoogleFonts.nunito(fontSize: 18, fontWeight: FontWeight.w800, color: kTextDark)),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    Text('Masuk', style: GoogleFonts.nunito(fontSize: 11, fontWeight: FontWeight.w600, color: kTextMuted)),
                    const SizedBox(height: 2),
                    Text(timeIn, style: GoogleFonts.nunito(fontSize: 15, fontWeight: FontWeight.w800, color: kTextDark)),
                  ],
                ),
                Container(width: 1, height: 30, color: const Color(0xFFE2E8F0)),
                Column(
                  children: [
                    Text('Pulang', style: GoogleFonts.nunito(fontSize: 11, fontWeight: FontWeight.w600, color: kTextMuted)),
                    const SizedBox(height: 2),
                    Text(timeOut, style: GoogleFonts.nunito(fontSize: 15, fontWeight: FontWeight.w800, color: kTextDark)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(status, style: GoogleFonts.nunito(fontSize: 11, fontWeight: FontWeight.w800, color: statusColor)),
          ),
        ],
      ),
    );
  }
}
