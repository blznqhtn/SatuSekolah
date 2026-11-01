import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../main_screen.dart';
import '../services/api_service.dart';

class PageKalender extends StatefulWidget {
  const PageKalender({super.key});

  @override
  State<PageKalender> createState() => _PageKalenderState();
}

class _PageKalenderState extends State<PageKalender> {
  late int _currentYear;
  late int _currentMonth;
  int? _selectedDay;

  bool _isLoading = true;
  List<Map<String, dynamic>> _events = [];

  final List<String> _monthNames = [
    '',
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember'
  ];

  final List<String> _weekDays = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _currentYear = now.year;
    _currentMonth = now.month;
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    setState(() {
      _isLoading = true;
    });

    final events = await ApiService.getCalendarEvents(_currentYear, _currentMonth);
    if (mounted) {
      setState(() {
        _events = events;
        _isLoading = false;
      });
    }
  }

  void _prevMonth() {
    setState(() {
      _selectedDay = null;
      if (_currentMonth == 1) {
        _currentMonth = 12;
        _currentYear--;
      } else {
        _currentMonth--;
      }
    });
    _loadEvents();
  }

  void _nextMonth() {
    setState(() {
      _selectedDay = null;
      if (_currentMonth == 12) {
        _currentMonth = 1;
        _currentYear++;
      } else {
        _currentMonth++;
      }
    });
    _loadEvents();
  }

  void _jumpToToday() {
    final now = DateTime.now();
    setState(() {
      _currentYear = now.year;
      _currentMonth = now.month;
      _selectedDay = now.day;
    });
    _loadEvents();
  }

  bool _dayHasEvent(int day) {
    for (final ev in _events) {
      final dateStr = ev['event_date']?.toString() ?? '';
      final parsed = DateTime.tryParse(dateStr);
      if (parsed != null) {
        if (parsed.year == _currentYear && parsed.month == _currentMonth && parsed.day == day) {
          return true;
        }
      } else if (dateStr.contains('-')) {
        final parts = dateStr.split('-');
        if (parts.length >= 3) {
          final y = int.tryParse(parts[0]);
          final m = int.tryParse(parts[1]);
          final d = int.tryParse(parts[2].split('T').first.split(' ').first);
          if (y == _currentYear && m == _currentMonth && d == day) {
            return true;
          }
        }
      }
    }
    return false;
  }

  bool _dayIsHoliday(int day) {
    final dt = DateTime(_currentYear, _currentMonth, day);
    if (dt.weekday == DateTime.sunday) return true;

    for (final ev in _events) {
      final cat = ev['category']?.toString().toUpperCase() ?? '';
      if (cat == 'LIBUR' || cat == 'HOLIDAY') {
        final dateStr = ev['event_date']?.toString() ?? '';
        final parsed = DateTime.tryParse(dateStr);
        if (parsed != null &&
            parsed.year == _currentYear &&
            parsed.month == _currentMonth &&
            parsed.day == day) {
          return true;
        }
      }
    }
    return false;
  }

  List<Map<String, dynamic>> _getEventsForDay(int day) {
    return _events.where((ev) {
      final dateStr = ev['event_date']?.toString() ?? '';
      final parsed = DateTime.tryParse(dateStr);
      if (parsed != null) {
        return parsed.year == _currentYear && parsed.month == _currentMonth && parsed.day == day;
      } else if (dateStr.contains('-')) {
        final parts = dateStr.split('-');
        if (parts.length >= 3) {
          final y = int.tryParse(parts[0]);
          final m = int.tryParse(parts[1]);
          final d = int.tryParse(parts[2].split('T').first.split(' ').first);
          return y == _currentYear && m == _currentMonth && d == day;
        }
      }
      return false;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final monthLabel = '${_monthNames[_currentMonth]} $_currentYear';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildHeader(context),
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator(color: AppTheme.accent))
              : RefreshIndicator(
                  color: AppTheme.accent,
                  onRefresh: _loadEvents,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 16),
                        _buildCalendarNav(monthLabel),
                        _buildCalendarGrid(),
                        _buildLegend(),
                        _buildSectionHeader(monthLabel),
                        _buildAgendaList(monthLabel),
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
      width: double.infinity,
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
              const Text('Kalender Akademik', style: AppTheme.headerTitle),
            ],
          ),
          GestureDetector(
            onTap: _jumpToToday,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: AppTheme.accentBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.accent.withOpacity(0.3)),
              ),
              child: const Text(
                'Hari Ini',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.accent,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarNav(String monthLabel) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Text(
              '‹',
              style: TextStyle(fontSize: 26, color: AppTheme.text, fontWeight: FontWeight.bold),
            ),
            onPressed: _prevMonth,
          ),
          Text(
            monthLabel,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.text),
          ),
          IconButton(
            icon: const Text(
              '›',
              style: TextStyle(fontSize: 26, color: AppTheme.text, fontWeight: FontWeight.bold),
            ),
            onPressed: _nextMonth,
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarGrid() {
    final now = DateTime.now();

    // Hari pertama dalam bulan ini: 1 = Senin, ..., 7 = Minggu
    final firstDayWeekday = DateTime(_currentYear, _currentMonth, 1).weekday;
    final emptyLeadingDays = firstDayWeekday - 1;

    // Total hari dalam bulan ini (mendukung tahun kabisat otomatis)
    final totalDaysInMonth = DateTime(_currentYear, _currentMonth + 1, 0).day;
    final totalCells = emptyLeadingDays + totalDaysInMonth;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          // Nama-nama hari: Sen, Sel, Rab, Kam, Jum, Sab, Min
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: _weekDays.map((day) {
              final isSun = day == 'Min';
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Text(
                    day.toUpperCase(),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: isSun ? AppTheme.red.withOpacity(0.8) : AppTheme.text3,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 6),

          // Grid tanggal dinamis sesuai kalender riil
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: totalCells,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              crossAxisSpacing: 4,
              mainAxisSpacing: 4,
              childAspectRatio: 1.0,
            ),
            itemBuilder: (context, index) {
              if (index < emptyLeadingDays) {
                return const SizedBox();
              }

              final dayNumber = index - emptyLeadingDays + 1;
              final isToday = now.year == _currentYear &&
                  now.month == _currentMonth &&
                  now.day == dayNumber;
              final isSelected = _selectedDay == dayNumber;
              final hasEvent = _dayHasEvent(dayNumber);
              final isHoliday = _dayIsHoliday(dayNumber);

              Color bgColor = Colors.transparent;
              Color textColor = AppTheme.text;
              FontWeight weight = FontWeight.w600;
              Border? border;

              if (isToday) {
                bgColor = AppTheme.accent;
                textColor = Colors.white;
                weight = FontWeight.w900;
              } else if (isSelected) {
                bgColor = AppTheme.accentBg;
                textColor = AppTheme.accent;
                border = Border.all(color: AppTheme.accent, width: 2);
                weight = FontWeight.w900;
              } else if (hasEvent) {
                textColor = AppTheme.teal;
                weight = FontWeight.w800;
              } else if (isHoliday) {
                textColor = AppTheme.red;
                weight = FontWeight.w700;
              }

              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedDay = _selectedDay == dayNumber ? null : dayNumber;
                  });
                },
                child: Center(
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: bgColor,
                      shape: BoxShape.circle,
                      border: border,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      dayNumber.toString(),
                      style: TextStyle(fontSize: 13, fontWeight: weight, color: textColor),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLegend() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      child: Row(
        children: [
          _buildLegendItem(AppTheme.accent, 'Hari ini'),
          const SizedBox(width: 14),
          _buildLegendItem(AppTheme.teal, 'Ada event'),
          const SizedBox(width: 14),
          _buildLegendItem(AppTheme.red, 'Libur'),
        ],
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.text2),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String monthLabel) {
    final title = _selectedDay != null
        ? 'Agenda $_selectedDay $monthLabel'
        : 'Agenda $monthLabel';

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: AppTheme.sectionTitle),
          if (_selectedDay != null)
            GestureDetector(
              onTap: () {
                setState(() {
                  _selectedDay = null;
                });
              },
              child: const Text('Lihat Semua', style: AppTheme.sectionMore),
            ),
        ],
      ),
    );
  }

  Widget _buildAgendaList(String monthLabel) {
    List<Map<String, dynamic>> displayedEvents = _events;

    if (_selectedDay != null) {
      displayedEvents = _getEventsForDay(_selectedDay!);
    }

    if (displayedEvents.isEmpty) {
      final msg = _selectedDay != null
          ? 'Tidak ada agenda kegiatan pada tanggal $_selectedDay $monthLabel'
          : 'Tidak ada agenda kegiatan pada bulan $monthLabel';

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Container(
          padding: const EdgeInsets.all(22),
          decoration: AppTheme.cardDecoration,
          child: Center(
            child: Text(
              msg,
              style: const TextStyle(fontSize: 12, color: AppTheme.text3),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    final colors = [
      AppTheme.blue,
      AppTheme.teal,
      AppTheme.accent,
      AppTheme.purple,
      AppTheme.yellow,
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: AppTheme.cardDecoration,
        child: Column(
          children: List.generate(displayedEvents.length, (index) {
            final ev = displayedEvents[index];
            final title = ev['title']?.toString() ?? 'Acara Sekolah';
            final rawDate = ev['event_date']?.toString() ?? '';
            final badge = ev['category']?.toString() ?? 'Kegiatan';
            final color = colors[index % colors.length];

            String formattedDate = rawDate;
            final parsed = DateTime.tryParse(rawDate);
            if (parsed != null) {
              formattedDate = '${parsed.day} ${_monthNames[parsed.month]} ${parsed.year}';
            }

            return Column(
              children: [
                if (index > 0) const Divider(height: 1, color: AppTheme.border),
                _buildAgendaItem(
                  color,
                  title,
                  formattedDate,
                  badge,
                  color,
                  color.withOpacity(0.12),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }

  Widget _buildAgendaItem(
    Color dotColor,
    String title,
    String date,
    String badge,
    Color badgeColor,
    Color badgeBg,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: dotColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.text),
                ),
                const SizedBox(height: 2),
                Text(
                  date,
                  style: const TextStyle(fontSize: 11, color: AppTheme.text3, fontFamily: 'DM Mono'),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: badgeBg,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              badge,
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: badgeColor),
            ),
          ),
        ],
      ),
    );
  }
}
