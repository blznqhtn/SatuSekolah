import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:aplikasi_mobile_siswa/features/schedule/screens/schedule_screen.dart';
import 'package:aplikasi_mobile_siswa/features/report_card/screens/report_card_screen.dart';
import 'package:aplikasi_mobile_siswa/features/evaluation/screens/evaluation_list_screen.dart';
import 'package:aplikasi_mobile_siswa/features/academic/screens/academic_calendar_screen.dart';
import 'package:aplikasi_mobile_siswa/features/academic/screens/extracurricular_screen.dart';
import 'package:aplikasi_mobile_siswa/features/academic/screens/counseling_screen.dart';
import 'package:aplikasi_mobile_siswa/features/academic/screens/student_permit_screen.dart';
import 'package:aplikasi_mobile_siswa/features/dashboard/screens/notification_screen.dart';
import 'package:aplikasi_mobile_siswa/features/academic/screens/academic_announcement_screen.dart';

// Model untuk data kelas
class ClassItem {
  final String subject;
  final String teacher;
  final String room;
  final IconData icon;
  final Color color;
  final String startTime; // format "HH:mm"
  final String endTime;   // format "HH:mm"

  const ClassItem({
    required this.subject,
    required this.teacher,
    required this.room,
    required this.icon,
    required this.color,
    required this.startTime,
    required this.endTime,
  });

  TimeOfDay get start {
    final parts = startTime.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  TimeOfDay get end {
    final parts = endTime.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }
}

class AkademikScreen extends StatefulWidget {
  const AkademikScreen({Key? key}) : super(key: key);

  @override
  State<AkademikScreen> createState() => _AkademikScreenState();
}

class _AkademikScreenState extends State<AkademikScreen> {
  late Timer _timer;
  late DateTime _now;

