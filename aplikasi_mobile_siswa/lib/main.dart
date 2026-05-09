import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:aplikasi_mobile_siswa/features/auth/screens/login_screen.dart';

void main() {
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
      home: const LoginScreen(),
    );
  }
}
