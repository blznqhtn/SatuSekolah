// =============================================================================
// dashboard_controller.dart — Fetch data Dashboard dari Backend
// =============================================================================
// Endpoint: GET /api/v1/dashboard/summary
//           GET /api/v1/dashboard/activities
// =============================================================================

import 'package:dio/dio.dart';
import 'package:get/get.dart' hide Response;
import 'package:aplikasi_mobile_siswa/core/services/api_service.dart';

class DashboardSummary {
  final int totalStudents;
  final double attendanceRate;
  final String greeting;
  final String userName;
  final String? userPhotoUrl;

  const DashboardSummary({
    required this.totalStudents,
    required this.attendanceRate,
    required this.greeting,
    required this.userName,
    this.userPhotoUrl,
  });

  factory DashboardSummary.fromJson(Map<String, dynamic> json) {
    return DashboardSummary(
      totalStudents: json['total_students'] as int? ?? 0,
      attendanceRate: (json['attendance_rate'] as num?)?.toDouble() ?? 0.0,
      greeting: json['greeting']?.toString() ?? 'Selamat Datang',
      userName: json['user_name']?.toString() ?? 'Siswa',
      userPhotoUrl: json['user_photo_url']?.toString(),
    );
  }
}

class ActivityItem {
  final String title;
  final String description;
  final String time;
  final String type; // 'attendance', 'academic', 'notification', etc.

  const ActivityItem({
    required this.title,
    required this.description,
    required this.time,
    required this.type,
  });

  factory ActivityItem.fromJson(Map<String, dynamic> json) {
    return ActivityItem(
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      time: json['time']?.toString() ?? '',
      type: json['type']?.toString() ?? 'general',
    );
  }
}

class AnnouncementItem {
  final String id;
  final String title;
  final String content;
  final String type;
  final String? eventDate;
  final String createdAt;

  const AnnouncementItem({
    required this.id,
    required this.title,
    required this.content,
    required this.type,
    required this.createdAt,
    this.eventDate,
  });

  factory AnnouncementItem.fromJson(Map<String, dynamic> json) {
    return AnnouncementItem(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      content: json['content']?.toString() ?? '',
      type: json['type']?.toString() ?? 'INFO',
      createdAt: json['created_at']?.toString() ?? '',
      eventDate: json['event_date']?.toString(),
    );
  }
}

class DashboardController extends GetxController {
  // Reactive state
  final isLoadingSummary = false.obs;
  final isLoadingActivities = false.obs;
  final isLoadingAnnouncements = false.obs;
  final summary = Rxn<DashboardSummary>();
  final activities = <ActivityItem>[].obs;
  final announcements = <AnnouncementItem>[].obs;
  final errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchAll();
  }

  /// Fetch semua data dashboard sekaligus.
  Future<void> fetchAll() async {
    await Future.wait([
      fetchSummary(),
      fetchActivities(),
      fetchAnnouncements(),
    ]);
  }

  /// Ambil ringkasan dashboard dari backend.
  Future<void> fetchSummary() async {
    isLoadingSummary.value = true;
    errorMessage.value = '';
    try {
      final response = await ApiService.dio.get('/dashboard/summary');
      if (response.statusCode == 200) {
        final data = response.data;
        final map = (data is Map && data['data'] is Map)
            ? data['data'] as Map<String, dynamic>
            : (data is Map ? data as Map<String, dynamic> : <String, dynamic>{});
        summary.value = DashboardSummary.fromJson(map);
      }
    } on DioException catch (e) {
      errorMessage.value = _parseError(e);
    } finally {
      isLoadingSummary.value = false;
    }
  }

  /// Ambil daftar aktivitas terbaru.
  Future<void> fetchActivities() async {
    isLoadingActivities.value = true;
    try {
      final response = await ApiService.dio.get('/dashboard/activities');
      if (response.statusCode == 200) {
        final data = response.data;
        List<dynamic> list;
        if (data is List) {
          list = data;
        } else if (data is Map && data['data'] is List) {
          list = data['data'] as List;
        } else {
          list = [];
        }
        activities.value = list
            .map((item) => ActivityItem.fromJson(item as Map<String, dynamic>))
            .toList();
      }
    } on DioException catch (_) {
      // Silent fail untuk aktivitas
    } finally {
      isLoadingActivities.value = false;
    }
  }

  /// Ambil pengumuman sekolah untuk banner dan info.
  Future<void> fetchAnnouncements() async {
    isLoadingAnnouncements.value = true;
    try {
      final response = await ApiService.dio.get('/academic/announcements');
      if (response.statusCode == 200) {
        final data = response.data;
        List<dynamic> list;
        if (data is List) {
          list = data;
        } else if (data is Map && data['data'] is List) {
          list = data['data'] as List;
        } else {
          list = [];
        }
        announcements.value = list
            .map((item) => AnnouncementItem.fromJson(item as Map<String, dynamic>))
            .toList();
      }
    } catch (_) {}
    isLoadingAnnouncements.value = false;
  }

  String _parseError(DioException e) {
    if (e.type == DioExceptionType.connectionError) {
      return 'Tidak bisa terhubung ke server.';
    }
    return e.response?.data?['error']?.toString() ?? 'Gagal memuat data.';
  }
}
