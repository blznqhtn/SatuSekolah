import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import 'package:get_storage/get_storage.dart';
import '../services/api_client.dart';

class RaporDetailScreen extends StatefulWidget {
  final String courseId;
  final String? termId;
  final String courseName;

  const RaporDetailScreen({
    super.key,
    required this.courseId,
    this.termId,
    required this.courseName,
  });

  @override
  State<RaporDetailScreen> createState() => _RaporDetailScreenState();
}

class _RaporDetailScreenState extends State<RaporDetailScreen> {
  bool _isLoading = true;
  Map<String, dynamic>? _data;

  @override
  void initState() {
    super.initState();
    _fetchDetail();
  }

  Future<void> _fetchDetail() async {
    try {
      final box = GetStorage();
      final childId = box.read('active_child_id') ?? 'child-uuid-123';
      
      String url = '/academic/grades/student/$childId/subject/${widget.courseId}';
      if (widget.termId != null) {
        url += '?term_id=${widget.termId}';
      }

      final response = await ApiClient().dio.get(url);
      if (response.statusCode == 200 && response.data['data'] != null) {
        setState(() {
          _data = response.data['data'];
          _isLoading = false;
        });
      } else {
        _useDummyData();
      }
    } catch (e) {
      print('Error fetching detail rapor: $e');
      _useDummyData();
    }
  }

  void _useDummyData() {
    if (!mounted) return;
    setState(() {
      _data = {
        'course_name': widget.courseName,
        'final_score': 88.5,
        'teacher_notes': 'Siswa sangat aktif di kelas.',
        'components': [
          {'component_name': 'Tugas Harian 1', 'score': 90.0, 'weight': 10.0},
          {'component_name': 'Tugas Harian 2', 'score': 85.0, 'weight': 10.0},
          {'component_name': 'Kuis 1', 'score': 80.0, 'weight': 10.0},
          {'component_name': 'UTS', 'score': 88.0, 'weight': 30.0},
          {'component_name': 'UAS', 'score': 92.0, 'weight': 40.0},
        ]
      };
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        title: Text(
          widget.courseName,
          style: AppTextStyles.h3.copyWith(fontSize: 16),
        ),
        iconTheme: const IconThemeData(color: AppColors.text),
        centerTitle: true,
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildFinalScoreCard(),
                const SizedBox(height: 24),
                Text('Detail Komponen Nilai', style: AppTextStyles.h3),
                const SizedBox(height: 12),
                _buildComponentsList(),
                const SizedBox(height: 24),
                if (_data?['teacher_notes'] != null && _data!['teacher_notes'] != "")
                  _buildTeacherNotes(),
              ],
            ),
          ),
    );
  }

  Widget _buildFinalScoreCard() {
    double finalScore = 0.0;
    if (_data?['final_score'] is num) {
      finalScore = (_data!['final_score'] as num).toDouble();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.blue, AppColors.blue.withOpacity(0.8)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.blue.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'NILAI AKHIR',
            style: TextStyle(
              fontFamily: 'Nunito',
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Colors.white70,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            finalScore.toStringAsFixed(1),
            style: const TextStyle(
              fontFamily: 'Nunito',
              fontSize: 56,
              fontWeight: FontWeight.w900,
              color: AppColors.white,
              letterSpacing: -2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComponentsList() {
    final components = _data?['components'] as List<dynamic>? ?? [];
    
    if (components.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Text('Belum ada nilai komponen.', style: TextStyle(color: AppColors.text3)),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: components.length,
        separatorBuilder: (_, __) => const Divider(height: 1, color: AppColors.border),
        itemBuilder: (_, index) {
          final comp = components[index];
          double score = 0.0;
          if (comp['score'] is num) score = (comp['score'] as num).toDouble();
          
          double weight = 0.0;
          if (comp['weight'] is num) weight = (comp['weight'] as num).toDouble();

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        comp['component_name'] ?? '-',
                        style: const TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.text,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Bobot: ${weight.toStringAsFixed(0)}%',
                        style: const TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 12,
                          color: AppColors.text3,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  score.toStringAsFixed(1),
                  style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.blue,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTeacherNotes() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.bg2,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.feedback_outlined, size: 18, color: AppColors.accent),
              const SizedBox(width: 8),
              Text(
                'Catatan Guru Mapel',
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.text2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            _data!['teacher_notes'],
            style: const TextStyle(
              fontFamily: 'Nunito',
              fontSize: 13,
              color: AppColors.text,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
