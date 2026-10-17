import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../models/activity_model.dart';
import 'rapor_detail_screen.dart';

import 'package:dio/dio.dart';
import 'package:get_storage/get_storage.dart';
import '../services/api_client.dart';
import 'package:url_launcher/url_launcher.dart';

class RaporScreen extends StatefulWidget {
  const RaporScreen({super.key});

  @override
  State<RaporScreen> createState() => _RaporScreenState();
}

class _RaporScreenState extends State<RaporScreen> {
  bool _isLoading = true;
  List<dynamic> _semesters = [];
  String? _selectedTermId;
  
  Map<String, dynamic>? _summary;
  List<NilaiMapel> _nilaiList = [];
  List<dynamic> _reportNotes = [];

  @override
  void initState() {
    super.initState();
    _fetchSemesters();
  }

  Future<void> _fetchSemesters() async {
    try {
      final box = GetStorage();
      final childId = box.read('active_child_id') ?? 'child-uuid-123';

      final response = await ApiClient().dio.get('/academic/report-cards/student/$childId/semesters');
      if (response.statusCode == 200 && response.data['data'] != null) {
        setState(() {
          _semesters = response.data['data'];
          if (_semesters.isNotEmpty) {
            _selectedTermId = _semesters[0]['term_id'];
          }
        });
        await _fetchRaporData();
      } else {
        _useDummyData();
      }
    } catch (e) {
      print("Error fetching semesters: $e");
      _useDummyData();
    }
  }

  Future<void> _fetchRaporData() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final box = GetStorage();
      final childId = box.read('active_child_id') ?? 'child-uuid-123';

      String url = '/academic/report-cards/student/$childId';
      if (_selectedTermId != null) {
        url += '?term_id=$_selectedTermId';
      }

      final response = await ApiClient().dio.get(url);
      
