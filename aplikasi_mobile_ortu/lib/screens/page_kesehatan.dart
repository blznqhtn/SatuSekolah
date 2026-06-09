import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../main_screen.dart';

class PageKesehatan extends StatelessWidget {
  const PageKesehatan({super.key});

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
                _buildVitalGrid(),
                _buildTrenCard(),
                _buildSectionHeader('Riwayat Pemeriksaan'),
                _buildRiwayatList(),
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
              const Text('Kesehatan Aditya', style: AppTheme.headerTitle),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: AppTheme.tealBg,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Text('●', style: TextStyle(fontSize: 6, color: AppTheme.teal)),
                SizedBox(width: 3),
                Text('Sehat', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppTheme.teal)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVitalGrid() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1.3,
        children: [
          _buildVitalCard('⚖️', 'Berat Badan', '65', 'kg', AppTheme.blue, '14 Mei 2026', 22),
          _buildVitalCard('📏', 'Tinggi Badan', '172', 'cm', AppTheme.teal, '14 Mei 2026', 22),
          _buildVitalCard('🌡️', 'Suhu Tubuh', '36.5', '°C', AppTheme.teal, '14 Mei 2026', 22),
          _buildVitalCard('💉', 'Tekanan Darah', '120/80', '', AppTheme.accent, '14 Mei 2026', 18),
        ],
      ),
    );
  }

  Widget _buildVitalCard(String icon, String label, String value, String unit, Color color, String date, double valSize) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: AppTheme.cardSmDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(icon, style: const TextStyle(fontSize: 22)),
          const SizedBox(height: 8),
          Text(label.toUpperCase(), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppTheme.text3, letterSpacing: 0.3)),
          const SizedBox(height: 2),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(value, style: TextStyle(fontSize: valSize, fontWeight: FontWeight.w900, color: color, letterSpacing: -0.5)),
              if (unit.isNotEmpty) ...[
                const SizedBox(width: 4),
                Text(unit, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.text3)),
              ],
            ],
          ),
          const Spacer(),
          Text('Cek: $date', style: const TextStyle(fontSize: 10, color: AppTheme.text3, fontFamily: 'DM Mono')),
        ],
      ),
    );
  }

  Widget _buildTrenCard() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: AppTheme.cardDecoration,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('📈 Tren Berat Badan', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800)),
            const SizedBox(height: 12),
            _buildProgressItem('Maret 2026', '63 kg', 0.79, AppTheme.blue),
            const SizedBox(height: 12),
            _buildProgressItem('April 2026', '64 kg', 0.81, AppTheme.blue),
            const SizedBox(height: 12),
            _buildProgressItem('Mei 2026', '65 kg', 0.83, AppTheme.teal),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressItem(String label, String value, double percent, Color color) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.text2)),
            Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppTheme.text, fontFamily: 'DM Mono')),
          ],
        ),
        const SizedBox(height: 5),
        Container(
          height: 8,
          decoration: BoxDecoration(
            color: AppTheme.bg2,
            borderRadius: BorderRadius.circular(10),
          ),
          alignment: Alignment.centerLeft,
          child: FractionallySizedBox(
            widthFactor: percent,
            child: Container(
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
      child: Text(title, style: AppTheme.sectionTitle),
    );
  }

  Widget _buildRiwayatList() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          _buildRiwayatCard('14 Mei 2026'),
          const SizedBox(height: 8),
          _buildRiwayatCard('14 Apr 2026'),
        ],
      ),
    );
  }

  Widget _buildRiwayatCard(String date) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: AppTheme.cardSmDecoration,
      child: Row(
        children: [
          const Text('🏥', style: TextStyle(fontSize: 24)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Pemeriksaan Rutin', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text('$date · Petugas PMR', style: const TextStyle(fontSize: 10, color: AppTheme.text3, fontFamily: 'DM Mono')),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: AppTheme.tealBg,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Text('●', style: TextStyle(fontSize: 6, color: AppTheme.teal)),
                SizedBox(width: 3),
                Text('Sehat', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppTheme.teal)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
