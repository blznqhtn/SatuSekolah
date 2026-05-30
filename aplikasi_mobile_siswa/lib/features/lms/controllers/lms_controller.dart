import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class LMSController extends GetxController {
  final String apiUrl = 'https://remold-nutshell-extortion.ngrok-free.dev/api';

  var isLoading = true.obs;
  var isSubmitting = false.obs;

  var tugasTertunda = 0.obs;
  var tugasSelesai = 0.obs;
  var rataRata = 0.0.obs;
  var mapelAktif = [].obs;

  // Untuk detail course
  var courseDetail = {}.obs;

  @override
  void onInit() {
    super.onInit();
    fetchDashboardData();
  }

  Future<void> fetchDashboardData() async {
    try {
      isLoading(true);
      final response = await http.get(Uri.parse('$apiUrl/lms/dashboard'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body)['data'];
        tugasTertunda.value = data['tugas_tertunda'];
        tugasSelesai.value = data['tugas_selesai'];
        rataRata.value = (data['rata_rata'] as num).toDouble();
        mapelAktif.value = data['mapel_aktif'];
      }
    } catch (e) {
      Get.snackbar('Error', 'Gagal memuat data LMS');
    } finally {
      isLoading(false);
    }
  }

  Future<void> fetchCourseDetail(String courseId) async {
    try {
      isLoading(true);
      final response = await http.get(Uri.parse('$apiUrl/lms/course/$courseId'));
      if (response.statusCode == 200) {
        courseDetail.value = jsonDecode(response.body)['data'];
      }
    } catch (e) {
      Get.snackbar('Error', 'Gagal memuat detail pelajaran');
    } finally {
      isLoading(false);
    }
  }

  Future<void> submitQuiz(int quizId, Map<String, dynamic> answers) async {
    try {
      isSubmitting(true);
      final response = await http.post(
        Uri.parse('$apiUrl/lms/quiz/submit'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'quiz_id': quizId, 'answers': answers}),
      );
      
      if (response.statusCode == 200) {
        final res = jsonDecode(response.body);
        final score = res['data']['skor'];
        Get.defaultDialog(
          title: "Kuis Selesai",
          middleText: "Anda mendapatkan skor: $score",
          textConfirm: "Tutup",
          onConfirm: () {
            Get.back(); // Tutup dialog
            Get.back(); // Kembali ke detail
          }
        );
      }
    } catch (e) {
      Get.snackbar('Error', 'Gagal mengirim jawaban kuis');
    } finally {
      isSubmitting(false);
    }
  }

  Future<void> submitAssignment(String assignmentId, String filePath) async {
    try {
      isSubmitting(true);
      
      var request = http.MultipartRequest('POST', Uri.parse('$apiUrl/lms/assignment/submit'));
      request.fields['assignment_id'] = assignmentId;
      request.files.add(await http.MultipartFile.fromPath('file', filePath));
      
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      
      if (response.statusCode == 200) {
        Get.defaultDialog(
          title: "Tugas Terkirim",
          middleText: "Tugas Anda berhasil diunggah dan dikumpulkan.",
          textConfirm: "Tutup",
          onConfirm: () {
            Get.back(); // Tutup dialog
            Get.back(); // Kembali ke detail
            // Refresh detail course jika perlu
            if (courseDetail.containsKey('course_id')) {
              fetchCourseDetail(courseDetail['course_id']);
            }
          }
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
