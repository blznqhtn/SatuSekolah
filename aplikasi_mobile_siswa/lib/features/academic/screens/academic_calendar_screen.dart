import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:aplikasi_mobile_siswa/core/services/api_service.dart';

class CalendarEventItem {
  final String id;
  final String title;
  final String description;
  final String eventDate;
  final String category;

  CalendarEventItem({
    required this.id,
    required this.title,
    required this.description,
    required this.eventDate,
    required this.category,
  });

  factory CalendarEventItem.fromJson(Map<String, dynamic> json) {
    return CalendarEventItem(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      eventDate: json['event_date']?.toString() ?? '',
      category: json['category']?.toString() ?? 'KEGIATAN',
    );
  }
}

class AcademicCalendarScreen extends StatefulWidget {
  const AcademicCalendarScreen({Key? key}) : super(key: key);

  @override
  State<AcademicCalendarScreen> createState() => _AcademicCalendarScreenState();
}

class _AcademicCalendarScreenState extends State<AcademicCalendarScreen> {
  DateTime _currentMonth = DateTime(2026, 10);
  bool _isLoading = false;
  List<CalendarEventItem> _events = [];

  @override
  void initState() {
    super.initState();
    _fetchEvents();
  }

  Future<void> _fetchEvents() async {
    setState(() => _isLoading = true);
    try {
      final response = await ApiService.dio.get('/calendar/month/${_currentMonth.year}/${_currentMonth.month}');
      if (response.statusCode == 200) {
        final data = response.data;
        List<dynamic> list = [];
        if (data is List) {
          list = data;
        } else if (data is Map && data['data'] is List) {
          list = data['data'] as List;
        }
        setState(() {
          _events = list.map((item) => CalendarEventItem.fromJson(item as Map<String, dynamic>)).toList();
        });
      }
    } catch (_) {
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _prevMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1);
    });
    _fetchEvents();
  }

  void _nextMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1);
    });
    _fetchEvents();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));

    final daysInMonth = DateTime(_currentMonth.year, _currentMonth.month + 1, 0).day;
    const indoMonths = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    final monthName = '${indoMonths[_currentMonth.month - 1]} ${_currentMonth.year}';

    // Set of days with events
    final Set<int> eventDays = {};
    for (var ev in _events) {
      try {
        final d = DateTime.parse(ev.eventDate);
        if (d.month == _currentMonth.month && d.year == _currentMonth.year) {
          eventDays.add(d.day);
        }
      } catch (_) {}
    }

    final today = DateTime.now();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF0F172A), size: 20),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Kalender Akademik',
          style: TextStyle(
            color: Color(0xFF0F172A),
            fontWeight: FontWeight.bold,
            fontSize: 20,
            letterSpacing: -0.5,
          ),
        ),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        color: const Color(0xFF055D97),
        onRefresh: _fetchEvents,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(onPressed: _prevMonth, icon: const Icon(Icons.chevron_left_rounded)),
                        Text(monthName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        IconButton(onPressed: _nextMonth, icon: const Icon(Icons.chevron_right_rounded)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 7,
                        mainAxisSpacing: 8,
                        crossAxisSpacing: 8,
                      ),
                      itemCount: daysInMonth,
                      itemBuilder: (context, index) {
                        final dayNum = index + 1;
                        final isEvent = eventDays.contains(dayNum);
                        final isToday = dayNum == today.day && _currentMonth.month == today.month && _currentMonth.year == today.year;
                        return Container(
                          decoration: BoxDecoration(
                            color: isToday ? const Color(0xFF055D97) : (isEvent ? const Color(0xFFEFF6FF) : Colors.transparent),
                            shape: BoxShape.circle,
                            border: isEvent ? Border.all(color: const Color(0xFF055D97).withOpacity(0.4), width: 1.5) : null,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            '$dayNum',
                            style: TextStyle(
                              color: isToday ? Colors.white : (isEvent ? const Color(0xFF055D97) : const Color(0xFF64748B)),
                              fontWeight: isToday || isEvent ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                'Agenda Bulan Ini',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 16),
              if (_isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: CircularProgressIndicator(color: Color(0xFF055D97)),
                  ),
                )
              else if (_events.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: const Center(
                    child: Text(
                      'Tidak ada agenda khusus bulan ini.',
                      style: TextStyle(color: Color(0xFF64748B), fontSize: 14),
                    ),
                  ),
                )
              else
                ..._events.map((ev) => _buildAgendaItem(ev.eventDate, ev.title, ev.description)).toList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAgendaItem(String date, String title, String desc) {
    String formattedDate = date;
    try {
      final parsed = DateTime.parse(date);
      const indoMonths = [
        'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
        'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
      ];
      formattedDate = '${parsed.day} ${indoMonths[parsed.month - 1]} ${parsed.year}';
    } catch (_) {}

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.event_note_rounded, color: Color(0xFF055D97)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F172A), fontSize: 15),
                ),
                if (desc.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    desc,
                    style: const TextStyle(color: Color(0xFF475569), fontSize: 12),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 4),
                Text(
                  formattedDate,
                  style: const TextStyle(color: Color(0xFF64748B), fontSize: 12),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