  // Semua kelas hari ini
  static const List<ClassItem> _todayClasses = [
    ClassItem(
      subject: 'Matematika',
      teacher: 'Monica Irawati. R, S.Pd.',
      room: 'Ruang X RPL 1',
      icon: Icons.calculate_rounded,
      color: Color(0xFF2563EB),
      startTime: '08:00',
      endTime: '08:40',
    ),
    ClassItem(
      subject: 'Matematika',
      teacher: 'Monica Irawati. R, S.Pd.',
      room: 'Ruang X RPL 1',
      icon: Icons.calculate_rounded,
      color: Color(0xFF2563EB),
      startTime: '08:40',
      endTime: '09:10',
    ),
    ClassItem(
      subject: 'Bahasa Indonesia',
      teacher: 'Ine Yulianti, S.Pd.',
      room: 'Ruang X RPL 1',
      icon: Icons.menu_book_rounded,
      color: Color(0xFF059669),
      startTime: '09:40',
      endTime: '10:10',
    ),
    ClassItem(
      subject: 'Bahasa Indonesia',
      teacher: 'Ine Yulianti, S.Pd.',
      room: 'Ruang X RPL 1',
      icon: Icons.menu_book_rounded,
      color: Color(0xFF059669),
      startTime: '10:10',
      endTime: '10:50',
    ),
    ClassItem(
      subject: 'Pendidikan Agama Islam',
      teacher: 'Drs. H. Ahmad',
      room: 'Ruang X RPL 1',
      icon: Icons.mosque_rounded,
      color: Color(0xFF055D97),
      startTime: '10:50',
      endTime: '11:30',
    ),
    ClassItem(
      subject: 'Pemrograman Web',
      teacher: 'Budi Santoso, M.Kom.',
      room: 'Lab Komputer 1',
      icon: Icons.computer_rounded,
      color: Color(0xFF7C3AED),
      startTime: '12:30',
      endTime: '13:10',
    ),
    ClassItem(
      subject: 'Pemrograman Web',
      teacher: 'Budi Santoso, M.Kom.',
      room: 'Lab Komputer 1',
      icon: Icons.computer_rounded,
      color: Color(0xFF7C3AED),
      startTime: '13:10',
      endTime: '13:50',
    ),
    ClassItem(
      subject: 'Bahasa Inggris',
      teacher: 'Siti Aminah, M.Pd.',
      room: 'Ruang X RPL 1',
      icon: Icons.language_rounded,
      color: Color(0xFFDC2626),
      startTime: '13:50',
      endTime: '14:30',
    ),
    ClassItem(
      subject: 'Basis Data',
      teacher: 'Rini Astuti, S.T.',
      room: 'Lab Komputer 2',
      icon: Icons.storage_rounded,
      color: Color(0xFF0D9488),
      startTime: '14:30',
      endTime: '15:10',
    ),
    ClassItem(
      subject: 'Basis Data',
      teacher: 'Rini Astuti, S.T.',
      room: 'Lab Komputer 2',
      icon: Icons.storage_rounded,
      color: Color(0xFF0D9488),
      startTime: '15:10',
      endTime: '15:50',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _now = DateTime.now();
    _timer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) {
        setState(() {
          _now = DateTime.now();
        });
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  /// Cari kelas yang sedang berlangsung atau kelas berikutnya
  _NextClassResult _getNextOrCurrentClass() {
    final now = TimeOfDay(hour: _now.hour, minute: _now.minute);
    final nowMinutes = now.hour * 60 + now.minute;

    // Cek apakah ada kelas yang sedang berlangsung
    for (final cls in _todayClasses) {
      final startMinutes = cls.start.hour * 60 + cls.start.minute;
      final endMinutes = cls.end.hour * 60 + cls.end.minute;
      if (nowMinutes >= startMinutes && nowMinutes < endMinutes) {
        return _NextClassResult(cls, isOngoing: true);
      }
    }

    // Cari kelas berikutnya
    for (final cls in _todayClasses) {
      final startMinutes = cls.start.hour * 60 + cls.start.minute;
      if (nowMinutes < startMinutes) {
        return _NextClassResult(cls, isOngoing: false);
      }
    }

    return _NextClassResult(null, isOngoing: false);
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));

    final nextClassResult = _getNextOrCurrentClass();
    final nextClass = nextClassResult.classItem;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text(
          'Akademik',
          style: TextStyle(
            color: Color(0xFF0F172A),
            fontWeight: FontWeight.bold,
            fontSize: 24,
            letterSpacing: -0.5,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Color(0xFF334155)),
            onPressed: () {
              Get.to(() => const NotificationScreen());
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Next Class Card (Real-time)
            const Text(
              'Kelas Selanjutnya',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 12),
            _buildNextClassCard(nextClass, nextClassResult.isOngoing),

            const SizedBox(height: 24),

            const Text(
              'Layanan Akademik',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 16),
            
            // Grid Akademik
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.zero,
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1.1,
              children: [
                _buildAcademicMenuCard(
                  title: 'Kalender\nAkademik',
                  icon: Icons.edit_calendar_rounded,
                  color: const Color(0xFF2563EB),
                  bgColor: const Color(0xFFEFF6FF),
                  onTap: () => Get.to(() => const AcademicCalendarScreen()),
                ),
                _buildAcademicMenuCard(
                  title: 'Ekstra\nKurikuler',
                  icon: Icons.sports_basketball_rounded,
                  color: const Color(0xFF059669),
                  bgColor: const Color(0xFFECFDF5),
                  onTap: () => Get.to(() => const ExtracurricularScreen()),
                ),
                _buildAcademicMenuCard(
                  title: 'Konseling\nBK',
                  icon: Icons.support_agent_rounded,
                  color: const Color(0xFF7C3AED),
                  bgColor: const Color(0xFFF5F3FF),
                  onTap: () => Get.to(() => const CounselingScreen()),
                ),
                _buildAcademicMenuCard(
                  title: 'Perizinan\nSiswa',
                  icon: Icons.assignment_rounded,
                  color: const Color(0xFFD97706),
                  bgColor: const Color(0xFFFFFBEB),
                  onTap: () => Get.to(() => const StudentPermitScreen()),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Pengumuman Akademik
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Expanded(
                  child: Text(
                    'Pengumuman Akademik',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Get.to(() => const AcademicAnnouncementScreen());
                  },
                  child: const Text(
                    'Lihat Semua',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF055D97),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildAnnouncementItem(
              title: 'Jadwal Remedial Semester Ganjil',
              date: '15 Desember 2025',
              type: 'Penting',
              desc: 'Pelaksanaan remedial untuk mata pelajaran Matematika dan Bahasa Indonesia akan dilaksanakan minggu depan. Harap mempersiapkan diri.',
              icon: Icons.assignment_late_rounded,
              color: const Color(0xFFDC2626),
            ),
            _buildAnnouncementItem(
              title: 'Pengumpulan Tugas Akhir PKL',
              date: '20 Desember 2025',
              type: 'Tugas',
              desc: 'Seluruh laporan PKL wajib dikumpulkan dalam bentuk digital dan cetak. Keterlambatan akan mempengaruhi nilai akhir semester.',
              icon: Icons.folder_rounded,
              color: const Color(0xFFD97706),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNextClassCard(ClassItem? cls, bool isOngoing) {
    if (cls == null) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle_outline_rounded, color: Color(0xFF64748B), size: 28),
            ),
            const SizedBox(width: 16),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Tidak Ada Kelas', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Color(0xFF0F172A))),
                  SizedBox(height: 4),
                  Text('Semua pelajaran hari ini telah selesai 🎉', style: TextStyle(color: Color(0xFF64748B), fontSize: 13)),
                ],
              ),
            ),
          ],
        ),
      );
    }

