import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../main_screen.dart';
import '../services/api_service.dart';

class PageRapor extends StatefulWidget {
  const PageRapor({super.key});

  @override
  State<PageRapor> createState() => _PageRaporState();
}

class _PageRaporState extends State<PageRapor> {
  bool _isLoading = true;
  String _childName = 'Anak';
  String _childId = '';

  Map<String, dynamic>? _reportData;

  @override
  void initState() {
    super.initState();
    _loadReportCard();
  }

  Future<void> _loadReportCard() async {
    setState(() {
      _isLoading = true;
    });

    final child = ApiService.getSelectedChild();
    if (child != null) {
      _childName = child['name'] ?? 'Anak';
      _childId = child['id']?.toString() ?? '';
    } else {
      final children = await ApiService.getChildren();
      if (children.isNotEmpty) {
        _childName = children.first['name'] ?? 'Anak';
        _childId = children.first['id']?.toString() ?? '';
      }
    }

    if (_childId.isNotEmpty) {
      final report = await ApiService.getReportCard(_childId);
      if (mounted) {
        setState(() {
          _reportData = report;
          _isLoading = false;
        });
      }
    } else {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final firstName = _childName.split(' ').first;
    final termName = _reportData?['term_name'] ?? 'Semester Genap';
    final avgScore = (_reportData?['average_score'] as num?)?.toDouble() ?? 89.5;
    final rank = _reportData?['class_rank']?.toString() ?? '1';
    final notes = _reportData?['homeroom_notes'] ??
        'Anak menunjukkan perkembangan belajar yang sangat baik dan konsisten.';
    final grades = (_reportData?['grades'] as List?)?.cast<Map<String, dynamic>>() ?? [];

    return Column(
      children: [
        _buildHeader(context, firstName, termName),
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator(color: AppTheme.accent))
              : RefreshIndicator(
                  color: AppTheme.accent,
                  onRefresh: _loadReportCard,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 16),
                        _buildSummaryCard(avgScore, rank),
                        _buildSectionHeader('Nilai Per Mata Pelajaran'),
                        _buildNilaiGrid(grades),
                        _buildCatatanCard(notes),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context, String firstName, String termName) {
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
              Text('Rapor $firstName', style: AppTheme.headerTitle),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.accentBg,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(termName,
                style: const TextStyle(
                    fontSize: 11, color: AppTheme.accent, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(double avgScore, String rank) {
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
                  children: [
                    const Text('Rata-rata Nilai',
                        style: TextStyle(
                            fontSize: 11, color: AppTheme.text3, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 2),
                    Text(avgScore.toStringAsFixed(1),
                        style: const TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.w900,
                            color: AppTheme.blue,
                            letterSpacing: -1)),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text('Peringkat Kelas',
                        style: TextStyle(
                            fontSize: 11, color: AppTheme.text3, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 2),
                    Text('🏆 $rank',
                        style: const TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.w900,
                            color: AppTheme.accent,
                            letterSpacing: -1)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text('Wali Kelas: Budi Waluyo, S.Pd.',
                style: TextStyle(fontSize: 11, color: AppTheme.text3, fontWeight: FontWeight.w600)),
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

  Widget _buildNilaiGrid(List<Map<String, dynamic>> grades) {
    if (grades.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: AppTheme.cardSmDecoration,
          child: const Center(
            child: Text('Belum ada nilai mata pelajaran tercatat',
                style: TextStyle(fontSize: 12, color: AppTheme.text3)),
          ),
        ),
      );
    }

    final colors = [
      AppTheme.blue,
      AppTheme.teal,
      AppTheme.purple,
      AppTheme.accent,
      AppTheme.yellow,
      AppTheme.red,
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        itemCount: grades.length,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 1.5,
        ),
        itemBuilder: (context, index) {
          final item = grades[index];
          final subject = item['course_name']?.toString() ?? 'Mata Pelajaran';
          final score = (item['score'] as num?)?.toInt() ?? 80;
          final color = colors[index % colors.length];

          return _buildNilaiCard(subject, score, color);
        },
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
          Text(subject,
              style: const TextStyle(
                  fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.text3),
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
          const SizedBox(height: 6),
          Text(score.toString(),
              style: TextStyle(
                  fontSize: 28, fontWeight: FontWeight.w900, color: color, letterSpacing: -1)),
          const Spacer(),
          Container(
            height: 4,
            decoration: BoxDecoration(
              color: AppTheme.bg2,
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.centerLeft,
            child: FractionallySizedBox(
              widthFactor: (score / 100).clamp(0.0, 1.0),
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

  Widget _buildCatatanCard(String notes) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: AppTheme.cardDecoration,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('📝 Catatan Wali Kelas',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            Text(
              notes,
              style: const TextStyle(fontSize: 12, color: AppTheme.text2, height: 1.7),
            ),
          ],
        ),
      ),
    );
  }
}
