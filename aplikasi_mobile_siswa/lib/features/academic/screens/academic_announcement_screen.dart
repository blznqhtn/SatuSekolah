import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AcademicAnnouncementScreen extends StatelessWidget {
  const AcademicAnnouncementScreen({Key? key}) : super(key: key);

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
      body: ListView(
        padding: const EdgeInsets.all(20),
        physics: const BouncingScrollPhysics(),
        children: [
          _buildAnnouncementCard('Jadwal Ujian Tengah Semester (UTS)', '15 Okt 2026', 'Pelaksanaan UTS akan dimulai minggu depan. Pastikan semua tugas telah diselesaikan dan tagihan administrasi sudah lunas.', Icons.assignment_rounded, const Color(0xFFDC2626)),
          _buildAnnouncementCard('Pendaftaran Ekstrakurikuler Semester Genap', '12 Okt 2026', 'Silakan pilih ekstrakurikuler wajib dan pilihan melalui menu akademik. Batas waktu pendaftaran sampai hari Jumat.', Icons.sports_basketball_rounded, const Color(0xFF055D97)),
          _buildAnnouncementCard('Kunjungan Industri Kelas XII', '10 Okt 2026', 'Bagi siswa kelas XII, persiapan kunjungan industri ke PT. Telkom Bandung. Kumpul di lapangan utama jam 06:00 WIB.', Icons.directions_bus_rounded, const Color(0xFFD97706)),
          _buildAnnouncementCard('Libur Nasional & Cuti Bersama', '05 Okt 2026', 'Pemberitahuan libur nasional memperingati hari besar agama. Sekolah akan kembali aktif pada hari Rabu.', Icons.event_available_rounded, const Color(0xFF059669)),
        ],
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
