import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // Import library ini
import 'auth/login_screen.dart';

void main() {
  runApp(const ParentSchoolApp());
}

class ParentSchoolApp extends StatelessWidget {
  const ParentSchoolApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Parent Portal',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
        
        // PERBAIKAN: Mengatur Poppins sebagai font utama dan memperbesar ukurannya
        textTheme: GoogleFonts.poppinsTextTheme(
          Theme.of(context).textTheme,
        ).apply(
          fontSizeFactor: 1.1, // Memperbesar semua teks dasar sebesar 10%
          bodyColor: Colors.black87,
          displayColor: Colors.black,
        ),
      ),
      home: const LoginScreen(),
    );
  }
}