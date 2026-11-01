import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import '../theme/app_theme.dart';
import '../main_screen.dart';
import '../services/api_service.dart';
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
  List<Map<String, dynamic>> _children = [];
  bool _isLoading = true;

  String _attendanceRate = '96%';
  String _averageScore = '89.5';
  String _violationPoints = '0';
  List<Map<String, dynamic>> _activities = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    final children = await ApiService.getChildren();
    if (children.isNotEmpty) {
      _children = children;
      if (_selectedChildIndex >= _children.length) {
        _selectedChildIndex = 0;
      }
      ApiService.setSelectedChild(_children[_selectedChildIndex]);
      await _loadChildStats(_children[_selectedChildIndex]['id'].toString());
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadChildStats(String childId) async {
    final summary = await ApiService.getAttendanceSummary(childId);
    final hadir = (summary['total_hadir'] as num?)?.toInt() ?? 24;
    final sakit = (summary['total_sakit'] as num?)?.toInt() ?? 1;
    final izin = (summary['total_izin'] as num?)?.toInt() ?? 0;
    final alpha = (summary['total_alpha'] as num?)?.toInt() ?? 1;
    final total = hadir + sakit + izin + alpha;
    final rate = total > 0 ? ((hadir / total) * 100).round() : 100;

    final report = await ApiService.getReportCard(childId);
    final avg = (report?['average_score'] as num?)?.toDouble() ?? 89.5;

    final points = await ApiService.getViolationPoints(childId);
    final invoices = await ApiService.getInvoices(childId);
    final checkups = await ApiService.getHealthCheckups(childId);

    // Bangun daftar aktivitas terbaru dari data nyata
    final List<Map<String, dynamic>> dynamicActs = [];

    // Tagihan
    final unpaid = invoices.firstWhere((inv) => inv['status'] == 'UNPAID', orElse: () => {});
    if (unpaid.isNotEmpty) {
      final amount = unpaid['total_amount'] ?? 600000;
      dynamicActs.add({
        'icon': '💳',
        'iconBg': AppTheme.accentBg,
        'title': unpaid['invoice_name'] ?? 'Tagihan SPP',
        'sub': '${ApiService.formatRupiah(amount)} — Belum dibayar',
        'time': 'Jatuh Tempo',
        'badgeLabel': 'Tagihan',
        'badgeColor': AppTheme.yellow,
        'badgeBg': AppTheme.yellowBg,
      });
    }

    // Rapor
    if (report != null) {
      dynamicActs.add({
        'icon': '📊',
        'iconBg': AppTheme.blueBg,
        'title': 'Rapor Belajar Siswa',
        'sub': '${report['term_name'] ?? 'Semester Genap'} — Rata-rata ${avg.toStringAsFixed(1)}',
        'time': 'Baru',
        'badgeLabel': 'Akademik',
        'badgeColor': AppTheme.blue,
        'badgeBg': AppTheme.blueBg,
      });
    }

    // Kesehatan
    if (checkups.isNotEmpty) {
      final latestCheckup = checkups.first;
      dynamicActs.add({
        'icon': '🩺',
        'iconBg': AppTheme.tealBg,
        'title': 'Pemeriksaan UKS Sekolah',
        'sub': 'TB ${latestCheckup['height'] ?? 172}cm · BB ${latestCheckup['weight'] ?? 65}kg · ${latestCheckup['diagnosis'] ?? 'Sehat'}',
        'time': latestCheckup['date'] ?? 'Terbaru',
        'badgeLabel': 'Sehat',
        'badgeColor': AppTheme.teal,
        'badgeBg': AppTheme.tealBg,
      });
    }

    // Presensi
    dynamicActs.add({
      'icon': '📋',
      'iconBg': alpha > 0 ? AppTheme.redBg : AppTheme.tealBg,
      'title': alpha > 0 ? 'Presensi: Tercatat Alpha' : 'Kehadiran Prima',
      'sub': alpha > 0 ? 'Terdapat $alpha hari alpha bulan ini' : 'Total hadir $hadir sesi pertemuan',
      'time': 'Bulan Ini',
      'badgeLabel': alpha > 0 ? 'Perhatian' : 'Hadir',
      'badgeColor': alpha > 0 ? AppTheme.red : AppTheme.teal,
      'badgeBg': alpha > 0 ? AppTheme.redBg : AppTheme.tealBg,
    });

    if (mounted) {
      setState(() {
        _attendanceRate = '$rate%';
        _averageScore = avg.toStringAsFixed(1);
        _violationPoints = points.toString();
        _activities = dynamicActs;
      });
    }
  }

  void _onSelectChild(int index) {
    if (index >= 0 && index < _children.length) {
      setState(() {
        _selectedChildIndex = index;
      });
      ApiService.setSelectedChild(_children[index]);
      _loadChildStats(_children[index]['id'].toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final box = GetStorage();
    final parentName = box.read('namaOrtu') ?? 'Ibu Kartini';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildHeader(parentName),
        _buildChildSelector(),
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator(color: AppTheme.accent))
              : RefreshIndicator(
                  color: AppTheme.accent,
                  onRefresh: _loadData,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildHeroCard(),
                        _buildQuickMenu(context),
                        _buildSectionHeader('Aktivitas Terbaru'),
                        _buildActivityList(),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildHeader(String parentName) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      decoration: const BoxDecoration(
        color: AppTheme.surface,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Selamat datang, 👋', style: AppTheme.headerGreeting),
              Text(parentName, style: AppTheme.headerName),
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
    if (_children.isEmpty) {
      return const SizedBox();
    }

    final gradients = [
      [AppTheme.accent, const Color(0xFFF5A073)],
      [AppTheme.teal, const Color(0xFF38BDF8)],
      [AppTheme.blue, const Color(0xFFA78BFA)],
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 2, 20, 14),
      decoration: const BoxDecoration(
        color: AppTheme.surface,
        border: Border(bottom: BorderSide(color: AppTheme.border)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          children: List.generate(_children.length, (index) {
            final child = _children[index];
            final name = child['name']?.toString() ?? 'Siswa';
            final shortName = name.split(' ').first;
            final kelas = child['class_name']?.toString() ?? 'Kelas XII';
            final initials = child['initials']?.toString() ??
                (name.length >= 2 ? name.substring(0, 2).toUpperCase() : 'SW');
            final grad = gradients[index % gradients.length];

            return Padding(
              padding: const EdgeInsets.only(right: 10),
              child: _buildChildChip(
                index: index,
                initials: initials,
                name: shortName,
                kelas: kelas,
                gradientColors: grad,
              ),
            );
          }),
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
      onTap: () => _onSelectChild(index),
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
    final child = _children.isNotEmpty ? _children[_selectedChildIndex] : null;
    final fullName = child?['name']?.toString() ?? 'Budi Siswa Teladan';
    final fullKelas = '${child?['class_name'] ?? 'XII RPL 1'} · SMK N 1 Cikarang';

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppTheme.radius),
        gradient: const LinearGradient(
          colors: [AppTheme.accent, Color(0xFFF5A073)],
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
      child: Column(
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
              _buildHeroStat(_attendanceRate, 'Kehadiran'),
              _buildHeroStatDivider(),
              _buildHeroStat(_averageScore, 'Rata Nilai'),
              _buildHeroStatDivider(),
              _buildHeroStat(_violationPoints, 'Poin Langgar'),
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
              _buildQuickMenuItem(itemWidth, '📋', 'Presensi', AppTheme.tealBg, onTap: () {
                final parent = context.findAncestorStateOfType<State<MainScreen>>() as dynamic;
                if (parent != null) parent.switchTab(1);
              }),
              _buildQuickMenuItem(itemWidth, '📊', 'Rapor', AppTheme.blueBg, onTap: () {
                final parent = context.findAncestorStateOfType<State<MainScreen>>() as dynamic;
                if (parent != null) parent.navigateToSubPage(const PageRapor());
              }),
              _buildQuickMenuItem(itemWidth, '💳', 'Bayar SPP', AppTheme.accentBg, hasBadge: true, onTap: () {
                final parent = context.findAncestorStateOfType<State<MainScreen>>() as dynamic;
                if (parent != null) parent.switchTab(2);
              }),
              _buildQuickMenuItem(itemWidth, '🩺', 'Kesehatan', AppTheme.redBg, onTap: () {
                final parent = context.findAncestorStateOfType<State<MainScreen>>() as dynamic;
                if (parent != null) parent.navigateToSubPage(const PageKesehatan());
              }),
              _buildQuickMenuItem(itemWidth, '📅', 'Jadwal', AppTheme.purpleBg, onTap: () {
                final parent = context.findAncestorStateOfType<State<MainScreen>>() as dynamic;
                if (parent != null) parent.navigateToSubPage(const PageJadwal());
              }),
              _buildQuickMenuItem(itemWidth, '⭐', 'Nilai Guru', AppTheme.yellowBg, onTap: () {
                final parent = context.findAncestorStateOfType<State<MainScreen>>() as dynamic;
                if (parent != null) parent.navigateToSubPage(const PagePenilaian());
              }),
              _buildQuickMenuItem(itemWidth, '🗓️', 'Kalender', AppTheme.tealBg, onTap: () {
                final parent = context.findAncestorStateOfType<State<MainScreen>>() as dynamic;
                if (parent != null) parent.switchTab(3);
              }),
              _buildQuickMenuItem(itemWidth, '👤', 'Profil', AppTheme.bg2, onTap: () {
                final parent = context.findAncestorStateOfType<State<MainScreen>>() as dynamic;
                if (parent != null) parent.switchTab(4);
              }),
            ],
          );
        },
      ),
    );
  }

  Widget _buildQuickMenuItem(double width, String icon, String label, Color bgColor,
      {bool hasBadge = false, VoidCallback? onTap}) {
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
                      child: const Text('!',
                          style: TextStyle(
                              color: Colors.white, fontSize: 9, fontWeight: FontWeight.w800)),
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

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: AppTheme.sectionTitle),
        ],
      ),
    );
  }

  Widget _buildActivityList() {
    if (_activities.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: AppTheme.cardSmDecoration,
          child: const Center(
            child: Text('Belum ada aktivitas tercatat', style: TextStyle(color: AppTheme.text3)),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
      child: Column(
        children: _activities.map((act) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _buildActivityCard(
              act['icon'] ?? '📌',
              act['iconBg'] ?? AppTheme.bg2,
              act['title'] ?? '',
              act['sub'] ?? '',
              act['time'] ?? '',
              act['badgeLabel'] ?? '',
              act['badgeColor'] ?? AppTheme.text2,
              act['badgeBg'] ?? AppTheme.bg2,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildActivityCard(String icon, Color iconBg, String title, String sub, String time,
      String badgeLabel, Color badgeColor, Color badgeBg) {
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
                Text(title,
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.text)),
                const SizedBox(height: 2),
                Text(
                  sub,
                  style: const TextStyle(
                      fontSize: 11, fontWeight: FontWeight.w500, color: AppTheme.text3),
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
                      style:
                          TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: badgeColor),
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
