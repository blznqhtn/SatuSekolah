import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../main_screen.dart';
import 'page_rapor.dart';
import 'page_kesehatan.dart';
import 'page_jadwal.dart';
import 'page_penilaian.dart';

class PageBeranda extends StatefulWidget {
  const PageBeranda({super.key});

  @override
  State<PageBeranda> createState() => _PageBerandaState();
}

class _PageBerandaState extends State<PageBeranda> {
  int _selectedChildIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildHeader(),
        _buildChildSelector(),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeroCard(),
                _buildQuickMenu(context),
                _buildSectionHeader('Aktivitas Terbaru', 'Lihat semua'),
                _buildActivityList(),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 14),
      decoration: const BoxDecoration(
        color: AppTheme.surface,
        border: Border(bottom: BorderSide(color: AppTheme.border)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Selamat pagi, 👋', style: AppTheme.headerGreeting),
              Text('Ibu Kartini', style: AppTheme.headerName),
            ],
          ),
          Container(
            width: 38,
            height: 38,
            decoration: const BoxDecoration(
              color: AppTheme.accentBg,
              shape: BoxShape.circle,
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                const Text('🔔', style: TextStyle(fontSize: 18)),
                Positioned(
                  top: 2,
                  right: 2,
                  child: Container(
                    width: 16,
                    height: 16,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppTheme.red,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppTheme.white, width: 1.5),
                    ),
                    child: const Text(
                      '3',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChildSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: const BoxDecoration(
        color: AppTheme.white,
        border: Border(bottom: BorderSide(color: AppTheme.border)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildChildChip(
              index: 0,
              initials: 'AP',
              name: 'Aditya',
              kelas: 'XII IPA 1',
              gradientColors: [AppTheme.accent, const Color(0xFFF5A073)],
            ),
            const SizedBox(width: 10),
            _buildChildChip(
              index: 1,
              initials: 'RK',
              name: 'Rina',
              kelas: 'X RPL 2',
              gradientColors: [AppTheme.teal, const Color(0xFF38BDF8)],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChildChip({
    required int index,
    required String initials,
    required String name,
    required String kelas,
    required List<Color> gradientColors,
  }) {
    final isActive = _selectedChildIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedChildIndex = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? AppTheme.accentBg : AppTheme.bg2,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: isActive ? AppTheme.accent : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 28,
              height: 28,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: gradientColors,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Text(
                initials,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.text,
                  ),
                ),
                Text(
                  kelas,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.text3,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroCard() {
    final isAditya = _selectedChildIndex == 0;
    final fullName = isAditya ? 'Aditya Pratama' : 'Rina Kartini';
    final fullKelas = isAditya ? 'XII IPA 1 · SMK N 1 Cikarang' : 'X RPL 2 · SMK N 1 Cikarang';
    
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppTheme.radius),
        gradient: LinearGradient(
          colors: [AppTheme.accent, const Color(0xFFF5A073)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.accent.withOpacity(0.35),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background decorations could be added here
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Pantau Anak',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                fullName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                fullKelas,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  _buildHeroStat('94%', 'Kehadiran'),
                  _buildHeroStatDivider(),
                  _buildHeroStat('87.4', 'Rata Nilai'),
                  _buildHeroStatDivider(),
                  _buildHeroStat('0', 'Poin Langgar'),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeroStat(String val, String label) {
    return Expanded(
      child: Column(
        children: [
          Text(
            val,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroStatDivider() {
    return Container(
      width: 1,
      height: 30,
      color: Colors.white.withOpacity(0.25),
    );
  }

  Widget _buildQuickMenu(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final itemWidth = (constraints.maxWidth - 30) / 4;
          return Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _buildQuickMenuItem(itemWidth, '📋', 'Presensi', AppTheme.tealBg, onTap: () {}), // Handled by bottom nav normally, but dummy here
              _buildQuickMenuItem(itemWidth, '📊', 'Rapor', AppTheme.blueBg, onTap: () {
                final parent = context.findAncestorStateOfType<State<MainScreen>>() as dynamic;
                if(parent != null) parent.navigateToSubPage(const PageRapor());
              }),
              _buildQuickMenuItem(itemWidth, '💳', 'Bayar SPP', AppTheme.accentBg, hasBadge: true, onTap: () {}),
              _buildQuickMenuItem(itemWidth, '🩺', 'Kesehatan', AppTheme.redBg, onTap: () {
                final parent = context.findAncestorStateOfType<State<MainScreen>>() as dynamic;
                if(parent != null) parent.navigateToSubPage(const PageKesehatan());
              }),
              _buildQuickMenuItem(itemWidth, '📅', 'Jadwal', AppTheme.purpleBg, onTap: () {
                final parent = context.findAncestorStateOfType<State<MainScreen>>() as dynamic;
                if(parent != null) parent.navigateToSubPage(const PageJadwal());
              }),
              _buildQuickMenuItem(itemWidth, '⭐', 'Nilai Guru', AppTheme.yellowBg, onTap: () {
                final parent = context.findAncestorStateOfType<State<MainScreen>>() as dynamic;
                if(parent != null) parent.navigateToSubPage(const PagePenilaian());
              }),
              _buildQuickMenuItem(itemWidth, '🗓️', 'Kalender', AppTheme.tealBg, onTap: () {}),
              _buildQuickMenuItem(itemWidth, '👤', 'Profil', AppTheme.bg2, onTap: () {}),
            ],
          );
        }
      ),
    );
  }

  Widget _buildQuickMenuItem(double width, String icon, String label, Color bgColor, {bool hasBadge = false, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
        decoration: AppTheme.cardSmDecoration,
        child: Column(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(icon, style: const TextStyle(fontSize: 20)),
                ),
                if (hasBadge)
                  Positioned(
                    top: -6,
                    right: -6,
                    child: Container(
                      width: 16,
                      height: 16,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                        color: AppTheme.red,
                        shape: BoxShape.circle,
                      ),
                      child: const Text('!', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w800)),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: AppTheme.text,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, [String? actionLabel]) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: AppTheme.sectionTitle),
          if (actionLabel != null)
            Text(actionLabel, style: AppTheme.sectionMore),
        ],
      ),
    );
  }

  Widget _buildActivityList() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
      child: Column(
        children: [
          _buildActivityCard('❌', AppTheme.redBg, 'Tidak hadir hari ini', 'Matematika jam 1 — Alpha', '08:15', 'Alpha', AppTheme.red, AppTheme.redBg),
          const SizedBox(height: 10),
          _buildActivityCard('📊', AppTheme.blueBg, 'Rapor semester baru', 'Rapor Genap 2025/2026 tersedia', 'Kemarin', 'Baru', AppTheme.blue, AppTheme.blueBg),
          const SizedBox(height: 10),
          _buildActivityCard('💳', AppTheme.accentBg, 'Tagihan SPP Mei 2026', 'Rp 600.000 — Belum dibayar', '1 Mei', 'Tagihan', AppTheme.yellow, AppTheme.yellowBg),
          const SizedBox(height: 10),
          _buildActivityCard('🩺', AppTheme.tealBg, 'Pemeriksaan kesehatan', 'BB 65kg · TB 172cm · Sehat', '14 Mei', 'Sehat', AppTheme.teal, AppTheme.tealBg),
        ],
      ),
    );
  }

  Widget _buildActivityCard(String icon, Color iconBg, String title, String sub, String time, String badgeLabel, Color badgeColor, Color badgeBg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: AppTheme.cardSmDecoration,
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(13),
            ),
            child: Text(icon, style: const TextStyle(fontSize: 20)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.text)),
                const SizedBox(height: 2),
                Text(
                  sub,
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: AppTheme.text3),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                time,
                style: const TextStyle(fontSize: 10, color: AppTheme.text3, fontFamily: 'DM Mono'),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: badgeBg,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('●', style: TextStyle(fontSize: 6, color: badgeColor)),
                    const SizedBox(width: 3),
                    Text(
                      badgeLabel,
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: badgeColor),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
