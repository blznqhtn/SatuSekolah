import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:aplikasi_mobile_siswa/features/academic/controllers/academic_activity_controller.dart';
import 'package:aplikasi_mobile_siswa/features/academic/screens/permit_submission_screen.dart';

class StudentPermitScreen extends StatelessWidget {
  const StudentPermitScreen({Key? key}) : super(key: key);

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
          'Perizinan Siswa',
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
        color: const Color(0xFFD97706),
        onRefresh: () => _ctrl.fetchMyPermits(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => Get.to(() => const PermitSubmissionScreen()),
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('Buat Pengajuan Izin'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD97706),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                'Riwayat Perizinan',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 16),
              Obx(() {
                if (_ctrl.isLoadingPermits.value) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: Center(
                      child: CircularProgressIndicator(color: Color(0xFFD97706)),
                    ),
                  );
                }

                if (_ctrl.permitError.value.isNotEmpty) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Center(
                      child: Column(
                        children: [
                          const Icon(Icons.error_outline_rounded, color: Colors.red, size: 36),
                          const SizedBox(height: 8),
                          Text(_ctrl.permitError.value, style: const TextStyle(color: Color(0xFF64748B))),
                          const SizedBox(height: 8),
                          TextButton(
                            onPressed: () => _ctrl.fetchMyPermits(),
                            child: const Text('Coba Lagi'),
                          )
                        ],
                      ),
                    ),
                  );
                }

                if (_ctrl.permits.isEmpty) {
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
                        Icon(Icons.assignment_outlined, size: 48, color: Color(0xFF94A3B8)),
                        SizedBox(height: 12),
                        Text(
                          'Belum Ada Pengajuan Izin',
                          style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F172A), fontSize: 16),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Riwayat perizinan sakit atau keperluan lain akan tampil di sini.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Color(0xFF64748B), fontSize: 13),
                        ),
                      ],
                    ),
                  );
                }

                return Column(
                  children: _ctrl.permits.map((permit) {
                    final dateRange = permit.startDate == permit.endDate
                        ? _formatDate(permit.startDate)
                        : '${_formatDate(permit.startDate)} - ${_formatDate(permit.endDate)}';
                    return _buildPermitItem(permit.typeLabel, dateRange, permit.statusLabel, _getStatusColor(permit.status), permit.reason);
                  }).toList(),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPermitItem(String type, String date, String status, Color statusColor, String reason) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFBEB),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.assignment_rounded, color: Color(0xFFD97706)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  type,
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F172A), fontSize: 15),
                ),
                const SizedBox(height: 4),
                Text(
                  date,
                  style: const TextStyle(color: Color(0xFF64748B), fontSize: 13),
                ),
                if (reason.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    reason,
                    style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
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
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'APPROVED':
        return Colors.green;
      case 'REJECTED':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  String _formatDate(String raw) {
    if (raw.length >= 10) {
      return raw.substring(0, 10);
    }
    return raw;
  }
}
