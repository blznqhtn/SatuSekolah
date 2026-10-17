// =============================================================================
// violation_controller.dart — Fetch Riwayat Pelanggaran dari Backend
// =============================================================================
// Endpoint: GET /api/v1/violations/history
// =============================================================================

import 'package:dio/dio.dart';
import 'package:get/get.dart' hide Response;
import 'package:aplikasi_mobile_siswa/core/services/api_service.dart';

class ViolationRecord {
  final String id;
  final String title;
  final String description;
  final int points;
  final String date;
  final String? punishment;
  final String? teacherName;

  const ViolationRecord({
    required this.id,
    required this.title,
    required this.description,
    required this.points,
    required this.date,
    this.punishment,
    this.teacherName,
  });

  factory ViolationRecord.fromJson(Map<String, dynamic> json) {
    return ViolationRecord(
      id: json['id']?.toString() ?? '',
      title: json['violation_type']?.toString() ??
          json['title']?.toString() ??
          json['notes']?.toString() ??
          'Pelanggaran Tata Tertib',
      description: json['description']?.toString() ?? json['notes']?.toString() ?? '',
      points: json['points'] as int? ?? json['points_applied'] as int? ?? 0,
      date: json['created_at']?.toString() ?? json['date']?.toString() ?? '',
      punishment: json['punishment']?.toString(),
      teacherName: json['teacher_name']?.toString(),
    );
  }
}

class ViolationController extends GetxController {
  final isLoading = false.obs;
  final records = <ViolationRecord>[].obs;
  final totalPoints = 0.obs;
  final statusLabel = ''.obs;
  final errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchHistory();
  }

  Future<void> fetchHistory() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final response = await ApiService.dio.get('/violations/history');
      if (response.statusCode == 200) {
        final data = response.data;

        // Backend mengembalikan list langsung atau wrapped dalam object
        List<dynamic> list;
        if (data is List) {
          list = data;
        } else if (data is Map && data['violations'] is List) {
          list = data['violations'] as List;
          totalPoints.value = data['total_points'] as int? ?? 0;
        } else if (data is Map && data['data'] is List) {
          list = data['data'] as List;
          totalPoints.value = data['total_points'] as int? ?? 0;
        } else {
          list = [];
          if (data is Map && data['total_points'] != null) {
            totalPoints.value = data['total_points'] as int;
          }
        }

        records.value = list
            .map((item) =>
                ViolationRecord.fromJson(item as Map<String, dynamic>))
            .toList();

        // Hitung total poin jika belum dikirim backend
        if (totalPoints.value == 0 && records.isNotEmpty) {
          totalPoints.value =
              records.fold(0, (sum, r) => sum + r.points);
        }

        // Tentukan status berdasarkan total poin
        _updateStatus();
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError) {
        errorMessage.value = 'Tidak bisa terhubung ke server.';
      } else {
        errorMessage.value =
            e.response?.data?['error']?.toString() ?? 'Gagal memuat data.';
      }
    } finally {
      isLoading.value = false;
    }
  }

  void _updateStatus() {
    final pts = totalPoints.value;
    if (pts == 0) {
      statusLabel.value = 'Status: Bersih ✅';
    } else if (pts <= 20) {
      statusLabel.value = 'Status: Peringatan Ringan';
    } else if (pts <= 50) {
      statusLabel.value = 'Status: Peringatan Sedang';
    } else if (pts <= 80) {
      statusLabel.value = 'Status: Peringatan Keras';
    } else {
      statusLabel.value = 'Status: Skorsing';
    }
  }
}
