import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../main_screen.dart';

class PageKalender extends StatelessWidget {
  const PageKalender({super.key});

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
                _buildCalendarNav(),
                _buildCalendarGrid(),
                _buildLegend(),
                _buildSectionHeader('Agenda Mei 2026'),
                _buildAgendaList(),
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
          const Text('Kalender Akademik', style: AppTheme.headerTitle),
        ],
      ),
    );
  }

  Widget _buildCalendarNav() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('‹', style: TextStyle(fontSize: 20, color: AppTheme.text3, fontWeight: FontWeight.w500)),
          const Text('Mei 2026', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.text)),
          const Text('›', style: TextStyle(fontSize: 20, color: AppTheme.text3, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildCalendarGrid() {
    // Creating the hardcoded grid from HTML for UI representation
    final List<String> days = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
    final List<Map<String, dynamic>> dates = [
      {'val': '', 'type': 'empty'}, {'val': '', 'type': 'empty'}, {'val': '1', 'type': 'normal'}, {'val': '2', 'type': 'normal'}, {'val': '3', 'type': 'event'}, {'val': '4', 'type': 'normal'}, {'val': '5', 'type': 'normal'},
      {'val': '6', 'type': 'normal'}, {'val': '7', 'type': 'normal'}, {'val': '8', 'type': 'normal'}, {'val': '9', 'type': 'normal'}, {'val': '10', 'type': 'event'}, {'val': '11', 'type': 'holiday'}, {'val': '12', 'type': 'holiday'},
      {'val': '13', 'type': 'normal'}, {'val': '14', 'type': 'normal'}, {'val': '15', 'type': 'normal'}, {'val': '16', 'type': 'today'}, {'val': '17', 'type': 'event'}, {'val': '18', 'type': 'normal'}, {'val': '19', 'type': 'normal'},
      {'val': '20', 'type': 'event'}, {'val': '21', 'type': 'normal'}, {'val': '22', 'type': 'normal'}, {'val': '23', 'type': 'event'}, {'val': '24', 'type': 'normal'}, {'val': '25', 'type': 'holiday'}, {'val': '26', 'type': 'holiday'},
      {'val': '27', 'type': 'normal'}, {'val': '28', 'type': 'normal'}, {'val': '29', 'type': 'event'}, {'val': '30', 'type': 'normal'}, {'val': '31', 'type': 'normal'},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: days.map((day) => Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Text(day.toUpperCase(), textAlign: TextAlign.center, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: AppTheme.text3)),
              ),
            )).toList(),
          ),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: dates.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              crossAxisSpacing: 4,
              mainAxisSpacing: 4,
            ),
            itemBuilder: (context, index) {
              final date = dates[index];
              if (date['type'] == 'empty') {
                return const SizedBox();
              }
              
              Color bgColor = Colors.transparent;
              Color textColor = AppTheme.text;
              FontWeight weight = FontWeight.w600;

              if (date['type'] == 'today') {
                bgColor = AppTheme.accent;
                textColor = Colors.white;
                weight = FontWeight.w900;
              } else if (date['type'] == 'event') {
                textColor = AppTheme.teal;
                weight = FontWeight.w800;
              } else if (date['type'] == 'holiday') {
                textColor = AppTheme.red;
              }

              return Container(
                decoration: BoxDecoration(
                  color: bgColor,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  date['val'],
                  style: TextStyle(fontSize: 12, fontWeight: weight, color: textColor),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLegend() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      child: Row(
        children: [
          _buildLegendItem(AppTheme.accent, 'Hari ini'),
          const SizedBox(width: 12),
          _buildLegendItem(AppTheme.teal, 'Ada event'),
          const SizedBox(width: 12),
          _buildLegendItem(AppTheme.red, 'Libur'),
        ],
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.text2)),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      child: Text(title, style: AppTheme.sectionTitle),
    );
  }

  Widget _buildAgendaList() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: AppTheme.cardDecoration,
        child: Column(
          children: [
            _buildAgendaItem(AppTheme.blue, 'UTS Semester Genap', '17–23 Mei 2026', 'Ujian', AppTheme.blue, AppTheme.blueBg),
            const Divider(height: 1, color: AppTheme.border),
            _buildAgendaItem(AppTheme.teal, 'Pembagian Rapor Antara', '29 Mei 2026', 'Kegiatan', AppTheme.teal, AppTheme.tealBg),
            const Divider(height: 1, color: AppTheme.border),
            _buildAgendaItem(AppTheme.red, 'Libur Akhir Pekan', 'Sabtu & Minggu', 'Libur', AppTheme.red, AppTheme.redBg),
            const Divider(height: 1, color: AppTheme.border),
            _buildAgendaItem(AppTheme.accent, 'Penyerahan PKL Siswa Kelas XII', '20 Mei 2026', 'Kegiatan', AppTheme.accent, AppTheme.accentBg),
          ],
        ),
      ),
    );
  }

  Widget _buildAgendaItem(Color dotColor, String title, String date, String badge, Color badgeColor, Color badgeBg) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: dotColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.text)),
                const SizedBox(height: 2),
                Text(date, style: const TextStyle(fontSize: 11, color: AppTheme.text3, fontFamily: 'DM Mono')),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: badgeBg,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(badge, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: badgeColor)),
          ),
        ],
      ),
    );
  }
}
