// =============================================================================
// evaluation_controller.dart — Evaluasi Kinerja Guru
// =============================================================================
// Endpoint: GET  /api/v1/evaluations/categories
//           GET  /api/v1/evaluations/active-period
//           GET  /api/v1/evaluations/teachers/eligible
//           POST /api/v1/evaluations/submit
// =============================================================================

import 'package:dio/dio.dart';
import 'package:get/get.dart' hide Response;
import 'package:aplikasi_mobile_siswa/core/services/api_service.dart';

class EvaluationCategory {
  final String id;
  final String name;
  final String description;
  final int maxScore;

  const EvaluationCategory({
    required this.id,
    required this.name,
    required this.description,
    required this.maxScore,
  });

  factory EvaluationCategory.fromJson(Map<String, dynamic> json) {
    return EvaluationCategory(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      maxScore: json['max_score'] as int? ?? 5,
    );
  }
}

class EligibleTeacher {
  final String id;
  final String name;
  final String subject;
  final String? photoUrl;
  final bool isEvaluated;

  const EligibleTeacher({
    required this.id,
    required this.name,
    required this.subject,
    this.photoUrl,
    this.isEvaluated = false,
  });

  factory EligibleTeacher.fromJson(Map<String, dynamic> json) {
    return EligibleTeacher(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      subject: json['course']?.toString() ?? json['subject']?.toString() ?? 'Mata Pelajaran',
      photoUrl: json['photo_url']?.toString(),
      isEvaluated: json['is_graded'] as bool? ?? json['is_evaluated'] as bool? ?? false,
    );
  }
}

class EvaluationController extends GetxController {
  final isLoading = false.obs;
  final isSubmitting = false.obs;
  final categories = <EvaluationCategory>[].obs;
  final teachers = <EligibleTeacher>[].obs;
  final activePeriod = ''.obs;
  final errorMessage = ''.obs;
  final successMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchData();
  }

  List<dynamic> _extractList(dynamic data) {
    if (data is List) return data;
    if (data is Map && data['data'] is List) return data['data'] as List;
    return [];
  }

  Future<void> fetchData() async {
    isLoading.value = true;
    await Future.wait([
      fetchCategories(),
      fetchActivePeriod(),
      fetchEligibleTeachers(),
    ]);
    isLoading.value = false;
  }

  Future<void> fetchCategories() async {
    try {
      final response = await ApiService.dio.get('/evaluations/categories');
      if (response.statusCode == 200) {
        final list = _extractList(response.data);
        categories.value = list
            .map((item) =>
                EvaluationCategory.fromJson(item as Map<String, dynamic>))
            .toList();
      }
    } catch (_) {}
  }

  Future<void> fetchActivePeriod() async {
    try {
      final response = await ApiService.dio.get('/evaluations/active-period');
      if (response.statusCode == 200) {
        final data = response.data;
        if (data is Map) {
          final p = data['data'] ?? data;
          activePeriod.value = p['period']?.toString() ?? p['name']?.toString() ?? '';
        }
      }
    } catch (_) {}
  }

  Future<void> fetchEligibleTeachers() async {
    try {
      final response =
          await ApiService.dio.get('/evaluations/teachers/eligible');
      if (response.statusCode == 200) {
        final list = _extractList(response.data);
        teachers.value = list
            .map((item) =>
                EligibleTeacher.fromJson(item as Map<String, dynamic>))
            .toList();
      }
    } catch (_) {}
  }

  /// Submit evaluasi guru.
  /// [scores] adalah Map<categoryId, score>.
  Future<bool> submitEvaluation({
    required String teacherId,
    required Map<String, int> scores,
    String? comment,
  }) async {
    isSubmitting.value = true;
    errorMessage.value = '';
    successMessage.value = '';

    try {
      final response = await ApiService.dio.post(
        '/evaluations/submit',
        data: {
          'teacher_id': teacherId,
          'scores': scores,
          if (comment != null && comment.isNotEmpty) 'comment': comment,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        successMessage.value = 'Evaluasi berhasil dikirim. Terima kasih!';
        return true;
      }
      return false;
    } on DioException catch (e) {
      final msg = e.response?.data?['error']?.toString();
      errorMessage.value = msg ?? 'Gagal mengirim evaluasi.';
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }
}
