import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class HealthController extends GetxController {
  final String apiUrl = 'https://remold-nutshell-extortion.ngrok-free.dev/api';

  var isLoading = true.obs;
  var isSubmitting = false.obs;

  var jenisKelamin = ''.obs;
  var golonganDarah = ''.obs;
  var rhesus = ''.obs;
  var tinggiBadan = 0.obs;
  var beratBadan = 0.obs;
  var bmi = 0.0.obs;
  var bmiStatus = ''.obs;
  var hemoglobin = 0.0.obs;
  var riwayatUks = [].obs;

  // Menstruasi
  var isMensLoading = true.obs;
  var mensData = {}.obs;

  // Pita
  var isPitaLoading = true.obs;
  var statusPita = {}.obs;
  var riwayatPita = [].obs;

  @override
  void onInit() {
    super.onInit();
    fetchDashboardData();
  }

  Future<void> fetchDashboardData() async {
    try {
      isLoading(true);
      final response = await http.get(Uri.parse('$apiUrl/health/dashboard'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body)['data'];
        jenisKelamin.value = data['jenis_kelamin'] ?? '';
        golonganDarah.value = data['golongan_darah'];
        rhesus.value = data['rhesus'];
        tinggiBadan.value = data['tinggi_badan'];
        beratBadan.value = data['berat_badan'];
        bmi.value = (data['bmi'] as num).toDouble();
        bmiStatus.value = data['bmi_status'];
        if (data.containsKey('hemoglobin')) {
          hemoglobin.value = (data['hemoglobin'] as num).toDouble();
        }
        riwayatUks.value = data['riwayat_uks'];
      }
    } catch (e) {
      Get.snackbar('Error', 'Gagal memuat data kesehatan');
    } finally {
      isLoading(false);
    }
  }

  Future<void> updateBMI(int tinggi, int berat) async {
    try {
      isSubmitting(true);
      final response = await http.post(
        Uri.parse('$apiUrl/health/update_bmi'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'tinggi': tinggi, 'berat': berat}),
      );
      
      if (response.statusCode == 200) {
        final res = jsonDecode(response.body);
        Get.snackbar('Berhasil', res['message']);
        
        // Update lokal
        tinggiBadan.value = tinggi;
        beratBadan.value = berat;
        bmi.value = (res['data']['bmi'] as num).toDouble();
        bmiStatus.value = res['data']['bmi_status'];
        
        Get.back();
      }
    } catch (e) {
      Get.snackbar('Error', 'Gagal memperbarui tinggi dan berat');
    } finally {
      isSubmitting(false);
    }
  }

  Future<void> requestUks(String keluhan) async {
    try {
      isSubmitting(true);
      final response = await http.post(
        Uri.parse('$apiUrl/health/request_uks'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'keluhan': keluhan}),
      );
      
      if (response.statusCode == 200) {
        final res = jsonDecode(response.body);
        Get.snackbar('Berhasil', res['message']);
        Get.back();
      }
    } catch (e) {
      Get.snackbar('Error', 'Gagal mengirim pengajuan UKS');
    } finally {
      isSubmitting(false);
    }
  }

  Future<void> updateHemoglobin(double hb) async {
    try {
      isSubmitting(true);
      final response = await http.post(
        Uri.parse('$apiUrl/health/hemoglobin/update'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'hemoglobin': hb}),
      );
      
      if (response.statusCode == 200) {
        final res = jsonDecode(response.body);
        Get.snackbar('Berhasil', res['message']);
        
        // Update lokal
        hemoglobin.value = hb;
        
        Get.back();
      }
    } catch (e) {
      Get.snackbar('Error', 'Gagal memperbarui data Hemoglobin');
    } finally {
      isSubmitting(false);
    }
  }

  Future<void> fetchMenstruationData() async {
    try {
      isMensLoading(true);
      final response = await http.get(Uri.parse('$apiUrl/health/menstruation'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body)['data'];
        mensData.value = data;
      }
    } catch (e) {
      Get.snackbar('Error', 'Gagal memuat data siklus haid');
    } finally {
      isMensLoading(false);
    }
  }

  Future<void> logMenstruation(String tanggal) async {
    try {
      isSubmitting(true);
      final response = await http.post(
        Uri.parse('$apiUrl/health/menstruation/log'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'tanggal': tanggal}),
      );
      
      if (response.statusCode == 200) {
        final res = jsonDecode(response.body);
        Get.snackbar('Berhasil', res['message']);
        await fetchMenstruationData(); // Refresh data
        Get.back();
      }
    } catch (e) {
      Get.snackbar('Error', 'Gagal mencatat siklus haid');
    } finally {
      isSubmitting(false);
    }
  }

  Future<void> requestPita() async {
    try {
      isSubmitting(true);
      final response = await http.post(
        Uri.parse('$apiUrl/health/request_pita'),
      );
      
      if (response.statusCode == 200) {
        final res = jsonDecode(response.body);
        Get.snackbar('Berhasil', res['message']);
        await fetchPitaData(); // Refresh data
        Get.back(); // Kembali ke dashboard
      }
    } catch (e) {
      Get.snackbar('Error', 'Gagal mengirim permintaan');
    } finally {
      isSubmitting(false);
    }
  }

  Future<void> fetchPitaData() async {
    try {
      isPitaLoading(true);
      // Fetch Status
      final resStatus = await http.get(Uri.parse('$apiUrl/health/pita/status'));
      if (resStatus.statusCode == 200) {
        statusPita.value = jsonDecode(resStatus.body)['data'];
      }
      
      // Fetch Riwayat
      final resRiwayat = await http.get(Uri.parse('$apiUrl/health/pita/riwayat'));
      if (resRiwayat.statusCode == 200) {
        riwayatPita.value = jsonDecode(resRiwayat.body)['data'];
      }
    } catch (e) {
      Get.snackbar('Error', 'Gagal memuat data peminjaman pita');
    } finally {
      isPitaLoading(false);
    }
  }
}
