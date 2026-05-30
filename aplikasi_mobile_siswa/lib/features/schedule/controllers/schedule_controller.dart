// =============================================================================
// schedule_controller.dart — Jadwal Pelajaran via Backend Go SatuSekolah
// =============================================================================
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:aplikasi_mobile_siswa/core/config/api_config.dart';

class ScheduleItem {
  final String id;
  final String courseId;
  final String mataPelajaran;
  final String guru;
  final String jamMulai;
  final String jamSelesai;
  final int hari;
  final String namaHari;
  final String ruangan;
  String jamKeLabel; // Tambahan untuk UI

  ScheduleItem({
    required this.id,
    required this.courseId,
    required this.mataPelajaran,
    required this.guru,
    required this.jamMulai,
    required this.jamSelesai,
    required this.hari,
    required this.namaHari,
    required this.ruangan,
    this.jamKeLabel = '',
  });

  factory ScheduleItem.fromJson(Map<String, dynamic> json) => ScheduleItem(
        id: json['id']?.toString() ?? '',
        courseId: json['course_id']?.toString() ?? '',
        mataPelajaran: json['mata_pelajaran']?.toString() ?? 'Mata Pelajaran',
        guru: json['guru']?.toString() ?? 'Guru',
        jamMulai: json['jam_mulai']?.toString() ?? '07:00',
        jamSelesai: json['jam_selesai']?.toString() ?? '08:00',
        hari: (json['hari'] as num?)?.toInt() ?? 1,
        namaHari: json['nama_hari']?.toString() ?? 'Senin',
        ruangan: json['ruangan']?.toString() ?? 'Ruang Kelas',
      );

  /// Warna berdasarkan mata pelajaran
  Color get color {
    final lc = mataPelajaran.toLowerCase();
    
    // Mata pelajaran kejuruan (RPL / IT)
    if (lc.contains('pemrograman') || lc.contains('objek') || lc.contains('terstruktur')) return const Color(0xFF6366F1); // Indigo
    if (lc.contains('gim') || lc.contains('game')) return const Color(0xFF8B5CF6); // Purple
    if (lc.contains('basis data') || lc.contains('database')) return const Color(0xFF3B82F6); // Blue
    if (lc.contains('informatika')) return const Color(0xFF0EA5E9); // Sky
    
    // Mata pelajaran umum
    if (lc.contains('matematika')) return const Color(0xFFEF4444); // Red
    if (lc.contains('bahasa indonesia')) return const Color(0xFFF97316); // Orange
    if (lc.contains('bahasa inggris')) return const Color(0xFFF43F5E); // Rose
    if (lc.contains('sunda') || lc.contains('mandarin')) return const Color(0xFFEAB308); // Yellow
    if (lc.contains('agama') || lc.contains('pai')) return const Color(0xFF10B981); // Emerald
    if (lc.contains('ipas') || lc.contains('ipa') || lc.contains('sains')) return const Color(0xFF14B8A6); // Teal
    if (lc.contains('penjaskes') || lc.contains('olahraga')) return const Color(0xFF84CC16); // Lime
    if (lc.contains('pancasila') || lc.contains('ppkn')) return const Color(0xFFF59E0B); // Amber
    if (lc.contains('sejarah')) return const Color(0xFFB45309); // Amber Dark
    
    // Fallback menggunakan hash
    final colors = [
      const Color(0xFF334155), const Color(0xFF0F766E), const Color(0xFF4338CA), 
      const Color(0xFFBE123C), const Color(0xFF0369A1), const Color(0xFF6D28D9)
    ];
    return colors[mataPelajaran.hashCode.abs() % colors.length];
  }

  /// Icon berdasarkan nama mata pelajaran
  dynamic get icon {
    final lc = mataPelajaran.toLowerCase();
    
    // Mata pelajaran umum
    if (lc.contains('matematika')) return FontAwesomeIcons.calculator;
    if (lc.contains('bahasa indonesia') || lc.contains('bahasa inggris') || lc.contains('sunda') || lc.contains('mandarin')) return FontAwesomeIcons.language;
    if (lc.contains('agama') || lc.contains('pai')) return FontAwesomeIcons.bookQuran;
    if (lc.contains('sejarah')) return FontAwesomeIcons.monument;
    if (lc.contains('penjaskes') || lc.contains('olahraga')) return FontAwesomeIcons.personRunning;
    if (lc.contains('pancasila') || lc.contains('ppkn')) return FontAwesomeIcons.scaleBalanced;
    
    // Mata pelajaran kejuruan (RPL / IT)
    if (lc.contains('pemrograman') || lc.contains('objek') || lc.contains('terstruktur') || lc.contains('informatika')) return FontAwesomeIcons.laptopCode;
    if (lc.contains('gim') || lc.contains('game')) return FontAwesomeIcons.gamepad;
    if (lc.contains('basis data') || lc.contains('database')) return FontAwesomeIcons.database;
    if (lc.contains('desain') || lc.contains('grafis')) return FontAwesomeIcons.penNib;
    if (lc.contains('kewirausahaan') || lc.contains('bisnis')) return FontAwesomeIcons.briefcase;
    
    // IPAS (Ilmu Pengetahuan Alam dan Sosial)
    if (lc.contains('ipas') || lc.contains('ipa') || lc.contains('sains')) return FontAwesomeIcons.flask;

    // Jam Kosong / Pulang
    if (lc.contains('tidak ada') || lc.contains('kosong')) return FontAwesomeIcons.house;

    return FontAwesomeIcons.bookOpen;
  }
}

