import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../main_screen.dart';
import 'package:get_storage/get_storage.dart';
import '../auth/login_screen.dart';

class PageProfil extends StatelessWidget {
  const PageProfil({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildHeader(context),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHero(),
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
                   if(parent != null) parent.goBack();
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
          const Text('Edit', style: TextStyle(fontSize: 13, color: AppTheme.accent, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  Widget _buildHero() {
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
            child: const Text('KR', style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900)),
          ),
          const SizedBox(height: 12),
          const Text('Kartini Rahayu', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppTheme.text)),
          const SizedBox(height: 4),
          const Text('kartini.r@email.com', style: TextStyle(fontSize: 12, color: AppTheme.text3, fontFamily: 'DM Mono')),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: AppTheme.accentBg,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Text('●', style: TextStyle(fontSize: 6, color: AppTheme.accent)),
                SizedBox(width: 3),
                Text('2 Anak Terdaftar', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppTheme.accent)),
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
          _buildMenuItem(context, '👤', AppTheme.accentBg, 'Data Diri'),
          const SizedBox(height: 8),
          _buildMenuItem(context, '👨‍👩‍👦', AppTheme.blueBg, 'Data Anak'),
          const SizedBox(height: 8),
          _buildMenuItem(context, '💳', AppTheme.tealBg, 'Riwayat Pembayaran'),
          const SizedBox(height: 8),
          _buildMenuItem(context, '🔔', AppTheme.yellowBg, 'Pengaturan Notifikasi'),
          const SizedBox(height: 8),
          _buildMenuItem(context, '🔑', AppTheme.purpleBg, 'Ganti Password'),
          const SizedBox(height: 8),
          _buildMenuItem(context, '❓', AppTheme.bg2, 'Bantuan & FAQ'),
          const SizedBox(height: 8),
          _buildMenuItem(context, '🚪', AppTheme.redBg, 'Keluar', isLogout: true),
        ],
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context, String icon, Color iconBg, String label, {bool isLogout = false}) {
    return GestureDetector(
      onTap: () {
        if (isLogout) {
          final box = GetStorage();
          box.remove('isLoggedIn');
          box.remove('namaOrtu');
          Navigator.of(context, rootNavigator: true).pushReplacement(
            MaterialPageRoute(builder: (context) => const LoginScreen()),
          );
        }
      },
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
          Text('›', style: TextStyle(fontSize: 16, color: isLogout ? AppTheme.red : AppTheme.text3)),
        ],
      ),
    ));
  }
}
