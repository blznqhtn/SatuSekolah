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
import 'package:get_storage/get_storage.dart';
import 'package:aplikasi_mobile_siswa/features/auth/screens/login_screen.dart';
import 'package:aplikasi_mobile_siswa/core/services/notification_service.dart';

/// Entry point. Wajib `async` karena menginisialisasi plugin native
/// sebelum UI dijalankan (`WidgetsFlutterBinding.ensureInitialized()`).
void main() async {
  // Pastikan binding Flutter siap sebelum memanggil kode native
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi Firebase & GetStorage
  await Firebase.initializeApp();
  await GetStorage.init();

  // Inisialisasi push notification (channel Android, minta izin, dll)
  await NotificationService().initialize();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'SatuSekolah',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFF8FAFC), 
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF055D97), 
          background: const Color(0xFFF8FAFC),
          surface: Colors.white,
        ),
        fontFamily: 'Inter', 
        useMaterial3: true,
      ),
      // Set LoginScreen sebagai halaman pertama saat aplikasi dibuka
      home: LoginScreen(),
    );
  }
}
