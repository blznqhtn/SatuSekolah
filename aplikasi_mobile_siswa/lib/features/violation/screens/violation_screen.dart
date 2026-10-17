// =============================================================================
// violation_screen.dart — Tampilan Poin Pelanggaran (terhubung ke Backend)
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:aplikasi_mobile_siswa/features/violation/controllers/violation_controller.dart';

class ViolationScreen extends StatelessWidget {
  const ViolationScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.put(ViolationController());

    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8FAFC),
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Color(0xFF0F172A), size: 20),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Poin Pelanggaran',
          style: TextStyle(
            color: Color(0xFF0F172A),
            fontWeight: FontWeight.bold,
            fontSize: 20,
            letterSpacing: -0.5,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded,
                color: Color(0xFF64748B), size: 22),
            onPressed: ctrl.fetchHistory,
            tooltip: 'Muat ulang',
          ),
        ],
      ),
      body: Obx(() {
        if (ctrl.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFFE11D48)),
          );
        }

        if (ctrl.errorMessage.isNotEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.cloud_off_rounded,
                      size: 64, color: Color(0xFFCBD5E1)),
                  const SizedBox(height: 16),
                  Text(
                    ctrl.errorMessage.value,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        color: Color(0xFF64748B), fontSize: 15),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: ctrl.fetchHistory,
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text('Coba Lagi'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE11D48),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Status Card (Total Poin)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFE11D48), Color(0xFFBE123C)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFE11D48).withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    )
                  ],
                ),
                child: Column(
                  children: [
                    const Text(
                      'Total Poin Pelanggaran',
                      style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                          fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${ctrl.totalPoints.value}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -1,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        ctrl.statusLabel.value,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w600),
                      ),
                    )
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Info Aturan
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF1F2),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFFECDD3)),
                ),
                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.info_outline_rounded,
                        color: Color(0xFFE11D48), size: 24),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Poin pelanggaran akan diakumulasi. Hukuman dan sanksi disiplin akan diberikan langsung oleh Guru BK sesuai dengan tingkat pelanggaran.',
                        style: TextStyle(
                            color: Color(0xFF9F1239), fontSize: 13, height: 1.4),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Riwayat Pelanggaran',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                      letterSpacing: -0.5,
                    ),
                  ),
                  Text(
                    '${ctrl.records.length} catatan',
                    style: const TextStyle(
                        color: Color(0xFF64748B), fontSize: 13),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              if (ctrl.records.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    child: Column(
                      children: [
                        const Icon(Icons.verified_rounded,
                            size: 64, color: Color(0xFF10B981)),
                        const SizedBox(height: 12),
                        const Text(
                          'Tidak ada pelanggaran 🎉',
                          style: TextStyle(
                              color: Color(0xFF10B981),
                              fontWeight: FontWeight.bold,
                              fontSize: 16),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Pertahankan perilaku baik kamu!',
                          style: TextStyle(
                              color: Color(0xFF64748B), fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                )
              else
                // List Riwayat dari Backend
                ...ctrl.records.map((record) =>
                    _buildViolationItem(record)).toList(),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildViolationItem(ViolationRecord record) {
    // Format tanggal jika memungkinkan
    String displayDate = record.date;
    try {
      final parsed = DateTime.parse(record.date);
      const indoMonths = [
        'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
        'Jul', 'Ags', 'Sep', 'Okt', 'Nov', 'Des'
      ];
      displayDate = '${parsed.day} ${indoMonths[parsed.month - 1]} ${parsed.year}';
    } catch (_) {}

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: Color(0xFFFFF1F2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.warning_rounded,
                color: Color(0xFFE11D48), size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  record.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  record.description,
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 13,
                  ),
                ),
                if (record.punishment != null && record.punishment!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.gavel_rounded,
                            size: 12, color: Color(0xFF475569)),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            'Hukuman BK: ${record.punishment}',
                            style: const TextStyle(
                                color: Color(0xFF475569),
                                fontSize: 11,
                                fontWeight: FontWeight.w600),
                            maxLines: 2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 8),
                Text(
                  displayDate,
                  style: const TextStyle(
                    color: Color(0xFF94A3B8),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF2F2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFFECDD3)),
            ),
            child: Text(
              '+${record.points}',
              style: const TextStyle(
                color: Color(0xFFE11D48),
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          )
        ],
      ),
    );
  }
}
