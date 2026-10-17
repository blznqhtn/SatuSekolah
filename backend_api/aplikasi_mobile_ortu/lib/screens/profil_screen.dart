import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import '../auth/login_screen.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../widgets/app_badge.dart';
import '../models/activity_model.dart';
import '../services/api_client.dart';
import 'edit_profil_screen.dart';
import 'data_anak_screen.dart';
import 'riwayat_bayar_screen.dart';
import 'notifikasi_screen.dart';
import 'ganti_password_screen.dart';
import 'faq_screen.dart';

class ProfilScreen extends StatefulWidget {
  const ProfilScreen({super.key});

  @override
  State<ProfilScreen> createState() => _ProfilScreenState();
}

class _ProfilScreenState extends State<ProfilScreen> {
  bool _isLoading = true;
  Map<String, dynamic>? _profileData;

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    setState(() => _isLoading = true);
    try {
      final res = await ApiClient().dio.get('/users/profile');
      if (mounted) {
        setState(() {
          _profileData = res.data['data'];
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.teal),
      );
    }

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          _buildProfilHero(),
          const SizedBox(height: 16),
          _buildMenuList(context),
          const SizedBox(height: 8),
          _buildLogoutButton(context),
          const SizedBox(height: 16),
          const Text(
            'Satu Sekolah v1.0.0 · Neura Cakrawira Solusi',
            style: TextStyle(
              fontFamily: 'Nunito',
              fontSize: 10,
              color: AppColors.text3,
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildProfilHero() {
    final name = _profileData?['name'] ?? 'Pengguna';
    final email = _profileData?['email'] ?? '-';
    final initials = name.isNotEmpty ? name.substring(0, 1).toUpperCase() : '?';
    
    // Check if SPMB completed to show "Belum terhubung dengan anak" vs "Orang Tua Terdaftar"
    final spmbCompleted = _profileData?['spmb_completed'] ?? false;

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.accentBg, AppColors.bg],
          stops: [0, 0.6],
        ),
      ),
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.accent, Color(0xFFF5A073)],
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.accent.withOpacity(0.35),
                  blurRadius: 20,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: Text(
              initials,
              style: const TextStyle(
                fontFamily: 'Nunito',
                fontSize: 32,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            name,
            style: const TextStyle(
              fontFamily: 'Nunito',
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: AppColors.text,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            email,
            style: const TextStyle(
              fontFamily: 'monospace',
              fontSize: 12,
              color: AppColors.text3,
            ),
          ),
          const SizedBox(height: 10),
          AppBadge(
            label: spmbCompleted ? 'Akun Orang Tua Aktif' : 'Belum Terhubung dengan Siswa', 
            variant: spmbCompleted ? BadgeVariant.green : BadgeVariant.orange,
          ),
        ],
      ),
    );
  }

  Widget _buildMenuList(BuildContext context) {
    final List<Map<String, dynamic>> menuItems = [
      {'emoji': '👤', 'label': 'Ubah Profil', 'color': AppColors.accentBg, 'action': 'edit_profil'},
      {'emoji': '👨‍👩‍👦', 'label': 'Data Anak', 'color': AppColors.blueBg, 'action': 'data_anak'},
      {'emoji': '💳', 'label': 'Riwayat Pembayaran', 'color': AppColors.tealBg, 'action': 'riwayat_bayar'},
      {'emoji': '🔔', 'label': 'Pengaturan Notifikasi', 'color': AppColors.yellowBg, 'action': 'notif'},
      {'emoji': '🔑', 'label': 'Ganti Password', 'color': AppColors.purpleBg, 'action': 'password'},
      {'emoji': '❓', 'label': 'Bantuan & FAQ', 'color': AppColors.bg2, 'action': 'faq'},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: menuItems.map((item) {
          return GestureDetector(
            onTap: () {
              if (item['action'] == 'edit_profil') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => EditProfilScreen(profileData: _profileData!)),
                ).then((_) {
                  // Refresh profil saat kembali
                  _fetchProfile();
                });
              } else if (item['action'] == 'data_anak') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const DataAnakScreen()),
                );
              } else if (item['action'] == 'riwayat_bayar') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const RiwayatBayarScreen()),
                );
              } else if (item['action'] == 'notif') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const NotifikasiScreen()),
                );
              } else if (item['action'] == 'password') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const GantiPasswordScreen()),
                );
              } else if (item['action'] == 'faq') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const FaqScreen()),
                );
              }
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: item['color'],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: Text(item['emoji'], style: const TextStyle(fontSize: 18)),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(item['label'], style: AppTextStyles.bodyBold),
                  ),
                  const Text('›', style: TextStyle(fontSize: 18, color: AppColors.text3)),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GestureDetector(
        onTap: () {
          final box = GetStorage();
          box.write('isLoggedIn', false);
          box.remove('hasChild');
          box.remove('jwt_token');
          Navigator.of(context, rootNavigator: true).pushReplacement(
            MaterialPageRoute(builder: (context) => const LoginScreen()),
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppColors.redBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: const Text('🚪', style: TextStyle(fontSize: 18)),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Text('Keluar', style: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: AppColors.red,
                )),
              ),
            ],
          ),
        ),
      ),
    );
  }
}