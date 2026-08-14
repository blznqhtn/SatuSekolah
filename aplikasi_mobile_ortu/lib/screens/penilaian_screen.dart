import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../services/api_client.dart';

class PenilaianScreen extends StatefulWidget {
  const PenilaianScreen({super.key});

  @override
  State<PenilaianScreen> createState() => _PenilaianScreenState();
}

class _PenilaianScreenState extends State<PenilaianScreen> {
  int _selectedGuruIndex = 0;
  bool _isLoadingData = true;
  bool _isSubmitting = false;

  Map<String, dynamic>? _activePeriod;
  List<dynamic> _categories = [];
  List<dynamic> _eligibleTeachers = [];

  // Map Category ID -> Score
  final Map<String, int> _ratings = {};
  
  final TextEditingController _komentarCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchEvaluationData();
  }

  @override
  void dispose() {
    _komentarCtrl.dispose();
    super.dispose();
  }

  Future<void> _fetchEvaluationData() async {
    setState(() => _isLoadingData = true);
    try {
      final periodRes = await ApiClient().dio.get('/evaluations/active-period');
      if (periodRes.statusCode == 200) {
        _activePeriod = periodRes.data['data'];
      }

      final catRes = await ApiClient().dio.get('/evaluations/categories');
      if (catRes.statusCode == 200) {
        _categories = catRes.data['data'] ?? [];
        // Initialize default scores to 0
        for (var cat in _categories) {
          _ratings[cat['id']] = 0;
        }
      }

      final teacherRes = await ApiClient().dio.get('/evaluations/teachers/eligible');
      if (teacherRes.statusCode == 200) {
        _eligibleTeachers = teacherRes.data['data'] ?? [];
      }
    } catch (e) {
      print("Error fetching evaluation data: $e");
    } finally {
      setState(() => _isLoadingData = false);
    }
  }

  void _onTeacherSelected(int index) {
    setState(() {
      _selectedGuruIndex = index;
      _komentarCtrl.clear();
      // Reset ratings
      for (var cat in _categories) {
        _ratings[cat['id']] = 0;
      }
    });
  }

  Future<void> _submit() async {
    if (_activePeriod == null || _eligibleTeachers.isEmpty) return;

    final teacher = _eligibleTeachers[_selectedGuruIndex];
    if (teacher['is_graded'] == true) return;

    // Build scores payload
    List<Map<String, dynamic>> scores = [];
    _ratings.forEach((catId, score) {
      if (score > 0) {
        scores.add({
          "category_id": catId,
          "score": score.toDouble()
        });
      }
    });

    if (scores.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Berikan setidaknya satu penilaian (bintang) terlebih dahulu.')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final response = await ApiClient().dio.post('/evaluations/submit', data: {
        "teacher_id": teacher['id'],
        "period_id": _activePeriod!['id'],
        "scores": scores,
        "advantages": _komentarCtrl.text,
        "disadvantages": "",
        "suggestions": ""
      });

      if (response.statusCode == 201) {
        // Mark as graded locally
        setState(() {
          _eligibleTeachers[_selectedGuruIndex]['is_graded'] = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Penilaian berhasil dikirim secara anonim!')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengirim penilaian: $e')),
      );
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  String _getInitials(String name) {
    List<String> parts = name.split(' ');
    if (parts.length > 1) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name.substring(0, 1).toUpperCase() : '?';
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingData) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_activePeriod == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('🏝️', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 16),
            Text('Tidak ada periode evaluasi aktif', style: AppTextStyles.h3),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 16),
          _buildAnonInfo(),
          const SizedBox(height: 16),
          if (_eligibleTeachers.isEmpty) ...[
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Text('Tidak ada guru yang dapat dinilai.', style: AppTextStyles.h3),
              ),
            ),
          ] else ...[
            _buildGuruSelector(),
            const SizedBox(height: 16),
            _buildRatingCard(),
            const SizedBox(height: 32),
          ]
        ],
      ),
    );
  }

  Widget _buildAnonInfo() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.accentBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.accent.withOpacity(0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text('🔒', style: TextStyle(fontSize: 18)),
                const SizedBox(width: 8),
                Expanded(child: Text('Penilaian Anonim - ${_activePeriod!['name']}', style: AppTextStyles.bodyBold)),
              ],
            ),
            const SizedBox(height: 6),
            const Text(
              'Identitas Anda tidak akan ditampilkan kepada guru. Penilaian ini murni bersifat rahasia dan akan direkap secara rata-rata.',
              style: TextStyle(
                fontFamily: 'Nunito',
                fontSize: 12,
                color: AppColors.text2,
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGuruSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text('Pilih Guru', style: AppTextStyles.h3),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: _eligibleTeachers.asMap().entries.map((entry) {
              final i = entry.key;
              final guru = entry.value;
              final isChosen = i == _selectedGuruIndex;
              final isGraded = guru['is_graded'] == true;

              return GestureDetector(
                onTap: () => _onTeacherSelected(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: isChosen ? AppColors.accentBg : AppColors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isChosen ? AppColors.accent : AppColors.border,
                      width: isChosen ? 2 : 1,
                    ),
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
                      GradientAvatar(
                        inisial: _getInitials(guru['name']),
                        colorStart: AppColors.teal,
                        colorEnd: AppColors.blueBg,
                        size: 40,
                        fontSize: 14,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(guru['name'], style: AppTextStyles.bodyBold),
                            Text(guru['course'], style: AppTextStyles.bodySmall),
                          ],
                        ),
                      ),
                      if (isGraded)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.teal.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text('Selesai', style: TextStyle(color: AppColors.teal, fontSize: 10, fontWeight: FontWeight.bold)),
                        )
                      else
                        Text(
                          isChosen ? '✅' : '○',
                          style: TextStyle(
                            fontSize: 18,
                            color: isChosen ? null : AppColors.border2,
                          ),
                        ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildRatingCard() {
    final guru = _eligibleTeachers[_selectedGuruIndex];
    final bool isGraded = guru['is_graded'] == true;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Rating untuk ${guru['name']}',
              style: AppTextStyles.h3,
            ),
            const SizedBox(height: 16),
            ..._categories.map((cat) => _buildAspekRating(cat, isGraded)),
            const SizedBox(height: 8),
            const Text(
              'Komentar',
              style: TextStyle(
                fontFamily: 'Nunito',
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.text2,
              ),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _komentarCtrl,
              maxLines: 3,
              enabled: !isGraded,
              style: const TextStyle(fontFamily: 'Nunito', fontSize: 13),
              decoration: InputDecoration(
                hintText: isGraded ? 'Sudah dinilai' : 'Tuliskan masukan Anda...',
                hintStyle: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 13,
                  color: AppColors.text3,
                ),
                filled: true,
                fillColor: isGraded ? AppColors.border.withOpacity(0.5) : AppColors.bg2,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: AppColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: AppColors.accent),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: AppColors.border),
                ),
                contentPadding: const EdgeInsets.all(12),
              ),
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: (_isSubmitting || isGraded) ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isGraded ? AppColors.teal : AppColors.accent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 0,
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        isGraded ? '✅ Penilaian Terkirim!' : 'Kirim Penilaian',
                        style: const TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAspekRating(dynamic cat, bool isGraded) {
    String catId = cat['id'];
    String name = cat['name'];

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            name,
            style: const TextStyle(
              fontFamily: 'Nunito',
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: List.generate(5, (i) {
              final isActive = i < (_ratings[catId] ?? 0);
              return GestureDetector(
                onTap: isGraded ? null : () => setState(() => _ratings[catId] = i + 1),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.only(right: 6),
                  child: Text(
                    '⭐',
                    style: TextStyle(
                      fontSize: 22,
                      color: isActive ? null : Colors.grey.withOpacity(0.3),
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class GradientAvatar extends StatelessWidget {
  final String inisial;
  final Color colorStart;
  final Color colorEnd;
  final double size;
  final double fontSize;

  const GradientAvatar({
    super.key,
    required this.inisial,
    required this.colorStart,
    required this.colorEnd,
    this.size = 34,
    this.fontSize = 12,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [colorStart, colorEnd],
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        inisial,
        style: TextStyle(
          fontFamily: 'Nunito',
          fontSize: fontSize,
          fontWeight: FontWeight.w800,
          color: Colors.white,
        ),
      ),
    );
  }
}