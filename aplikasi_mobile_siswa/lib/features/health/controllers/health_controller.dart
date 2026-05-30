// =============================================================================
// health_controller.dart — Kesehatan via AkuSehat API
// =============================================================================
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:aplikasi_mobile_siswa/core/config/api_config.dart';
import 'package:aplikasi_mobile_siswa/core/services/external_auth_service.dart';

class HealthController extends GetxController {
  final _auth = ExternalAuthService();

  var isLoading = true.obs;
  var isSubmitting = false.obs;

  // ─── Data Kesehatan Umum ──────────────────────────────────────────────────
  var jenisKelamin = ''.obs;
  var golonganDarah = ''.obs;
  var rhesus = ''.obs;
  var tinggiBadan = 0.obs;
  var beratBadan = 0.obs;
  var bmi = 0.0.obs;
  var bmiStatus = ''.obs;
  var hemoglobin = 0.0.obs;
  var riwayatUks = [].obs;

  // ─── Ringkasan Kesehatan (dari AkuSehat /member/summary) ─────────────────
  var lastCheckDate = ''.obs;
  var sistol = 0.0.obs;
  var diastol = 0.0.obs;
  var grafikData = [].obs; // skor kesehatan per tahun

  // ─── Riwayat Kesehatan Lengkap ────────────────────────────────────────────
  var riwayatKesehatan = [].obs; // grouped by year

  // ─── Menstruasi ───────────────────────────────────────────────────────────
  var isMensLoading = true.obs;
  var mensData = {}.obs;
  var riwayatHaid = [].obs;

  // ─── Pita ─────────────────────────────────────────────────────────────────
  var isPitaLoading = true.obs;
  var statusPita = {}.obs;
  var riwayatPita = [].obs;

