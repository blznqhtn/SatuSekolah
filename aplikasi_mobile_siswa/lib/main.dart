// =============================================================================
// main.dart — Entry Point Aplikasi SatuSekolah
// =============================================================================
// Tugas file ini:
//   1. Menginisialisasi plugin (NotificationService) sebelum UI dijalankan
//   2. Menjalankan GetMaterialApp sebagai root widget
//   3. Mendaftarkan tema global (warna, font, Material3)
// =============================================================================

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:aplikasi_mobile_siswa/features/auth/screens/login_screen.dart';
import 'package:aplikasi_mobile_siswa/features/auth/controllers/auth_controller.dart';
import 'package:aplikasi_mobile_siswa/core/services/notification_service.dart';

// Top-level function untuk menangani notifikasi di background
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  // Munculkan notifikasi lokal
  if (message.notification != null) {
    await NotificationService().showNotification(
      title: message.notification?.title ?? 'Pengumuman Baru',
      body: message.notification?.body ?? '',
    );
  }
}

/// Entry point. Wajib `async` karena menginisialisasi plugin native
/// sebelum UI dijalankan (`WidgetsFlutterBinding.ensureInitialized()`).
void main() async {
  // Pastikan binding Flutter siap sebelum memanggil kode native
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi Firebase & GetStorage
  await Firebase.initializeApp();
  await GetStorage.init();

  // Daftarkan handler background FCM
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Inisialisasi push notification (channel Android, minta izin, dll)
  await NotificationService().initialize();

  // Dengarkan notifikasi saat aplikasi sedang dibuka (Foreground)
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    if (message.notification != null) {
      NotificationService().showNotification(
        title: message.notification?.title ?? 'Pengumuman Baru',
        body: message.notification?.body ?? '',
      );
    }
  });

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Inisialisasi AuthController secara global agar state tetap hidup (permanen)
    Get.put(AuthController(), permanent: true);

    return GetMaterialApp(
      title: 'SatuSekolah',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFF0F4FF),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6C63FF),
          primary: const Color(0xFF6C63FF),
          secondary: const Color(0xFFFF6B6B),
          background: const Color(0xFFF0F4FF),
          surface: Colors.white,
        ),
        textTheme: GoogleFonts.nunitoTextTheme(),
        useMaterial3: true,
      ),
      // Set LoginScreen sebagai halaman pertama saat aplikasi dibuka
      home: LoginScreen(),
    );
  }
}
