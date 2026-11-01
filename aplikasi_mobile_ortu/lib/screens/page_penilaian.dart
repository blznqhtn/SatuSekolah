import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../main_screen.dart';
import '../services/api_service.dart';

class PagePenilaian extends StatefulWidget {
  const PagePenilaian({super.key});

  @override
  State<PagePenilaian> createState() => _PagePenilaianState();
}

class _PagePenilaianState extends State<PagePenilaian> {
  int _selectedGuru = 0;
  final List<int> _ratings = [5, 4, 5];
  final TextEditingController _commentController = TextEditingController();

  bool _isLoading = true;
  bool _isSubmitting = false;
  bool _isSuccess = false;

  List<Map<String, dynamic>> _teachers = [];

  @override
  void initState() {
    super.initState();
    _loadTeachers();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _loadTeachers() async {
    setState(() {
      _isLoading = true;
    });

    final list = await ApiService.getEligibleTeachers();
    if (mounted) {
      setState(() {
        _teachers = list;
        _isLoading = false;
      });
    }
  }

  Future<void> _submitEvaluation() async {
    if (_teachers.isEmpty) return;

    setState(() {
      _isSubmitting = true;
    });

    final teacher = _teachers[_selectedGuru];
    final teacherId = teacher['id']?.toString() ?? '';
    final avgRating = (_ratings.reduce((a, b) => a + b) / _ratings.length).round();
    final review = _commentController.text.trim();

    final ok = await ApiService.submitEvaluation(teacherId, avgRating, review);

    if (mounted) {
      setState(() {
        _isSubmitting = false;
        _isSuccess = ok;
      });

      if (ok) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Penilaian berhasil dikirim secara anonim!'),
            backgroundColor: AppTheme.teal,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedTeacherName = _teachers.isNotEmpty
        ? (_teachers[_selectedGuru]['name'] ?? 'Guru')
        : 'Guru Pengajar';

    return Column(
      children: [
        _buildHeader(context),
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator(color: AppTheme.accent))
              : RefreshIndicator(
                  color: AppTheme.accent,
                  onRefresh: _loadTeachers,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 16),
                        _buildInfoCard(),
                        _buildSectionHeader('Pilih Guru Pengajar'),
                        _buildGuruList(),
                        _buildRatingCard(selectedTeacherName),
                        const SizedBox(height: 24),
                      ],
                    ),
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
          const Text('Nilai Kinerja Guru', style: AppTheme.headerTitle),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.accentBg,
          borderRadius: BorderRadius.circular(AppTheme.radius),
          border: Border.all(color: AppTheme.accent.withOpacity(0.2)),
        ),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('🔒 Penilaian Anonim & Rahasia',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800)),
            SizedBox(height: 4),
            Text(
              'Identitas Anda tidak akan ditampilkan kepada guru. Penilaian ini digunakan oleh pihak sekolah untuk meningkatkan kualitas pembelajaran anak Anda.',
              style: TextStyle(fontSize: 12, color: AppTheme.text2, height: 1.6),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(title, style: AppTheme.sectionTitle),
    );
  }

  Widget _buildGuruList() {
    if (_teachers.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: AppTheme.cardSmDecoration,
          child: const Center(
            child: Text('Belum ada guru yang terdaftar untuk dievaluasi',
                style: TextStyle(fontSize: 12, color: AppTheme.text3)),
          ),
        ),
      );
    }

    final gradients = [
      [const Color(0xFF4F8EF7), const Color(0xFFA78BFA)],
      [const Color(0xFF34D497), const Color(0xFF38BDF8)],
      [const Color(0xFFF5C842), const Color(0xFFF76F6F)],
      [const Color(0xFFEC4899), const Color(0xFF8B5CF6)],
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: List.generate(_teachers.length, (index) {
          final guru = _teachers[index];
          final name = guru['name']?.toString() ?? 'Guru';
          final mapel = guru['subject']?.toString() ?? 'Mata Pelajaran';
          final grad = gradients[index % gradients.length];
          final initials = name.length >= 2 ? name.substring(0, 2).toUpperCase() : 'GR';

          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _buildGuruCard(index, initials, name, mapel, grad),
          );
        }),
      ),
    );
  }

  Widget _buildGuruCard(
      int index, String initials, String name, String mapel, List<Color> gradientColors) {
    final isSelected = _selectedGuru == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedGuru = index;
          _isSuccess = false;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.accentBg : AppTheme.white,
          borderRadius: BorderRadius.circular(AppTheme.radiusSm),
          border: Border.all(
            color: isSelected ? AppTheme.accent : Colors.transparent,
            width: 2,
          ),
          boxShadow: AppTheme.shadowSm,
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: gradientColors,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Text(initials,
                  style: const TextStyle(
                      color: Colors.white, fontSize: 14, fontWeight: FontWeight.w800)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name,
                      style: const TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.text)),
                  Text(mapel, style: const TextStyle(fontSize: 11, color: AppTheme.text3)),
                ],
              ),
            ),
            if (isSelected)
              const Text('✅', style: TextStyle(fontSize: 18))
            else
              const Text('○', style: TextStyle(fontSize: 18, color: AppTheme.border2)),
          ],
        ),
      ),
    );
  }

  Widget _buildRatingCard(String teacherName) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: AppTheme.cardDecoration,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Rating untuk $teacherName',
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800)),
            const SizedBox(height: 14),
            _buildRatingRow(0, 'Penguasaan Materi'),
            const SizedBox(height: 16),
            _buildRatingRow(1, 'Cara Mengajar & Keterbukaan'),
            const SizedBox(height: 16),
            _buildRatingRow(2, 'Komunikasi dengan Orang Tua'),
            const SizedBox(height: 16),
            const Text('Komentar & Masukan (opsional)',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.text2)),
            const SizedBox(height: 6),
            TextField(
              controller: _commentController,
              maxLines: 3,
              style: const TextStyle(fontSize: 13),
              decoration: InputDecoration(
                hintText: 'Tuliskan apresiasi atau saran konstruktif Anda...',
                hintStyle: const TextStyle(color: AppTheme.text3, fontSize: 13),
                filled: true,
                fillColor: AppTheme.bg2,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusXs),
                  borderSide: const BorderSide(color: AppTheme.border, width: 1.5),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusXs),
                  borderSide: const BorderSide(color: AppTheme.border, width: 1.5),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusXs),
                  borderSide: const BorderSide(color: AppTheme.accent, width: 1.5),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: (_isSubmitting || _isSuccess) ? null : _submitEvaluation,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isSuccess ? AppTheme.teal : AppTheme.accent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  _isSubmitting
                      ? '⏳ Mengirim Penilaian...'
                      : (_isSuccess ? '✅ Penilaian Terkirim!' : 'Kirim Penilaian'),
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w800, fontFamily: 'Nunito'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRatingRow(int ratingIndex, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.text)),
        const SizedBox(height: 8),
        Row(
          children: List.generate(5, (starIndex) {
            final isActive = starIndex < _ratings[ratingIndex];
            return GestureDetector(
              onTap: () {
                setState(() {
                  _ratings[ratingIndex] = starIndex + 1;
                });
              },
              child: Padding(
                padding: const EdgeInsets.only(right: 6),
                child: ColorFiltered(
                  colorFilter: isActive
                      ? const ColorFilter.mode(Colors.transparent, BlendMode.multiply)
                      : const ColorFilter.matrix([
                          0.33, 0.33, 0.33, 0, 0,
                          0.33, 0.33, 0.33, 0, 0,
                          0.33, 0.33, 0.33, 0, 0,
                          0, 0, 0, 0.3, 0,
                        ]),
                  child: const Text('⭐', style: TextStyle(fontSize: 22)),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}
