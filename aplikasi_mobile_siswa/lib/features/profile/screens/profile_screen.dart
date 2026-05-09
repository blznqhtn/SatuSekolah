import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:aplikasi_mobile_siswa/features/auth/screens/login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), // Slate 50
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Profil Saya',
          style: TextStyle(
            color: Color(0xFF0F172A), // Slate 900
            fontWeight: FontWeight.w700,
            fontSize: 18,
            letterSpacing: -0.5,
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 120),
        child: Column(
          children: [
            // 1. HEADER PROFIL (Avatar, Nama, Kelas)
            Column(
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 4),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                    image: const DecorationImage(
                      image: NetworkImage('https://ui-avatars.com/api/?name=Siswa+Bintang&background=055D97&color=fff&size=200&bold=true'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Siswa Bintang',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'NISN: 0041234567 • XII RPL 1',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF64748B), // Slate 500
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // 2. RINGKASAN STATUS (Card Horizontal)
            Row(
              children: [
                Expanded(
                  child: _buildStatusCard(
                    title: 'Kehadiran',
                    value: '100%',
                    icon: Icons.check_circle_outline,
                    color: const Color(0xFF10B981), // Emerald 500
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatusCard(
                    title: 'Poin Pelanggaran',
                    value: '0 Poin',
                    icon: Icons.shield_outlined,
                    color: const Color(0xFF055D97), // Blue Base
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // 3. MENU PENGATURAN AKUN
            _buildMenuSectionTitle('Akun & Keamanan'),
            const SizedBox(height: 10),
            _buildMenuGroup([
              _buildMenuItem(Icons.person_outline, 'Edit Profil', onTap: () {}),
              _buildDivider(),
              _buildMenuItem(Icons.lock_outline, 'Ganti Kata Sandi', onTap: () {}),
            ]),
            const SizedBox(height: 24),

            // 4. MENU INFORMASI & AKADEMIK
            _buildMenuSectionTitle('Informasi Sekolah'),
            const SizedBox(height: 10),
            _buildMenuGroup([
              _buildMenuItem(Icons.rule_outlined, 'Tata Tertib & Poin', onTap: () {}),
              _buildDivider(),
              _buildMenuItem(Icons.support_agent_outlined, 'Kontak Hubin / BK', onTap: () {}),
              _buildDivider(),
              _buildMenuItem(Icons.help_outline, 'Bantuan & FAQ', onTap: () {}),
            ]),
            const SizedBox(height: 32),

            // 5. TOMBOL KELUAR (LOGOUT)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  // Kembali ke halaman Login
                  Get.offAll(() => const LoginScreen());
                },
                icon: const Icon(Icons.logout, size: 20),
                label: const Text('Keluar Aplikasi', style: TextStyle(fontWeight: FontWeight.w600)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFEF2F2), // Red 50
                  foregroundColor: const Color(0xFFEF4444), // Red 500
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: const BorderSide(color: Color(0xFFFEE2E2), width: 1.5),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Komponen Card Kecil untuk Status
  Widget _buildStatusCard({required String title, required String value, required IconData icon, required Color color}) {
    return Container(
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
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A), letterSpacing: -0.5),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF64748B)),
          ),
        ],
      ),
    );
  }

  // Teks Judul Kategori Menu
  Widget _buildMenuSectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Color(0xFF475569), // Slate 600
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  // Bungkus Grup Menu agar mirip gaya iOS/Shadcn Settings
  Widget _buildMenuGroup(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.01),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: children,
      ),
    );
  }

  // Item Menu Individual
  Widget _buildMenuItem(IconData icon, String title, {required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16), // Mencegah splash kotak di sudut
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9), // Slate 100
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: const Color(0xFF334155), size: 20), // Slate 700
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1E293B), // Slate 800
                ),
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Color(0xFFCBD5E1), size: 16), // Slate 300
          ],
        ),
      ),
    );
  }

  // Garis Pembatas Halus antar menu
  Widget _buildDivider() {
    return const Divider(
      height: 1,
      thickness: 1,
      indent: 56, // Mulai dari setelah icon
      endIndent: 16,
      color: Color(0xFFF1F5F9), // Slate 100
    );
  }
}
