// =============================================================================
// academic_activity_controller.dart — Controller Perizinan, BK, & Ekstrakulikuler
// =============================================================================
// Endpoint:
//   Permits:          POST /academic/permits, GET /academic/permits/my
//   Counseling:       POST /academic/counseling/book, GET /academic/counseling/my
//   Extracurriculars: GET /academic/extracurriculars, POST /academic/extracurriculars/:id/register, GET /academic/extracurriculars/my
// =============================================================================

import 'package:dio/dio.dart';
import 'package:get/get.dart' hide Response;
import 'package:aplikasi_mobile_siswa/core/services/api_service.dart';

// =============================================================================
// MODELS
// =============================================================================

class PermitModel {
  final String id;
  final String type; // SICK, FAMILY, DISPENSATION, OTHER
  final String reason;
  final String startDate;
  final String endDate;
  final String status; // PENDING, APPROVED, REJECTED
  final String? reviewerNote;
  final String? attachmentUrl;
  final String createdAt;

  const PermitModel({
    required this.id,
    required this.type,
    required this.reason,
    required this.startDate,
    required this.endDate,
    required this.status,
    this.reviewerNote,
    this.attachmentUrl,
    required this.createdAt,
  });

  factory PermitModel.fromJson(Map<String, dynamic> json) {
    return PermitModel(
      id: json['id']?.toString() ?? '',
      type: json['type']?.toString() ?? 'SICK',
      reason: json['reason']?.toString() ?? '',
      startDate: json['start_date']?.toString() ?? '',
      endDate: json['end_date']?.toString() ?? '',
      status: json['status']?.toString() ?? 'PENDING',
      reviewerNote: json['reviewer_note']?.toString(),
      attachmentUrl: json['attachment_url']?.toString(),
      createdAt: json['created_at']?.toString() ?? '',
    );
  }

  String get typeLabel {
    switch (type.toUpperCase()) {
      case 'SICK':
        return 'Sakit';
      case 'FAMILY':
        return 'Izin Keluarga';
      case 'DISPENSATION':
        return 'Dispensasi';
      default:
        return 'Izin Lainnya';
    }
  }

  String get statusLabel {
    switch (status.toUpperCase()) {
      case 'APPROVED':
        return 'Disetujui Walas';
      case 'REJECTED':
        return 'Ditolak';
      default:
        return 'Menunggu Persetujuan';
    }
  }
}

class CounselingModel {
  final String id;
  final String topic;
  final String description;
  final String preferredDate;
  final String? scheduledAt;
  final String status; // PENDING, SCHEDULED, COMPLETED, CANCELLED
  final String? counselorNotes;
  final String createdAt;

  const CounselingModel({
    required this.id,
    required this.topic,
    required this.description,
    required this.preferredDate,
    this.scheduledAt,
    required this.status,
    this.counselorNotes,
    required this.createdAt,
  });

  factory CounselingModel.fromJson(Map<String, dynamic> json) {
    return CounselingModel(
      id: json['id']?.toString() ?? '',
      topic: json['topic']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      preferredDate: json['preferred_date']?.toString() ?? '',
      scheduledAt: json['scheduled_at']?.toString(),
      status: json['status']?.toString() ?? 'PENDING',
      counselorNotes: json['counselor_notes']?.toString(),
      createdAt: json['created_at']?.toString() ?? '',
    );
  }

  String get statusLabel {
    switch (status.toUpperCase()) {
      case 'SCHEDULED':
        return 'Dijadwalkan';
      case 'COMPLETED':
        return 'Selesai';
      case 'CANCELLED':
        return 'Dibatalkan';
      default:
        return 'Menunggu Konfirmasi';
    }
  }
}

class ExtracurricularModel {
  final String id;
  final String name;
  final String description;
  final String category; // Wajib, Pilihan
  final String scheduleDay;
  final String scheduleTime;
  final String location;
  final String coachName;
  final int maxParticipants;
  final int currentParticipants;

  const ExtracurricularModel({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.scheduleDay,
    required this.scheduleTime,
    required this.location,
    required this.coachName,
    required this.maxParticipants,
    required this.currentParticipants,
  });

  factory ExtracurricularModel.fromJson(Map<String, dynamic> json) {
    final rawSchedule = json['schedule']?.toString() ?? json['schedule_day']?.toString() ?? 'Reguler';
    return ExtracurricularModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      category: json['category']?.toString() ?? 'Pilihan',
      scheduleDay: rawSchedule,
      scheduleTime: json['schedule_time']?.toString() ?? '',
      location: json['location']?.toString() ?? 'Area Sekolah',
      coachName: json['coach_name']?.toString() ?? '',
      maxParticipants: json['max_members'] as int? ?? json['max_participants'] as int? ?? 30,
      currentParticipants: json['total_member'] as int? ?? json['current_participants'] as int? ?? 0,
    );
  }
}

class ExtracurricularRegistrationModel {
  final String id;
  final String extracurricularId;
  final String status; // PENDING, APPROVED, REJECTED
  final String registeredAt;
  final ExtracurricularModel? extracurricular;

  const ExtracurricularRegistrationModel({
    required this.id,
    required this.extracurricularId,
    required this.status,
    required this.registeredAt,
    this.extracurricular,
  });

