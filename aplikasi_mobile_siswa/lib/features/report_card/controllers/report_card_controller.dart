// =============================================================================
// report_card_controller.dart — Fetch Rapor Siswa dari Backend
// =============================================================================
// Endpoint: GET /api/v1/academic/report-cards/student/:studentId
//           GET /api/v1/academic/report-cards/student/:studentId/semesters
// =============================================================================

import 'package:dio/dio.dart';
import 'package:get/get.dart' hide Response;
import 'package:get_storage/get_storage.dart';
import 'package:aplikasi_mobile_siswa/core/services/api_service.dart';

class SubjectGrade {
  final String subject;
  final double dailyScore;
  final double midtermScore;
  final double finalScore;
  final double average;
  final String grade;

  const SubjectGrade({
    required this.subject,
    required this.dailyScore,
    required this.midtermScore,
    required this.finalScore,
    required this.average,
    required this.grade,
  });

  factory SubjectGrade.fromJson(Map<String, dynamic> json) {
    final finalScore = (json['final_score'] as num?)?.toDouble() ??
        (json['average'] as num?)?.toDouble() ??
        0.0;
    return SubjectGrade(
      subject: json['subject']?.toString() ??
          json['course_name']?.toString() ??
          'Mata Pelajaran',
      dailyScore: (json['daily_score'] as num?)?.toDouble() ?? finalScore,
      midtermScore: (json['midterm_score'] as num?)?.toDouble() ?? finalScore,
      finalScore: finalScore,
      average: (json['average'] as num?)?.toDouble() ??
          (json['achievement_percentage'] as num?)?.toDouble() ??
          finalScore,
      grade: json['grade']?.toString() ?? json['predicate']?.toString() ?? 'B',
    );
  }
}

class ReportCard {
  final String id;
  final String studentName;
  final String className;
  final int semester;
  final String academicYear;
  final List<SubjectGrade> grades;
  final double gpa;
  final String? teacherNote;
  final int rank;
  final int totalStudents;

  const ReportCard({
    required this.id,
    required this.studentName,
    required this.className,
    required this.semester,
    required this.academicYear,
    required this.grades,
    required this.gpa,
    this.teacherNote,
    required this.rank,
    required this.totalStudents,
  });

  factory ReportCard.fromJson(Map<String, dynamic> json) {
    final summary = json['summary'] as Map<String, dynamic>?;
    final subjects = json['subjects'] as List<dynamic>? ??
        json['grades'] as List<dynamic>? ??
        [];

    final gradeList = subjects
        .map((g) => SubjectGrade.fromJson(g as Map<String, dynamic>))
        .toList();

    final gpa = (summary?['average_score'] as num?)?.toDouble() ??
        (json['gpa'] as num?)?.toDouble() ??
        (json['average_score'] as num?)?.toDouble() ??
        0.0;

    final rank = summary?['class_rank'] as int? ??
        json['rank'] as int? ??
        1;

    final academicYear = summary?['academic_year']?.toString() ??
        json['academic_year']?.toString() ??
        '2025/2026';

    final teacherNote = summary?['homeroom_notes']?.toString() ??
        json['teacher_note']?.toString();

    return ReportCard(
      id: json['id']?.toString() ?? '',
      studentName: json['student_name']?.toString() ?? '',
      className: json['class_name']?.toString() ?? 'XII RPL 1',
      semester: json['semester'] as int? ?? 1,
      academicYear: academicYear,
      grades: gradeList,
      gpa: gpa,
      teacherNote: teacherNote,
      rank: rank,
      totalStudents: json['total_students'] as int? ?? 32,
    );
  }
}

class SemesterOption {
  final String termId;
  final String termName;
  final String academicYear;
  final bool isActive;

  const SemesterOption({
    required this.termId,
    required this.termName,
    required this.academicYear,
    this.isActive = false,
  });

  String get label {
    if (termName.isNotEmpty && academicYear.isNotEmpty) {
      return '$termName $academicYear';
    }
    return termName.isNotEmpty ? termName : 'Semester Ganjil 2025/2026';
  }

  factory SemesterOption.fromJson(Map<String, dynamic> json) {
    return SemesterOption(
      termId: json['term_id']?.toString() ?? json['id']?.toString() ?? '',
      termName: json['term_name']?.toString() ?? json['name']?.toString() ?? 'Semester Ganjil',
      academicYear: json['academic_year']?.toString() ?? json['year']?.toString() ?? '2025/2026',
      isActive: json['is_active'] as bool? ?? false,
    );
  }
}

class ReportCardController extends GetxController {
  final _storage = GetStorage();

  final isLoading = false.obs;
  final reportCard = Rxn<ReportCard>();
  final semesters = <SemesterOption>[].obs;
  final selectedTermId = ''.obs;
  final errorMessage = ''.obs;

  String get _studentId {
    final fromStorage = _storage.read<Map>('user_data')?['id']?.toString();
    if (fromStorage != null && fromStorage.isNotEmpty) return fromStorage;
    try {
      final authData = _storage.read<Map>('auth_user')?['id']?.toString();
      if (authData != null && authData.isNotEmpty) return authData;
    } catch (_) {}
    return '';
  }

  @override
  void onInit() {
    super.onInit();
    fetchSemesters();
  }

  /// Ambil daftar semester yang tersedia.
  Future<void> fetchSemesters() async {
    if (_studentId.isEmpty) return;
    isLoading.value = true;

    try {
      final response = await ApiService.dio
          .get('/academic/report-cards/student/$_studentId/semesters');
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

        semesters.value = list.map((item) {
          if (item is Map<String, dynamic>) {
            return SemesterOption.fromJson(item);
          } else if (item is Map) {
            return SemesterOption.fromJson(Map<String, dynamic>.from(item));
          }
          final str = item.toString();
          return SemesterOption(termId: str, termName: str, academicYear: '');
        }).toList();

        if (semesters.isNotEmpty) {
          final active = semesters.firstWhereOrNull((s) => s.isActive) ?? semesters.first;
          selectedTermId.value = active.termId;
          await fetchReportCard();
        } else {
          await fetchReportCard();
        }
      }
    } on DioException catch (_) {
      // Fallback ke fetch langsung tanpa pilih semester
      await fetchReportCard();
    } finally {
      isLoading.value = false;
    }
  }

  /// Ambil data rapor siswa.
  Future<void> fetchReportCard() async {
    if (_studentId.isEmpty) return;
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final queryParams = selectedTermId.value.isNotEmpty
          ? {'term_id': selectedTermId.value}
          : <String, dynamic>{};

      final response = await ApiService.dio.get(
        '/academic/report-cards/student/$_studentId',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final map = (data is Map && data['data'] is Map)
            ? data['data'] as Map<String, dynamic>
            : (data is Map ? data as Map<String, dynamic> : <String, dynamic>{});
        reportCard.value = ReportCard.fromJson(map);
      }
    } on DioException catch (e) {
      errorMessage.value =
          e.response?.data?['error']?.toString() ?? 'Gagal memuat rapor.';
    } finally {
      isLoading.value = false;
    }
  }

  void changeSemester(String termId) {
    selectedTermId.value = termId;
    fetchReportCard();
  }
}
