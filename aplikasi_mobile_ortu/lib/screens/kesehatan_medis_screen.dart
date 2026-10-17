import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';

import 'package:dio/dio.dart';
import 'package:get_storage/get_storage.dart';
import '../services/api_client.dart';

class KesehatanMedisScreen extends StatefulWidget {
  const KesehatanMedisScreen({super.key});

  @override
  State<KesehatanMedisScreen> createState() => _KesehatanMedisScreenState();
}

class _KesehatanMedisScreenState extends State<KesehatanMedisScreen> {
  bool _isLoading = true;
  Map<String, dynamic>? _history;

  @override
  void initState() {
    super.initState();
    _fetchHistoryData();
  }

  Future<void> _fetchHistoryData() async {
    try {
      final box = GetStorage();
      final childId = box.read('active_child_id') ?? 'child-uuid-123';

      final response = await ApiClient().dio.get('/health/student/$childId/history');
      if (response.statusCode == 200) {
        setState(() {
          _history = response.data['data'];
          _isLoading = false;
        });
      } else {
        _useDummyData();
      }
    } catch (e) {
      print("API Error (Medical History): $e. Menggunakan data lokal.");
      _useDummyData();
    }
  }

  void _useDummyData() {
    if (!mounted) return;
    setState(() {
      _history = {
        'blood_type': 'O',
        'allergies': 'Alergi Udang, Debu',
        'chronic_diseases': 'Asma ringan',
        'special_conditions': 'Membutuhkan inhaler saat olahraga berat'
      };
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        title: Text('Riwayat Medis & Alergi', style: AppTextStyles.h3.copyWith(fontSize: 16)),
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppColors.text),
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoCard(
                  'Golongan Darah', 
                  _history?['blood_type']?.toString().isNotEmpty == true ? _history!['blood_type'] : 'Belum Ada Data', 
                  '🩸', 
                  AppColors.red
                ),
                const SizedBox(height: 16),
                _buildInfoCard(
                  'Riwayat Alergi', 
                  _history?['allergies']?.toString().isNotEmpty == true ? _history!['allergies'] : 'Tidak ada riwayat alergi', 
                  '🤧', 
                  AppColors.orange
                ),
                const SizedBox(height: 16),
                _buildInfoCard(
                  'Penyakit Bawaan / Kronis', 
                  _history?['chronic_diseases']?.toString().isNotEmpty == true ? _history!['chronic_diseases'] : 'Tidak ada penyakit bawaan', 
                  '🤒', 
                  AppColors.blue
                ),
                const SizedBox(height: 16),
                _buildInfoCard(
                  'Kondisi Khusus', 
                  _history?['special_conditions']?.toString().isNotEmpty == true ? _history!['special_conditions'] : 'Tidak ada kondisi khusus', 
                  '⚠️', 
                  AppColors.teal
                ),
              ],
            ),
          ),
    );
  }

  Widget _buildInfoCard(String title, String content, String emoji, Color iconColor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Text(emoji, style: const TextStyle(fontSize: 24)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: AppColors.text3,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  content,
                  style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.text,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
