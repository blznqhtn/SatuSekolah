import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class AttendanceController extends GetxController {
  final String apiUrl = 'https://remold-nutshell-extortion.ngrok-free.dev/api'; // Menggunakan URL ngrok

  var isLoading = true.obs;
  var isSubmitting = false.obs;

  var bulanIni = ''.obs;
  var persentaseKehadiran = 0.0.obs;
  var rekap = {}.obs;
  var riwayatMingguan = [].obs;
  var statusHariIni = ''.obs;
  var rfidData = {}.obs;

  @override
  void onInit() {
    super.onInit();
    fetchDashboardData();
  }

  Future<void> fetchDashboardData() async {
    try {
      isLoading(true);
      final response = await http.get(Uri.parse('$apiUrl/attendance/dashboard'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body)['data'];
        bulanIni.value = data['bulan_ini'];
        persentaseKehadiran.value = (data['persentase_kehadiran'] as num).toDouble();
        rekap.value = data['rekap'];
        riwayatMingguan.value = data['riwayat_mingguan'];
        statusHariIni.value = data['status_hari_ini'];
        if (data.containsKey('rfid')) {
          rfidData.value = data['rfid'];
        }
      }
    } catch (e) {
      print("Error fetching attendance data: $e");
      Get.snackbar('Error', 'Gagal memuat data absensi');
    } finally {
      isLoading(false);
    }
  }

  Future<void> submitCheckIn(double lat, double lng, String filePath) async {
    try {
      isSubmitting(true);
      
      var request = http.MultipartRequest('POST', Uri.parse('$apiUrl/attendance/checkin'));
      request.fields['latitude'] = lat.toString();
      request.fields['longitude'] = lng.toString();
      request.files.add(await http.MultipartFile.fromPath('foto', filePath));
      
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      
      if (response.statusCode == 200) {
        final res = jsonDecode(response.body);
        Get.defaultDialog(
          title: "Berhasil",
          middleText: res['message'],
          textConfirm: "Tutup",
          onConfirm: () {
            fetchDashboardData(); // Refresh data
            Get.back(); // Tutup dialog
            Get.back(); // Tutup layar check-in
          }
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

  Future<void> submitPermit(String tanggal, String alasan, String keterangan, {String? filePath}) async {
    try {
      isSubmitting(true);
      
      var request = http.MultipartRequest('POST', Uri.parse('$apiUrl/attendance/permit'));
      request.fields['tanggal'] = tanggal;
      request.fields['alasan'] = alasan;
      request.fields['keterangan'] = keterangan;
      
      if (filePath != null) {
        request.files.add(await http.MultipartFile.fromPath('lampiran', filePath));
      }
      
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      
      if (response.statusCode == 200) {
        final res = jsonDecode(response.body);
        Get.defaultDialog(
          title: "Berhasil",
          middleText: res['message'],
          textConfirm: "Tutup",
          onConfirm: () {
            Get.back(); // Tutup dialog
            Get.back(); // Tutup layar izin
          }
        );
      } else {
        Get.snackbar('Gagal', 'Gagal mengajukan izin');
      }
    } catch (e) {
      Get.snackbar('Error', 'Terjadi kesalahan saat mengajukan izin');
    } finally {
      isSubmitting(false);
    }
  }
}
