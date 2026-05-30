import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:aplikasi_mobile_siswa/features/auth/screens/login_screen.dart';
import 'package:aplikasi_mobile_siswa/features/auth/controllers/auth_controller.dart';
import 'package:aplikasi_mobile_siswa/shared/widgets/premium_header.dart';

// =====================
// KONSTANTA DESAIN
// =====================
const Color kPrimaryBlue = Color(0xFF055D97);
const Color kBgColor = Color(0xFFF8FAFC);
const Color kCardBg = Colors.white;
const Color kTextDark = Color(0xFF0F172A);
const Color kTextMuted = Color(0xFF64748B);
const Color kDanger = Color(0xFFEF4444);

// =====================
// EDIT PROFIL SCREEN
// =====================
class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({Key? key}) : super(key: key);
  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final AuthController auth = Get.find<AuthController>();
  late TextEditingController noHpController;
  late TextEditingController alamatController;

  @override
  void initState() {
    super.initState();
    final user = auth.userData.value;
    noHpController = TextEditingController(text: user['no_hp']?.toString() ?? '');
    alamatController = TextEditingController(text: user['alamat']?.toString() ?? '');
  }

  @override
  void dispose() {
    noHpController.dispose();
    alamatController.dispose();
    super.dispose();
  }

  void _saveProfile() async {
    bool success = await auth.updateProfile(noHpController.text, alamatController.text);
    if (success) {
      Get.back();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBgColor,
      appBar: AppBar(
        backgroundColor: kPrimaryBlue,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white), onPressed: () => Get.back()),
        title: Text('Edit Profil', style: GoogleFonts.nunito(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 18)),
        centerTitle: true,
      ),
      body: Obx(() {
        final user = auth.userData.value;
        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              _buildStaticField(Icons.person, 'Nama Lengkap', user['nama']?.toString() ?? '-'),
              _buildStaticField(Icons.assignment_ind, 'NIS', user['nis']?.toString() ?? '-'),
              _buildStaticField(Icons.badge, 'NISN', user['identifier']?.toString() ?? '-'),
              _buildStaticField(Icons.email, 'Email', user['email']?.toString() ?? '-'),
              _buildStaticField(Icons.school, 'Kelas', user['kelas']?.toString() ?? '-'),
              _buildStaticField(Icons.book, 'Jurusan', user['jurusan']?.toString() ?? '-'),
              
              const SizedBox(height: 10),
              _buildInputField(Icons.phone, 'No. HP', noHpController, 'Masukkan nomor HP aktif', TextInputType.phone),
              _buildInputField(Icons.home, 'Alamat Lengkap', alamatController, 'Masukkan alamat domisili', TextInputType.streetAddress, maxLines: 3),
              
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: auth.isLoading.value ? null : _saveProfile,
                  style: ElevatedButton.styleFrom(backgroundColor: kPrimaryBlue, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                  child: auth.isLoading.value 
                      ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
                      : Text('Simpan Perubahan', style: GoogleFonts.nunito(fontWeight: FontWeight.w800, fontSize: 14)),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildStaticField(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: GoogleFonts.nunito(fontWeight: FontWeight.w700, color: kTextMuted, fontSize: 12)),
        const SizedBox(height: 6),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
          child: Row(
            children: [
              Icon(icon, color: const Color(0xFF94A3B8), size: 20),
              const SizedBox(width: 12),
              Expanded(child: Text(value, style: GoogleFonts.nunito(fontWeight: FontWeight.w700, fontSize: 14, color: kTextDark))),
            ],
          ),
        ),
      ]),
    );
  }

  Widget _buildInputField(IconData icon, String label, TextEditingController controller, String hint, TextInputType type, {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: GoogleFonts.nunito(fontWeight: FontWeight.w700, color: kTextDark, fontSize: 13)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: type,
          maxLines: maxLines,
          style: GoogleFonts.nunito(fontWeight: FontWeight.w600, color: kTextDark),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.nunito(color: const Color(0xFF94A3B8), fontWeight: FontWeight.w500),
            prefixIcon: maxLines == 1 ? Icon(icon, color: kPrimaryBlue, size: 20) : null,
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: kPrimaryBlue, width: 2)),
          ),
        ),
      ]),
    );
  }
}

