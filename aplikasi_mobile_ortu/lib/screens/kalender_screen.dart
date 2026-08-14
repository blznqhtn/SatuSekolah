import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../models/activity_model.dart';
import '../widgets/app_badge.dart';
import '../widgets/section_header.dart';
import '../services/api_client.dart';

class KalenderScreen extends StatefulWidget {
  const KalenderScreen({super.key});

  @override
  State<KalenderScreen> createState() => _KalenderScreenState();
}

class _KalenderScreenState extends State<KalenderScreen> {
  DateTime _currentMonth = DateTime(DateTime.now().year, DateTime.now().month, 1);
  int? _selectedDay;
  bool _isLoading = false;
  List<dynamic> _apiEvents = [];

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now().year == _currentMonth.year && DateTime.now().month == _currentMonth.month 
      ? DateTime.now().day 
      : null;
    _fetchEvents();
  }

  Future<void> _fetchEvents() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final year = _currentMonth.year;
      final month = _currentMonth.month;
      final response = await ApiClient().dio.get('/calendar/month/$year/$month');
      if (mounted) {
        setState(() {
          _apiEvents = response.data['data'] ?? [];
        });
      }
    } catch (e) {
      debugPrint('Error fetching calendar: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _nextMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1, 1);
      _selectedDay = null; // reset filter on month change
    });
    _fetchEvents();
  }

  void _prevMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1, 1);
      _selectedDay = null; // reset filter on month change
    });
    _fetchEvents();
  }

  // Get events on a specific day
  List<dynamic> _getEventsForDay(int day) {
    final targetDate = DateFormat('yyyy-MM-dd').format(DateTime(_currentMonth.year, _currentMonth.month, day));
    return _apiEvents.where((e) {
      final ed = e['event_date'];
      if (ed == null) return false;
      return ed.toString().startsWith(targetDate);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          _buildCalHeader(),
          const SizedBox(height: 12),
          _buildCalGrid(),
          const SizedBox(height: 12),
          _buildLegend(),
          const SizedBox(height: 16),
          SectionHeader(title: _selectedDay == null ? 'Agenda Bulan Ini' : 'Agenda Tanggal $_selectedDay'),
          const SizedBox(height: 10),
          _isLoading 
            ? const Center(child: Padding(
                padding: EdgeInsets.all(32.0),
                child: CircularProgressIndicator(color: AppColors.teal),
              ))
            : _buildAgenda(),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildCalHeader() {
    final monthName = DateFormat('MMMM yyyy', 'id_ID').format(_currentMonth);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: _prevMonth,
            child: const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text('‹', style: TextStyle(fontSize: 24, color: AppColors.text3)),
            ),
          ),
          Text(monthName, style: AppTextStyles.h2),
          GestureDetector(
            onTap: _nextMonth,
            child: const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text('›', style: TextStyle(fontSize: 24, color: AppColors.text3)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalGrid() {
    const dayLabels = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
    
    int daysInMonth = DateTime(_currentMonth.year, _currentMonth.month + 1, 0).day;
    int firstDayWeekday = _currentMonth.weekday; // 1 = Monday, 7 = Sunday
    
    List<Widget> dayWidgets = [];
    
    // Empty slots before 1st day
    for (int i = 1; i < firstDayWeekday; i++) {
      dayWidgets.add(const Expanded(child: SizedBox(height: 36)));
    }
    
    // Actual days
    for (int i = 1; i <= daysInMonth; i++) {
      dayWidgets.add(Expanded(child: _buildCalDay(i)));
    }
    
    // Fill remaining slots
    while (dayWidgets.length % 7 != 0) {
      dayWidgets.add(const Expanded(child: SizedBox(height: 36)));
    }
    
    List<Widget> rows = [];
    for (int i = 0; i < dayWidgets.length; i += 7) {
      rows.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Row(
            children: dayWidgets.sublist(i, i + 7),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          // Day labels
          Row(
            children: dayLabels.map((d) => Expanded(
              child: Center(
                child: Text(
                  d,
                  style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: AppColors.text3,
                  ),
                ),
              ),
            )).toList(),
          ),
          const SizedBox(height: 8),
          ...rows,
        ],
      ),
    );
  }

  Widget _buildCalDay(int day) {
    final now = DateTime.now();
    bool isToday = (now.year == _currentMonth.year && now.month == _currentMonth.month && now.day == day);
    bool isSelected = _selectedDay == day;
    
    final dayEvents = _getEventsForDay(day);
    bool hasEvent = dayEvents.isNotEmpty;
    bool hasHoliday = dayEvents.any((e) => e['category'] == 'LIBUR');
    bool hasExam = dayEvents.any((e) => e['category'] == 'UJIAN');

    Color fg = AppColors.text;
    Color? bg;

    if (hasHoliday) {
      fg = AppColors.red;
    } else if (hasExam) {
      fg = AppColors.blue;
    } else if (hasEvent) {
      fg = AppColors.teal;
    }

    if (isSelected) {
      bg = AppColors.border;
    }
    
    if (isToday) {
      bg = AppColors.accent;
      fg = Colors.white;
    }

    return GestureDetector(
      onTap: () {
        setState(() {
          if (_selectedDay == day) {
            _selectedDay = null; // deselect
          } else {
            _selectedDay = day;
          }
        });
      },
      child: Container(
        height: 36,
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: bg, 
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '$day',
              style: TextStyle(
                fontFamily: 'Nunito',
                fontSize: 12,
                fontWeight: isToday ? FontWeight.w900 : FontWeight.w600,
                color: fg,
              ),
            ),
            if (hasEvent && !isToday)
              Container(
                margin: const EdgeInsets.only(top: 2),
                width: 4,
                height: 4,
                decoration: BoxDecoration(
                  color: fg,
                  shape: BoxShape.circle,
                ),
              )
          ],
        ),
      ),
    );
  }

  Widget _buildLegend() {
    final items = [
      (AppColors.accent, 'Hari ini'),
      (AppColors.teal, 'Ada Event'),
      (AppColors.blue, 'Ujian'),
      (AppColors.red, 'Libur'),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Wrap(
        spacing: 16,
        runSpacing: 8,
        children: items.map((item) => Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(color: item.$1, shape: BoxShape.circle),
            ),
            const SizedBox(width: 6),
            Text(
              item.$2,
              style: const TextStyle(
                fontFamily: 'Nunito',
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.text2,
              ),
            ),
          ],
        )).toList(),
      ),
    );
  }

  Widget _buildAgenda() {
    List<dynamic> filteredEvents = _apiEvents;
    if (_selectedDay != null) {
      filteredEvents = _getEventsForDay(_selectedDay!);
    }

    if (filteredEvents.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Container(
          padding: const EdgeInsets.all(24),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(18),
          ),
          child: const Text('Tidak ada agenda', style: TextStyle(color: AppColors.text3, fontFamily: 'Nunito')),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
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
          children: filteredEvents.asMap().entries.map((entry) {
            final i = entry.key;
            final event = entry.value;
            final category = event['category'] ?? 'KEGIATAN';
            Color bulletColor = AppColors.teal;
            BadgeVariant badgeVar = BadgeVariant.green;
            
            if (category == 'UJIAN') { bulletColor = AppColors.blue; badgeVar = BadgeVariant.blue; }
            else if (category == 'LIBUR') { bulletColor = AppColors.red; badgeVar = BadgeVariant.red; }
            else if (category == 'PENGUMUMAN') { bulletColor = AppColors.orange; badgeVar = BadgeVariant.orange; }
            else if (category == 'PEMBAYARAN') { bulletColor = AppColors.accent; badgeVar = BadgeVariant.orange; }

            String title = event['title'] ?? 'Agenda';
            String dateStr = event['event_date'] ?? '';
            String displayDate = dateStr;
            try {
              if (dateStr.isNotEmpty) {
                 DateTime d = DateTime.parse(dateStr);
                 displayDate = DateFormat('dd MMM yyyy', 'id_ID').format(d);
              }
            } catch (_) {}

            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                border: i < filteredEvents.length - 1
                    ? const Border(bottom: BorderSide(color: AppColors.border))
                    : null,
              ),
              child: Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      color: bulletColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title, style: AppTextStyles.bodyBold),
                        Text(displayDate, style: AppTextStyles.caption),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  AppBadge(label: category, variant: badgeVar),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}