import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Membuat status bar transparan menyatu dengan layar
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), // Slate 50 - Sangat bersih
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'SatuSekolah',
          style: TextStyle(
            color: Color(0xFF0F172A), // Slate 900
            fontWeight: FontWeight.w800,
            fontSize: 24,
            letterSpacing: -0.5,
          ),
        ),
        actions: [
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined, color: Color(0xFF334155), size: 26),
                onPressed: () {},
              ),
              Positioned(
                right: 12,
                top: 12,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEF4444), // Red 500
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFF8FAFC), width: 1.5),
                  ),
                ),
              )
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. KARTU SAMBUTAN MINIMALIS
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE2E8F0)), // Border halus
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02), // Bayangan super tipis
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: Row(
                children: [
                  // Foto Profil
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFFF1F5F9), width: 2),
                      image: const DecorationImage(
                        image: NetworkImage('https://ui-avatars.com/api/?name=Siswa+Bintang&background=055D97&color=fff&bold=true'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Teks Sambutan
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Selamat Pagi,',
                          style: TextStyle(color: Color(0xFF64748B), fontSize: 13, fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'Siswa Bintang',
                          style: TextStyle(
                            color: Color(0xFF0F172A),
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 10),
                        // Badge Status Minimalis
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9), // Slate 100
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.check_circle, color: Color(0xFF10B981), size: 12),
                              SizedBox(width: 4),
                              Text(
                                'Kehadiran: 100%',
                                style: TextStyle(color: Color(0xFF334155), fontSize: 11, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            
            const Text(
              'Akses Cepat',
              style: TextStyle(
                fontSize: 18, 
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F172A),
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 16),
            
            // 2. GRID MENU MINIMALIS (Tanpa Glow)
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 3,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 0.85, 
              children: [
                _buildMinimalMenuCard(Icons.menu_book_rounded, 'LMS\n& Tugas', const Color(0xFF2563EB), const Color(0xFFEFF6FF)),
                _buildMinimalMenuCard(Icons.monitor_heart_rounded, 'Kesehatan', const Color(0xFFDC2626), const Color(0xFFFEF2F2)),
                _buildMinimalMenuCard(Icons.fact_check_rounded, 'Presensi', const Color(0xFF059669), const Color(0xFFECFDF5)),
                _buildMinimalMenuCard(Icons.local_library_rounded, 'E-Perpus', const Color(0xFFD97706), const Color(0xFFFFFBEB)),
                _buildMinimalMenuCard(Icons.warning_rounded, 'Poin\nPelanggaran', const Color(0xFFE11D48), const Color(0xFFFFF1F2)),
                _buildMinimalMenuCard(Icons.calendar_month_rounded, 'Jadwal\nPelajaran', const Color(0xFF7C3AED), const Color(0xFFF5F3FF)),
                _buildMinimalMenuCard(Icons.assignment_ind_rounded, 'Rapor\nDigital', const Color(0xFF0D9488), const Color(0xFFF0FDFA)),
                _buildMinimalMenuCard(Icons.work_rounded, 'Karir\n& PKL', const Color(0xFFB45309), const Color(0xFFFEF3C7)),
                _buildMinimalMenuCard(Icons.rate_review_rounded, 'Kinerja\nGuru', const Color(0xFF4F46E5), const Color(0xFFEEF2FF)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Desain Kartu Menu Minimalis: Bersih, Rata, Tanpa Glow
  Widget _buildMinimalMenuCard(IconData icon, String label, Color primaryColor, Color lightBackgroundColor) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16), // Rounded sedikit lebih formal
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1), // Border tipis Slate 200
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02), // Bayangan nyaris tidak terlihat
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          splashColor: primaryColor.withOpacity(0.1),
          highlightColor: primaryColor.withOpacity(0.05),
          onTap: () {},
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon dengan background warna yang sangat pastel/halus
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: lightBackgroundColor,
                  shape: BoxShape.circle, // Bentuk lingkaran klasik & minimalis
                ),
                child: Icon(icon, color: primaryColor, size: 28),
              ),
              const SizedBox(height: 10),
              // Teks Label
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12, 
                    fontWeight: FontWeight.w600, // Semi-bold agar tidak terlalu berat
                    color: Color(0xFF475569), // Slate-600
                    height: 1.2,
                    letterSpacing: -0.2,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
