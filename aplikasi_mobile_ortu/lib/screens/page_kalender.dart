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
  int _currentYear = 2026;
  int _currentMonth = 5;

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

  @override
  void initState() {
    super.initState();
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
      if (_currentMonth == 12) {
        _currentMonth = 1;
        _currentYear++;
      } else {
        _currentMonth++;
      }
    });
    _loadEvents();
  }

  @override
  Widget build(BuildContext context) {
    final monthLabel = '${_monthNames[_currentMonth]} $_currentYear';

    return Column(
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
                        _buildSectionHeader('Agenda $monthLabel'),
                        _buildAgendaList(),
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
          const Text('Kalender Akademik', style: AppTheme.headerTitle),
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
            icon: const Text('‹',
                style: TextStyle(fontSize: 24, color: AppTheme.text, fontWeight: FontWeight.bold)),
            onPressed: _prevMonth,
          ),
          Text(monthLabel,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.text)),
          IconButton(
            icon: const Text('›',
                style: TextStyle(fontSize: 24, color: AppTheme.text, fontWeight: FontWeight.bold)),
            onPressed: _nextMonth,
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarGrid() {
    final List<String> days = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
    final List<Map<String, dynamic>> dates = [
      {'val': '', 'type': 'empty'},
      {'val': '', 'type': 'empty'},
      {'val': '1', 'type': 'normal'},
      {'val': '2', 'type': 'normal'},
      {'val': '3', 'type': 'event'},
      {'val': '4', 'type': 'normal'},
      {'val': '5', 'type': 'normal'},
      {'val': '6', 'type': 'normal'},
      {'val': '7', 'type': 'normal'},
      {'val': '8', 'type': 'normal'},
      {'val': '9', 'type': 'normal'},
      {'val': '10', 'type': 'event'},
      {'val': '11', 'type': 'holiday'},
      {'val': '12', 'type': 'holiday'},
      {'val': '13', 'type': 'normal'},
      {'val': '14', 'type': 'normal'},
      {'val': '15', 'type': 'normal'},
      {'val': '16', 'type': 'today'},
      {'val': '17', 'type': 'event'},
      {'val': '18', 'type': 'normal'},
      {'val': '19', 'type': 'normal'},
      {'val': '20', 'type': 'event'},
      {'val': '21', 'type': 'normal'},
      {'val': '22', 'type': 'normal'},
      {'val': '23', 'type': 'event'},
      {'val': '24', 'type': 'normal'},
      {'val': '25', 'type': 'holiday'},
      {'val': '26', 'type': 'holiday'},
      {'val': '27', 'type': 'normal'},
      {'val': '28', 'type': 'normal'},
      {'val': '29', 'type': 'event'},
      {'val': '30', 'type': 'normal'},
      {'val': '31', 'type': 'normal'},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: days
                .map((day) => Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Text(day.toUpperCase(),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.text3)),
                      ),
                    ))
                .toList(),
          ),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: dates.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              crossAxisSpacing: 4,
              mainAxisSpacing: 4,
            ),
            itemBuilder: (context, index) {
              final date = dates[index];
              if (date['type'] == 'empty') {
                return const SizedBox();
              }

              Color bgColor = Colors.transparent;
              Color textColor = AppTheme.text;
              FontWeight weight = FontWeight.w600;

              if (date['type'] == 'today') {
                bgColor = AppTheme.accent;
                textColor = Colors.white;
                weight = FontWeight.w900;
              } else if (date['type'] == 'event') {
                textColor = AppTheme.teal;
                weight = FontWeight.w800;
              } else if (date['type'] == 'holiday') {
                textColor = AppTheme.red;
              }

              return Container(
                decoration: BoxDecoration(
                  color: bgColor,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  date['val'],
                  style: TextStyle(fontSize: 12, fontWeight: weight, color: textColor),
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
          const SizedBox(width: 12),
          _buildLegendItem(AppTheme.teal, 'Ada event'),
          const SizedBox(width: 12),
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
        Text(label,
            style: const TextStyle(
                fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.text2)),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      child: Text(title, style: AppTheme.sectionTitle),
    );
  }

  Widget _buildAgendaList() {
    if (_events.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: AppTheme.cardDecoration,
          child: const Center(
            child: Text('Tidak ada agenda acara pada bulan ini',
                style: TextStyle(fontSize: 12, color: AppTheme.text3)),
          ),
        ),
      );
    }

    final colors = [
      AppTheme.blue,
      AppTheme.teal,
      AppTheme.accent,
      AppTheme.purple,
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: AppTheme.cardDecoration,
        child: Column(
          children: List.generate(_events.length, (index) {
            final ev = _events[index];
            final title = ev['title']?.toString() ?? 'Acara Sekolah';
            final date = ev['event_date']?.toString() ?? 'Mei 2026';
            final badge = ev['category']?.toString() ?? 'Kegiatan';
            final color = colors[index % colors.length];

            return Column(
              children: [
                if (index > 0) const Divider(height: 1, color: AppTheme.border),
                _buildAgendaItem(color, title, date, badge, color, color.withOpacity(0.12)),
              ],
            );
          }),
        ),
      ),
    );
  }

  Widget _buildAgendaItem(
      Color dotColor, String title, String date, String badge, Color badgeColor, Color badgeBg) {
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
                Text(title,
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.text)),
                const SizedBox(height: 2),
                Text(date,
                    style: const TextStyle(
                        fontSize: 11, color: AppTheme.text3, fontFamily: 'DM Mono')),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: badgeBg,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(badge,
                style:
                    TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: badgeColor)),
          ),
        ],
      ),
    );
  }
}
