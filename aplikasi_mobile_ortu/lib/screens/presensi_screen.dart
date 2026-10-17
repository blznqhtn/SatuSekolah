import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:get_storage/get_storage.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../widgets/app_badge.dart';
import '../widgets/section_header.dart';
import '../services/api_client.dart';
import '../models/activity_model.dart';

class PresensiScreen extends StatefulWidget {
  const PresensiScreen({super.key});

  @override
  State<PresensiScreen> createState() => _PresensiScreenState();
}

class _PresensiScreenState extends State<PresensiScreen> {
  bool _isLoading = true;
  
  Map<String, dynamic> _summary = {
    'total_hadir': 0,
    'total_sakit': 0,
    'total_izin': 0,
    'total_alpha': 0,
  };
  List<dynamic> _weekly = [];
  List<dynamic> _history = [];
  List<dynamic> _violations = [];
  int _totalPoints = 0;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      final box = GetStorage();
      final childId = box.read('active_child_id');
      
      Map<String, dynamic> query = {};
      if (childId != null) query['child_id'] = childId;

      final futures = await Future.wait([
        ApiClient().dio.get('/attendance/summary', queryParameters: query),
        ApiClient().dio.get('/attendance/weekly', queryParameters: query),
        ApiClient().dio.get('/attendance/history', queryParameters: query),
        ApiClient().dio.get('/violations/history', queryParameters: query),
      ]);

      if (mounted) {
        setState(() {
          _summary = futures[0].data['data'] ?? {};
          _weekly = futures[1].data['data'] ?? [];
          _history = futures[2].data['data'] ?? [];
          
          final vioData = futures[3].data;
          _violations = vioData['violations'] ?? [];
          _totalPoints = vioData['total_points'] ?? 0;
          
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("API Error (Presensi): $e");
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.teal));
    }

