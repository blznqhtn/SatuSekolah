// =============================================================================
// profile_screen.dart — Profil & Pengaturan Siswa
// =============================================================================
// Fitur utama:
//   • Header profil: avatar, nama, NISN & kelas
//   • Card ringkasan: kehadiran & poin pelanggaran
//   • Menu Akun: Edit Profil → EditProfileScreen
//                Ganti Kata Sandi → ChangePasswordScreen
//   • Menu Informasi: Tata Tertib → SchoolRulesScreen
//                     Kontak → ContactScreen
//                     FAQ → FaqScreen (ExpansionTile)
//   • Tombol Logout → kembali ke LoginScreen
//
// Semua sub-screen didefinisikan di file yang sama (single file approach)
// State: StatelessWidget (ProfileScreen), StatefulWidget (ChangePasswordScreen)
// =============================================================================

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:aplikasi_mobile_siswa/features/auth/screens/login_screen.dart';

// Sub-screens untuk profil
class EditProfileScreen extends StatelessWidget {
  const EditProfileScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: Color(0xFF0F172A)), onPressed: () => Get.back()),
        title: const Text('Edit Profil', style: TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.bold, fontSize: 18)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                CircleAvatar(radius: 55, backgroundImage: const NetworkImage('https://ui-avatars.com/api/?name=Siswa+Bintang&background=055D97&color=fff&size=200&bold=true')),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(color: Color(0xFF055D97), shape: BoxShape.circle),
                  child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 16),
                ),
              ],
            ),
            const SizedBox(height: 28),
            _buildField('Nama Lengkap', 'Siswa Bintang'),
            _buildField('NISN', '0041234567', enabled: false),
            _buildField('Email', 'siswa@sekolah.sch.id'),
            _buildField('No. HP', '0812-xxxx-xxxx'),
            _buildField('Alamat', 'Jl. Contoh No. 10, Bandung'),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () { Get.back(); Get.snackbar('Berhasil', 'Profil berhasil diperbarui', backgroundColor: Colors.white); },
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF055D97), padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), foregroundColor: Colors.white),
                child: const Text('Simpan Perubahan', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField(String label, String value, {bool enabled = true}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF475569), fontSize: 13)),
          const SizedBox(height: 6),
          TextField(
            enabled: enabled,
            controller: TextEditingController(text: value),
            decoration: InputDecoration(
              filled: true,
              fillColor: enabled ? const Color(0xFFF8FAFC) : const Color(0xFFF1F5F9),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
              disabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFF1F5F9))),
            ),
          ),
        ],
      ),
    );
  }
}

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({Key? key}) : super(key: key);
  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  bool _showOld = false, _showNew = false, _showConfirm = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: Color(0xFF0F172A)), onPressed: () => Get.back()),
        title: const Text('Ganti Kata Sandi', style: TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.bold, fontSize: 18)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: const Color(0xFFEFF6FF), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFBFDBFE))),
              child: const Row(children: [
                Icon(Icons.info_outline_rounded, color: Color(0xFF1D4ED8)),
                SizedBox(width: 12),
                Expanded(child: Text('Kata sandi minimal 8 karakter, kombinasi huruf besar, kecil, dan angka.', style: TextStyle(color: Color(0xFF1E3A8A), fontSize: 13, height: 1.4))),
              ]),
            ),
            const SizedBox(height: 24),
            _buildPasswordField('Kata Sandi Lama', _showOld, () => setState(() => _showOld = !_showOld)),
            _buildPasswordField('Kata Sandi Baru', _showNew, () => setState(() => _showNew = !_showNew)),
            _buildPasswordField('Konfirmasi Kata Sandi', _showConfirm, () => setState(() => _showConfirm = !_showConfirm)),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () { Get.back(); Get.snackbar('Berhasil', 'Kata sandi berhasil diubah', backgroundColor: Colors.white); },
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF055D97), padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), foregroundColor: Colors.white),
                child: const Text('Ubah Kata Sandi', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordField(String label, bool show, VoidCallback toggle) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF475569), fontSize: 13)),
          const SizedBox(height: 6),
          TextField(
            obscureText: !show,
            decoration: InputDecoration(
              filled: true, fillColor: const Color(0xFFF8FAFC),
              suffixIcon: IconButton(icon: Icon(show ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: const Color(0xFF94A3B8)), onPressed: toggle),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
            ),
          ),
        ],
      ),
    );
  }
}

