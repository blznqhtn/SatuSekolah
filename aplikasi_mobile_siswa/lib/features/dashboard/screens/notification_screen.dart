import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF0F172A), size: 20),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Notifikasi',
          style: TextStyle(
            color: Color(0xFF0F172A),
            fontWeight: FontWeight.bold,
            fontSize: 20,
            letterSpacing: -0.5,
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 10, 20, 16),
              child: Text(
                'Baru',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),
            ),
            _buildNotificationItem(
              icon: Icons.assignment_rounded,
              iconBgColor: const Color(0xFFEFF6FF),
              iconColor: const Color(0xFF2563EB),
              title: 'Tugas Baru: Pemrograman Mobile',
              message: 'Bpk. Budi menambahkan tugas baru. Tenggat waktu besok.',
              time: '2j',
              isUnread: true,
            ),
            _buildNotificationItem(
              icon: Icons.emoji_events_rounded,
              iconBgColor: const Color(0xFFFFFBEB),
              iconColor: const Color(0xFFF59E0B),
              title: 'Nilai Diperbarui',
              message: 'Nilai ulangan harian Matematika kamu sudah keluar!',
              time: '5j',
              isUnread: true,
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 24, 20, 16),
              child: Text(
                'Hari Ini',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),
            ),
            _buildNotificationItem(
              icon: Icons.campaign_rounded,
              iconBgColor: const Color(0xFFFEF2F2),
              iconColor: const Color(0xFFE11D48),
              title: 'Pengumuman Penting',
              message: 'Besok kegiatan belajar mengajar diliburkan karena cuti bersama.',
              time: '12j',
              isUnread: false,
            ),
            _buildNotificationItem(
              icon: Icons.library_books_rounded,
              iconBgColor: const Color(0xFFECFDF5),
              iconColor: const Color(0xFF059669),
              title: 'Peminjaman Buku Berhasil',
              message: 'Buku "Atomic Habits" berhasil dipinjam dari E-Perpus.',
              time: '18j',
              isUnread: false,
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 24, 20, 16),
              child: Text(
                'Minggu Ini',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),
            ),
            _buildNotificationItem(
              icon: Icons.warning_rounded,
              iconBgColor: const Color(0xFFFEF2F2),
              iconColor: const Color(0xFFE11D48),
              title: 'Peringatan Kedisiplinan',
              message: 'Kamu mendapatkan 5 poin pelanggaran hari ini.',
              time: '3h',
              isUnread: false,
            ),
            _buildNotificationItem(
              icon: Icons.work_history_rounded,
              iconBgColor: const Color(0xFFF5F3FF),
              iconColor: const Color(0xFF7C3AED),
              title: 'Pendaftaran PKL Dibuka',
              message: 'Pendaftaran gelombang 1 untuk PKL tahun ajaran depan telah dibuka.',
              time: '5h',
              isUnread: false,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationItem({
    required IconData icon,
    required Color iconBgColor,
    required Color iconColor,
    required String title,
    required String message,
    required String time,
    required bool isUnread,
  }) {
    return Container(
      color: isUnread ? const Color(0xFFEFF6FF).withOpacity(0.5) : Colors.white,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {},
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: iconBgColor,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(icon, color: iconColor, size: 24),
                    ),
                  ],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RichText(
                        text: TextSpan(
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 14,
                            color: Color(0xFF0F172A),
                            height: 1.4,
                          ),
                          children: [
                            TextSpan(
                              text: '$title ',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            TextSpan(
                              text: message,
                              style: const TextStyle(color: Color(0xFF475569)),
                            ),
                            TextSpan(
                              text: '  $time',
                              style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                if (isUnread) ...[
                  const SizedBox(width: 8),
                  Container(
                    margin: const EdgeInsets.only(top: 8),
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Color(0xFF2563EB),
                      shape: BoxShape.circle,
                    ),
                  )
                ]
              ],
            ),
          ),
        ),
      ),
    );
  }
}
