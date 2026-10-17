import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:aplikasi_mobile_siswa/features/academic/controllers/academic_activity_controller.dart';
import 'package:aplikasi_mobile_siswa/features/academic/screens/counseling_booking_screen.dart';

class CounselingScreen extends StatelessWidget {
  const CounselingScreen({Key? key}) : super(key: key);

  AcademicActivityController get _ctrl =>
      Get.isRegistered<AcademicActivityController>()
          ? Get.find<AcademicActivityController>()
          : Get.put(AcademicActivityController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF0F172A), size: 20),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Konseling BK',
          style: TextStyle(
            color: Color(0xFF0F172A),
            fontWeight: FontWeight.bold,
            fontSize: 20,
            letterSpacing: -0.5,
          ),
        ),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        color: const Color(0xFF7C3AED),
        onRefresh: () => _ctrl.fetchMyCounselingSessions(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF7C3AED),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Butuh Teman Cerita?',
                            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Guru BK kami siap mendengarkan dan membantu memberikan solusi.',
                            style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.5),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Icon(Icons.forum_rounded, color: Colors.white, size: 48),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => Get.to(() => const CounselingBookingScreen()),
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('Ajukan Jadwal Konseling'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F172A),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                'Riwayat Konseling',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 16),
              Obx(() {
                if (_ctrl.isLoadingCounseling.value) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: Center(
                      child: CircularProgressIndicator(color: Color(0xFF7C3AED)),
                    ),
                  );
                }

                if (_ctrl.counselingError.value.isNotEmpty) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Center(
                      child: Column(
                        children: [
                          const Icon(Icons.error_outline_rounded, color: Colors.red, size: 36),
                          const SizedBox(height: 8),
                          Text(_ctrl.counselingError.value, style: const TextStyle(color: Color(0xFF64748B))),
                          const SizedBox(height: 8),
                          TextButton(
                            onPressed: () => _ctrl.fetchMyCounselingSessions(),
                            child: const Text('Coba Lagi'),
                          )
                        ],
                      ),
                    ),
                  );
                }

                if (_ctrl.counselingSessions.isEmpty) {
                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      children: const [
                        Icon(Icons.chat_bubble_outline_rounded, size: 48, color: Color(0xFF94A3B8)),
                        SizedBox(height: 12),
                        Text(
                          'Belum Ada Sesi Konseling',
                          style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F172A), fontSize: 16),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Pengajuan sesi konseling bersama Guru BK akan tercatat di sini.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Color(0xFF64748B), fontSize: 13),
                        ),
                      ],
                    ),
                  );
                }

                return Column(
                  children: _ctrl.counselingSessions.map((session) {
                    final date = session.scheduledAt ?? session.preferredDate;
                    return _buildHistoryItem(
                      session.topic,
                      date,
                      session.statusLabel,
                      _getStatusColor(session.status),
                      session.description,
                      session.counselorNotes,
                    );
                  }).toList(),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHistoryItem(String title, String date, String status, Color statusColor, String description, String? counselorNotes) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F3FF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.event_note_rounded, color: Color(0xFF7C3AED)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F172A), fontSize: 15),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      date.length >= 10 ? date.substring(0, 10) : date,
                      style: const TextStyle(color: Color(0xFF64748B), fontSize: 13),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  status,
                  style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 12),
                ),
              )
            ],
          ),
          if (description.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              description,
              style: const TextStyle(color: Color(0xFF475569), fontSize: 13),
            ),
          ],
          if (counselorNotes != null && counselorNotes.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Text(
                'Catatan BK: $counselorNotes',
                style: const TextStyle(color: Color(0xFF64748B), fontSize: 12, fontStyle: FontStyle.italic),
              ),
            ),
          ]
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'COMPLETED':
        return Colors.green;
      case 'SCHEDULED':
        return const Color(0xFF2563EB);
      case 'CANCELLED':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }
}