    final timeLabel = isOngoing
        ? 'Sedang berlangsung hingga ${cls.endTime}'
        : 'Dimulai pukul ${cls.startTime}';
    final badgeColor = isOngoing ? const Color(0xFF10B981) : const Color(0xFFF59E0B);
    final badgeText = isOngoing ? '🔴 LIVE' : '⏰ Berikutnya';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF055D97), Color(0xFF0891B2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF055D97).withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          )
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: badgeColor.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: badgeColor.withOpacity(0.5)),
                  ),
                  child: Text(badgeText, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 8),
                Text(
                  cls.subject,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  timeLabel,
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  'Guru: ${cls.teacher}',
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '📍 ${cls.room}',
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(cls.icon, color: Colors.white, size: 32),
          )
        ],
      ),
    );
  }

  Widget _buildAcademicMenuCard({
    required String title,
    required IconData icon,
    required Color color,
    required Color bgColor,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                    height: 1.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnnouncementItem({
    required String title,
    required String date,
    required String type,
    required String desc,
    required IconData icon,
    required Color color,
  }) {
    return GestureDetector(
      onTap: () {
        Get.to(() => AnnouncementDetailScreen(
          title: title,
          date: date,
          type: type,
          desc: desc,
          icon: icon,
          color: color,
        ));
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 8,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: Row(
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
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Color(0xFF0F172A),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    date,
                    style: const TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                type,
                style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NextClassResult {
  final ClassItem? classItem;
  final bool isOngoing;
  _NextClassResult(this.classItem, {required this.isOngoing});
}

// ========================
// Halaman Detail Pengumuman
// ========================
class AnnouncementDetailScreen extends StatelessWidget {
  final String title;
  final String date;
  final String type;
  final String desc;
  final IconData icon;
  final Color color;

  const AnnouncementDetailScreen({
    Key? key,
    required this.title,
    required this.date,
    required this.type,
    required this.desc,
    required this.icon,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF0F172A), size: 20),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Detail Pengumuman',
          style: TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: color.withOpacity(0.2)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, color: color, size: 28),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(type, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          title,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF0F172A), height: 1.3),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(Icons.calendar_today_rounded, size: 13, color: Color(0xFF64748B)),
                            const SizedBox(width: 4),
                            Text(date, style: const TextStyle(color: Color(0xFF64748B), fontSize: 12)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text('Detail Pengumuman', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF0F172A))),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Text(
                desc,
                style: const TextStyle(color: Color(0xFF475569), height: 1.6, fontSize: 14),
              ),
            ),
            const SizedBox(height: 24),
            const Text('Informasi Tambahan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF0F172A))),
            const SizedBox(height: 12),
            _buildInfoRow('Dikeluarkan oleh', 'Waka Kurikulum'),
            _buildInfoRow('Berlaku untuk', 'Semua Siswa'),
            _buildInfoRow('Status', 'Aktif'),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => Get.back(),
                icon: const Icon(Icons.check_rounded),
                label: const Text('Sudah Dipahami'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: color,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Color(0xFF64748B), fontSize: 13)),
          Text(value, style: const TextStyle(color: Color(0xFF0F172A), fontSize: 13, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
