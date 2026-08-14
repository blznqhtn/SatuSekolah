import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';

import 'package:dio/dio.dart';
import 'package:get_storage/get_storage.dart';
import '../services/api_client.dart';
import 'kesehatan_medis_screen.dart';

class KesehatanScreen extends StatefulWidget {
  const KesehatanScreen({super.key});

  @override
  State<KesehatanScreen> createState() => _KesehatanScreenState();
}

class _KesehatanScreenState extends State<KesehatanScreen> {
  bool _isLoading = true;
  
  Map<String, dynamic>? _summary;
  List<dynamic> _checkups = [];

  @override
  void initState() {
    super.initState();
    _fetchKesehatanData();
  }

  Future<void> _fetchKesehatanData() async {
    try {
      final box = GetStorage();
      final childId = box.read('active_child_id') ?? 'child-uuid-123';

      final responseSummary = await ApiClient().dio.get('/health/student/$childId/summary');
      final responseCheckups = await ApiClient().dio.get('/health/student/$childId/checkups');
      
      if (responseSummary.statusCode == 200 && responseCheckups.statusCode == 200) {
        setState(() {
          _summary = responseSummary.data['data'];
          _checkups = responseCheckups.data['data'] ?? [];
          _isLoading = false;
        });
      } else {
        _useDummyData();
      }
    } catch (e) {
      print("API Error (Kesehatan): $e. Menggunakan data lokal.");
      _useDummyData();
    }
  }