      if (response.statusCode == 200 && response.data['data'] != null) {
        final data = response.data['data'];
        final subjects = data['subjects'] as List<dynamic>? ?? [];
        
        setState(() {
          _summary = data['summary'];
          _reportNotes = data['report_notes'] as List<dynamic>? ?? [];
          _nilaiList = subjects.map((e) => NilaiMapel(
            courseId: e['course_id'] ?? '',
            mapel: e['course_name'] ?? '', 
            nilai: (e['final_score'] ?? 0).toDouble(), 
            predicate: e['predicate'] ?? '',
            warna: AppColors.blue 
          )).toList();
        });
      } else {
        _useDummyData();
      }
    } catch (e) {
      print("Error fetching rapor: $e");
      _useDummyData();
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _useDummyData() {
    if (!mounted) return;
    setState(() {
      _summary = {
        'average_score': 87.4,
        'class_rank': 2,
        'homeroom_teacher': 'Budi Waluyo, S.Pd.',
        'active_semester': 'Semester Genap',
        'academic_year': '2025/2026',
        'homeroom_notes': 'Aditya menunjukkan perkembangan yang sangat baik di semester ini...'
      };
      _nilaiList = const [
        NilaiMapel(courseId: '1', mapel: 'Matematika', nilai: 92, predicate: 'A', warna: AppColors.blue),
        NilaiMapel(courseId: '2', mapel: 'Fisika', nilai: 88, predicate: 'B', warna: AppColors.teal),
      ];
      _reportNotes = [
        {
          'category': 'ACADEMIC',
          'notes': 'Belajar dengan sangat giat.'
        }
      ];
      _isLoading = false;
    });
  }

  void _downloadPDF() async {
    final box = GetStorage();
    final childId = box.read('active_child_id') ?? 'child-uuid-123';
    // In a real app, we would use url_launcher or a file downloader to hit the API with Auth headers
    // For demo purposes, we can print a message or launch the url if it's a GET request
    final String baseUrl = ApiClient().dio.options.baseUrl;
    String url = '$baseUrl/academic/report-cards/student/$childId/pdf';
    if (_selectedTermId != null) {
      url += '?term_id=$_selectedTermId';
    }
    
    // Add token as query param for browser download, since browsers don't send auth headers easily
    final token = box.read('token');
    url += '&token=$token';

    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tidak dapat mengunduh PDF')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildSemesterDropdown(),
                ElevatedButton.icon(
                  onPressed: _downloadPDF,
                  icon: const Icon(Icons.download, size: 18),
                  label: const Text('PDF'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.blue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _buildSummaryCard(),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text('Nilai Per Mata Pelajaran', style: AppTextStyles.h3),
          ),
          const SizedBox(height: 10),
          _buildNilaiGrid(),
          const SizedBox(height: 16),
          _buildCatatanWali(),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildSemesterDropdown() {
    if (_semesters.isEmpty) return const SizedBox();
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedTermId,
          icon: const Icon(Icons.arrow_drop_down, color: AppColors.text2),
          style: const TextStyle(
            fontFamily: 'Nunito',
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.text,
          ),
          onChanged: (String? newValue) {
            setState(() {
              _selectedTermId = newValue;
            });
            _fetchRaporData();
          },
          items: _semesters.map<DropdownMenuItem<String>>((dynamic term) {
            return DropdownMenuItem<String>(
              value: term['term_id'],
              child: Text(term['term_name'] ?? 'Semester'),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildSummaryCard() {
    String avg = _summary?['average_score']?.toString() ?? '0';
    if (_summary?['average_score'] is double) {
      avg = (_summary?['average_score'] as double).toStringAsFixed(1);
    }
    String rank = _summary?['class_rank']?.toString() ?? '-';
    String ht = _summary?['homeroom_teacher'] ?? '-';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.blueBg, AppColors.white.withOpacity(0.9)],
          ),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Rata-rata Nilai',
                      style: TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 11,
                        color: AppColors.text3,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      avg,
                      style: const TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 36,
                        fontWeight: FontWeight.w900,
                        color: AppColors.blue,
                        letterSpacing: -1,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      'Peringkat Kelas',
                      style: TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 11,
                        color: AppColors.text3,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '🏆 $rank',
                      style: const TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 36,
                        fontWeight: FontWeight.w900,
                        color: AppColors.accent,
                        letterSpacing: -1,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Wali Kelas: $ht',
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 11,
                  color: AppColors.text3,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNilaiGrid() {
    if (_nilaiList.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Text('Belum ada nilai yang diinputkan.', style: TextStyle(color: AppColors.text3)),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 1.6,
        ),
        itemCount: _nilaiList.length,
        itemBuilder: (_, i) {
          final item = _nilaiList[i];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => RaporDetailScreen(
                    courseId: item.courseId,
                    termId: _selectedTermId,
                    courseName: item.mapel,
                  ),
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(12),
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
                    item.mapel,
                    style: const TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.text3,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        item.nilai.toStringAsFixed(0),
                        style: TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          color: item.warna,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '(${item.predicate})',
                        style: const TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.text3,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: item.nilai / 100,
                      minHeight: 4,
                      backgroundColor: AppColors.bg2,
                      valueColor: AlwaysStoppedAnimation<Color>(item.warna),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCatatanWali() {
    List<Widget> noteWidgets = [];
    
    if (_summary?['homeroom_notes'] != null && _summary!['homeroom_notes'] != "") {
       noteWidgets.add(
         Padding(
           padding: const EdgeInsets.only(bottom: 8.0),
           child: Text(
              _summary!['homeroom_notes'],
              style: const TextStyle(
                fontFamily: 'Nunito',
                fontSize: 12,
                color: AppColors.text2,
                height: 1.7,
              ),
           ),
         )
       );
    }

    for (var note in _reportNotes) {
      noteWidgets.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                note['category'] ?? '',
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.text,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                note['notes'] ?? '',
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 12,
                  color: AppColors.text2,
                  height: 1.5,
                ),
              ),
            ],
          ),
        )
      );
    }

    if (noteWidgets.isEmpty) {
      return const SizedBox();
    }

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
            Text('📝 Catatan Wali Kelas', style: AppTextStyles.h3),
            const SizedBox(height: 12),
            ...noteWidgets,
          ],
        ),
      ),
    );
  }
}
