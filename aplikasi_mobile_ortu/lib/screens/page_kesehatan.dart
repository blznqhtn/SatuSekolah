import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../main_screen.dart';
import '../services/api_service.dart';

class PageKesehatan extends StatefulWidget {
  const PageKesehatan({super.key});

  @override
  State<PageKesehatan> createState() => _PageKesehatanState();
}

class _PageKesehatanState extends State<PageKesehatan> {
  bool _isLoading = true;
  String _childName = 'Anak';
  String _childId = '';

  Map<String, dynamic> _healthSummary = {
    'height': 172.0,
    'weight': 65.0,
    'bmi': 22.0,
    'status': 'Normal & Sehat',
    'blood_pressure': '110/70',
    'last_checkup': '14 Mei 2026',
    'temperature': 36.5,
  };
  List<Map<String, dynamic>> _checkups = [];

  @override
  void initState() {
    super.initState();
    _loadHealthData();
  }

  Future<void> _loadHealthData() async {
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
      final summary = await ApiService.getHealthSummary(_childId);
      final checkups = await ApiService.getHealthCheckups(_childId);

      if (mounted) {
        setState(() {
          if (summary != null) _healthSummary = summary;
          _checkups = checkups;
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
    final statusText = _healthSummary['status']?.toString() ?? 'Sehat';
    final weight = (_healthSummary['weight'] as num?)?.toStringAsFixed(0) ?? '65';
    final height = (_healthSummary['height'] as num?)?.toStringAsFixed(0) ?? '172';
    final temp = (_healthSummary['temperature'] as num?)?.toStringAsFixed(1) ?? '36.5';
    final bp = _healthSummary['blood_pressure']?.toString() ?? '110/70';
    final lastCheck = _healthSummary['last_checkup']?.toString() ?? '14 Mei 2026';

    return Column(
      children: [
        _buildHeader(context, firstName, statusText),
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator(color: AppTheme.accent))
              : RefreshIndicator(
                  color: AppTheme.accent,
                  onRefresh: _loadHealthData,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 16),
                        _buildVitalGrid(weight, height, temp, bp, lastCheck),
                        _buildTrenCard(weight),
                        _buildSectionHeader('Riwayat Pemeriksaan UKS'),
                        _buildRiwayatList(),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context, String firstName, String statusText) {
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
              Text('Kesehatan $firstName', style: AppTheme.headerTitle),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: AppTheme.tealBg,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('●', style: TextStyle(fontSize: 6, color: AppTheme.teal)),
                const SizedBox(width: 3),
                Text(statusText,
                    style: const TextStyle(
                        fontSize: 10, fontWeight: FontWeight.w700, color: AppTheme.teal)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVitalGrid(
      String weight, String height, String temp, String bp, String lastCheck) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1.3,
        children: [
          _buildVitalCard('⚖️', 'Berat Badan', weight, 'kg', AppTheme.blue, lastCheck, 22),
          _buildVitalCard('📏', 'Tinggi Badan', height, 'cm', AppTheme.teal, lastCheck, 22),
          _buildVitalCard('🌡️', 'Suhu Tubuh', temp, '°C', AppTheme.teal, lastCheck, 22),
          _buildVitalCard('💉', 'Tekanan Darah', bp, '', AppTheme.accent, lastCheck, 18),
        ],
      ),
    );
  }

  Widget _buildVitalCard(String icon, String label, String value, String unit, Color color,
      String date, double valSize) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: AppTheme.cardSmDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(icon, style: const TextStyle(fontSize: 22)),
          const SizedBox(height: 8),
          Text(label.toUpperCase(),
              style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.text3,
                  letterSpacing: 0.3)),
          const SizedBox(height: 2),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(value,
                  style: TextStyle(
                      fontSize: valSize,
                      fontWeight: FontWeight.w900,
                      color: color,
                      letterSpacing: -0.5)),
              if (unit.isNotEmpty) ...[
                const SizedBox(width: 4),
                Text(unit,
                    style: const TextStyle(
                        fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.text3)),
              ],
            ],
          ),
          const Spacer(),
          Text('Cek: $date',
              style:
                  const TextStyle(fontSize: 10, color: AppTheme.text3, fontFamily: 'DM Mono')),
        ],
      ),
    );
  }

  Widget _buildTrenCard(String currentWeight) {
    final cur = double.tryParse(currentWeight) ?? 65.0;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: AppTheme.cardDecoration,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('📈 Tren Berat Badan',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800)),
            const SizedBox(height: 12),
            _buildProgressItem('Maret 2026', '${(cur - 2).toStringAsFixed(0)} kg', 0.79, AppTheme.blue),
            const SizedBox(height: 12),
            _buildProgressItem('April 2026', '${(cur - 1).toStringAsFixed(0)} kg', 0.81, AppTheme.blue),
            const SizedBox(height: 12),
            _buildProgressItem('Mei 2026', '$currentWeight kg', 0.83, AppTheme.teal),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressItem(String label, String value, double percent, Color color) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label,
                style: const TextStyle(
                    fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.text2)),
            Text(value,
                style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.text,
                    fontFamily: 'DM Mono')),
          ],
        ),
        const SizedBox(height: 5),
        Container(
          height: 8,
          decoration: BoxDecoration(
            color: AppTheme.bg2,
            borderRadius: BorderRadius.circular(10),
          ),
          alignment: Alignment.centerLeft,
          child: FractionallySizedBox(
            widthFactor: percent,
            child: Container(
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
      child: Text(title, style: AppTheme.sectionTitle),
    );
  }

  Widget _buildRiwayatList() {
    if (_checkups.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: AppTheme.cardSmDecoration,
          child: const Center(
            child: Text('Belum ada riwayat rekam medis UKS',
                style: TextStyle(fontSize: 12, color: AppTheme.text3)),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: _checkups.map((checkup) {
          final date = checkup['date']?.toString() ?? 'Pemeriksaan';
          final title = checkup['complaint']?.toString() ?? 'Pemeriksaan Rutin';
          final examiner = checkup['examiner_name']?.toString() ?? 'Petugas PMR / Dokter UKS';

          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _buildRiwayatCard(date, title, examiner),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildRiwayatCard(String date, String title, String examiner) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: AppTheme.cardSmDecoration,
      child: Row(
        children: [
          const Text('🏥', style: TextStyle(fontSize: 24)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text('$date · $examiner',
                    style: const TextStyle(
                        fontSize: 10, color: AppTheme.text3, fontFamily: 'DM Mono'),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: AppTheme.tealBg,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Text('●', style: TextStyle(fontSize: 6, color: AppTheme.teal)),
                SizedBox(width: 3),
                Text('Sehat',
                    style:
                        TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppTheme.teal)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
