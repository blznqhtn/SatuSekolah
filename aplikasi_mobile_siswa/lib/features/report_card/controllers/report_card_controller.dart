import 'package:aplikasi_mobile_siswa/core/config/api_config.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class LeaderboardModel {
  final String studentName;
  final String className;
  final int rank;
  final double averageScore;
  final bool isCurrentUser;

  LeaderboardModel({
    required this.studentName,
    required this.className,
    required this.rank,
    required this.averageScore,
    required this.isCurrentUser,
  });

  factory LeaderboardModel.fromJson(Map<String, dynamic> json) {
    return LeaderboardModel(
      studentName: json['student_name'] ?? '',
      className: json['class_name'] ?? '',
      rank: json['rank'] ?? 0,
      averageScore: (json['average_score'] as num?)?.toDouble() ?? 0.0,
      isCurrentUser: json['is_current_user'] ?? false,
    );
  }
}

class ReportCardModel {
  final String termName;
  final String academicYear;
  final int classRank;
  final String homeroomNotes;
  final List<ReportCardGrade> grades;

  ReportCardModel({
    required this.termName,
    required this.academicYear,
    required this.classRank,
    required this.homeroomNotes,
    required this.grades,
  });

  factory ReportCardModel.fromJson(Map<String, dynamic> json) {
    return ReportCardModel(
      termName: json['term_name'] ?? '',
      academicYear: json['academic_year'] ?? '',
      classRank: json['class_rank'] ?? 0,
      homeroomNotes: json['homeroom_notes'] ?? '',
      grades: (json['grades'] as List?)
              ?.map((e) => ReportCardGrade.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class ReportCardGrade {
  final String courseName;
  final int score;
  final String predicate;
  final String description;

  ReportCardGrade({
    required this.courseName,
    required this.score,
    required this.predicate,
    required this.description,
  });

  factory ReportCardGrade.fromJson(Map<String, dynamic> json) {
    return ReportCardGrade(
      courseName: json['course_name'] ?? '',
      score: json['score'] ?? 0,
      predicate: json['predicate'] ?? '',
      description: json['description'] ?? '',
    );
  }
}

class ReportCardController extends GetxController {
  var isLoading = false.obs;
  var isLeaderboardLoading = false.obs;
  var reportCard = Rxn<ReportCardModel>();
  var errorMessage = ''.obs;
  var leaderboardError = ''.obs;
  
  var leaderboardData = <LeaderboardModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchReportCard();
    fetchLeaderboard('Kelas');
  }

  Future<void> fetchReportCard() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt_token');
      if (token == null) {
        throw Exception('Token tidak ditemukan, silakan login ulang.');
      }

      final url = Uri.parse('${ApiConfig.satuSekolah}/report_card');
      final response = await http.get(
        url,
        headers: ApiConfig.bearerHeaders(token),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['data'] != null) {
          reportCard.value = ReportCardModel.fromJson(data['data']);
        }
      } else if (response.statusCode == 404) {
        errorMessage.value = 'Rapor belum tersedia untuk semester ini.';
      } else {
        errorMessage.value = 'Gagal memuat data rapor. Kode: ${response.statusCode}';
      }
    } catch (e) {
      errorMessage.value = 'Terjadi kesalahan: $e';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchLeaderboard(String filterType) async {
    isLeaderboardLoading.value = true;
    leaderboardError.value = '';

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt_token');
      if (token == null) {
        throw Exception('Token tidak ditemukan.');
      }

      final url = Uri.parse('${ApiConfig.satuSekolah}/leaderboard?filter=$filterType');
      final response = await http.get(
        url,
        headers: ApiConfig.bearerHeaders(token),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['data'] != null) {
          final List<dynamic> list = data['data'];
          leaderboardData.value = list.map((e) => LeaderboardModel.fromJson(e)).toList();
        }
      } else {
        leaderboardError.value = 'Gagal memuat leaderboard. Kode: ${response.statusCode}';
      }
    } catch (e) {
      leaderboardError.value = 'Terjadi kesalahan: $e';
    } finally {
      isLeaderboardLoading.value = false;
    }
  }
}
