import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import '../theme/app_theme.dart';
import '../main_screen.dart';
import '../services/api_service.dart';
import '../auth/login_screen.dart';

class PageProfil extends StatefulWidget {
  const PageProfil({super.key});

  @override
  State<PageProfil> createState() => _PageProfilState();
}

class _PageProfilState extends State<PageProfil> {
  String _parentName = 'Kartini Rahayu';
  String _email = 'ortu@sekolah.id';
  String _phone = '081234567890';
  List<Map<String, dynamic>> _children = [];

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final box = GetStorage();
    final name = box.read('namaOrtu') ?? 'Kartini Rahayu';
    final email = box.read('email') ?? 'ortu@sekolah.id';
    final phone = box.read('phone') ?? '081234567890';

    final children = await ApiService.getChildren();

    if (mounted) {
      setState(() {
        _parentName = name;
        _email = email;
        _phone = phone;
        _children = children;
      });
    }
  }

  void _showDataDiriDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Data Diri Orang Tua',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDialogRow('Nama Lengkap', _parentName),
            const Divider(height: 16),
            _buildDialogRow('Email', _email),
            const Divider(height: 16),
            _buildDialogRow('Nomor WhatsApp', _phone),
            const Divider(height: 16),
            _buildDialogRow('Peran', 'Orang Tua / Wali Murid'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup', style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  void _showDataAnakDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Data Anak Terdaftar',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: _children.map((child) {
            final name = child['name'] ?? 'Siswa';
            final nisn = child['nisn'] ?? '-';
            final kelas = child['class_name'] ?? 'Kelas XII';
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.bg2,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      color: AppTheme.accentBg,
                      shape: BoxShape.circle,
                    ),
                    child: const Text('🎓', style: TextStyle(fontSize: 18)),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(name,
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800)),
                        Text('NISN: $nisn · $kelas',
                            style: const TextStyle(fontSize: 11, color: AppTheme.text3)),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup', style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  Widget _buildDialogRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: AppTheme.text3)),
        const SizedBox(height: 2),
        Text(value,
            style: const TextStyle(
                fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.text)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final initials = _parentName.isNotEmpty
        ? (_parentName.trim().split(' ').map((w) => w.isNotEmpty ? w[0] : '').take(2).join())
        : 'KR';

    return Column(
      children: [
        _buildHeader(context),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHero(initials),
                const SizedBox(height: 16),
                _buildMenuList(context),
                const SizedBox(height: 16),
                const Padding(
                  padding: EdgeInsets.only(bottom: 16),
                  child: Text(
                    'Satu Sekolah v1.0.0 · Neura Cakrawira Solusi',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 10, color: AppTheme.text3),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 14),
      decoration: const BoxDecoration(
        color: AppTheme.surface,
        border: Border(bottom: BorderSide(color: AppTheme.border)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  final parent = context.findAncestorStateOfType<State<MainScreen>>() as dynamic;
                  if (parent != null) parent.goBack();
                },
                child: Container(
                  width: 34,
                  height: 34,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: AppTheme.bg2,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.arrow_back, size: 16, color: AppTheme.text),
                ),
              ),
              const SizedBox(width: 10),
              const Text('Profil Saya', style: AppTheme.headerTitle),
            ],
          ),
          GestureDetector(
            onTap: _showDataDiriDialog,
            child: const Text('Detail',
                style: TextStyle(
                    fontSize: 13, color: AppTheme.accent, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  Widget _buildHero(String initials) {
    final childrenCount = _children.isNotEmpty ? _children.length : 2;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.accentBg, AppTheme.bg],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          stops: [0.0, 0.6],
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [AppTheme.accent, Color(0xFFF5A073)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.accent.withOpacity(0.35),
                  blurRadius: 20,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Text(initials,
                style: const TextStyle(
                    color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900)),
          ),
          const SizedBox(height: 12),
          Text(_parentName,
              style: const TextStyle(
                  fontSize: 20, fontWeight: FontWeight.w900, color: AppTheme.text)),
          const SizedBox(height: 4),
          Text(_email,
              style: const TextStyle(
                  fontSize: 12, color: AppTheme.text3, fontFamily: 'DM Mono')),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.accentBg,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('●', style: TextStyle(fontSize: 6, color: AppTheme.accent)),
                const SizedBox(width: 4),
                Text('$childrenCount Anak Terdaftar',
                    style: const TextStyle(
                        fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.accent)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuList(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          _buildMenuItem(context, '👤', AppTheme.accentBg, 'Data Diri', onTap: _showDataDiriDialog),
          const SizedBox(height: 8),
          _buildMenuItem(context, '👨‍👩‍👦', AppTheme.blueBg, 'Data Anak', onTap: _showDataAnakDialog),
          const SizedBox(height: 8),
          _buildMenuItem(context, '💳', AppTheme.tealBg, 'Riwayat Pembayaran', onTap: () {
            final parent = context.findAncestorStateOfType<State<MainScreen>>() as dynamic;
            if (parent != null) parent.switchTab(2);
          }),
          const SizedBox(height: 8),
          _buildMenuItem(context, '🔔', AppTheme.yellowBg, 'Pengaturan Notifikasi'),
          const SizedBox(height: 8),
          _buildMenuItem(context, '🔑', AppTheme.purpleBg, 'Ganti Password'),
          const SizedBox(height: 8),
          _buildMenuItem(context, '❓', AppTheme.bg2, 'Bantuan & FAQ'),
          const SizedBox(height: 8),
          _buildMenuItem(context, '🚪', AppTheme.redBg, 'Keluar', isLogout: true, onTap: () {
            final box = GetStorage();
            box.remove('isLoggedIn');
            box.remove('namaOrtu');
            box.remove('token');
            box.remove('userId');
            Navigator.of(context, rootNavigator: true).pushReplacement(
              MaterialPageRoute(builder: (context) => const LoginScreen()),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
      BuildContext context, String icon, Color iconBg, String label,
      {bool isLogout = false, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: AppTheme.cardSmDecoration,
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(icon, style: const TextStyle(fontSize: 18)),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: isLogout ? AppTheme.red : AppTheme.text,
                ),
              ),
            ),
            Text('›',
                style: TextStyle(fontSize: 16, color: isLogout ? AppTheme.red : AppTheme.text3)),
          ],
        ),
      ),
    );
  }
}
