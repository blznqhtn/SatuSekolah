import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../main_screen.dart';
import '../services/api_service.dart';

class PageJadwal extends StatefulWidget {
  const PageJadwal({super.key});

  @override
  State<PageJadwal> createState() => _PageJadwalState();
}

class _PageJadwalState extends State<PageJadwal> {
  int _selectedDay = 0; // 0=Senin, 1=Selasa, 2=Rabu, 3=Kamis, 4=Jumat
  final List<String> _days = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum'];
  final List<String> _fullDays = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat'];

  bool _isLoading = true;
  String _childName = 'Anak';
  String _childId = '';
  List<Map<String, dynamic>> _schedules = [];

  @override
  void initState() {
    super.initState();
    _loadSchedule();
  }

  Future<void> _loadSchedule() async {
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

    // dayOfWeek: 1=Senin, 2=Selasa, ...
    final dayOfWeek = _selectedDay + 1;
    final list = await ApiService.getSchedules(dayOfWeek, childId: _childId);

    if (mounted) {
      setState(() {
        _schedules = list;
        _isLoading = false;
      });
    }
  }

  void _onDaySelect(int index) {
    if (_selectedDay != index) {
      setState(() {
        _selectedDay = index;
      });
      _loadSchedule();
    }
  }

  @override
  Widget build(BuildContext context) {
    final firstName = _childName.split(' ').first;
    final dayName = _fullDays[_selectedDay];

    return Column(
      children: [
        _buildHeader(context, firstName, dayName),
        _buildDaySelector(),
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator(color: AppTheme.accent))
              : RefreshIndicator(
                  color: AppTheme.accent,
                  onRefresh: _loadSchedule,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 16),
                        _buildScheduleList(),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context, String firstName, String dayName) {
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
              Text('Jadwal $firstName', style: AppTheme.headerTitle),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.tealBg,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(dayName,
                style: const TextStyle(
                    fontSize: 11, color: AppTheme.teal, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  Widget _buildDaySelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: AppTheme.white,
        border: Border(bottom: BorderSide(color: AppTheme.border)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(_days.length, (index) {
            final isSelected = _selectedDay == index;
            return GestureDetector(
              onTap: () => _onDaySelect(index),
              child: Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: isSelected ? AppTheme.accent : AppTheme.bg2,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _days[index],
                  style: TextStyle(
                    color: isSelected ? Colors.white : AppTheme.text2,
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w700,
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildScheduleList() {
    if (_schedules.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: AppTheme.cardSmDecoration,
          child: const Center(
            child: Text('Tidak ada jadwal pelajaran pada hari ini',
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
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: List.generate(_schedules.length, (index) {
          final item = _schedules[index];
          final start = item['start_time']?.toString() ?? '08:00';
          final end = item['end_time']?.toString() ?? '09:30';
          final time = '$start–$end';
          final title = item['course_name']?.toString() ?? 'Mata Pelajaran';
          final teacher = item['staff_name']?.toString() ?? 'Guru Pengajar';
          final room = item['room']?.toString() ?? 'Kelas';
          final sub = '$teacher · $room';
          final color = colors[index % colors.length];

          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _buildClassItem(time, title, sub, color),
          );
        }),
      ),
    );
  }

  Widget _buildClassItem(String time, String title, String subtitle, Color color) {
    return Container(
      decoration: AppTheme.cardSmDecoration.copyWith(
        color: AppTheme.white,
      ),
      clipBehavior: Clip.antiAlias,
      child: IntrinsicHeight(
        child: Row(
          children: [
            Container(
              width: 4,
              color: color,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    SizedBox(
                      width: 80,
                      child: Text(time,
                          style: const TextStyle(
                              fontFamily: 'DM Mono', fontSize: 11, color: AppTheme.text3)),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(title,
                              style:
                                  const TextStyle(fontSize: 13, fontWeight: FontWeight.w800)),
                          const SizedBox(height: 2),
                          Text(subtitle,
                              style:
                                  const TextStyle(fontSize: 11, color: AppTheme.text3),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
