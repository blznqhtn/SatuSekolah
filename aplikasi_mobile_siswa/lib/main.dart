// =============================================================================
// main.dart — Entry Point Aplikasi SatuSekolah
// =============================================================================

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:aplikasi_mobile_siswa/features/auth/controllers/auth_controller.dart';
import 'package:aplikasi_mobile_siswa/features/auth/screens/login_screen.dart';
import 'package:aplikasi_mobile_siswa/features/dashboard/screens/main_wrapper_screen.dart';
import 'package:aplikasi_mobile_siswa/core/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi format tanggal bahasa Indonesia
  try {
    await initializeDateFormatting('id_ID', null);
    await initializeDateFormatting('id', null);
  } catch (e) {
    debugPrint('Date formatting init error: $e');
  }

  // Inisialisasi local storage GetStorage
  await GetStorage.init();

  // Inisialisasi Firebase & NotificationService dengan try-catch agar graceful
  // jika google-services.json belum dikonfigurasi di environment developer
  try {
    await Firebase.initializeApp();
    await NotificationService().initialize();
  } catch (e) {
    debugPrint('Firebase/Notification init warning (development mode): $e');
  }

  // Daftarkan AuthController secara permanen di memori
  final authCtrl = Get.put(AuthController(), permanent: true);

  runApp(MyApp(isLoggedIn: authCtrl.isLoggedIn));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;
  const MyApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'SatuSekolah',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF055D97),
          surface: Colors.white,
        ),
        fontFamily: 'Inter',
        useMaterial3: true,
      ),
      initialRoute: isLoggedIn ? '/home' : '/login',
      getPages: [
        GetPage(
          name: '/login',
          page: () => const LoginScreen(),
          transition: Transition.fadeIn,
        ),
        GetPage(
          name: '/home',
          page: () => const MainWrapperScreen(),
          transition: Transition.fadeIn,
        ),
      ],
    );
  }
}
