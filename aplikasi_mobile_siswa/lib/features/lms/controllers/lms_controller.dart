// =============================================================================
// lms_controller.dart — LMS via LMS-Tels (diproxy oleh Backend Go SatuSekolah)
// =============================================================================
// LMS-Tels menggunakan Laravel Web Session sehingga Flutter tidak bisa
// langsung memanggil API-nya. Backend Go SatuSekolah akan bertindak sebagai
// proxy yang menyimpan cookie session LMS dan mem-forward request.
//
// Endpoint Go yang digunakan:
//   GET  /api/lms/courses        → proxy ke LMS getDataCourseku
//   GET  /api/lms/courses/:id    → proxy ke LMS getDataCourseku/{id}
//   POST /api/lms/progress       → proxy ke LMS updateProgress
//   GET  /api/lms/certificates   → proxy ke LMS /api/certificates
//   GET  /api/lms/grades         → proxy ke LMS student grades
// =============================================================================

import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:aplikasi_mobile_siswa/core/config/api_config.dart';
import 'package:aplikasi_mobile_siswa/core/services/external_auth_service.dart';

class LMSController extends GetxController {
  final _auth = ExternalAuthService();

  var isLoading = true.obs;
  var isSubmitting = false.obs;

  // ─── Dashboard Summary ────────────────────────────────────────────────────
  var tugasTertunda = 0.obs;
  var tugasSelesai  = 0.obs;
  var rataRata      = 0.0.obs;
  var mapelAktif    = [].obs;

  // ─── Daftar Kursus (dari LMS-Tels) ───────────────────────────────────────
  var daftarKursus  = [].obs;

  // ─── Detail Kursus ────────────────────────────────────────────────────────
  var courseDetail  = {}.obs;
  var courseProgress = 0.0.obs; // 0.0 - 1.0

  // ─── Sertifikat ───────────────────────────────────────────────────────────
  var sertifikat    = [].obs;

  // ─── Nilai / Grades ───────────────────────────────────────────────────────
  var gradesData    = [].obs;

  @override
  void onInit() {
    super.onInit();
    fetchDashboardData();
  }