// =====================
// GANTI PASSWORD SCREEN
// =====================
class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({Key? key}) : super(key: key);
  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final AuthController auth = Get.find<AuthController>();
  final TextEditingController oldPassCtrl = TextEditingController();
  final TextEditingController newPassCtrl = TextEditingController();
  final TextEditingController confirmPassCtrl = TextEditingController();
  final TextEditingController tokenCtrl = TextEditingController();
  
  bool _showOld = false, _showNew = false, _showConfirm = false;

  void _requestToken() {
    auth.requestPasswordToken();
  }

  void _submitChange() async {
    if (newPassCtrl.text != confirmPassCtrl.text) {
      Get.snackbar("Kesalahan", "Konfirmasi sandi baru tidak cocok", backgroundColor: Colors.red.shade100);
      return;
    }
    bool success = await auth.changePassword(oldPassCtrl.text, newPassCtrl.text, tokenCtrl.text);
    if (success) {
      Get.back();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBgColor,
      appBar: AppBar(
        backgroundColor: kPrimaryBlue,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white), onPressed: () => Get.back()),
        title: Text('Ganti Kata Sandi', style: GoogleFonts.nunito(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 18)),
        centerTitle: true,
      ),
      body: Obx(() => SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: const Color(0xFFEFF6FF), borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFFDBEAFE))),
            child: Row(children: [
              const Icon(Icons.security, color: kPrimaryBlue),
              const SizedBox(width: 12),
              Expanded(child: Text('Gunakan kata sandi yang kuat dengan minimal 8 karakter. Token verifikasi (OTP) diperlukan.', style: GoogleFonts.nunito(color: kPrimaryBlue, fontSize: 13, fontWeight: FontWeight.w600, height: 1.4))),
            ]),
          ),
          const SizedBox(height: 24),
          _buildPasswordField('Kata Sandi Lama', oldPassCtrl, _showOld, () => setState(() => _showOld = !_showOld)),
          _buildPasswordField('Kata Sandi Baru', newPassCtrl, _showNew, () => setState(() => _showNew = !_showNew)),
          _buildPasswordField('Konfirmasi Kata Sandi Baru', confirmPassCtrl, _showConfirm, () => setState(() => _showConfirm = !_showConfirm)),
          
          const Divider(height: 32, thickness: 1, color: Color(0xFFE2E8F0)),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Kode Verifikasi (OTP)', style: GoogleFonts.nunito(fontWeight: FontWeight.w700, color: kTextDark, fontSize: 13)),
              TextButton(
                onPressed: auth.isLoading.value ? null : _requestToken,
                style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: const Size(0, 0), tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                child: Text('Kirim Kode OTP', style: GoogleFonts.nunito(color: kPrimaryBlue, fontWeight: FontWeight.w800, fontSize: 13)),
              )
            ],
          ),
          const SizedBox(height: 6),
          TextField(
            controller: tokenCtrl,
            keyboardType: TextInputType.number,
            style: GoogleFonts.nunito(fontWeight: FontWeight.w800, letterSpacing: 4, color: kTextDark, fontSize: 16),
            textAlign: TextAlign.center,
            decoration: InputDecoration(
              hintText: '• • • • • •',
              hintStyle: GoogleFonts.nunito(letterSpacing: 4),
              filled: true, fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: kPrimaryBlue, width: 2)),
            ),
          ),
          
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: auth.isLoading.value ? null : _submitChange,
              style: ElevatedButton.styleFrom(backgroundColor: kPrimaryBlue, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
              child: auth.isLoading.value
                  ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
                  : Text('Ubah Kata Sandi', style: GoogleFonts.nunito(fontWeight: FontWeight.w800, fontSize: 16)),
            ),
          ),
        ]),
      )),
    );
  }

  Widget _buildPasswordField(String label, TextEditingController controller, bool show, VoidCallback toggle) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: GoogleFonts.nunito(fontWeight: FontWeight.w700, color: kTextDark, fontSize: 13)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          obscureText: !show,
          style: GoogleFonts.nunito(fontWeight: FontWeight.w600, color: kTextDark),
          decoration: InputDecoration(
            filled: true, fillColor: Colors.white,
            prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF94A3B8), size: 20),
            suffixIcon: IconButton(icon: Icon(show ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: const Color(0xFF94A3B8), size: 20), onPressed: toggle),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: kPrimaryBlue, width: 2)),
          ),
        ),
      ]),
    );
  }
}

