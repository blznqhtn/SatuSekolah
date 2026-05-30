// =============================================================================
// attendance_controller.dart — Presensi via SeHadir API
// =============================================================================
import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:aplikasi_mobile_siswa/core/config/api_config.dart';
import 'package:aplikasi_mobile_siswa/core/services/external_auth_service.dart';

class AttendanceController extends GetxController {
  final _auth = ExternalAuthService();

  var isLoading = true.obs;
  var isSubmitting = false.obs;

  // ─── Dashboard Data ───────────────────────────────────────────────────────
  var bulanIni = ''.obs;
  var persentaseKehadiran = 0.0.obs;
  var rekap = {}.obs;
  var riwayatMingguan = [].obs;
  var statusHariIni = ''.obs;
  var rfidData = {}.obs;

  // ─── Chart / Statistik ────────────────────────────────────────────────────
  var chartData = [].obs;

  // ─── Leave Documents (Surat Izin/Sakit) ──────────────────────────────────
  var leaveDocuments = [].obs;

  @override
  void onInit() {
    super.onInit();
    fetchDashboardData();
  }

  // ─── Helper: satusekolah token ────────────────────────────────────────────
  Future<String?> _getMainToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token');
  }

  // =========================================================================
  // DASHBOARD DATA — dari backend Go SatuSekolah (yang forward ke SeHadir)
  // =========================================================================
  Future<void> fetchDashboardData() async {
    try {
      isLoading(true);
      final token = await _getMainToken();
      if (token == null) return;

      final response = await http.get(
        Uri.parse('${ApiConfig.satuSekolah}/attendance/dashboard'),
        headers: ApiConfig.bearerHeaders(token),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body)['data'];
        bulanIni.value       = data['bulan_ini'] ?? '';
        persentaseKehadiran.value = (data['persentase_kehadiran'] as num? ?? 0).toDouble();
        rekap.value          = Map<String, dynamic>.from(data['rekap'] ?? {});
        riwayatMingguan.value = List.from(data['riwayat_mingguan'] ?? []);
        statusHariIni.value  = data['status_hari_ini'] ?? '';
        if (data.containsKey('rfid')) rfidData.value = Map<String, dynamic>.from(data['rfid'] ?? {});
      } else {
        // Fallback: coba langsung dari SeHadir jika sudah login
        await _fetchFromSeHadirDirect();
      }
    } catch (e) {
      print('[Attendance] fetchDashboardData error: $e');
      await _fetchFromSeHadirDirect();
    } finally {
      isLoading(false);
    }
  }

  /// Ambil data langsung dari SeHadir jika Go proxy gagal.
  Future<void> _fetchFromSeHadirDirect() async {
    if (!_auth.isSeHadirLoggedIn) return;
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.seHadir}/presensi/charts'),
        headers: _auth.seHadirHeaders(),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body)['data'];
        chartData.value = List.from(data ?? []);
      }
    } catch (e) {
      print('[SeHadir] fetchDirect error: $e');
      Get.snackbar('Error', 'Gagal memuat data absensi');
    }
  }

  // =========================================================================
  // STATISTIK CHART KEHADIRAN — langsung dari SeHadir
  // =========================================================================
  Future<void> fetchAttendanceChart() async {
    if (!_auth.isSeHadirLoggedIn) {
      Get.snackbar('Info', 'Menghubungkan ke SeHadir...');
      return;
    }
    try {
      isLoading(true);
      final response = await http.get(
        Uri.parse('${ApiConfig.seHadir}/presensi/charts'),
        headers: _auth.seHadirHeaders(),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body)['data'];
        chartData.value = List.from(data ?? []);
      }
    } catch (e) {
      print('[SeHadir] fetchChart error: $e');
      Get.snackbar('Error', 'Gagal memuat data grafik kehadiran');
    } finally {
      isLoading(false);
    }
  }

  // =========================================================================
  // SURAT IZIN / SAKIT — via SeHadir API
  // =========================================================================

  /// Ambil daftar surat izin/sakit siswa dari SeHadir.
  Future<void> fetchLeaveDocuments() async {
    if (!_auth.isSeHadirLoggedIn) return;
    try {
      isLoading(true);
      final response = await http.get(
        Uri.parse('${ApiConfig.seHadir}/leave-documents/'),
        headers: _auth.seHadirHeaders(),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body)['data'];
        leaveDocuments.value = List.from(data ?? []);
      }
    } catch (e) {
      print('[SeHadir] fetchLeave error: $e');
      Get.snackbar('Error', 'Gagal memuat surat izin');
    } finally {
      isLoading(false);
    }
  }

  /// Kirim surat izin/sakit ke SeHadir.
  Future<void> submitPermit(
    String tanggal,
    String alasan,
    String keterangan, {
    String? filePath,
  }) async {
    if (!_auth.isSeHadirLoggedIn) {
      Get.snackbar('Error', 'Belum terhubung ke sistem SeHadir');
      return;
    }
    try {
      isSubmitting(true);

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiConfig.seHadir}/leave-documents/send'),
      );
      request.headers.addAll(_auth.seHadirHeaders());
      request.fields['tanggal']    = tanggal;
      request.fields['alasan']     = alasan;
      request.fields['keterangan'] = keterangan;

      if (filePath != null) {
        request.files.add(await http.MultipartFile.fromPath('lampiran', filePath));
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final res = jsonDecode(response.body);
        Get.defaultDialog(
          title: 'Berhasil',
          middleText: res['message'] ?? 'Surat izin berhasil dikirim',
          textConfirm: 'Tutup',
          onConfirm: () {
            fetchLeaveDocuments();
            Get.back();
            Get.back();
          },
        );
      } else {
        final err = jsonDecode(response.body);
        Get.snackbar('Gagal', err['message'] ?? 'Gagal mengirim surat izin');
      }
    } catch (e) {
      Get.snackbar('Error', 'Terjadi kesalahan saat mengirim surat izin');
    } finally {
      isSubmitting(false);
    }
  }

  /// Hapus surat izin berdasarkan ID.
  Future<void> deleteLeaveDocument(String id) async {
    if (!_auth.isSeHadirLoggedIn) return;
    try {
      final response = await http.delete(
        Uri.parse('${ApiConfig.seHadir}/leave-documents/$id'),
        headers: _auth.seHadirHeaders(),
      );

      if (response.statusCode == 200) {
        leaveDocuments.removeWhere((d) => d['id'].toString() == id);
        Get.snackbar('Berhasil', 'Surat izin dihapus');
      } else {
        Get.snackbar('Gagal', 'Tidak dapat menghapus surat izin');
      }
    } catch (e) {
      Get.snackbar('Error', 'Terjadi kesalahan');
    }
  }

  // =========================================================================
  // CHECK-IN (Tetap via SatuSekolah backend Go)
  // =========================================================================
  Future<void> submitCheckIn(double lat, double lng, String filePath) async {
    try {
      isSubmitting(true);
      final token = await _getMainToken();
      if (token == null) return;

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiConfig.satuSekolah}/attendance/checkin'),
      );
      request.headers.addAll(ApiConfig.bearerHeaders(token));
      request.fields['latitude']  = lat.toString();
      request.fields['longitude'] = lng.toString();
      request.files.add(await http.MultipartFile.fromPath('foto', filePath));

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final res = jsonDecode(response.body);
        Get.defaultDialog(
          title: 'Berhasil',
          middleText: res['message'] ?? 'Presensi berhasil',
          textConfirm: 'Tutup',
          onConfirm: () {
            fetchDashboardData();
            Get.back();
            Get.back();
          },
        );
      } else {
        Get.snackbar('Gagal', 'Gagal memproses absensi');
      }
    } catch (e) {
      Get.snackbar('Error', 'Terjadi kesalahan saat check-in');
    } finally {
      isSubmitting(false);
    }
  }
}
