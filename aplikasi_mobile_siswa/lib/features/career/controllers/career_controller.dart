// =============================================================================
// career_controller.dart — Fetch Lowongan Karir & PKL dari Backend
// =============================================================================
// Endpoint: GET /api/v1/career/vacancies/local
//           GET /api/v1/career/vacancies/public
//           POST /api/v1/career/vacancies/:id/apply
//           GET /api/v1/career/applications/my
// =============================================================================

import 'package:dio/dio.dart';
import 'package:get/get.dart' hide Response;
import 'package:aplikasi_mobile_siswa/core/services/api_service.dart';

class JobVacancy {
  final String id;
  final String title;
  final String company;
  final String location;
  final String type; // 'PKL', 'Kerja', etc.
  final String description;
  final String deadline;
  final String? logoUrl;
  final bool hasApplied;

  const JobVacancy({
    required this.id,
    required this.title,
    required this.company,
    required this.location,
    required this.type,
    required this.description,
    required this.deadline,
    this.logoUrl,
    this.hasApplied = false,
  });

  factory JobVacancy.fromJson(Map<String, dynamic> json) {
    return JobVacancy(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      company: json['company']?.toString() ??
          json['company_name']?.toString() ??
          'Mitra Industri',
      location: json['location']?.toString() ??
          json['company_location']?.toString() ??
          json['arrangement']?.toString() ??
          'Indonesia',
      type: json['type']?.toString() ?? 'Lowongan',
      description: json['description']?.toString() ?? '',
      deadline: json['deadline']?.toString() ?? json['expired_at']?.toString() ?? '',
      logoUrl: json['logo_url']?.toString() ??
          json['company_logo']?.toString() ??
          '',
      hasApplied: json['has_applied'] as bool? ?? false,
    );
  }
}

class CareerController extends GetxController {
  final isLoading = false.obs;
  final isApplying = false.obs;
  final localVacancies = <JobVacancy>[].obs;
  final publicVacancies = <JobVacancy>[].obs;
  final myApplications = <JobVacancy>[].obs;
  final errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchAll();
  }

  Future<void> fetchAll() async {
    await Future.wait([
      fetchLocalVacancies(),
      fetchPublicVacancies(),
      fetchMyApplications(),
    ]);
  }

  /// Lowongan dari sekolah sendiri (tenant saat ini).
  Future<void> fetchLocalVacancies() async {
    isLoading.value = true;
    try {
      final response = await ApiService.dio.get('/career/vacancies/local');
      if (response.statusCode == 200) {
        localVacancies.value = _parseList(response.data);
      }
    } on DioException catch (e) {
      errorMessage.value = _parseError(e);
    } finally {
      isLoading.value = false;
    }
  }

  /// Lowongan publik lintas sekolah.
  Future<void> fetchPublicVacancies() async {
    try {
      final response = await ApiService.dio.get('/career/vacancies/public');
      if (response.statusCode == 200) {
        publicVacancies.value = _parseList(response.data);
      }
    } catch (_) {}
  }

  /// Lamaranku.
  Future<void> fetchMyApplications() async {
    try {
      final response = await ApiService.dio.get('/career/applications/my');
      if (response.statusCode == 200) {
        myApplications.value = _parseList(response.data);
      }
    } catch (_) {}
  }

  /// Lamar lowongan.
  Future<bool> applyJob(String vacancyId) async {
    isApplying.value = true;
    errorMessage.value = '';
    try {
      final response = await ApiService.dio.post(
        '/career/vacancies/$vacancyId/apply',
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        await fetchMyApplications();
        return true;
      }
      return false;
    } on DioException catch (e) {
      errorMessage.value = e.response?.data?['error']?.toString() ??
          'Gagal melamar. Coba lagi.';
      return false;
    } finally {
      isApplying.value = false;
    }
  }

  List<JobVacancy> _parseList(dynamic data) {
    if (data is List) {
      return data
          .map((item) => JobVacancy.fromJson(item as Map<String, dynamic>))
          .toList();
    } else if (data is Map && data['data'] is List) {
      return (data['data'] as List)
          .map((item) => JobVacancy.fromJson(item as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  String _parseError(DioException e) {
    if (e.type == DioExceptionType.connectionError) {
      return 'Tidak bisa terhubung ke server.';
    }
    return e.response?.data?['error']?.toString() ?? 'Terjadi kesalahan.';
  }
}
