import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_storage/get_storage.dart';
import 'constants/app_colors.dart';
import 'constants/app_theme.dart';
import 'auth/login_screen.dart';
import 'screens/beranda_screen.dart';
import 'screens/cari_sekolah_screen.dart';
import 'screens/presensi_screen.dart';
import 'screens/bayar_screen.dart';
import 'screens/kalender_screen.dart';
import 'screens/profil_screen.dart';
import 'screens/rapor_screen.dart';
import 'screens/penilaian_screen.dart';
import 'screens/jadwal_screen.dart';
import 'screens/kesehatan_screen.dart';
import 'screens/chat_screen.dart';
import 'services/api_client.dart';
import 'auth/register_screen.dart' as auth_register;
import 'screens/tagihan_spmb_screen.dart';

	import 'package:intl/date_symbol_data_local.dart';

	void main() async {
	  WidgetsFlutterBinding.ensureInitialized();
	  await GetStorage.init();
	  await initializeDateFormatting('id_ID', null);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );
  runApp(const SatuSekolahApp());
}

class SatuSekolahApp extends StatelessWidget {
  const SatuSekolahApp({super.key});

  @override
  Widget build(BuildContext context) {
    final box = GetStorage();
    bool isLoggedIn = box.read('isLoggedIn') ?? false;

    return MaterialApp(
      navigatorKey: ApiClient.navigatorKey, // Kunci global untuk redirect 401/403
      title: 'Satu Sekolah — Orang Tua',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const auth_register.RegisterScreen(),
        '/beranda': (context) => const MainShell(),
      },
      builder: (context, child) {
        final data = MediaQuery.of(context);
        return MediaQuery(
          // Memperbesar SEMUA teks di aplikasi sebesar 15%
          data: data.copyWith(textScaler: const TextScaler.linear(1.05)),
          child: child!,
        );
      },
      home: isLoggedIn ? const MainShell() : const LoginScreen(),
    );
  }
}

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;
  bool _isLoading = true;
  bool _spmbCompleted = false;

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    try {
      final res = await ApiClient().dio.get('/users/profile');
      if (mounted) {
        final spmbCompleted = res.data['data']['spmb_completed'] ?? false;
        // Simpan status agar child screen (seperti BerandaScreen) bisa tahu jika diperlukan
        GetStorage().write('hasChild', spmbCompleted);
        
        setState(() {
          _spmbCompleted = spmbCompleted;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _navigateTo(int index) {
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppColors.bg,
        body: const Center(
          child: CircularProgressIndicator(color: AppColors.teal),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(),
            Expanded(
              child: IndexedStack(
                index: _currentIndex,
                children: _buildScreens(),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  List<Widget> _buildScreens() {
    if (!_spmbCompleted) {
      return [
        const CariSekolahScreen(),
        const ProfilScreen(),
      ];
    }
    
    return [
      BerandaScreen(onNavigate: _navigateTo),
      const PresensiScreen(),
      const BayarScreen(),
      const KalenderScreen(),
      const ProfilScreen(),
      const RaporScreen(),
      const PenilaianScreen(),
      const JadwalScreen(),
      const KesehatanScreen(),
      const ChatScreen(),
    ];
  }

  // ── TOP BAR (judul halaman + back/notif) ──────────────────────────────
  Widget _buildTopBar() {
    final List<String> titles;
    if (!_spmbCompleted) {
      titles = ['Pendaftaran SPMB', 'Profil Saya'];
    } else {
      titles = [
        'Beranda', 'Presensi', 'Bayar SPP', 'Kalender', 'Profil Saya',
        'Rapor Akademik', 'Nilai dari Guru', 'Jadwal Pelajaran', 'Kesehatan Anak', 'Pesan (E2EE)'
      ];
    }
    
    // Fallback safe index
    final safeIndex = _currentIndex < titles.length ? _currentIndex : 0;
    final isHome = safeIndex == 0 && _spmbCompleted;

    if (isHome) return const SizedBox.shrink(); // Beranda punya header sendiri

    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          // Tombol Back (hanya jika spmb selesai dan bukan di halaman utama)
          if (_spmbCompleted && safeIndex != 0) ...[
            GestureDetector(
              onTap: () => _navigateTo(0),
              child: Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(color: AppColors.bg2, shape: BoxShape.circle),
                alignment: Alignment.center,
                child: const Text('←', style: TextStyle(fontSize: 18)),
              ),
            ),
            const SizedBox(width: 12),
          ],
          Text(
            titles[safeIndex],
            style: const TextStyle(
              fontFamily: 'Nunito',
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: AppColors.text,
            ),
          ),

          if (_spmbCompleted && safeIndex == 1) ...[
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.accentBg,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'Aditya · XII IPA 1',
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.accent,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ── BOTTOM NAVIGATION ─────────────────────────────────────────────────
  Widget _buildBottomNav() {
    final List<_NavTab> tabs;
    
    if (!_spmbCompleted) {
      tabs = [
        const _NavTab('📝', 'Daftar SPMB', false),
        const _NavTab('👤', 'Profil', false),
      ];
    } else {
      tabs = [
        const _NavTab('🏠', 'Beranda', false),
        const _NavTab('📋', 'Presensi', true),   // has badge
        const _NavTab('💳', 'Bayar SPP', true),  // has badge
        const _NavTab('🗓️', 'Kalender', false),
        const _NavTab('👤', 'Profil', false),
      ];
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border(top: BorderSide(color: AppColors.border)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: tabs.asMap().entries.map((entry) {
            final i = entry.key;
            final tab = entry.value;
            // Prevent out of bounds if tabs switch dynamically
            final isActive = i == (_currentIndex < tabs.length ? _currentIndex : 0);
            
            return GestureDetector(
              onTap: () {
                if (i < tabs.length) {
                  setState(() => _currentIndex = i);
                }
              },
              behavior: HitTestBehavior.opaque,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: isActive ? AppColors.accentBg : Colors.transparent,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Text(
                          tab.emoji,
                          style: TextStyle(
                            fontSize: 22,
                            color: isActive ? null : null,
                          ),
                        ),
                        if (tab.hasBadge)
                          Positioned(
                            top: -2,
                            right: -4,
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: AppColors.red,
                                shape: BoxShape.circle,
                                border: Border.all(color: AppColors.white, width: 1.5),
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      tab.label,
                      style: TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: isActive ? AppColors.accent : AppColors.text3,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _NavTab {
  final String emoji;
  final String label;
  final bool hasBadge;
  const _NavTab(this.emoji, this.label, this.hasBadge);
}