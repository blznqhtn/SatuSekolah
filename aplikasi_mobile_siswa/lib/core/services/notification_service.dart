// =============================================================================
// notification_service.dart — Layanan Push Notification Lokal
// =============================================================================
// Package: flutter_local_notifications
//
// Cara Penggunaan:
//   // Di mana saja dalam aplikasi:
//   await NotificationService().showAnnouncementNotification(
//     'Judul Pengumuman', 'Isi pengumuman...'
//   );
//
// Inisialisasi:
//   Dipanggil SEKALI di main() sebelum runApp():
//   await NotificationService().initialize();
//
// Channel Android:
//   ID     : satu_sekolah_channel
//   Suara  : ✅ (default system sound)
//   Getar  : ✅
//   Prioritas: HIGH (muncul sebagai heads-up notification)
//
// Izin yang Diperlukan (AndroidManifest.xml):
//   POST_NOTIFICATIONS, VIBRATE, RECEIVE_BOOT_COMPLETED
// =============================================================================

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();

  // Channel ID & Name
  static const String _channelId = 'satu_sekolah_channel';
  static const String _channelName = 'SatuSekolah Notifikasi';
  static const String _channelDesc = 'Notifikasi dari aplikasi SatuSekolah';

  /// Inisialisasi plugin — panggil di main() sebelum runApp
  Future<void> initialize() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
    );

    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // Handling ketika notifikasi ditekan (dapat diarahkan ke halaman tertentu)
      },
    );

    // Buat channel notifikasi Android (wajib untuk Android 8.0+)
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(
          const AndroidNotificationChannel(
            _channelId,
            _channelName,
            description: _channelDesc,
            importance: Importance.high,
            playSound: true,
            enableVibration: true,
          ),
        );

    // Minta izin notifikasi (Android 13+)
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  /// Tampilkan notifikasi lokal dengan suara
  Future<void> showNotification({
    int id = 0,
    required String title,
    required String body,
    String? payload,
  }) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDesc,
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      styleInformation: BigTextStyleInformation(''),
      icon: '@mipmap/ic_launcher',
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
    );

    await _plugin.show(id, title, body, details, payload: payload);
  }

  /// Notifikasi pengumuman baru
  Future<void> showAnnouncementNotification(String title, String body) async {
    await showNotification(
      id: 1,
      title: '📢 $title',
      body: body,
      payload: 'announcement',
    );
  }

  /// Notifikasi pengingat kelas
  Future<void> showClassReminderNotification(String subject, String time) async {
    await showNotification(
      id: 2,
      title: '🔔 Kelas Segera Dimulai',
      body: '$subject • Pukul $time',
      payload: 'schedule',
    );
  }

  /// Notifikasi buku baru di perpustakaan
  Future<void> showLibraryNotification(String bookTitle) async {
    await showNotification(
      id: 3,
      title: '📚 Buku Baru Tersedia',
      body: '"$bookTitle" sudah bisa dibaca di E-Perpus',
      payload: 'library',
    );
  }

  /// Batalkan semua notifikasi
  Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }
}
