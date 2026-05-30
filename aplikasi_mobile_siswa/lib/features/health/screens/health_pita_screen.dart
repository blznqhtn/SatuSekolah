import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:aplikasi_mobile_siswa/features/health/controllers/health_controller.dart';
import 'package:aplikasi_mobile_siswa/shared/widgets/premium_header.dart';

const Color kPrimaryPink = Color(0xFFEC4899);
const Color kDangerRed = Color(0xFFEF4444);
const Color kSuccessGreen = Color(0xFF10B981);
const Color kHealthBg = Color(0xFFF8FAFC);
const Color kTextDark = Color(0xFF0F172A);
const Color kTextMuted = Color(0xFF64748B);

class HealthPitaScreen extends StatelessWidget {
  const HealthPitaScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final HealthController controller = Get.find<HealthController>();

    return Scaffold(
      backgroundColor: kHealthBg,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          PremiumHeader(
            title: 'Sistem Pita',
            expandedHeight: 180,
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
                  child: const Icon(Icons.favorite_rounded, color: Colors.white, size: 40),
                ),
                const SizedBox(height: 12),
                Text('Peminjaman Pita UKS', style: GoogleFonts.nunito(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
              ],
            ),
          ),
          SliverToBoxAdapter(
            child: Obx(() {
              if (controller.isPitaLoading.value) {
                return const Padding(padding: EdgeInsets.all(40), child: Center(child: CircularProgressIndicator(color: kPrimaryPink)));
              }

              final status = controller.statusPita;
              final isActive = status['is_active'] == true;

              return Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ─── KARTU STATUS AKTIF ──────────────────────────────────
                    if (isActive) _buildActivePitaCard(status)
                    else _buildNoActivePita(controller),

                    const SizedBox(height: 32),

                    // ─── RIWAYAT ──────────────────────────────────────────────
                    Text('Riwayat Peminjaman', style: GoogleFonts.nunito(fontSize: 18, fontWeight: FontWeight.w800, color: kTextDark)),
                    const SizedBox(height: 16),
                    _buildHistoryList(controller),
                    
                    const SizedBox(height: 40),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildActivePitaCard(Map<dynamic, dynamic> status) {
    final int keterlambatan = status['keterlambatan'] ?? 0;
    final bool isLate = keterlambatan > 0;
    
    final Color cardColor = isLate ? kDangerRed : const Color(0xFF3B82F6);
    
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: cardColor.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 10)),
        ],
        border: Border.all(color: cardColor.withOpacity(0.2), width: 1.5),
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            decoration: BoxDecoration(
              color: cardColor.withOpacity(0.1),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Row(
              children: [
                Icon(isLate ? Icons.warning_rounded : Icons.info_rounded, color: cardColor),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    isLate ? 'TERLAMBAT MENGEMBALIKAN' : 'SEDANG MEMINJAM PITA',
                    style: GoogleFonts.nunito(color: cardColor, fontWeight: FontWeight.w800, fontSize: 14),
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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Tanggal Pinjam', style: GoogleFonts.nunito(color: kTextMuted, fontWeight: FontWeight.w600)),
                    Text(status['tanggal_pinjam'] ?? '-', style: GoogleFonts.nunito(color: kTextDark, fontWeight: FontWeight.w800)),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Estimasi Kembali', style: GoogleFonts.nunito(color: kTextMuted, fontWeight: FontWeight.w600)),
                    Text(status['estimasi_kembali'] ?? '-', style: GoogleFonts.nunito(color: kTextDark, fontWeight: FontWeight.w800)),
                  ],
                ),
                if (isLate) ...[
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: kDangerRed.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: kDangerRed.withOpacity(0.2)),
                    ),
                    child: Text(
                      status['warning_msg'] ?? 'Segera kembalikan pita ke UKS!',
                      style: GoogleFonts.nunito(color: kDangerRed, fontWeight: FontWeight.w700, fontSize: 13, height: 1.4),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ] else ...[
                   const SizedBox(height: 16),
                   Text(
                      'Harap kembalikan pita ke UKS tepat waktu.',
                      style: GoogleFonts.nunito(color: kTextMuted, fontWeight: FontWeight.w600, fontSize: 13),
                      textAlign: TextAlign.center,
                   ),
                ]
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoActivePita(HealthController controller) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: kPrimaryPink.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.favorite_border_rounded, size: 40, color: kPrimaryPink),
          ),
          const SizedBox(height: 16),
          Text('Tidak Ada Peminjaman Aktif', style: GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.w800, color: kTextDark)),
          const SizedBox(height: 8),
          Text('Anda dapat meminjam pita jika sedang dalam kondisi tidak enak badan atau membutuhkan izin ke UKS.', 
            style: GoogleFonts.nunito(fontSize: 13, color: kTextMuted, height: 1.5), textAlign: TextAlign.center),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: Obx(() => ElevatedButton.icon(
              onPressed: controller.isSubmitting.value ? null : () => controller.requestPita(),
              icon: controller.isSubmitting.value ? const SizedBox() : const Icon(Icons.add_rounded, size: 18),
              label: controller.isSubmitting.value 
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : Text('Ajukan Peminjaman Pita', style: GoogleFonts.nunito(fontWeight: FontWeight.w700)),
              style: ElevatedButton.styleFrom(
                backgroundColor: kPrimaryPink,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            )),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryList(HealthController controller) {
    if (controller.riwayatPita.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Text('Belum ada riwayat peminjaman.', style: GoogleFonts.nunito(color: kTextMuted), textAlign: TextAlign.center),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      itemCount: controller.riwayatPita.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final item = controller.riwayatPita[index];
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: kSuccessGreen.withOpacity(0.1), shape: BoxShape.circle),
                child: const Icon(Icons.check_circle_rounded, color: kSuccessGreen, size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Pinjam: ${item['tanggal_pinjam']}', style: GoogleFonts.nunito(fontWeight: FontWeight.w700, color: kTextDark, fontSize: 14)),
                    const SizedBox(height: 4),
                    Text('Kembali: ${item['tanggal_kembali']}', style: GoogleFonts.nunito(fontWeight: FontWeight.w600, color: kTextMuted, fontSize: 13)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: kSuccessGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(item['status'], style: GoogleFonts.nunito(fontWeight: FontWeight.w800, color: kSuccessGreen, fontSize: 10)),
              ),
            ],
          ),
        );
      },
    );
  }
}
