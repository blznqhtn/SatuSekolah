// =============================================================================
// notification_controller.dart — Fetch & Manage Notifikasi dari Backend
// =============================================================================
// Endpoint: GET  /api/v1/notifications/
//           PUT  /api/v1/notifications/:id/read
//           DELETE /api/v1/notifications/:id
// =============================================================================

import 'package:dio/dio.dart';
import 'package:get/get.dart' hide Response;
import 'package:aplikasi_mobile_siswa/core/services/api_service.dart';

class NotificationItem {
  final String id;
  final String title;
  final String message;
  final String type;
  final bool isRead;
  final String createdAt;

  const NotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.isRead,
    required this.createdAt,
  });

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    return NotificationItem(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      message: json['message']?.toString() ?? json['body']?.toString() ?? '',
      type: json['type']?.toString() ?? 'general',
      isRead: json['is_read'] as bool? ?? false,
      createdAt: json['created_at']?.toString() ?? '',
    );
  }

  NotificationItem copyWith({bool? isRead}) {
    return NotificationItem(
      id: id,
      title: title,
      message: message,
      type: type,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt,
    );
  }
}

class NotificationController extends GetxController {
  final isLoading = false.obs;
  final notifications = <NotificationItem>[].obs;
  final errorMessage = ''.obs;

  /// Jumlah notifikasi yang belum dibaca.
  int get unreadCount => notifications.where((n) => !n.isRead).length;

  @override
  void onInit() {
    super.onInit();
    fetchNotifications();
  }

  Future<void> fetchNotifications() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final response = await ApiService.dio.get('/notifications/');
      if (response.statusCode == 200) {
        final data = response.data;
        List<dynamic> list;
        if (data is List) {
          list = data;
        } else if (data is Map && data['data'] is List) {
          list = data['data'] as List;
        } else {
          list = [];
        }

        notifications.value = list
            .map((item) =>
                NotificationItem.fromJson(item as Map<String, dynamic>))
            .toList();
      }
    } on DioException catch (e) {
      errorMessage.value =
          e.response?.data?['error']?.toString() ?? 'Gagal memuat notifikasi.';
    } finally {
      isLoading.value = false;
    }
  }

  /// Tandai satu notifikasi sebagai sudah dibaca.
  Future<void> markAsRead(String id) async {
    try {
      await ApiService.dio.put('/notifications/$id/read');
      final index = notifications.indexWhere((n) => n.id == id);
      if (index != -1) {
        notifications[index] = notifications[index].copyWith(isRead: true);
      }
    } catch (_) {
      // Silent fail — UI tetap update
    }
  }

  /// Hapus satu notifikasi.
  Future<void> deleteNotification(String id) async {
    try {
      await ApiService.dio.delete('/notifications/$id');
      notifications.removeWhere((n) => n.id == id);
    } on DioException catch (e) {
      errorMessage.value =
          e.response?.data?['error']?.toString() ?? 'Gagal menghapus notifikasi.';
    }
  }
}
