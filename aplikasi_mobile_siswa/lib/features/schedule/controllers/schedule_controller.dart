import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:get/get.dart' hide Response;
import 'package:aplikasi_mobile_siswa/core/services/api_service.dart';

class ScheduleItem {
  final String id;
  final String subject;
  final String teacherName;
  final String room;
  final String startTime;
  final String endTime;
  final int dayOfWeek;

  const ScheduleItem({
    required this.id,
    required this.subject,
    required this.teacherName,
    required this.room,
    required this.startTime,
    required this.endTime,
    required this.dayOfWeek,
  });

  factory ScheduleItem.fromJson(Map<String, dynamic> json) {
    return ScheduleItem(
      id: json['id']?.toString() ?? json['schedule_id']?.toString() ?? '',
      subject: json['subject']?.toString() ??
          json['course_name']?.toString() ??
          json['activity_name']?.toString() ??
          'Pelajaran',
      teacherName: json['teacher_name']?.toString() ??
          json['staff_name']?.toString() ??
          '-',
      room: json['room']?.toString() ?? 'Ruang Kelas',
      startTime: json['start_time']?.toString() ?? '07:00',
      endTime: json['end_time']?.toString() ?? '08:00',
      dayOfWeek: json['day_of_week'] as int? ?? 1,
    );
  }

  TimeOfDay get start {
    try {
      final parts = startTime.split(':');
      return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
    } catch (_) {
      return const TimeOfDay(hour: 7, minute: 0);
    }
  }

  TimeOfDay get end {
    try {
      final parts = endTime.split(':');
      return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
    } catch (_) {
      return const TimeOfDay(hour: 8, minute: 0);
    }
  }

  String get formattedTime {
    final sParts = startTime.split(':');
    final eParts = endTime.split(':');
    final s = sParts.length >= 2 ? '${sParts[0]}:${sParts[1]}' : startTime;
    final e = eParts.length >= 2 ? '${eParts[0]}:${eParts[1]}' : endTime;
    return '$s - $e';
  }

  IconData get icon {
    final lower = subject.toLowerCase();
    if (lower.contains('matematika')) return Icons.calculate_rounded;
    if (lower.contains('web') || lower.contains('komputer') || lower.contains('pemrograman')) return Icons.computer_rounded;
    if (lower.contains('basis data') || lower.contains('database')) return Icons.storage_rounded;
    if (lower.contains('inggris')) return Icons.language_rounded;
    if (lower.contains('indonesia')) return Icons.menu_book_rounded;
    if (lower.contains('agama')) return Icons.mosque_rounded;
    if (lower.contains('upacara')) return Icons.flag_rounded;
    return Icons.school_rounded;
  }

  Color get color {
    final lower = subject.toLowerCase();
    if (lower.contains('matematika')) return const Color(0xFF2563EB);
    if (lower.contains('web') || lower.contains('pemrograman')) return const Color(0xFF7C3AED);
    if (lower.contains('basis data')) return const Color(0xFF0D9488);
    if (lower.contains('inggris')) return const Color(0xFFDC2626);
    if (lower.contains('indonesia')) return const Color(0xFF059669);
    if (lower.contains('agama')) return const Color(0xFF055D97);
    if (lower.contains('upacara')) return const Color(0xFFE11D48);
    return const Color(0xFFD97706);
  }
}

class ScheduleController extends GetxController {
  final isLoading = false.obs;
  final schedules = <ScheduleItem>[].obs;
  final todaySchedules = <ScheduleItem>[].obs;
  final selectedDay = 0.obs; // 0 = Senin
  final errorMessage = ''.obs;

  static const List<String> dayNames = [
    'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu'
  ];

  @override
  void onInit() {
    super.onInit();
    final today = DateTime.now().weekday; // 1=Senin, 7=Minggu
    selectedDay.value = (today <= 5) ? today - 1 : 0;
    fetchTodaySchedules();
    fetchSchedules();
  }

  void selectDay(int dayIndex) {
    selectedDay.value = dayIndex;
    fetchSchedules();
  }

  Future<void> fetchTodaySchedules() async {
    final today = DateTime.now().weekday;
    final dayOfWeek = (today <= 5) ? today : 1;
    try {
      final response = await ApiService.dio.get('/academic/schedules/student/day/$dayOfWeek');
      if (response.statusCode == 200) {
        final data = response.data;
        List<dynamic> list = [];
        if (data is List) {
          list = data;
        } else if (data is Map && data['data'] is List) {
          list = data['data'] as List;
        }
        final items = list.map((item) => ScheduleItem.fromJson(item as Map<String, dynamic>)).toList();
        items.sort((a, b) => a.startTime.compareTo(b.startTime));
        todaySchedules.value = items;
      }
    } catch (_) {}
  }

  Future<void> fetchSchedules() async {
    isLoading.value = true;
    errorMessage.value = '';

    final dayOfWeek = selectedDay.value + 1;

    try {
      final response = await ApiService.dio.get('/academic/schedules/student/day/$dayOfWeek');

      if (response.statusCode == 200) {
        final data = response.data;
        List<dynamic> list = [];
        if (data is List) {
          list = data;
        } else if (data is Map && data['data'] is List) {
          list = data['data'] as List;
        }

        final items = list
            .map((item) => ScheduleItem.fromJson(item as Map<String, dynamic>))
            .toList();

        items.sort((a, b) => a.startTime.compareTo(b.startTime));
        schedules.value = items;

        if (dayOfWeek == (DateTime.now().weekday <= 5 ? DateTime.now().weekday : 1)) {
          todaySchedules.value = items;
        }
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError) {
        errorMessage.value = 'Tidak bisa terhubung ke server.';
      } else {
        errorMessage.value = e.response?.data?['error']?.toString() ??
            'Gagal memuat jadwal.';
      }
    } finally {
      isLoading.value = false;
    }
  }
}
