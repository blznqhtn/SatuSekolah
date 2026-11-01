import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:get_storage/get_storage.dart';

class ApiService {
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:8080';
    }
    // Emulator Android menggunakan 10.0.2.2 untuk mengakses localhost mesin host
    return 'http://10.0.2.2:8080';
  }

  static Map<String, String> get headers {
    final box = GetStorage();
    final token = box.read('token') ?? '';
    final h = <String, String>{
      'Content-Type': 'application/json',
    };
    if (token.isNotEmpty) {
      h['Authorization'] = 'Bearer $token';
    }
    return h;
  }

  // Helper untuk melakukan request GET dengan timeout
  static Future<dynamic> get(String path) async {
    try {
      final url = Uri.parse('$baseUrl$path');
      final response = await http.get(url, headers: headers).timeout(const Duration(seconds: 4));
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      debugPrint('ApiService GET error on $path: $e');
    }
    return null;
  }

  // Helper untuk POST
  static Future<dynamic> post(String path, Map<String, dynamic> body) async {
    try {
      final url = Uri.parse('$baseUrl$path');
      final response = await http
          .post(url, headers: headers, body: jsonEncode(body))
          .timeout(const Duration(seconds: 4));
      return jsonDecode(response.body);
    } catch (e) {
      debugPrint('ApiService POST error on $path: $e');
    }
    return null;
  }

  // =========================================================================
  // HELPER FORMAT RUPIAH & SELECTED CHILD
  // =========================================================================
  static String formatRupiah(num amount) {
    final str = amount.toInt().toString();
    final buffer = StringBuffer();
    for (int i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) {
        buffer.write('.');
      }
      buffer.write(str[i]);
    }
    return 'Rp ${buffer.toString()}';
  }

  static Map<String, dynamic>? getSelectedChild() {
    final box = GetStorage();
    final raw = box.read('selected_child');
    if (raw is Map) {
      return Map<String, dynamic>.from(raw);
    }
    return null;
  }

  static void setSelectedChild(Map<String, dynamic> child) {
    final box = GetStorage();
    box.write('selected_child', child);
    box.write('selectedChildId', child['id']);
    box.write('selectedChildName', child['name']);
    box.write('selectedChildClass', child['class_name']);
  }

  // =========================================================================
  // 1. DATA ANAK (CHILDREN)
  // =========================================================================
  static Future<List<Map<String, dynamic>>> getChildren() async {
    List<Map<String, dynamic>> list = [];
    final res = await get('/api/v1/users/children');
    if (res != null && res['data'] is List && (res['data'] as List).isNotEmpty) {
      list = List<Map<String, dynamic>>.from(res['data']);
    } else {
      // Fallback data anak jika database kosong atau offline
      list = [
        {
          'id': 'b1111111-1111-1111-1111-111111111111',
          'name': 'Budi Siswa Teladan',
          'nisn': '0012345678',
          'class_name': 'XII RPL 1',
          'initials': 'BT',
        },
        {
          'id': 'b2222222-2222-2222-2222-222222222222',
          'name': 'Rina Kartini',
          'nisn': '0098765432',
          'class_name': 'X RPL 2',
          'initials': 'RK',
        },
      ];
    }

    if (getSelectedChild() == null && list.isNotEmpty) {
      setSelectedChild(list.first);
    }
    return list;
  }

  // =========================================================================
  // 2. PRESENSI (ATTENDANCE)
  // =========================================================================
  static Future<Map<String, dynamic>> getAttendanceSummary(String childId) async {
    final res = await get('/api/v1/attendance/summary?child_id=$childId');
    if (res != null && res['data'] != null) {
      return Map<String, dynamic>.from(res['data']);
    }
    return {
      'total_hadir': 24,
      'total_sakit': 1,
      'total_izin': 0,
      'total_alpha': 1,
    };
  }

  static Future<List<Map<String, dynamic>>> getAttendanceHistory(String childId) async {
    final res = await get('/api/v1/attendance/history?child_id=$childId');
    if (res != null && res['data'] is List && (res['data'] as List).isNotEmpty) {
      return List<Map<String, dynamic>>.from(res['data']);
    }
    return [
      {
        'date': '2026-05-18',
        'day': 'Senin',
        'status': 'PRESENT',
        'course': 'Matematika',
        'time_start': '08:00',
        'time_end': '09:30',
        'teacher': 'Drs. Supriyanto, M.Pd',
      },
      {
        'date': '2026-05-18',
        'day': 'Senin',
        'status': 'PRESENT',
        'course': 'Bahasa Indonesia',
        'time_start': '09:45',
        'time_end': '11:15',
        'teacher': 'Siti Rahmawati, S.Pd',
      },
      {
        'date': '2026-05-15',
        'day': 'Jumat',
        'status': 'PRESENT',
        'course': 'Bahasa Inggris',
        'time_start': '08:00',
        'time_end': '09:30',
        'teacher': 'Ahmad Fauzi, S.Pd',
      },
      {
        'date': '2026-05-14',
        'day': 'Kamis',
        'status': 'SICK',
        'course': 'Basis Data',
        'time_start': '10:15',
        'time_end': '12:00',
        'teacher': 'Ir. Hendra Kusuma',
        'notes': 'Izin sakit UKS',
      },
    ];
  }

  // =========================================================================
  // 3. TAGIHAN & PEMBAYARAN SPP (FINANCE)
  // =========================================================================
  static Future<List<Map<String, dynamic>>> getInvoices(String studentId) async {
    final res = await get('/api/v1/finance/invoices?student_id=$studentId');
    if (res != null && res['data'] is List && (res['data'] as List).isNotEmpty) {
      return List<Map<String, dynamic>>.from(res['data']);
    }
    return [
      {
        'id': 'in000001-1111-1111-1111-111111111111',
        'invoice_name': 'Tagihan SPP Mei 2026',
        'total_amount': 600000,
        'status': 'UNPAID',
        'due_date': '2026-05-10',
        'transfer_target_account': 'VA-88880012345678',
        'dynamic_qr_code': 'QR-SPP-MEI-2026',
      },
      {
        'id': 'in000002-1111-1111-1111-111111111111',
        'invoice_name': 'Tagihan SPP April 2026',
        'total_amount': 600000,
        'status': 'PAID',
        'due_date': '2026-04-10',
        'paid_at': '2026-04-05 09:30:00',
        'transfer_target_account': 'VA-88880012345678',
      },
      {
        'id': 'in000003-1111-1111-1111-111111111111',
        'invoice_name': 'Tagihan SPP Maret 2026',
        'total_amount': 600000,
        'status': 'PAID',
        'due_date': '2026-03-10',
        'paid_at': '2026-03-04 11:15:00',
        'transfer_target_account': 'VA-88880012345678',
      },
    ];
  }

  static Future<bool> payInvoice(String invoiceId, double amount) async {
    final res = await post('/api/v1/finance/invoices/pay-dynamic-qr', {
      'invoice_id': invoiceId,
      'amount': amount,
    });
    return res != null && res['message'] != null;
  }

  // =========================================================================
  // 4. RAPOR & NILAI (ACADEMIC)
  // =========================================================================
  static Future<Map<String, dynamic>?> getReportCard(String studentId) async {
    final res = await get('/api/v1/academic/report-cards/student/$studentId');
    if (res != null && res['data'] != null) {
      return Map<String, dynamic>.from(res['data']);
    }
    return {
      'term_name': 'Semester Ganjil 2025/2026',
      'class_rank': 3,
      'average_score': 89.5,
      'homeroom_notes': 'Prestasi belajar sangat memuaskan. Pertahankan di semester berikutnya.',
      'grades': [
        {'course_name': 'Matematika', 'score': 88, 'predicate': 'A', 'description': 'Sangat menguasai kalkulus dan aljabar'},
        {'course_name': 'Bahasa Indonesia', 'score': 92, 'predicate': 'A', 'description': 'Sangat aktif dalam literasi & penulisan karya'},
        {'course_name': 'Pemrograman Web', 'score': 95, 'predicate': 'A', 'description': 'Kreativitas dan logika pemrograman istimewa'},
        {'course_name': 'Basis Data', 'score': 90, 'predicate': 'A', 'description': 'Memahami perancangan ERD dan optimasi SQL'},
        {'course_name': 'Bahasa Inggris', 'score': 85, 'predicate': 'B', 'description': 'Komunikasi lisan dan tulisan baik'},
        {'course_name': 'Pendidikan Agama Islam', 'score': 87, 'predicate': 'A', 'description': 'Karakter dan akhlak mulia terpuji'},
      ],
    };
  }

  // =========================================================================
  // 5. KESEHATAN UKS (HEALTH)
  // =========================================================================
  static Future<Map<String, dynamic>?> getHealthSummary(String studentId) async {
    final res = await get('/api/v1/health/student/$studentId/summary');
    if (res != null && res['data'] != null) {
      return Map<String, dynamic>.from(res['data']);
    }
    return {
      'height': 172.0,
      'weight': 65.0,
      'bmi': 22.0,
      'status': 'Normal & Sehat',
      'blood_pressure': '110/70',
      'last_checkup': '14 Mei 2026',
    };
  }

  static Future<List<Map<String, dynamic>>> getHealthCheckups(String studentId) async {
    final res = await get('/api/v1/health/student/$studentId/checkups');
    if (res != null && res['data'] is List && (res['data'] as List).isNotEmpty) {
      return List<Map<String, dynamic>>.from(res['data']);
    }
    return [
      {
        'date': '2026-05-14',
        'complaint': 'Pemeriksaan fisik berkala UKS',
        'diagnosis': 'Kondisi fisik prima dan sehat',
        'treatment': 'Diberikan suplemen vitamin C',
        'examiner_name': 'dr. Siti Rahma (Dokter UKS)',
        'height': 172.0,
        'weight': 65.0,
        'temperature': 36.5,
        'blood_pressure': '110/70',
      },
      {
        'date': '2026-04-10',
        'complaint': 'Keluhan pusing ringan',
        'diagnosis': 'Kelelahan setelah kegiatan olahraga',
        'treatment': 'Istirahat 30 menit & teh hangat manis',
        'examiner_name': 'Bidan Nurul',
        'height': 171.8,
        'weight': 64.5,
        'temperature': 36.6,
        'blood_pressure': '115/75',
      },
    ];
  }

  // =========================================================================
  // 6. JADWAL PELAJARAN (SCHEDULES)
  // =========================================================================
  static Future<List<Map<String, dynamic>>> getSchedules(int dayOfWeek, {String? childId}) async {
    String query = '';
    if (childId != null && childId.isNotEmpty) {
      query = '?child_id=$childId';
    }
    final res = await get('/api/v1/academic/schedules/student/day/$dayOfWeek$query');
    if (res != null && res['data'] is List && (res['data'] as List).isNotEmpty) {
      return List<Map<String, dynamic>>.from(res['data']);
    }

    // Default jadwal berdasarkan hari jika offline
    final defaultByDay = {
      1: [
        {'course_name': 'Matematika', 'start_time': '08:00', 'end_time': '09:30', 'staff_name': 'Drs. Supriyanto, M.Pd', 'room': 'R. XII-1'},
        {'course_name': 'Bahasa Indonesia', 'start_time': '09:45', 'end_time': '11:15', 'staff_name': 'Siti Rahmawati, S.Pd', 'room': 'R. XII-1'},
        {'course_name': 'Pendidikan Agama Islam', 'start_time': '11:30', 'end_time': '13:00', 'staff_name': 'Ustadz Mansyur', 'room': 'Masjid Sekolah'},
      ],
      2: [
        {'course_name': 'Pemrograman Web', 'start_time': '08:00', 'end_time': '10:00', 'staff_name': 'Budi Raharjo, S.Kom', 'room': 'Lab Komputer 1'},
        {'course_name': 'Basis Data', 'start_time': '10:15', 'end_time': '12:00', 'staff_name': 'Ir. Hendra Kusuma', 'room': 'Lab Komputer 2'},
      ],
      3: [
        {'course_name': 'Bahasa Inggris', 'start_time': '08:00', 'end_time': '09:30', 'staff_name': 'Ahmad Fauzi, S.Pd', 'room': 'R. XII-1'},
        {'course_name': 'Pemrograman Web', 'start_time': '09:45', 'end_time': '12:00', 'staff_name': 'Budi Raharjo, S.Kom', 'room': 'Lab Komputer 1'},
      ],
      4: [
        {'course_name': 'Basis Data', 'start_time': '08:00', 'end_time': '10:00', 'staff_name': 'Ir. Hendra Kusuma', 'room': 'Lab Komputer 2'},
        {'course_name': 'Matematika', 'start_time': '10:15', 'end_time': '12:00', 'staff_name': 'Drs. Supriyanto, M.Pd', 'room': 'R. XII-1'},
      ],
      5: [
        {'course_name': 'Bahasa Indonesia', 'start_time': '08:00', 'end_time': '09:30', 'staff_name': 'Siti Rahmawati, S.Pd', 'room': 'R. XII-1'},
        {'course_name': 'Bahasa Inggris', 'start_time': '09:45', 'end_time': '11:00', 'staff_name': 'Ahmad Fauzi, S.Pd', 'room': 'R. XII-1'},
      ],
    };

    return defaultByDay[dayOfWeek] ?? defaultByDay[1]!;
  }

  // =========================================================================
  // 7. NILAI GURU / EVALUASI (EVALUATIONS)
  // =========================================================================
  static Future<List<Map<String, dynamic>>> getEligibleTeachers() async {
    final res = await get('/api/v1/evaluations/teachers/eligible');
    if (res != null && res['data'] is List && (res['data'] as List).isNotEmpty) {
      return List<Map<String, dynamic>>.from(res['data']);
    }
    return [
      {
        'id': 't0000001-1111-1111-1111-111111111111',
        'name': 'Drs. Supriyanto, M.Pd',
        'subject': 'Matematika',
        'rating': 4.8,
        'total_reviews': 32,
      },
      {
        'id': 't0000002-1111-1111-1111-111111111111',
        'name': 'Siti Rahmawati, S.Pd',
        'subject': 'Bahasa Indonesia',
        'rating': 4.9,
        'total_reviews': 28,
      },
      {
        'id': 't0000003-1111-1111-1111-111111111111',
        'name': 'Budi Raharjo, S.Kom',
        'subject': 'Pemrograman Web',
        'rating': 4.7,
        'total_reviews': 40,
      },
      {
        'id': 't0000004-1111-1111-1111-111111111111',
        'name': 'Ir. Hendra Kusuma',
        'subject': 'Basis Data',
        'rating': 4.6,
        'total_reviews': 25,
      },
    ];
  }

  static Future<bool> submitEvaluation(String teacherId, int rating, String review) async {
    final res = await post('/api/v1/evaluations/submit', {
      'teacher_id': teacherId,
      'rating': rating,
      'review': review,
    });
    return res != null;
  }

  // =========================================================================
  // 8. KALENDER AKADEMIK (CALENDAR)
  // =========================================================================
  static Future<List<Map<String, dynamic>>> getCalendarEvents(int year, int month) async {
    final res = await get('/api/v1/calendar/month/$year/$month');
    if (res != null && res['data'] is List && (res['data'] as List).isNotEmpty) {
      return List<Map<String, dynamic>>.from(res['data']);
    }
    return [
      {
        'title': 'Ujian Akhir Semester (UAS)',
        'description': 'Pelaksanaan ujian teori dan praktik semester genap',
        'event_date': '2026-05-18',
        'category': 'UJIAN',
      },
      {
        'title': 'Batas Pembayaran SPP Mei',
        'description': 'Jatuh tempo pembayaran SPP bulanan',
        'event_date': '2026-05-10',
        'category': 'KEUANGAN',
      },
      {
        'title': 'Pentas Seni & Gelar Karya Siswa',
        'description': 'Pameran proyek inovasi siswa SMK',
        'event_date': '2026-05-25',
        'category': 'KEGIATAN',
      },
      {
        'title': 'Rapat Pleno Orang Tua & Guru',
        'description': 'Konsultasi perkembangan hasil belajar siswa',
        'event_date': '2026-05-29',
        'category': 'RAPAT',
      },
    ];
  }

  // =========================================================================
  // 9. PELANGGARAN SISWA (VIOLATIONS)
  // =========================================================================
  static Future<int> getViolationPoints(String studentId) async {
    final res = await get('/api/v1/violations/users/$studentId');
    if (res != null && res['data'] is List) {
      int total = 0;
      for (var item in res['data']) {
        total += (item['points_applied'] as num?)?.toInt() ?? 0;
      }
      return total;
    }
    return 0;
  }
}
