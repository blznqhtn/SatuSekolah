import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../main_screen.dart';

class PageRapor extends StatelessWidget {
  const PageRapor({super.key});

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
                _buildSummaryCard(),
                _buildSectionHeader('Nilai Per Mata Pelajaran'),
                _buildNilaiGrid(),
                _buildCatatanCard(),
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
              const Text('Rapor Aditya', style: AppTheme.headerTitle),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.accentBg,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text('Genap 25/26', style: TextStyle(fontSize: 11, color: AppTheme.accent, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppTheme.radius),
          border: Border.all(color: AppTheme.border),
          gradient: const LinearGradient(
            colors: [AppTheme.blueBg, Colors.white],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('Rata-rata Nilai', style: TextStyle(fontSize: 11, color: AppTheme.text3, fontWeight: FontWeight.w600)),
                    SizedBox(height: 2),
                    Text('87.4', style: TextStyle(fontSize: 36, fontWeight: FontWeight.w900, color: AppTheme.blue, letterSpacing: -1)),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: const [
                    Text('Peringkat Kelas', style: TextStyle(fontSize: 11, color: AppTheme.text3, fontWeight: FontWeight.w600)),
                    SizedBox(height: 2),
                    Text('🥈 2', style: TextStyle(fontSize: 36, fontWeight: FontWeight.w900, color: AppTheme.accent, letterSpacing: -1)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text('Wali Kelas: Budi Waluyo, S.Pd.', style: TextStyle(fontSize: 11, color: AppTheme.text3, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
      child: Text(title, style: AppTheme.sectionTitle),
    );
  }

  Widget _buildNilaiGrid() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1.5,
        children: [
          _buildNilaiCard('Matematika', 92, AppTheme.blue),
          _buildNilaiCard('Fisika', 88, AppTheme.teal),
          _buildNilaiCard('Kimia', 85, AppTheme.purple),
          _buildNilaiCard('B. Indonesia', 90, AppTheme.accent),
          _buildNilaiCard('B. Inggris', 82, AppTheme.yellow),
          _buildNilaiCard('Sejarah', 78, AppTheme.red),
        ],
      ),
    );
  }

  Widget _buildNilaiCard(String subject, int score, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: AppTheme.cardSmDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(subject, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.text3)),
          const SizedBox(height: 6),
          Text(score.toString(), style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: color, letterSpacing: -1)),
          const Spacer(),
          Container(
            height: 4,
            decoration: BoxDecoration(
              color: AppTheme.bg2,
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.centerLeft,
            child: FractionallySizedBox(
              widthFactor: score / 100,
              child: Container(
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCatatanCard() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: AppTheme.cardDecoration,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text('📝 Catatan Wali Kelas', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800)),
            SizedBox(height: 8),
            Text(
              'Aditya menunjukkan perkembangan yang sangat baik di semester ini, terutama dalam penguasaan Matematika dan Fisika. Diharapkan dapat lebih aktif berdiskusi di kelas dan meningkatkan nilai Sejarah.',
              style: TextStyle(fontSize: 12, color: AppTheme.text2, height: 1.7),
            ),
          ],
        ),
      ),
    );
  }
}