  void _useDummyData() {
    if (!mounted) return;
    setState(() {
      _summary = {
        'latest_checkup_date': '2026-05-14T00:00:00Z',
        'weight': 65.0,
        'height': 172.0,
        'temperature': 36.5,
        'blood_pressure': '120/80',
        'bmi': 21.9,
        'status_gizi': 'Normal',
        'trends': [
          {'date': '2026-03-14', 'weight': 63.0, 'height': 171.0},
          {'date': '2026-04-14', 'weight': 64.0, 'height': 171.5},
          {'date': '2026-05-14', 'weight': 65.0, 'height': 172.0},
        ]
      };
      _checkups = [
        {
          'date': '2026-05-14T10:00:00Z',
          'diagnosis': 'Pemeriksaan Rutin',
          'examiner_name': 'Petugas UKS',
          'treatment': 'Tidak ada',
          'notes': 'Siswa Sehat'
        }
      ];
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        title: Text('Kesehatan Anak (UKS)', style: AppTextStyles.h3.copyWith(fontSize: 16)),
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppColors.text),
        actions: [
          IconButton(
            icon: const Icon(Icons.history_edu, color: AppColors.blue),
            tooltip: 'Riwayat Medis',
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const KesehatanMedisScreen()));
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            _buildBMIAndStatus(),
            const SizedBox(height: 16),
            _buildSummaryGrid(),
            const SizedBox(height: 24),
            _buildTrenCard(),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text('Riwayat Kunjungan UKS', style: AppTextStyles.h3),
            ),
            const SizedBox(height: 16),
            _buildHistoryList(),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildBMIAndStatus() {
    double bmi = 0;
    if (_summary?['bmi'] is num) bmi = (_summary!['bmi'] as num).toDouble();
    String status = _summary?['status_gizi'] ?? '-';
    
    Color statusColor = AppColors.green;
    if (status == 'Kurang Gizi') statusColor = AppColors.orange;
    if (status == 'Kelebihan Berat Badan' || status == 'Obesitas') statusColor = AppColors.red;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Column(
              children: [
                const Text(
                  'BMI / IMT',
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.text3,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  bmi.toStringAsFixed(1),
                  style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: AppColors.text,
                  ),
                ),
              ],
            ),
            Container(width: 1, height: 40, color: AppColors.border),
            Column(
              children: [
                const Text(
                  'Status Gizi',
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.text3,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryGrid() {
    String bb = _summary?['weight']?.toString() ?? '0';
    String tb = _summary?['height']?.toString() ?? '0';
    String suhu = _summary?['temperature']?.toString() ?? '0';
    String td = _summary?['blood_pressure']?.toString() ?? '-';
    
    String lastCheck = '-';
    if (_summary?['latest_checkup_date'] != null) {
      DateTime dt = DateTime.parse(_summary!['latest_checkup_date']);
      lastCheck = '${dt.day}/${dt.month}/${dt.year}';
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.15,
        children: [
          _buildStatCard('Berat Badan', bb, 'kg', '⚖️', AppColors.blue, lastCheck),
          _buildStatCard('Tinggi Badan', tb, 'cm', '📏', AppColors.teal, lastCheck),
          _buildStatCard('Suhu Tubuh', suhu, '°C', '🌡️', AppColors.orange, lastCheck),
          _buildStatCard('Tensi Darah', td, '', '💉', AppColors.accent, lastCheck),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, String unit, String emoji, Color textColor, String lastCheck) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
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
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(height: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title.toUpperCase(),
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: AppColors.text3,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    value,
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      color: textColor,
                      letterSpacing: -1,
                      height: 1.0,
                    ),
                  ),
                  if (unit.isNotEmpty) ...[
                    const SizedBox(width: 4),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 2),
                      child: Text(
                        unit,
                        style: const TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.text3,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Cek: $lastCheck',
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.text3,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTrenCard() {
    final trends = _summary?['trends'] as List<dynamic>? ?? [];
    if (trends.isEmpty) return const SizedBox();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
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
          Row(
            children: [
              const Text('📈', style: TextStyle(fontSize: 18)),
              const SizedBox(width: 8),
              Text('Tren Berat Badan', style: AppTextStyles.h3),
            ],
          ),
          const SizedBox(height: 24),
          ...trends.map((t) {
            double weight = 0;
            if (t['weight'] is num) weight = (t['weight'] as num).toDouble();
            
            // simple progress relative to max 100kg for UI purpose
            double progress = weight / 100.0;
            if (progress > 1.0) progress = 1.0;

            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _buildTrenItem(t['date'] ?? '-', '${weight.toStringAsFixed(1)} kg', progress, AppColors.blue),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildTrenItem(String month, String value, double progress, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              month,
              style: const TextStyle(
                fontFamily: 'Nunito',
                fontSize: 13,
                color: AppColors.text2,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                fontFamily: 'Nunito',
                fontSize: 13,
                color: AppColors.text,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          height: 10,
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.bg2,
            borderRadius: BorderRadius.circular(5),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: progress,
            child: Container(
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(5),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHistoryList() {
    if (_checkups.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Text('Belum ada riwayat kunjungan.', style: TextStyle(color: AppColors.text3)),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: _checkups.map((item) {
          String tgl = '-';
          if (item['date'] != null) {
            DateTime dt = DateTime.parse(item['date']);
            tgl = '${dt.day}/${dt.month}/${dt.year} ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
          }
          
          String diagnosis = item['diagnosis'] ?? 'Pemeriksaan Rutin';
          if (diagnosis.isEmpty) diagnosis = 'Pemeriksaan Rutin';

          String petugas = item['examiner_name'] ?? 'Petugas UKS';
          String treatment = item['treatment'] ?? '';
          if (treatment.isEmpty) treatment = 'Tidak ada tindakan';

          return Container(
            margin: const EdgeInsets.only(bottom: 14),
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
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
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppColors.redBg,
                        shape: BoxShape.circle,
                      ),
                      child: const Text('🏥', style: TextStyle(fontSize: 20)),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(diagnosis, style: AppTextStyles.bodyBold),
                          const SizedBox(height: 4),
                          Text(
                            '$tgl · $petugas',
                            style: const TextStyle(
                              fontFamily: 'Nunito',
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.text3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Divider(height: 1, color: AppColors.border),
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.medical_services_outlined, size: 16, color: AppColors.text2),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        treatment,
                        style: const TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 12,
                          color: AppColors.text2,
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