// =====================
// PROFIL SCREEN UTAMA
// =====================
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  Future<void> _pickPhoto(BuildContext context) async {
    final AuthController auth = Get.find<AuthController>();
    
    // Tampilkan bottom sheet untuk pilih sumber
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Ubah Foto Profil', style: GoogleFonts.nunito(fontSize: 18, fontWeight: FontWeight.w800, color: kTextDark)),
              const SizedBox(height: 16),
              ListTile(
                leading: const CircleAvatar(backgroundColor: Color(0xFFEFF6FF), child: Icon(Icons.camera_alt, color: kPrimaryBlue)),
                title: Text('Ambil dari Kamera', style: GoogleFonts.nunito(fontWeight: FontWeight.w700)),
                onTap: () async {
                  Navigator.pop(ctx);
                  final picker = ImagePicker();
                  final XFile? image = await picker.pickImage(source: ImageSource.camera, imageQuality: 70);
                  if (image != null) {
                    final croppedFile = await ImageCropper().cropImage(
                      sourcePath: image.path,
                      aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
                      uiSettings: [
                        AndroidUiSettings(
                            toolbarTitle: 'Sesuaikan Foto',
                            toolbarColor: kPrimaryBlue,
                            toolbarWidgetColor: Colors.white,
                            initAspectRatio: CropAspectRatioPreset.square,
                            lockAspectRatio: true),
                        IOSUiSettings(
                          title: 'Sesuaikan Foto',
                        ),
                      ],
                    );
                    if (croppedFile != null) {
                      auth.uploadProfilePhoto(croppedFile.path);
                    }
                  }
                },
              ),
              ListTile(
                leading: const CircleAvatar(backgroundColor: Color(0xFFEFF6FF), child: Icon(Icons.photo_library, color: kPrimaryBlue)),
                title: Text('Pilih dari Galeri', style: GoogleFonts.nunito(fontWeight: FontWeight.w700)),
                onTap: () async {
                  Navigator.pop(ctx);
                  final picker = ImagePicker();
                  final XFile? image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
                  if (image != null) {
                    final croppedFile = await ImageCropper().cropImage(
                      sourcePath: image.path,
                      aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
                      uiSettings: [
                        AndroidUiSettings(
                            toolbarTitle: 'Sesuaikan Foto',
                            toolbarColor: kPrimaryBlue,
                            toolbarWidgetColor: Colors.white,
                            initAspectRatio: CropAspectRatioPreset.square,
                            lockAspectRatio: true),
                        IOSUiSettings(
                          title: 'Sesuaikan Foto',
                        ),
                      ],
                    );
                    if (croppedFile != null) {
                      auth.uploadProfilePhoto(croppedFile.path);
                    }
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showContactDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('📞 Kontak Kami', style: GoogleFonts.nunito(fontWeight: FontWeight.w800, color: kPrimaryBlue)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _contactItem(Icons.handshake, 'Hubin', '0812-3456-7890'),
            const Divider(),
            _contactItem(Icons.psychology, 'Bimbingan Konseling (BK)', '0821-1234-5678'),
            const Divider(),
            _contactItem(Icons.support_agent, 'Tata Usaha (TU)', '021-888-999'),
            const Divider(),
            _contactItem(Icons.account_balance_wallet, 'Keuangan', '0855-5555-5555'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Tutup', style: GoogleFonts.nunito(fontWeight: FontWeight.w800, color: kPrimaryBlue)),
          )
        ],
      ),
    );
  }

  Widget _contactItem(IconData icon, String title, String subtitle) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: const Color(0xFFEFF6FF), borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, color: kPrimaryBlue, size: 24),
      ),
      title: Text(title, style: GoogleFonts.nunito(fontWeight: FontWeight.w700, fontSize: 14, color: kTextDark)),
      subtitle: Text(subtitle, style: GoogleFonts.nunito(fontWeight: FontWeight.w600, fontSize: 13, color: kTextMuted)),
    );
  }

  void _showFAQDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('❓ Bantuan & FAQ', style: GoogleFonts.nunito(fontWeight: FontWeight.w800, color: kPrimaryBlue)),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView(
            shrinkWrap: true,
            children: [
              _faqItem('Lupa Password / Akun terkunci?', 'Gunakan fitur Ganti Kata Sandi jika masih bisa login. Jika tidak, hubungi Tata Usaha untuk reset sandi.'),
              _faqItem('Mengapa poin pelanggaran bertambah?', 'Poin bertambah otomatis jika presensi terlambat atau ada catatan pelanggaran dari Guru BK. Hubungi BK untuk konfirmasi.'),
              _faqItem('Data biodata salah?', 'Data seperti Nama dan Kelas dikunci. Silakan lapor ke Tata Usaha untuk dilakukan perbaikan di sistem inti.'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Tutup', style: GoogleFonts.nunito(fontWeight: FontWeight.w800, color: kPrimaryBlue)),
          )
        ],
      ),
    );
  }

  Widget _faqItem(String q, String a) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(q, style: GoogleFonts.nunito(fontWeight: FontWeight.w800, fontSize: 14, color: kTextDark)),
          const SizedBox(height: 4),
          Text(a, style: GoogleFonts.nunito(fontWeight: FontWeight.w600, fontSize: 13, color: kTextMuted, height: 1.4)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final AuthController auth = Get.find<AuthController>();

    return Scaffold(
      backgroundColor: kBgColor,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ─── HEADER PREMIUM ──────────────────────────────────
          PremiumHeader(
            title: 'Profil Saya',
            expandedHeight: 260,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: Obx(() {
                      final user = auth.userData.value;
                      final nama = user['nama']?.toString() ?? 'Pengguna';
                      final role = user['role']?.toString().capitalizeFirst ?? 'Siswa';
                      final kelas = user['kelas']?.toString() ?? '';
                      final jurusan = user['jurusan']?.toString() ?? '';
                      final foto = user['foto']?.toString() ?? '';
                      final info = [kelas, jurusan].where((s) => s.isNotEmpty).join(' • ');

                      return Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          // Avatar + Tombol Kamera
                          Stack(
                            children: [
                              Container(
                                width: 90, height: 90,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white.withOpacity(0.3), width: 3),
                                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 15, offset: const Offset(0, 8))],
                                  image: DecorationImage(
                                    image: foto.isNotEmpty
                                        ? NetworkImage(foto) as ImageProvider
                                        : NetworkImage('https://ui-avatars.com/api/?name=${Uri.encodeComponent(nama)}&background=E2E8F0&color=0F172A&bold=true&size=200'),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: 0, right: 0,
                                child: GestureDetector(
                                  onTap: () => _pickPhoto(context),
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.white, 
                                      shape: BoxShape.circle,
                                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 8, offset: const Offset(0, 4))],
                                    ),
                                    child: const Icon(Icons.camera_alt_rounded, color: kPrimaryBlue, size: 20),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Text(nama, style: GoogleFonts.nunito(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800, letterSpacing: -0.5)),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.white.withOpacity(0.2)),
                            ),
                            child: Text(
                              info.isNotEmpty ? '$role • $info' : role,
                              style: GoogleFonts.nunito(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700),
                            ),
                          ),
                        ],
                      );
                    }),
                  ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
              child: Column(
                children: [

                  // STATS CARD (Pelanggaran diubah ke kDanger/Merah)
                  Row(
                    children: [
                      Expanded(child: _buildStatCard('100%', 'Kehadiran', Icons.check_circle_rounded, const Color(0xFF10B981), const Color(0xFFD1FAE5))),
                      const SizedBox(width: 12),
                      Expanded(child: _buildStatCard('0 Poin', 'Pelanggaran', Icons.warning_rounded, kDanger, const Color(0xFFFEE2E2))),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // AKUN & KEAMANAN
                  _sectionTitle('Akun & Keamanan'),
                  const SizedBox(height: 12),
                  _buildMenuGroup([
                    _buildMenuItem(Icons.person_outline, 'Edit Profil', kPrimaryBlue, onTap: () => Get.to(() => const EditProfileScreen())),
                    _buildDivider(),
                    _buildMenuItem(Icons.lock_outline, 'Ganti Kata Sandi', kDanger, onTap: () => Get.to(() => const ChangePasswordScreen())),
                  ]),
                  const SizedBox(height: 20),

                  // INFO SEKOLAH
                  _sectionTitle('Informasi Sekolah'),
                  const SizedBox(height: 12),
                  _buildMenuGroup([
                    _buildMenuItem(Icons.rule_outlined, 'Tata Tertib & Poin', kPrimaryBlue, onTap: () {}),
                    _buildDivider(),
                    _buildMenuItem(Icons.headset_mic_outlined, 'Kontak Kami', kPrimaryBlue, onTap: () => _showContactDialog(context)),
                    _buildDivider(),
                    _buildMenuItem(Icons.help_outline, 'Bantuan & FAQ', const Color(0xFFF59E0B), onTap: () => _showFAQDialog(context)),
                  ]),
                  const SizedBox(height: 24),

                  // LOGOUT
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        await auth.logout();
                        Get.offAll(() => LoginScreen());
                      },
                      icon: const Icon(Icons.logout_rounded, size: 20),
                      label: Text('Keluar Aplikasi', style: GoogleFonts.nunito(fontWeight: FontWeight.w800, fontSize: 14)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kCardBg,
                        foregroundColor: kDanger,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: const BorderSide(color: Color(0xFFFECACA), width: 1.5),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String value, String label, IconData icon, Color color, Color bg) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(16), border: Border.all(color: color.withOpacity(0.3))),
      child: Row(children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(width: 12),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(value, style: GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.w800, color: color)),
          Text(label, style: GoogleFonts.nunito(fontSize: 12, fontWeight: FontWeight.w700, color: color.withOpacity(0.8))),
        ]),
      ]),
    );
  }

  Widget _sectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(title, style: GoogleFonts.nunito(fontSize: 14, fontWeight: FontWeight.w800, color: kTextMuted, letterSpacing: 0.5)),
    );
  }

  Widget _buildMenuGroup(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: kCardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8, offset: const Offset(0, 4))],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, Color color, {required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(child: Text(title, style: GoogleFonts.nunito(fontSize: 14, fontWeight: FontWeight.w700, color: kTextDark))),
          Icon(Icons.arrow_forward_ios_rounded, color: const Color(0xFFCBD5E1), size: 16),
        ]),
      ),
    );
  }

  Widget _buildDivider() => const Divider(height: 1, thickness: 1, indent: 64, endIndent: 16, color: Color(0xFFF1F5F9));
}