class SchoolRulesScreen extends StatelessWidget {
  const SchoolRulesScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white, elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: Color(0xFF0F172A)), onPressed: () => Get.back()),
        title: const Text('Tata Tertib & Poin', style: TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.bold, fontSize: 18)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildRuleCard('Kehadiran', [
            'Hadir tepat waktu (sebelum 07.00 WIB) — Terlambat: -5 poin',
            'Absen tanpa keterangan: -15 poin per hari',
            'Meninggalkan sekolah tanpa izin: -20 poin',
          ], Icons.access_time_rounded, const Color(0xFF2563EB)),
          _buildRuleCard('Seragam & Penampilan', [
            'Wajib menggunakan seragam lengkap sesuai hari',
            'Rambut rapi, tidak diwarnai — Pelanggaran: -10 poin',
            'Tidak menggunakan aksesoris berlebihan',
          ], Icons.checkroom_rounded, const Color(0xFF059669)),
          _buildRuleCard('Perilaku', [
            'Dilarang membawa/menggunakan HP saat KBM — -25 poin',
            'Dilarang berkelahi — -50 poin + surat peringatan',
            'Menghormati guru dan seluruh warga sekolah',
          ], Icons.shield_rounded, const Color(0xFFDC2626)),
        ],
      ),
    );
  }

  Widget _buildRuleCard(String title, List<String> rules, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE2E8F0))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)), child: Icon(icon, color: color, size: 20)),
            const SizedBox(width: 12),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF0F172A))),
          ]),
          const SizedBox(height: 12),
          ...rules.map((r) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Padding(padding: const EdgeInsets.only(top: 5), child: Icon(Icons.circle, size: 6, color: color)),
              const SizedBox(width: 10),
              Expanded(child: Text(r, style: const TextStyle(color: Color(0xFF475569), height: 1.4, fontSize: 13))),
            ]),
          )),
        ],
      ),
    );
  }
}

class ContactScreen extends StatelessWidget {
  const ContactScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white, elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: Color(0xFF0F172A)), onPressed: () => Get.back()),
        title: const Text('Kontak Hubin / BK', style: TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.bold, fontSize: 18)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildContactCard('Hub. Industri (Hubin)', 'Bpk. Agus Setiawan, M.Pd.', 'Ruang Hubin, Gedung Utama Lt.1', '0812-1234-5678', Icons.factory_rounded, const Color(0xFF055D97)),
          _buildContactCard('Bimbingan Konseling (BK)', 'Ibu Dewi Rahayu, S.Pd.', 'Ruang BK, Gedung Samping', '0813-9876-5432', Icons.support_agent_rounded, const Color(0xFF7C3AED)),
          _buildContactCard('Tata Usaha (TU)', 'Staff Administrasi', 'Ruang TU, Gedung Utama', '(022) 123-4567', Icons.admin_panel_settings_rounded, const Color(0xFF059669)),
        ],
      ),
    );
  }

  Widget _buildContactCard(String dept, String name, String room, String phone, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE2E8F0))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: color, size: 22)),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(dept, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF0F172A))),
              Text(name, style: const TextStyle(color: Color(0xFF64748B), fontSize: 13)),
            ])),
          ]),
          const SizedBox(height: 12),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          const SizedBox(height: 12),
          Row(children: [const Icon(Icons.location_on_outlined, size: 16, color: Color(0xFF94A3B8)), const SizedBox(width: 8), Expanded(child: Text(room, style: const TextStyle(color: Color(0xFF475569), fontSize: 13)))]),
          const SizedBox(height: 6),
          Row(children: [const Icon(Icons.phone_outlined, size: 16, color: Color(0xFF94A3B8)), const SizedBox(width: 8), Text(phone, style: const TextStyle(color: Color(0xFF475569), fontSize: 13, fontWeight: FontWeight.w600))]),
        ],
      ),
    );
  }
}

class FaqScreen extends StatelessWidget {
  const FaqScreen({Key? key}) : super(key: key);

