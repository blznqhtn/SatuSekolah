import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';

import 'package:dio/dio.dart';
import 'package:get_storage/get_storage.dart';
import '../services/api_client.dart';

class JadwalScreen extends StatefulWidget {
  const JadwalScreen({super.key});

  @override
  State<JadwalScreen> createState() => _JadwalScreenState();
}

class _JadwalScreenState extends State<JadwalScreen> {
  int _selectedDayIndex = 1; // 1 = Senin, 2 = Selasa, dst (API menganggap 0 = Minggu, 1 = Senin)

  final List<String> _days = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat'];
  bool _isLoading = true;
  List<dynamic> _jadwalHariIni = [];

  @override
  void initState() {
    super.initState();
    _fetchSchedules();
  }

  Future<void> _fetchSchedules() async {
    setState(() => _isLoading = true);
    try {
      // Endpoint requires dayOfWeek: 0=Sunday, 1=Monday, ...
      // Our _selectedDayIndex is an index in _days: 0=Senin, 1=Selasa ...
      // So dayOfWeek for API = _selectedDayIndex + 1
      int dayOfWeek = _selectedDayIndex + 1;

      final response = await ApiClient().dio.get('/academic/schedules/student/day/$dayOfWeek');
      if (response.statusCode == 200) {
        setState(() {
          _jadwalHariIni = response.data['data'] ?? [];
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      print("API Error (Jadwal): $e");
      // Fallback dummy for demonstration
      setState(() {
        _jadwalHariIni = [];
        _isLoading = false;
      });
    }
  }

  void _onDayChanged(int index) {
    setState(() {
      _selectedDayIndex = index;
    });
    _fetchSchedules();
  }

  // Mapper untuk UI berdasarkan ActivityType
  Map<String, dynamic> _getActivityUI(String type) {
    switch (type) {
      case 'CEREMONY':
        return {'warna': AppColors.redBg, 'ikon': '🇮🇩'};
      case 'BREAK':
        return {'warna': AppColors.bg2, 'ikon': '🍱'};
      case 'EXTRACURRICULAR':
        return {'warna': AppColors.yellowBg, 'ikon': '🏃'};
      case 'EXAM':
        return {'warna': AppColors.purpleBg, 'ikon': '📝'};
      case 'EVENT':
        return {'warna': AppColors.tealBg, 'ikon': '🎉'};
      case 'SUBJECT':
      default:
        return {'warna': AppColors.blueBg, 'ikon': '📚'};
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildDaySelector(),
        Expanded(
          child: _isLoading 
            ? const Center(child: CircularProgressIndicator()) 
            : _buildTimeline(),
        ),
      ],
    );
  }

  Widget _buildDaySelector() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 20),
      height: 45,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _days.length,
        itemBuilder: (context, index) {
          final isSelected = _selectedDayIndex == index;
          return GestureDetector(
            onTap: () => _onDayChanged(index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 24),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.accent : AppColors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppColors.accent.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        )
                      ]
                    : [],
              ),
              alignment: Alignment.center,
              child: Text(
                _days[index],
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                  color: isSelected ? Colors.white : AppColors.text3,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTimeline() {
    if (_jadwalHariIni.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('🏝️', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 16),
            Text('Tidak ada jadwal', style: AppTextStyles.h3),
          ],
        ),
      );
    }

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      itemCount: _jadwalHariIni.length,
      itemBuilder: (context, index) {
        final item = _jadwalHariIni[index];
        final isLast = index == _jadwalHariIni.length - 1;

        String waktu = '${item['start_time'] ?? '-'} - ${item['end_time'] ?? '-'}';
        String mapel = item['activity_name'] ?? item['course_name'] ?? '-';
        if (mapel.isEmpty) mapel = item['course_name'] ?? 'Pelajaran';
        
        String guru = item['staff_name'] ?? '-';
        if (guru.isEmpty) guru = '-';
        
        String ruang = item['room'] ?? '-';
        if (ruang.isEmpty) ruang = '-';
        
        String type = item['activity_type'] ?? 'SUBJECT';
        Map<String, dynamic> uiConf = _getActivityUI(type);

        bool isChanged = item['is_changed'] == true;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Timeline line & dot
            Column(
              children: [
                Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.accent, width: 3),
                  ),
                ),
                if (!isLast)
                  Container(
                    width: 2,
                    height: 110,
                    color: AppColors.accent.withOpacity(0.2),
                  ),
              ],
            ),
            const SizedBox(width: 16),
            // Timeline Card
            Expanded(
              child: Container(
                margin: const EdgeInsets.only(bottom: 24),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isChanged ? AppColors.yellowBg.withOpacity(0.5) : AppColors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: isChanged ? Border.all(color: AppColors.orange.withOpacity(0.5)) : null,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (isChanged) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          color: AppColors.orange,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'JADWAL PENGGANTI',
                          style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: uiConf['warna'],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          alignment: Alignment.center,
                          child: Text(uiConf['ikon'], style: const TextStyle(fontSize: 24)),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(waktu, style: AppTextStyles.caption.copyWith(color: isChanged ? AppColors.orange : AppColors.accent, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 4),
                              Text(mapel, style: AppTextStyles.h3),
                              const SizedBox(height: 4),
                              if (guru != '-') ...[
                                Row(
                                  children: [
                                    const Icon(Icons.person_outline, size: 14, color: AppColors.text3),
                                    const SizedBox(width: 4),
                                    Expanded(child: Text(guru, style: AppTextStyles.bodySmall, overflow: TextOverflow.ellipsis)),
                                  ],
                                ),
                                const SizedBox(height: 2),
                              ],
                              if (ruang != '-') ...[
                                Row(
                                  children: [
                                    const Icon(Icons.location_on_outlined, size: 14, color: AppColors.text3),
                                    const SizedBox(width: 4),
                                    Expanded(child: Text(ruang, style: AppTextStyles.bodySmall, overflow: TextOverflow.ellipsis)),
                                  ],
                                ),
                              ],
                              if (isChanged && item['change_notes'] != null && item['change_notes'].toString().isNotEmpty) ...[
                                const SizedBox(height: 8),
                                Text(
                                  'Catatan: ${item['change_notes']}',
                                  style: const TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: AppColors.text2),
                                ),
                              ]
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
