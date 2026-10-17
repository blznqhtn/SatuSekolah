import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:aplikasi_mobile_siswa/features/dashboard/controllers/notification_controller.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({Key? key}) : super(key: key);

  NotificationController get _ctrl =>
      Get.isRegistered<NotificationController>()
          ? Get.find<NotificationController>()
          : Get.put(NotificationController());

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF0F172A), size: 20),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Notifikasi',
          style: TextStyle(
            color: Color(0xFF0F172A),
            fontWeight: FontWeight.bold,
            fontSize: 20,
            letterSpacing: -0.5,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Color(0xFF0F172A)),
            onPressed: () => _ctrl.fetchNotifications(),
          ),
        ],
      ),
      body: Obx(() {
        if (_ctrl.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF055D97)),
          );
        }

        if (_ctrl.errorMessage.value.isNotEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.cloud_off_rounded, size: 56, color: Color(0xFF94A3B8)),
                  const SizedBox(height: 16),
                  Text(
                    _ctrl.errorMessage.value,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Color(0xFF64748B), fontSize: 14),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => _ctrl.fetchNotifications(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF055D97),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Coba Lagi'),
                  ),
                ],
              ),
            ),
          );
        }

        if (_ctrl.notifications.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.notifications_none_rounded, size: 64, color: Colors.grey.shade400),
                const SizedBox(height: 16),
                const Text(
                  'Belum ada notifikasi',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF475569),
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Pemberitahuan akademik dan sekolah akan muncul di sini.',
                  style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          color: const Color(0xFF055D97),
          onRefresh: () => _ctrl.fetchNotifications(),
          child: ListView.separated(
            physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: _ctrl.notifications.length,
            separatorBuilder: (_, __) => const Divider(height: 1, color: Color(0xFFF1F5F9)),
            itemBuilder: (context, index) {
              final item = _ctrl.notifications[index];
              return _buildNotificationTile(item);
            },
          ),
        );
      }),
    );
  }

  Widget _buildNotificationTile(NotificationItem item) {
    final typeConfig = _getTypeConfig(item.type);

    return Dismissible(
      key: Key(item.id.isNotEmpty ? item.id : item.title + item.createdAt),
      direction: DismissDirection.endToStart,
      background: Container(
        color: const Color(0xFFEF4444),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete_outline_rounded, color: Colors.white, size: 24),
      ),
      onDismissed: (_) {
        if (item.id.isNotEmpty) {
          _ctrl.deleteNotification(item.id);
        }
      },
      child: Container(
        color: item.isRead ? Colors.white : const Color(0xFFEFF6FF).withOpacity(0.5),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              if (!item.isRead && item.id.isNotEmpty) {
                _ctrl.markAsRead(item.id);
              }
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: typeConfig.bgColor,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(typeConfig.icon, color: typeConfig.iconColor, size: 22),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                item.title,
                                style: TextStyle(
                                  fontWeight: item.isRead ? FontWeight.w600 : FontWeight.bold,
                                  fontSize: 14,
                                  color: const Color(0xFF0F172A),
                                ),
                              ),
                            ),
                            if (item.createdAt.isNotEmpty) ...[
                              const SizedBox(width: 8),
                              Text(
                                _formatTime(item.createdAt),
                                style: const TextStyle(
                                  color: Color(0xFF94A3B8),
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.message,
                          style: const TextStyle(
                            color: Color(0xFF475569),
                            fontSize: 13,
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (!item.isRead) ...[
                    const SizedBox(width: 8),
                    Container(
                      margin: const EdgeInsets.only(top: 6),
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Color(0xFF2563EB),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _formatTime(String rawDate) {
    try {
      final date = DateTime.tryParse(rawDate);
      if (date == null) return rawDate;
      final now = DateTime.now();
      final diff = now.difference(date);

      if (diff.inMinutes < 60) {
        return '${diff.inMinutes}m lalu';
      } else if (diff.inHours < 24) {
        return '${diff.inHours}j lalu';
      } else if (diff.inDays < 7) {
        return '${diff.inDays}h lalu';
      } else {
        return '${date.day}/${date.month}/${date.year}';
      }
    } catch (_) {
      return rawDate;
    }
  }

  _TypeConfig _getTypeConfig(String type) {
    switch (type.toLowerCase()) {
      case 'assignment':
      case 'academic':
        return _TypeConfig(
          icon: Icons.assignment_rounded,
          bgColor: const Color(0xFFEFF6FF),
          iconColor: const Color(0xFF2563EB),
        );
      case 'grade':
      case 'achievement':
        return _TypeConfig(
          icon: Icons.emoji_events_rounded,
          bgColor: const Color(0xFFFFFBEB),
          iconColor: const Color(0xFFF59E0B),
        );
      case 'warning':
      case 'violation':
      case 'discipline':
        return _TypeConfig(
          icon: Icons.warning_rounded,
          bgColor: const Color(0xFFFEF2F2),
          iconColor: const Color(0xFFE11D48),
        );
      case 'library':
        return _TypeConfig(
          icon: Icons.library_books_rounded,
          bgColor: const Color(0xFFECFDF5),
          iconColor: const Color(0xFF059669),
        );
      case 'counseling':
      case 'permit':
        return _TypeConfig(
          icon: Icons.event_note_rounded,
          bgColor: const Color(0xFFF5F3FF),
          iconColor: const Color(0xFF7C3AED),
        );
      default:
        return _TypeConfig(
          icon: Icons.campaign_rounded,
          bgColor: const Color(0xFFEFF6FF),
          iconColor: const Color(0xFF0284C7),
        );
    }
  }
}

class _TypeConfig {
  final IconData icon;
  final Color bgColor;
  final Color iconColor;

  const _TypeConfig({
    required this.icon,
    required this.bgColor,
    required this.iconColor,
  });
}