  static const _faqs = [
    {'q': 'Bagaimana cara mengajukan izin tidak hadir?', 'a': 'Buka menu Akademik → Perizinan Siswa → Buat Pengajuan Baru. Isi form dan lampirkan surat keterangan jika ada.'},
    {'q': 'Cara mendaftar ekstrakurikuler?', 'a': 'Buka menu Akademik → Ekstra Kurikuler → pilih ekskul yang diinginkan → klik Daftar dan isi form.'},
    {'q': 'Kapan jadwal konsultasi BK?', 'a': 'Konsultasi BK tersedia setiap hari Selasa & Kamis pukul 09.00–11.00. Daftarkan diri melalui menu Konseling BK.'},
    {'q': 'Bagaimana cara melihat rapor digital?', 'a': 'Buka menu Beranda → Rapor Digital. Pilih semester yang ingin dilihat.'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white, elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: Color(0xFF0F172A)), onPressed: () => Get.back()),
        title: const Text('Bantuan & FAQ', style: TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.bold, fontSize: 18)),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: _faqs.length,
        itemBuilder: (context, index) {
          final faq = _faqs[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE2E8F0))),
            child: ExpansionTile(
              tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              title: Text(faq['q']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF0F172A))),
              iconColor: const Color(0xFF055D97),
              collapsedIconColor: const Color(0xFF94A3B8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              collapsedShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              children: [Text(faq['a']!, style: const TextStyle(color: Color(0xFF475569), height: 1.5, fontSize: 13))],
            ),
          );
        },
      ),
    );
  }
}

// =====================
// PROFILE SCREEN UTAMA
// =====================
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text('Profil Saya', style: TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.w700, fontSize: 18, letterSpacing: -0.5)),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 120),
        child: Column(
          children: [
            Column(
              children: [
                Container(
                  width: 100, height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 4),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))],
                    image: const DecorationImage(image: NetworkImage('https://ui-avatars.com/api/?name=Siswa+Bintang&background=055D97&color=fff&size=200&bold=true'), fit: BoxFit.cover),
                  ),
                ),
                const SizedBox(height: 16),
                const Text('Siswa Bintang', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF0F172A), letterSpacing: -0.5)),
                const SizedBox(height: 4),
                const Text('NISN: 0041234567 • XII RPL 1', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF64748B))),
              ],
            ),
            const SizedBox(height: 24),
            Row(children: [
              Expanded(child: _buildStatusCard(title: 'Kehadiran', value: '100%', icon: Icons.check_circle_outline, color: const Color(0xFF10B981))),
              const SizedBox(width: 16),
              Expanded(child: _buildStatusCard(title: 'Poin Pelanggaran', value: '0 Poin', icon: Icons.shield_outlined, color: const Color(0xFF055D97))),
            ]),
            const SizedBox(height: 32),

            _buildMenuSectionTitle('Akun & Keamanan'),
            const SizedBox(height: 10),
            _buildMenuGroup([
              _buildMenuItem(Icons.person_outline, 'Edit Profil', onTap: () => Get.to(() => const EditProfileScreen())),
              _buildDivider(),
              _buildMenuItem(Icons.lock_outline, 'Ganti Kata Sandi', onTap: () => Get.to(() => const ChangePasswordScreen())),
            ]),
            const SizedBox(height: 24),

            _buildMenuSectionTitle('Informasi Sekolah'),
            const SizedBox(height: 10),
            _buildMenuGroup([
              _buildMenuItem(Icons.rule_outlined, 'Tata Tertib & Poin', onTap: () => Get.to(() => const SchoolRulesScreen())),
              _buildDivider(),
              _buildMenuItem(Icons.support_agent_outlined, 'Kontak Hubin / BK', onTap: () => Get.to(() => const ContactScreen())),
              _buildDivider(),
              _buildMenuItem(Icons.help_outline, 'Bantuan & FAQ', onTap: () => Get.to(() => const FaqScreen())),
            ]),
            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => Get.offAll(() => LoginScreen()),
                icon: const Icon(Icons.logout, size: 20),
                label: const Text('Keluar Aplikasi', style: TextStyle(fontWeight: FontWeight.w600)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFEF2F2),
                  foregroundColor: const Color(0xFFEF4444),
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: const BorderSide(color: Color(0xFFFEE2E2), width: 1.5)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard({required String title, required String value, required IconData icon, required Color color}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8, offset: const Offset(0, 2))]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 12),
        Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A), letterSpacing: -0.5)),
        const SizedBox(height: 2),
        Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF64748B))),
      ]),
    );
  }

  Widget _buildMenuSectionTitle(String title) {
    return Align(alignment: Alignment.centerLeft, child: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF475569), letterSpacing: 0.5)));
  }

  Widget _buildMenuGroup(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.01), blurRadius: 10, offset: const Offset(0, 4))]),
      child: Column(children: children),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, {required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(children: [
          Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(10)), child: Icon(icon, color: const Color(0xFF334155), size: 20)),
          const SizedBox(width: 16),
          Expanded(child: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF1E293B)))),
          const Icon(Icons.arrow_forward_ios, color: Color(0xFFCBD5E1), size: 16),
        ]),
      ),
    );
  }

  Widget _buildDivider() => const Divider(height: 1, thickness: 1, indent: 56, endIndent: 16, color: Color(0xFFF1F5F9));
}
