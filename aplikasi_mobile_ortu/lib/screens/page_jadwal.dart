import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../main_screen.dart';

class PageJadwal extends StatefulWidget {
  const PageJadwal({super.key});

  @override
  State<PageJadwal> createState() => _PageJadwalState();
}

class _PageJadwalState extends State<PageJadwal> {
  int _selectedDay = 0;
  final List<String> _days = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum'];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildHeader(context),
        _buildDaySelector(),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 16),
                _buildScheduleList(),
                const SizedBox(height: 16),
              ],
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () {
                   final parent = context.findAncestorStateOfType<State<MainScreen>>() as dynamic;
                   if(parent != null) parent.goBack();
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
              const Text('Jadwal Aditya', style: AppTheme.headerTitle),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.tealBg,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text('Senin', style: TextStyle(fontSize: 11, color: AppTheme.teal, fontWeight: FontWeight.w700)),
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
              onTap: () {
                setState(() {
                  _selectedDay = index;
                });
              },
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          _buildClassItem('07.30–09.00', 'Matematika', 'Budi Waluyo, S.Pd. · R.12', AppTheme.blue, false),
          const SizedBox(height: 10),
          _buildClassItem('09.15–10.45', 'Fisika', 'Sari Dewi, M.Pd. · R.08', AppTheme.teal, false),
          const SizedBox(height: 10),
          _buildBreakItem('11.00–11.30', 'Istirahat'),
          const SizedBox(height: 10),
          _buildClassItem('11.30–13.00', 'Kimia', 'Hendra Gunawan · R.Lab', AppTheme.purple, false),
          const SizedBox(height: 10),
          _buildBreakItem('13.00–13.30', 'Ishoma'),
          const SizedBox(height: 10),
          _buildClassItem('13.30–14.30', 'Bimbingan Wali Kelas', 'Budi Waluyo, S.Pd. · R.12', AppTheme.accent, false),
        ],
      ),
    );
  }

  Widget _buildClassItem(String time, String title, String subtitle, Color color, bool isBreak) {
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
                      width: 75,
                      child: Text(time, style: const TextStyle(fontFamily: 'DM Mono', fontSize: 11, color: AppTheme.text3)),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800)),
                          const SizedBox(height: 2),
                          Text(subtitle, style: const TextStyle(fontSize: 11, color: AppTheme.text3)),
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

  Widget _buildBreakItem(String time, String title) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.bg2,
        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
      ),
      clipBehavior: Clip.antiAlias,
      child: IntrinsicHeight(
        child: Row(
          children: [
            Container(
              width: 4,
              color: AppTheme.text3,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    SizedBox(
                      width: 75,
                      child: Text(time, style: const TextStyle(fontFamily: 'DM Mono', fontSize: 11, color: AppTheme.text3)),
                    ),
                    Expanded(
                      child: Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.text3)),
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