  factory ExtracurricularRegistrationModel.fromJson(Map<String, dynamic> json) {
    return ExtracurricularRegistrationModel(
      id: json['id']?.toString() ?? '',
      extracurricularId: json['extracurricular_id']?.toString() ?? '',
      status: json['status']?.toString() ?? 'PENDING',
      registeredAt: json['registered_at']?.toString() ?? '',
      extracurricular: json['extracurricular'] != null
          ? ExtracurricularModel.fromJson(json['extracurricular'] as Map<String, dynamic>)
          : null,
    );
  }
}

// =============================================================================
// CONTROLLER
// =============================================================================

class AcademicActivityController extends GetxController {
  // State Permits
  final isLoadingPermits = false.obs;
  final permits = <PermitModel>[].obs;
  final permitError = ''.obs;

  // State Counseling
  final isLoadingCounseling = false.obs;
  final counselingSessions = <CounselingModel>[].obs;
  final counselingError = ''.obs;

  // State Extracurriculars
  final isLoadingExtras = false.obs;
  final extracurriculars = <ExtracurricularModel>[].obs;
  final myRegistrations = <ExtracurricularRegistrationModel>[].obs;
  final extrasError = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchMyPermits();
    fetchMyCounselingSessions();
    fetchExtracurriculars();
    fetchMyRegistrations();
  }

  // ==========================================
  // PERMIT METHODS
  // ==========================================

  Future<void> fetchMyPermits() async {
    isLoadingPermits.value = true;
    permitError.value = '';
    try {
      final response = await ApiService.dio.get('/academic/permits/my');
      if (response.statusCode == 200) {
        final list = response.data['data'] as List<dynamic>? ?? [];
        permits.value = list
            .map((item) => PermitModel.fromJson(item as Map<String, dynamic>))
            .toList();
      }
    } on DioException catch (e) {
      permitError.value = e.response?.data?['error']?.toString() ?? 'Gagal memuat izin';
    } finally {
      isLoadingPermits.value = false;
    }
  }

  Future<bool> submitPermit({
    required String type,
    required String reason,
    required String startDate,
    required String endDate,
    String? attachmentUrl,
  }) async {
    try {
      final response = await ApiService.dio.post(
        '/academic/permits',
        data: {
          'type': type,
          'reason': reason,
          'start_date': startDate,
          'end_date': endDate,
          'attachment_url': attachmentUrl ?? '',
        },
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        await fetchMyPermits();
        return true;
      }
      return false;
    } on DioException catch (e) {
      Get.snackbar(
        'Gagal Mengajukan Izin',
        e.response?.data?['error']?.toString() ?? 'Terjadi kesalahan sistem',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }
  }

  // ==========================================
  // COUNSELING METHODS
  // ==========================================

  Future<void> fetchMyCounselingSessions() async {
    isLoadingCounseling.value = true;
    counselingError.value = '';
    try {
      final response = await ApiService.dio.get('/academic/counseling/my');
      if (response.statusCode == 200) {
        final list = response.data['data'] as List<dynamic>? ?? [];
        counselingSessions.value = list
            .map((item) => CounselingModel.fromJson(item as Map<String, dynamic>))
            .toList();
      }
    } on DioException catch (e) {
      counselingError.value = e.response?.data?['error']?.toString() ?? 'Gagal memuat sesi BK';
    } finally {
      isLoadingCounseling.value = false;
    }
  }

  Future<bool> bookCounselingSession({
    required String topic,
    required String description,
    required String preferredDate,
  }) async {
    try {
      final response = await ApiService.dio.post(
        '/academic/counseling/book',
        data: {
          'topic': topic,
          'description': description,
          'preferred_date': preferredDate,
        },
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        await fetchMyCounselingSessions();
        return true;
      }
      return false;
    } on DioException catch (e) {
      Get.snackbar(
        'Gagal Mengajukan Konseling',
        e.response?.data?['error']?.toString() ?? 'Terjadi kesalahan sistem',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }
  }

  // ==========================================
  // EXTRACURRICULAR METHODS
  // ==========================================

  Future<void> fetchExtracurriculars() async {
    isLoadingExtras.value = true;
    extrasError.value = '';
    try {
      final response = await ApiService.dio.get('/academic/extracurriculars');
      if (response.statusCode == 200) {
        final list = response.data['data'] as List<dynamic>? ?? [];
        extracurriculars.value = list
            .map((item) => ExtracurricularModel.fromJson(item as Map<String, dynamic>))
            .toList();
      }
    } on DioException catch (e) {
      extrasError.value = e.response?.data?['error']?.toString() ?? 'Gagal memuat ekskul';
    } finally {
      isLoadingExtras.value = false;
    }
  }

  Future<void> fetchMyRegistrations() async {
    try {
      final response = await ApiService.dio.get('/academic/extracurriculars/my');
      if (response.statusCode == 200) {
        final list = response.data['data'] as List<dynamic>? ?? [];
        myRegistrations.value = list
            .map((item) => ExtracurricularRegistrationModel.fromJson(item as Map<String, dynamic>))
            .toList();
      }
    } catch (_) {}
  }

  Future<bool> registerExtracurricular(String extraId) async {
    try {
      final response = await ApiService.dio.post('/academic/extracurriculars/$extraId/register');
      if (response.statusCode == 200 || response.statusCode == 201) {
        await Future.wait([
          fetchExtracurriculars(),
          fetchMyRegistrations(),
        ]);
        return true;
      }
      return false;
    } on DioException catch (e) {
      Get.snackbar(
        'Pendaftaran Gagal',
        e.response?.data?['error']?.toString() ?? 'Gagal mendaftar ekskul',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }
  }
}