class ScheduleController extends GetxController {
  var isLoading = true.obs;
  var isSeeding = false.obs;

  /// Jadwal per hari: key = nama hari ("Senin", "Selasa", ...)
  var jadwalPerHari = <String, List<ScheduleItem>>{}.obs;

  /// Jadwal hari ini
  var jadwalHariIni = <ScheduleItem>[].obs;

  static const List<String> hariList = [
    'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu'
  ];

  @override
  void onInit() {
    super.onInit();
    fetchSchedule();
    fetchTodaySchedule();
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token');
  }

  // ===========================================================================
  // FETCH — Seluruh jadwal (semua hari)
  // ===========================================================================
  Future<void> fetchSchedule() async {
    try {
      isLoading(true);
      final token = await _getToken();
      if (token == null) return;

      final response = await http.get(
        Uri.parse('${ApiConfig.satuSekolah}/schedule'),
        headers: ApiConfig.bearerHeaders(token),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final jadwal = data['jadwal'] as Map<String, dynamic>?;

        if (jadwal != null) {
          final parsed = <String, List<ScheduleItem>>{};
          for (final hari in hariList) {
            final items = jadwal[hari];
            if (items is List) {
              var list = items
                  .map((j) => ScheduleItem.fromJson(j as Map<String, dynamic>))
                  .toList();
              // Assign period number sequentially
              for (int i = 0; i < list.length; i++) {
                list[i].jamKeLabel = '${i + 1}';
              }
              parsed[hari] = list;
            } else {
              parsed[hari] = [];
            }
          }
          jadwalPerHari.value = parsed;
        }

        // Jika jadwal kosong, coba seed otomatis
        final totalItems = jadwalPerHari.values.fold<int>(0, (s, l) => s + l.length);
        if (totalItems == 0) {
          await seedSchedule();
        }
      }
    } catch (e) {
      print('[Schedule] fetchSchedule error: $e');
      // Fallback ke data contoh
      _setFallbackData();
    } finally {
      isLoading(false);
    }
  }

  // ===========================================================================
  // FETCH — Jadwal hari ini
  // ===========================================================================
  Future<void> fetchTodaySchedule() async {
    try {
      final token = await _getToken();
      if (token == null) return;

      final response = await http.get(
        Uri.parse('${ApiConfig.satuSekolah}/schedule/today'),
        headers: ApiConfig.bearerHeaders(token),
      ).timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final jadwal = data['jadwal'];
        if (jadwal is List) {
          var list = jadwal
              .map((j) => ScheduleItem.fromJson(j as Map<String, dynamic>))
              .toList();
          for (int i = 0; i < list.length; i++) {
            list[i].jamKeLabel = '${i + 1}';
          }
          jadwalHariIni.value = list;
        }
      }
    } catch (e) {
      print('[Schedule] fetchTodaySchedule error: $e');
    }
  }

  // ===========================================================================
  // SEED — Isi jadwal contoh ke DB (dev only)
  // ===========================================================================
  Future<void> seedSchedule() async {
    try {
      isSeeding(true);
      final token = await _getToken();
      if (token == null) return;

      final response = await http.post(
        Uri.parse('${ApiConfig.satuSekolah}/schedule/seed'),
        headers: ApiConfig.bearerHeaders(token),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final jumlah = data['jumlah'] ?? 0;
        if (jumlah > 0) {
          print('[Schedule] Seeded $jumlah jadwal entries');
          await fetchSchedule();
        }
      }
    } catch (e) {
      print('[Schedule] seed error: $e');
    } finally {
      isSeeding(false);
    }
  }

  /// Ambil jadwal untuk hari tertentu
  List<ScheduleItem> getJadwalHari(String hari) {
    return jadwalPerHari[hari] ?? [];
  }

  /// Nama hari ini dalam Bahasa Indonesia
  String get namaHariIni {
    const hari = ['Minggu', 'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu'];
    return hari[DateTime.now().weekday % 7];
  }

  /// Index tab hari ini (untuk TabController, Senin=0 ... Jumat=4)
  int get todayTabIndex {
    final day = DateTime.now().weekday; // 1=Mon ... 7=Sun
    if (day >= 1 && day <= 5) return day - 1;
    return 0; // Sabtu/Minggu → tampilkan Senin
  }

  // ===========================================================================
  // Fallback data jika API tidak tersedia
  // ===========================================================================
  void _setFallbackData() {
    final fallback = <String, List<ScheduleItem>>{};
    for (final hari in hariList) {
      fallback[hari] = [];
    }
    // Senin minimal
    fallback['Senin'] = [
      ScheduleItem(
        id: '1', courseId: '1',
        mataPelajaran: 'Matematika', guru: 'Guru Matematika',
        jamMulai: '08:00', jamSelesai: '08:40',
        hari: 1, namaHari: 'Senin', ruangan: 'Ruang Kelas',
      ),
    ];
    jadwalPerHari.value = fallback;
  }
}
