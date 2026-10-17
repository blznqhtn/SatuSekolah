import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:aplikasi_mobile_siswa/features/dashboard/controllers/dashboard_controller.dart';

class AcademicAnnouncementScreen extends StatelessWidget {
  const AcademicAnnouncementScreen({Key? key}) : super(key: key);

  DashboardController get _dashCtrl =>
      Get.isRegistered<DashboardController>()
          ? Get.find<DashboardController>()
          : Get.put(DashboardController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF0F172A), size: 20),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Semua Pengumuman',
          style: TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      body: RefreshIndicator(
        color: const Color(0xFF055D97),
        onRefresh: () => _dashCtrl.fetchAnnouncements(),
        child: Obx(() {
          final announcements = _dashCtrl.announcements;
          if (announcements.isEmpty) {
            return const Center(
              child: Text(
                'Belum ada pengumuman akademik.',
                style: TextStyle(color: Color(0xFF64748B), fontSize: 14),
              ),
            );
          }

          final colors = [
            const Color(0xFFDC2626),
            const Color(0xFF055D97),
            const Color(0xFFD97706),
            const Color(0xFF059669),
          ];

          final icons = [
            Icons.assignment_rounded,
            Icons.sports_basketball_rounded,
            Icons.directions_bus_rounded,
            Icons.event_available_rounded,
          ];

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
            itemCount: announcements.length,
            itemBuilder: (context, index) {
              final item = announcements[index];
              final color = colors[index % colors.length];
              final icon = icons[index % icons.length];
              final date = item.createdAt.isNotEmpty ? item.createdAt : 'Terbaru';
              return _buildAnnouncementCard(
                item.title,
                date,
                item.content,
                icon,
                color,
              );
            },
          );
        }),
      ),
    );
  }

  Widget _buildAnnouncementCard(String title, String date, String desc, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF0F172A)),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      date,
                      style: const TextStyle(color: Color(0xFF64748B), fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            desc,
            style: const TextStyle(color: Color(0xFF475569), height: 1.5, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