    return RefreshIndicator(
      onRefresh: _fetchData,
      color: AppColors.teal,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            _buildSummaryPills(),
            const SizedBox(height: 16),
            SectionHeader(title: 'Minggu Ini', actionLabel: DateFormat('MMMM yyyy', 'id_ID').format(DateTime.now())),
            const SizedBox(height: 10),
            _buildMingguIni(),
            const SizedBox(height: 16),
            const SectionHeader(title: 'Riwayat Terbaru'),
            const SizedBox(height: 10),
            _buildRiwayat(),
            const SizedBox(height: 16),
            const SectionHeader(title: 'Poin Pelanggaran'),
            const SizedBox(height: 10),
            _buildPelanggaran(),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryPills() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _buildSummaryPill('${_summary['total_hadir'] ?? 0}', 'Hadir', AppColors.teal),
          const SizedBox(width: 8),
          _buildSummaryPill('${_summary['total_sakit'] ?? 0}', 'Sakit', AppColors.yellow),
          const SizedBox(width: 8),
          _buildSummaryPill('${_summary['total_izin'] ?? 0}', 'Izin', AppColors.blue),
          const SizedBox(width: 8),
          _buildSummaryPill('${_summary['total_alpha'] ?? 0}', 'Alpha', AppColors.red),
        ],
      ),
    );
  }

  Widget _buildSummaryPill(String val, String label, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
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
          children: [
            Text(
              val,
              style: TextStyle(fontFamily: 'Nunito', fontSize: 22, fontWeight: FontWeight.w900, color: color, letterSpacing: -0.5),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(fontFamily: 'Nunito', fontSize: 9, fontWeight: FontWeight.w700, color: AppColors.text3, letterSpacing: 0.3),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMingguIni() {
    // Generate week days from Monday to Sunday
    List<Map<String, dynamic>> weekDays = [];
    DateTime now = DateTime.now();
    int currentWeekday = now.weekday; // 1 (Mon) - 7 (Sun)
    DateTime monday = now.subtract(Duration(days: currentWeekday - 1));

    for (int i = 0; i < 7; i++) {
      DateTime day = monday.add(Duration(days: i));
      String dateStr = DateFormat('yyyy-MM-dd').format(day);
      
      // Find status in API response
      String statusStr = 'L'; // Default Libur
      if (i < 5) statusStr = '?'; // Default belum diabsen for weekdays
      
      for (var w in _weekly) {
        if (w['date'] != null && w['date'].toString().startsWith(dateStr)) {
          String s = w['status'] ?? '';
          if (s == 'PRESENT') statusStr = 'H';
          else if (s == 'SICK') statusStr = 'S';
          else if (s == 'EXCUSED') statusStr = 'I';
          else if (s == 'ABSENT') statusStr = 'A';
          else if (s == 'LATE') statusStr = 'H'; // Late counts as Present icon usually
        }
      }

      weekDays.add({
        'label': DateFormat('E', 'id_ID').format(day),
        'status': statusStr,
        'isToday': i == (currentWeekday - 1),
      });
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: weekDays.map((item) {
          return Expanded(
            child: Column(
              children: [
                Text(
                  item['label'],
                  style: const TextStyle(fontFamily: 'Nunito', fontSize: 9, fontWeight: FontWeight.w700, color: AppColors.text3),
                ),
                const SizedBox(height: 4),
                _buildHariDot(item),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildHariDot(Map<String, dynamic> item) {
    Color bg = AppColors.bg2;
    Color fg = AppColors.text3;
    String text = item['status'];

    if (text == 'H') {
      bg = AppColors.tealBg; fg = AppColors.teal;
    } else if (text == 'S') {
      bg = AppColors.yellowBg; fg = AppColors.yellow;
    } else if (text == 'I') {
      bg = AppColors.blueBg; fg = AppColors.blue;
    } else if (text == 'A') {
      bg = AppColors.redBg; fg = AppColors.red;
    }

    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: bg,
        shape: BoxShape.circle,
        border: item['isToday'] ? Border.all(color: AppColors.accent, width: 2) : null,
      ),
      alignment: Alignment.center,
      child: Text(text, style: TextStyle(fontFamily: 'Nunito', fontSize: 11, fontWeight: FontWeight.w700, color: fg)),
    );
  }

  Widget _buildRiwayat() {
    if (_history.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Center(child: Text("Belum ada riwayat kehadiran mata pelajaran.")),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: _history.map((item) {
          
          String s = item['status'] ?? 'UNKNOWN';
          PresensiStatus pStatus = PresensiStatus.hadir;
          if (s == 'SICK') pStatus = PresensiStatus.sakit;
          if (s == 'EXCUSED') pStatus = PresensiStatus.izin;
          if (s == 'ABSENT') pStatus = PresensiStatus.alpha;
          // Note: Late falls under hadir icon with LATE badge if we had one, for now we map to hadir.

          String dateStr = item['date'] ?? '';
          try {
             DateTime d = DateTime.parse(dateStr);
             dateStr = DateFormat('dd/MM').format(d);
          } catch (_) {}

          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10, offset: const Offset(0, 2)),
              ],
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 52,
                  child: Text(dateStr, style: const TextStyle(fontFamily: 'monospace', fontSize: 11, color: AppColors.text3)),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${item['day']}, ${item['time_start']} - ${item['time_end']}', style: AppTextStyles.bodyBold),
                      Text('${item['course']} (${item['teacher']})', style: AppTextStyles.bodySmall),
                      if (item['notes'] != null && item['notes'].toString().isNotEmpty)
                         Text('Catatan: ${item['notes']}', style: const TextStyle(fontSize: 10, color: Colors.grey, fontStyle: FontStyle.italic)),
                    ],
                  ),
                ),
                PresensiStatusBadge(status: pStatus),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPelanggaran() {
    if (_violations.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10, offset: const Offset(0, 2)),
            ],
          ),
          child: Column(
            children: [
              const Text('🎉', style: TextStyle(fontSize: 42)),
              const SizedBox(height: 8),
              const Text(
                'Tidak ada pelanggaran',
                style: TextStyle(fontFamily: 'Nunito', fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.teal),
              ),
              const SizedBox(height: 4),
              Text(
                'Memiliki $_totalPoints poin pelanggaran',
                style: AppTextStyles.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.redBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.red.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.warning_amber_rounded, color: AppColors.red),
                const SizedBox(width: 8),
                Text('Total Poin Pelanggaran: $_totalPoints', style: const TextStyle(color: AppColors.red, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          const SizedBox(height: 12),
          ..._violations.map((v) {
             String dateStr = v['created_at'] ?? '';
             try {
               DateTime d = DateTime.parse(dateStr);
               dateStr = DateFormat('dd MMM yyyy HH:mm').format(d);
             } catch (_) {}

             return Container(
               margin: const EdgeInsets.only(bottom: 8),
               padding: const EdgeInsets.all(12),
               decoration: BoxDecoration(
                 color: Colors.white,
                 borderRadius: BorderRadius.circular(12),
                 border: Border.all(color: Colors.grey.shade200),
               ),
               child: Column(
                 crossAxisAlignment: CrossAxisAlignment.start,
                 children: [
                   Row(
                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                     children: [
                       Text(dateStr, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                       Text('+${v['points_applied']} Poin', style: const TextStyle(color: AppColors.red, fontWeight: FontWeight.bold, fontSize: 12)),
                     ],
                   ),
                   const SizedBox(height: 4),
                   Text(v['notes'] ?? 'Pelanggaran', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                 ],
               ),
             );
          }).toList(),
        ],
      ),
    );
  }
}