import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../main_screen.dart';

class PagePresensi extends StatelessWidget {
  const PagePresensi({super.key});

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
                const SizedBox(height: 16),
                _buildSummaryPills(),
                _buildSectionHeader('Minggu Ini', 'Mei 2026'),
                _buildPresensiGrid(),
                _buildSectionHeader('Riwayat Terbaru'),
                _buildHistoryList(),
                const SizedBox(height: 16),
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
          const Text('Presensi Aditya', style: AppTheme.headerTitle),
        ],
      ),
    );
  }

  Widget _buildSummaryPills() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
      child: Row(
        children: [
          _buildPill('18', 'Hadir', AppTheme.teal),
          const SizedBox(width: 8),
          _buildPill('1', 'Sakit', AppTheme.yellow),
          const SizedBox(width: 8),
          _buildPill('1', 'Izin', AppTheme.blue),
          const SizedBox(width: 8),
          _buildPill('1', 'Alpha', AppTheme.red),
        ],
      ),
    );
  }

  Widget _buildPill(String val, String label, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: AppTheme.cardSmDecoration,
        child: Column(
          children: [
            Text(val, style: TextStyle(color: color, fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: -0.5)),
            const SizedBox(height: 2),
            Text(label.toUpperCase(), style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: AppTheme.text3, letterSpacing: 0.3)),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, [String? actionLabel]) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
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

  Widget _buildPresensiGrid() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildDayCol('Sen', 'H', AppTheme.teal, AppTheme.tealBg, isToday: true),
          _buildDayCol('Sel', 'H', AppTheme.teal, AppTheme.tealBg),
          _buildDayCol('Rab', 'H', AppTheme.teal, AppTheme.tealBg),
          _buildDayCol('Kam', 'S', AppTheme.yellow, AppTheme.yellowBg),
          _buildDayCol('Jum', 'H', AppTheme.teal, AppTheme.tealBg),
          _buildDayCol('Sab', 'L', AppTheme.text3, AppTheme.bg2),
          _buildDayCol('Min', 'L', AppTheme.text3, AppTheme.bg2),
        ],
      ),
    );
  }

  Widget _buildDayCol(String day, String status, Color color, Color bgColor, {bool isToday = false}) {
    return Column(
      children: [
        Text(day.toUpperCase(), style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: AppTheme.text3)),
        const SizedBox(height: 4),
        Container(
          width: 32,
          height: 32,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: bgColor,
            shape: BoxShape.circle,
            border: isToday ? Border.all(color: AppTheme.accent, width: 2) : null,
          ),
          child: Text(status, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w700)),
        ),
      ],
    );
  }

  Widget _buildHistoryList() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          _buildHistoryCard('16/05', 'Senin 16 Mei 2026', 'Matematika, Fisika, Kimia', 'Hadir', AppTheme.teal, AppTheme.tealBg),
          const SizedBox(height: 8),
          _buildHistoryCard('15/05', 'Jumat 15 Mei 2026', 'Matematika, B.Indonesia', 'Hadir', AppTheme.teal, AppTheme.tealBg),
          const SizedBox(height: 8),
          _buildHistoryCard('14/05', 'Kamis 14 Mei 2026', 'Semua pelajaran', 'Sakit', AppTheme.yellow, AppTheme.yellowBg),
          const SizedBox(height: 8),
          _buildHistoryCard('13/05', 'Rabu 13 Mei 2026', 'Fisika, Kimia, MTK Peminatan', 'Hadir', AppTheme.teal, AppTheme.tealBg),
          const SizedBox(height: 16),
          
          Row(
            children: const [
              Text('Poin Pelanggaran', style: AppTheme.sectionTitle),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: AppTheme.cardDecoration,
            child: Column(
              children: [
                const Text('🎉', style: TextStyle(fontSize: 42)),
                const SizedBox(height: 8),
                const Text('Tidak ada pelanggaran', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppTheme.teal)),
                const SizedBox(height: 4),
                const Text('Aditya memiliki 0 poin pelanggaran bulan ini', style: TextStyle(fontSize: 12, color: AppTheme.text3)),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildHistoryCard(String dateShort, String dateFull, String subjects, String badge, Color badgeColor, Color badgeBg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: AppTheme.cardSmDecoration,
      child: Row(
        children: [
          SizedBox(
            width: 52,
            child: Text(dateShort, style: const TextStyle(fontFamily: 'DM Mono', fontSize: 11, color: AppTheme.text3)),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(dateFull, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                Text(subjects, style: const TextStyle(fontSize: 10, color: AppTheme.text3)),
              ],
            ),
          ),
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
                Text(badge, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: badgeColor)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
