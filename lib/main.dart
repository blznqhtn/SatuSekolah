import 'package:flutter/material.dart';
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
        primarySwatch: Colors.blue,
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
      ),
      home: const LoginScreen(),
    );
  }
}