  // ─── User ID di AkuSehat ─────────────────────────────────────────────────
  var akuSehatUserId = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchDashboardData();
  }

  Future<String?> _getMainToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token');
  }

  // =========================================================================
  // DASHBOARD — data dari SatuSekolah Go backend (wrapper)
  // =========================================================================
  Future<void> fetchDashboardData() async {
    try {
      isLoading(true);
      final token = await _getMainToken();
      if (token == null) return;

      final response = await http.get(
        Uri.parse('${ApiConfig.satuSekolah}/health/dashboard'),
        headers: ApiConfig.bearerHeaders(token),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body)['data'];
        _applyDashboardData(data);
      } else {
        // Fallback: langsung ke AkuSehat
        await _fetchFromAkuSehatDirect();
      }
    } catch (e) {
      print('[Health] fetchDashboard error: $e');
      await _fetchFromAkuSehatDirect();
    } finally {
      isLoading(false);
    }
  }

  void _applyDashboardData(Map<String, dynamic> data) {
    jenisKelamin.value  = data['jenis_kelamin'] ?? '';
    golonganDarah.value = data['golongan_darah'] ?? '';
    rhesus.value        = data['rhesus'] ?? '';
    tinggiBadan.value   = (data['tinggi_badan'] as num? ?? 0).toInt();
    beratBadan.value    = (data['berat_badan'] as num? ?? 0).toInt();
    bmi.value           = (data['bmi'] as num? ?? 0).toDouble();
    bmiStatus.value     = data['bmi_status'] ?? '';
    if (data.containsKey('hemoglobin')) {
      hemoglobin.value  = (data['hemoglobin'] as num? ?? 0).toDouble();
    }
    riwayatUks.value    = List.from(data['riwayat_uks'] ?? []);
  }

  // =========================================================================
  // AKUSEHAT DIRECT — Ambil data langsung dari AkuSehat API
  // =========================================================================
  Future<void> _fetchFromAkuSehatDirect() async {
    if (!_auth.isAkuSehatLoggedIn) {
      Get.snackbar('Info', 'Tidak terhubung ke AkuSehat');
      return;
    }
    try {
      // Ambil ID user di AkuSehat dulu via /api/me
      final meResp = await http.get(
        Uri.parse('${ApiConfig.akuSehat}/me'),
        headers: _auth.akuSehatHeaders(),
      ).timeout(const Duration(seconds: 10));

      if (meResp.statusCode == 200) {
        final me = jsonDecode(meResp.body)['data'];
        akuSehatUserId.value = me['id'].toString();
        jenisKelamin.value   = me['jk'] ?? '';
      }

      // Ringkasan kesehatan
      await fetchAkuSehatSummary();
    } catch (e) {
      print('[AkuSehat] fetchDirect error: $e');
    }
  }

  // =========================================================================
  // RINGKASAN KESEHATAN — /api/member/summary
  // =========================================================================
  Future<void> fetchAkuSehatSummary() async {
    if (!_auth.isAkuSehatLoggedIn) return;
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.akuSehat}/member/summary'),
        headers: _auth.akuSehatHeaders(),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body)['data'];
        bmi.value           = (data['bmi'] as num? ?? 0).toDouble();
        sistol.value        = (data['sistol'] as num? ?? 0).toDouble();
        diastol.value       = (data['diastol'] as num? ?? 0).toDouble();
        lastCheckDate.value = data['last_check'] ?? '';
        tinggiBadan.value   = (data['tinggi'] as num? ?? 0).toInt();
        beratBadan.value    = (data['berat'] as num? ?? 0).toInt();
        hemoglobin.value    = (data['hb'] as num? ?? 0).toDouble();
      }
    } catch (e) {
      print('[AkuSehat] fetchSummary error: $e');
    }
  }

  // =========================================================================
  // GRAFIK SKOR KESEHATAN — /api/member/summary/grafik
  // =========================================================================
  Future<void> fetchGrafikKesehatan() async {
    if (!_auth.isAkuSehatLoggedIn) return;
    try {
      isLoading(true);
      final response = await http.get(
        Uri.parse('${ApiConfig.akuSehat}/member/summary/grafik'),
        headers: _auth.akuSehatHeaders(),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body)['data'];
        grafikData.value = List.from(data ?? []);
      }
    } catch (e) {
      print('[AkuSehat] fetchGrafik error: $e');
      Get.snackbar('Error', 'Gagal memuat grafik kesehatan');
    } finally {
      isLoading(false);
    }
  }

  // =========================================================================
  // RIWAYAT KESEHATAN LENGKAP — /api/member/{id}/kesehatan
  // =========================================================================
  Future<void> fetchRiwayatKesehatan() async {
    if (!_auth.isAkuSehatLoggedIn || akuSehatUserId.value.isEmpty) return;
    try {
      isLoading(true);
      final response = await http.get(
        Uri.parse('${ApiConfig.akuSehat}/member/${akuSehatUserId.value}/kesehatan'),
        headers: _auth.akuSehatHeaders(),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body)['data'];
        riwayatKesehatan.value = List.from(data ?? []);
      }
    } catch (e) {
      print('[AkuSehat] fetchRiwayat error: $e');
      Get.snackbar('Error', 'Gagal memuat riwayat kesehatan');
    } finally {
      isLoading(false);
    }
  }

  // =========================================================================
  // BMI UPDATE — via SatuSekolah backend (Go tetap jadi proxy)
  // =========================================================================
  Future<void> updateBMI(int tinggi, int berat) async {
    try {
      isSubmitting(true);
      final token = await _getMainToken();
      if (token == null) return;

      final response = await http.post(
        Uri.parse('${ApiConfig.satuSekolah}/health/update_bmi'),
        headers: ApiConfig.bearerHeaders(token),
        body: jsonEncode({'tinggi': tinggi, 'berat': berat}),
      );

      if (response.statusCode == 200) {
        final res = jsonDecode(response.body);
        Get.snackbar('Berhasil', res['message'] ?? 'BMI diperbarui');
        tinggiBadan.value = tinggi;
        beratBadan.value  = berat;
        bmi.value = (res['data']?['bmi'] as num? ?? 0).toDouble();
        bmiStatus.value = res['data']?['bmi_status'] ?? '';
        Get.back();
      }
    } catch (e) {
      Get.snackbar('Error', 'Gagal memperbarui tinggi dan berat');
    } finally {
      isSubmitting(false);
    }
  }

  // =========================================================================
  // MENSTRUASI — via AkuSehat API
  // =========================================================================
  Future<void> fetchMenstruationData() async {
    if (!_auth.isAkuSehatLoggedIn) return;
    try {
      isMensLoading(true);

      // Ambil data haid aktif hari ini
      final response = await http.get(
        Uri.parse('${ApiConfig.akuSehat}/member/data-haid'),
        headers: _auth.akuSehatHeaders(),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body)['data'];
        if (data is List && data.isNotEmpty) {
          mensData.value = Map<String, dynamic>.from(data.first);
        } else {
          mensData.value = {};
        }
      }

      // Ambil riwayat haid berdasarkan id user
      if (akuSehatUserId.value.isNotEmpty) {
        final riwayatResp = await http.get(
          Uri.parse('${ApiConfig.akuSehat}/member/${akuSehatUserId.value}/riwayat-haid'),
          headers: _auth.akuSehatHeaders(),
        ).timeout(const Duration(seconds: 10));

        if (riwayatResp.statusCode == 200) {
          riwayatHaid.value = List.from(jsonDecode(riwayatResp.body)['data'] ?? []);
        }
      }
    } catch (e) {
      Get.snackbar('Error', 'Gagal memuat data siklus haid');
    } finally {
      isMensLoading(false);
    }
  }

  /// Catat mulai siklus haid baru.
  Future<void> logMenstruation(String tanggal) async {
    if (!_auth.isAkuSehatLoggedIn) {
      Get.snackbar('Error', 'Belum terhubung ke AkuSehat');
      return;
    }
    try {
      isSubmitting(true);
      final response = await http.post(
        Uri.parse('${ApiConfig.akuSehat}/member/data-haid'),
        headers: _auth.akuSehatHeaders(),
        body: jsonEncode({'tanggal_mulai': tanggal}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final res = jsonDecode(response.body);
        Get.snackbar('Berhasil', res['message'] ?? 'Siklus haid dicatat');
        await fetchMenstruationData();
        Get.back();
      } else {
        final err = jsonDecode(response.body);
        Get.snackbar('Gagal', err['message'] ?? 'Gagal mencatat siklus haid');
      }
    } catch (e) {
      Get.snackbar('Error', 'Gagal mencatat siklus haid');
    } finally {
      isSubmitting(false);
    }
  }

  /// Selesaikan siklus haid yang sedang berlangsung.
  Future<void> endMenstruation(String haidId) async {
    if (!_auth.isAkuSehatLoggedIn) return;
    try {
      isSubmitting(true);
      final response = await http.put(
        Uri.parse('${ApiConfig.akuSehat}/member/data-haid/$haidId'),
        headers: _auth.akuSehatHeaders(),
        body: jsonEncode({}),
      );

      if (response.statusCode == 200) {
        Get.snackbar('Berhasil', 'Siklus haid diselesaikan');
        await fetchMenstruationData();
        Get.back();
      }
    } catch (e) {
      Get.snackbar('Error', 'Gagal menyelesaikan siklus haid');
    } finally {
      isSubmitting(false);
    }
  }

  // =========================================================================
  // PEMINJAMAN PITA — via AkuSehat API
  // =========================================================================
  Future<void> fetchPitaData() async {
    if (!_auth.isAkuSehatLoggedIn) return;
    try {
      isPitaLoading(true);

      // Status peminjaman aktif
      final resStatus = await http.get(
        Uri.parse('${ApiConfig.akuSehat}/member/status-pita'),
        headers: _auth.akuSehatHeaders(),
      ).timeout(const Duration(seconds: 10));

      if (resStatus.statusCode == 200) {
        statusPita.value = Map<String, dynamic>.from(
          jsonDecode(resStatus.body) ?? {}
        );
      }

      // Riwayat pita
      if (akuSehatUserId.value.isNotEmpty) {
        final resRiwayat = await http.get(
          Uri.parse('${ApiConfig.akuSehat}/member/${akuSehatUserId.value}/riwayat-pita'),
          headers: _auth.akuSehatHeaders(),
        ).timeout(const Duration(seconds: 10));

        if (resRiwayat.statusCode == 200) {
          riwayatPita.value = List.from(jsonDecode(resRiwayat.body)['data'] ?? []);
        }
      }
    } catch (e) {
      Get.snackbar('Error', 'Gagal memuat data peminjaman pita');
    } finally {
      isPitaLoading(false);
    }
  }

  /// Ajukan peminjaman pita — tampilkan dialog konfirmasi dulu.
  Future<void> requestPita({int jumlahPita = 1, String? tanggalPinjam}) async {
    if (!_auth.isAkuSehatLoggedIn) {
      // Tampilkan dialog konfirmasi sebelum submit
      Get.defaultDialog(
        title: 'Ajukan Peminjaman Pita',
        middleText: 'Apakah Anda ingin mengajukan peminjaman 1 buah pita ke UKS?\n\nPastikan Anda sedang dalam kondisi siklus haid yang aktif.',
        textConfirm: 'Ajukan',
        textCancel: 'Batal',
        confirmTextColor: Colors.white,
        buttonColor: const Color(0xFFEC4899),
        onConfirm: () async {
          Get.back();
          await _submitPitaToAkuSehat(jumlahPita: jumlahPita, tanggalPinjam: tanggalPinjam);
        },
      );
      return;
    }
    Get.defaultDialog(
      title: 'Ajukan Peminjaman Pita',
      middleText: 'Apakah Anda ingin mengajukan peminjaman 1 buah pita ke UKS?\n\nPastikan Anda sedang dalam kondisi siklus haid yang aktif.',
      textConfirm: 'Ajukan',
      textCancel: 'Batal',
      confirmTextColor: Colors.white,
      buttonColor: const Color(0xFFEC4899),
      onConfirm: () async {
        Get.back();
        await _submitPitaToAkuSehat(jumlahPita: jumlahPita, tanggalPinjam: tanggalPinjam);
      },
    );
  }

  Future<void> _submitPitaToAkuSehat({int jumlahPita = 1, String? tanggalPinjam}) async {
    if (!_auth.isAkuSehatLoggedIn) {
      // Fallback: via SatuSekolah backend Go
      try {
        isSubmitting(true);
        final token = await _getMainToken();
        if (token == null) return;
        final tgl = tanggalPinjam ?? DateTime.now().toIso8601String().substring(0, 10);
        final response = await http.post(
          Uri.parse('${ApiConfig.satuSekolah}/health/request_pita'),
          headers: ApiConfig.bearerHeaders(token),
          body: jsonEncode({'jumlah_pita': jumlahPita, 'tanggal_pinjam': tgl}),
        );
        if (response.statusCode == 200) {
          Get.snackbar('Berhasil', 'Pengajuan pita dikirim');
          await fetchPitaData();
        } else {
          Get.snackbar('Gagal', 'Gagal mengajukan peminjaman pita');
        }
      } catch (e) {
        Get.snackbar('Error', 'Terjadi kesalahan saat mengirim permintaan');
      } finally {
        isSubmitting(false);
      }
      return;
    }

    try {
      isSubmitting(true);
      final tgl = tanggalPinjam ?? DateTime.now().toIso8601String().substring(0, 10);
      final response = await http.post(
        Uri.parse('${ApiConfig.akuSehat}/member/peminjaman-pita'),
        headers: _auth.akuSehatHeaders(),
        body: jsonEncode({
          'jumlah_pita': jumlahPita,
          'tanggal_pinjam': tgl,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final res = jsonDecode(response.body);
        Get.snackbar('Berhasil', res['message'] ?? 'Pengajuan pita dikirim');
        await fetchPitaData();
      } else {
        final err = jsonDecode(response.body);
        Get.snackbar('Gagal', err['message'] ?? 'Gagal mengajukan peminjaman pita');
      }
    } catch (e) {
      Get.snackbar('Error', 'Gagal mengirim permintaan');
    } finally {
      isSubmitting(false);
    }
  }


  // =========================================================================
  // HEMOGLOBIN — via SatuSekolah backend
  // =========================================================================
  Future<void> updateHemoglobin(double hb) async {
    try {
      isSubmitting(true);
      final token = await _getMainToken();
      if (token == null) return;

      final response = await http.post(
        Uri.parse('${ApiConfig.satuSekolah}/health/hemoglobin/update'),
        headers: ApiConfig.bearerHeaders(token),
        body: jsonEncode({'hemoglobin': hb}),
      );

      if (response.statusCode == 200) {
        final res = jsonDecode(response.body);
        Get.snackbar('Berhasil', res['message'] ?? 'Data HB diperbarui');
        hemoglobin.value = hb;
        Get.back();
      }
    } catch (e) {
      Get.snackbar('Error', 'Gagal memperbarui data Hemoglobin');
    } finally {
      isSubmitting(false);
    }
  }

  // =========================================================================
  // REQUEST UKS — via SatuSekolah backend
  // =========================================================================
  Future<void> requestUks(String keluhan) async {
    try {
      isSubmitting(true);
      final token = await _getMainToken();
      if (token == null) return;

      final response = await http.post(
        Uri.parse('${ApiConfig.satuSekolah}/health/request_uks'),
        headers: ApiConfig.bearerHeaders(token),
        body: jsonEncode({'keluhan': keluhan}),
      );

      if (response.statusCode == 200) {
        final res = jsonDecode(response.body);
        Get.snackbar('Berhasil', res['message'] ?? 'Permintaan UKS dikirim');
        Get.back();
      }
    } catch (e) {
      Get.snackbar('Error', 'Gagal mengirim pengajuan UKS');
    } finally {
      isSubmitting(false);
    }
  }
}
