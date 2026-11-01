import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../main_screen.dart';
import '../services/api_service.dart';

class PagePresensi extends StatefulWidget {
  const PagePresensi({super.key});

  @override
  State<PagePresensi> createState() => _PagePresensiState();
}

class _PagePresensiState extends State<PagePresensi> {
  bool _isLoading = true;
  String _childName = 'Anak';
  String _childId = '';

  Map<String, dynamic> _summary = {
    'total_hadir': 24,
    'total_sakit': 1,
    'total_izin': 0,
    'total_alpha': 1,
  };
  List<Map<String, dynamic>> _history = [];
  int _violationPoints = 0;

  @override
  void initState() {
    super.initState();
    _loadPresensi();
  }

  Future<void> _loadPresensi() async {
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
      final summary = await ApiService.getAttendanceSummary(_childId);
      final history = await ApiService.getAttendanceHistory(_childId);
      final points = await ApiService.getViolationPoints(_childId);

      if (mounted) {
        setState(() {
          _summary = summary;
          _history = history;
          _violationPoints = points;
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

    return Column(
      children: [
        _buildHeader(context, firstName),
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator(color: AppTheme.accent))
              : RefreshIndicator(
                  color: AppTheme.accent,
                  onRefresh: _loadPresensi,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 16),
                        _buildSummaryPills(),
                        _buildSectionHeader('Minggu Ini', 'Mei 2026'),
                        _buildPresensiGrid(),
                        _buildSectionHeader('Riwayat Kehadiran'),
                        _buildHistoryList(),
                        _buildViolationCard(firstName),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context, String firstName) {
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
          Text('Presensi $firstName', style: AppTheme.headerTitle),
        ],
      ),
    );
  }

  Widget _buildSummaryPills() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
      child: Row(
        children: [
          _buildPill('${_summary['total_hadir'] ?? 0}', 'Hadir', AppTheme.teal),
          const SizedBox(width: 8),
          _buildPill('${_summary['total_sakit'] ?? 0}', 'Sakit', AppTheme.yellow),
          const SizedBox(width: 8),
          _buildPill('${_summary['total_izin'] ?? 0}', 'Izin', AppTheme.blue),
          const SizedBox(width: 8),
          _buildPill('${_summary['total_alpha'] ?? 0}', 'Alpha', AppTheme.red),
        ],
      ),
    );
  }

  Widget _buildPill(String val, String label, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: AppTheme.cardSmDecoration,
        child: Column(
          children: [
            Text(val,
                style: TextStyle(
                    color: color, fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: -0.5)),
            const SizedBox(height: 2),
            Text(label.toUpperCase(),
                style: const TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.text3,
                    letterSpacing: 0.3)),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, [String? actionLabel]) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: AppTheme.sectionTitle),
          if (actionLabel != null) Text(actionLabel, style: AppTheme.sectionMore),
        ],
      ),
    );
  }

  Widget _buildPresensiGrid() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildDayCol('Sen', 'H', AppTheme.teal, AppTheme.tealBg, isToday: true),
          _buildDayCol('Sel', 'H', AppTheme.teal, AppTheme.tealBg),
          _buildDayCol('Rab', 'H', AppTheme.teal, AppTheme.tealBg),
          _buildDayCol('Kam', 'S', AppTheme.yellow, AppTheme.yellowBg),
          _buildDayCol('Jum', 'H', AppTheme.teal, AppTheme.tealBg),
          _buildDayCol('Sab', 'L', AppTheme.text3, AppTheme.bg2),
          _buildDayCol('Min', 'L', AppTheme.text3, AppTheme.bg2),
        ],
      ),
    );
  }

  Widget _buildDayCol(String day, String status, Color color, Color bgColor,
      {bool isToday = false}) {
    return Column(
      children: [
        Text(day.toUpperCase(),
            style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: AppTheme.text3)),
        const SizedBox(height: 4),
        Container(
          width: 32,
          height: 32,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: bgColor,
            shape: BoxShape.circle,
            border: isToday ? Border.all(color: AppTheme.accent, width: 2) : null,
          ),
          child: Text(status,
              style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w700)),
        ),
      ],
    );
  }

  Widget _buildHistoryList() {
    if (_history.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: AppTheme.cardSmDecoration,
          child: const Center(
            child: Text('Belum ada data riwayat kehadiran',
                style: TextStyle(fontSize: 12, color: AppTheme.text3)),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: _history.map((item) {
          final dateStr = item['date']?.toString() ?? '';
          final dayStr = item['day']?.toString() ?? '';
          final course = item['course']?.toString() ?? 'Mata Pelajaran';
          final teacher = item['teacher']?.toString() ?? '';
          final status = item['status']?.toString().toUpperCase() ?? 'PRESENT';

          String badgeText = 'Hadir';
          Color badgeColor = AppTheme.teal;
          Color badgeBg = AppTheme.tealBg;

          if (status == 'SICK') {
            badgeText = 'Sakit';
            badgeColor = AppTheme.yellow;
            badgeBg = AppTheme.yellowBg;
          } else if (status == 'PERMIT') {
            badgeText = 'Izin';
            badgeColor = AppTheme.blue;
            badgeBg = AppTheme.blueBg;
          } else if (status == 'ALPHA') {
            badgeText = 'Alpha';
            badgeColor = AppTheme.red;
            badgeBg = AppTheme.redBg;
          }

          final subtitle = teacher.isNotEmpty ? '$course · $teacher' : course;

          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _buildHistoryCard(
              dateStr,
              dayStr.isNotEmpty ? '$dayStr, $dateStr' : dateStr,
              subtitle,
              badgeText,
              badgeColor,
              badgeBg,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildHistoryCard(String dateShort, String dateFull, String subjects, String badge,
      Color badgeColor, Color badgeBg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: AppTheme.cardSmDecoration,
      child: Row(
        children: [
          SizedBox(
            width: 75,
            child: Text(dateShort,
                style: const TextStyle(
                    fontFamily: 'DM Mono', fontSize: 11, color: AppTheme.text3)),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(dateFull,
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                Text(subjects,
                    style: const TextStyle(fontSize: 10, color: AppTheme.text3),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: badgeBg,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('●', style: TextStyle(fontSize: 6, color: badgeColor)),
                const SizedBox(width: 3),
                Text(badge,
                    style: TextStyle(
                        fontSize: 10, fontWeight: FontWeight.w700, color: badgeColor)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildViolationCard(String firstName) {
    final hasViolation = _violationPoints > 0;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Poin Pelanggaran', style: AppTheme.sectionTitle),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: AppTheme.cardDecoration,
            child: Column(
              children: [
                Text(hasViolation ? '⚠️' : '🎉', style: const TextStyle(fontSize: 42)),
                const SizedBox(height: 8),
                Text(
                  hasViolation
                      ? '$_violationPoints Poin Pelanggaran'
                      : 'Tidak Ada Pelanggaran',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: hasViolation ? AppTheme.red : AppTheme.teal,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  hasViolation
                      ? '$firstName memiliki $_violationPoints poin pelanggaran tercatat di database.'
                      : '$firstName memiliki 0 poin pelanggaran semester ini.',
                  style: const TextStyle(fontSize: 12, color: AppTheme.text3),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