  Future<String?> _getMainToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token');
  }

  Map<String, String> _headers(String token) => ApiConfig.bearerHeaders(token);

  // =========================================================================
  // DASHBOARD — Ringkasan LMS via SatuSekolah Go Proxy
  // =========================================================================
  Future<void> fetchDashboardData() async {
    try {
      isLoading(true);
      final token = await _getMainToken();
      if (token == null) return;

      final response = await http.get(
        Uri.parse('${ApiConfig.satuSekolah}/lms/dashboard'),
        headers: _headers(token),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body)['data'];
        tugasTertunda.value = (data['tugas_tertunda'] as num? ?? 0).toInt();
        tugasSelesai.value  = (data['tugas_selesai'] as num? ?? 0).toInt();
        rataRata.value      = (data['rata_rata'] as num? ?? 0).toDouble();
        mapelAktif.value    = List.from(data['mapel_aktif'] ?? []);
      } else {
        // Fallback: ambil kursus langsung dari proxy LMS
        await fetchDaftarKursus();
      }
    } catch (e) {
      print('[LMS] fetchDashboard error: $e');
      await fetchDaftarKursus();
    } finally {
      isLoading(false);
    }
  }

  // =========================================================================
  // DAFTAR KURSUS — via Go Proxy → LMS-Tels /api/getDataCourseku
  // =========================================================================
  Future<void> fetchDaftarKursus() async {
    try {
      isLoading(true);
      final token = await _getMainToken();
      if (token == null) return;

      final response = await http.get(
        Uri.parse('${ApiConfig.satuSekolah}/lms/courses'),
        headers: _headers(token),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // LMS returns {'kursus': [...]}
        final kursus = data['kursus'] ?? data['data'] ?? [];
        daftarKursus.value = List.from(kursus);

        // Hitung summary dari kursus
        final total = daftarKursus.length;
        mapelAktif.value = List.from(daftarKursus.take(5));
        tugasTertunda.value = total; // estimasi
      }
    } catch (e) {
      print('[LMS] fetchKursus error: $e');
      Get.snackbar('Error', 'Gagal memuat daftar pelajaran');
    } finally {
      isLoading(false);
    }
  }

  // =========================================================================
  // DETAIL KURSUS — via Go Proxy → LMS-Tels /api/getDataCourseku/{id}
  // =========================================================================
  Future<void> fetchCourseDetail(String courseId) async {
    try {
      isLoading(true);
      final token = await _getMainToken();
      if (token == null) return;

      final response = await http.get(
        Uri.parse('${ApiConfig.satuSekolah}/lms/courses/$courseId'),
        headers: _headers(token),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final kursus = data['kursus'];
        if (kursus is List && kursus.isNotEmpty) {
          courseDetail.value = Map<String, dynamic>.from(kursus.first);
        } else if (kursus is Map) {
          courseDetail.value = Map<String, dynamic>.from(kursus);
        }
      } else {
        Get.snackbar('Gagal', 'Pelajaran tidak ditemukan');
      }
    } catch (e) {
      print('[LMS] fetchDetail error: $e');
      Get.snackbar('Error', 'Gagal memuat detail pelajaran');
    } finally {
      isLoading(false);
    }
  }

  // =========================================================================
  // UPDATE PROGRESS VIDEO — via Go Proxy → LMS-Tels /api/progress/video-completion
  // =========================================================================
  Future<void> updateVideoProgress({
    required int courseId,
    required int contentId,
    required String videoId,
    required int duration,
  }) async {
    try {
      final token = await _getMainToken();
      if (token == null) return;

      final response = await http.post(
        Uri.parse('${ApiConfig.satuSekolah}/lms/progress/video'),
        headers: _headers(token),
        body: jsonEncode({
          'course_id':  courseId,
          'content_id': contentId,
          'video_id':   videoId,
          'duration':   duration,
        }),
      );

      if (response.statusCode == 200) {
        print('[LMS] Video progress saved: $videoId');
      }
    } catch (e) {
      print('[LMS] updateVideoProgress error: $e');
    }
  }

  // =========================================================================
  // UPDATE PROGRESS PDF — via Go Proxy → LMS-Tels /api/progress/pdf-download
  // =========================================================================
  Future<void> updatePDFProgress({
    required int courseId,
    required int contentId,
    required String pdfFilename,
  }) async {
    try {
      final token = await _getMainToken();
      if (token == null) return;

      await http.post(
        Uri.parse('${ApiConfig.satuSekolah}/lms/progress/pdf'),
        headers: _headers(token),
        body: jsonEncode({
          'course_id':    courseId,
          'content_id':   contentId,
          'pdf_filename': pdfFilename,
        }),
      );
    } catch (e) {
      print('[LMS] updatePDFProgress error: $e');
    }
  }

  // =========================================================================
  // SUBMIT KUIS — via Go Proxy → LMS-Tels /api/progress/quiz-completion
  // =========================================================================
  Future<void> submitQuiz(int quizId, Map<String, dynamic> answers, {int? courseId, int? contentId}) async {
    try {
      isSubmitting(true);
      final token = await _getMainToken();
      if (token == null) return;

      final response = await http.post(
        Uri.parse('${ApiConfig.satuSekolah}/lms/quiz/submit'),
        headers: _headers(token),
        body: jsonEncode({
          'quiz_id':    quizId,
          'answers':    answers,
          'course_id':  courseId,
          'content_id': contentId,
        }),
      );

      if (response.statusCode == 200) {
        final res = jsonDecode(response.body);
        final score = res['data']?['score'] ?? res['data']?['skor'] ?? 0;
        Get.defaultDialog(
          title: 'Kuis Selesai! 🎉',
          middleText: 'Skor Anda: $score',
          textConfirm: 'Tutup',
          onConfirm: () {
            Get.back();
            Get.back();
          },
        );
      } else {
        Get.snackbar('Gagal', 'Gagal mengirim jawaban kuis');
      }
    } catch (e) {
      Get.snackbar('Error', 'Gagal mengirim jawaban kuis');
    } finally {
      isSubmitting(false);
    }
  }

  // =========================================================================
  // SERTIFIKAT — via Go Proxy → LMS-Tels /api/certificates
  // =========================================================================
  Future<void> fetchSertifikat() async {
    try {
      isLoading(true);
      final token = await _getMainToken();
      if (token == null) return;

      final response = await http.get(
        Uri.parse('${ApiConfig.satuSekolah}/lms/certificates'),
        headers: _headers(token),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        sertifikat.value = List.from(data['data'] ?? data['certificates'] ?? []);
      }
    } catch (e) {
      print('[LMS] fetchSertifikat error: $e');
      Get.snackbar('Error', 'Gagal memuat sertifikat');
    } finally {
      isLoading(false);
    }
  }

  // =========================================================================
  // CEK KELAYAKAN SERTIFIKAT — /api/lms/certificates/eligibility/:courseId
  // =========================================================================
  Future<bool> checkCertificateEligibility(int courseId) async {
    try {
      final token = await _getMainToken();
      if (token == null) return false;

      final response = await http.get(
        Uri.parse('${ApiConfig.satuSekolah}/lms/certificates/eligibility/$courseId'),
        headers: _headers(token),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['eligible'] == true;
      }
    } catch (e) {
      print('[LMS] checkEligibility error: $e');
    }
    return false;
  }

  // =========================================================================
  // NILAI / GRADES — via Go Proxy → LMS student grades
  // =========================================================================
  Future<void> fetchGrades() async {
    try {
      isLoading(true);
      final token = await _getMainToken();
      if (token == null) return;

      final response = await http.get(
        Uri.parse('${ApiConfig.satuSekolah}/lms/grades'),
        headers: _headers(token),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        gradesData.value = List.from(data['data'] ?? []);

        // Hitung rata-rata nilai dari semua kursus
        if (gradesData.isNotEmpty) {
          final avg = gradesData
              .map((g) => (g['average_score'] as num? ?? 0).toDouble())
              .reduce((a, b) => a + b) / gradesData.length;
          rataRata.value = avg;
        }
      }
    } catch (e) {
      print('[LMS] fetchGrades error: $e');
      Get.snackbar('Error', 'Gagal memuat nilai');
    } finally {
      isLoading(false);
    }
  }

  // =========================================================================
  // SUBMIT TUGAS — via Go Proxy
  // =========================================================================
  Future<void> submitAssignment(String assignmentId, String filePath) async {
    try {
      isSubmitting(true);
      final token = await _getMainToken();
      if (token == null) return;

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiConfig.satuSekolah}/lms/assignment/submit'),
      );
      request.headers.addAll(ApiConfig.bearerHeaders(token));
      request.fields['assignment_id'] = assignmentId;
      request.files.add(await http.MultipartFile.fromPath('file', filePath));

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        Get.defaultDialog(
          title: 'Tugas Terkirim ✅',
          middleText: 'Tugas Anda berhasil diunggah.',
          textConfirm: 'Tutup',
          onConfirm: () {
            Get.back();
            Get.back();
            if (courseDetail.containsKey('id')) {
              fetchCourseDetail(courseDetail['id'].toString());
            }
          },
        );
      } else {
        Get.snackbar('Gagal', 'Gagal mengunggah tugas');
      }
    } catch (e) {
      Get.snackbar('Error', 'Terjadi kesalahan saat mengunggah tugas');
    } finally {
      isSubmitting(false);
    }
  }
}
