import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'main_screen.dart';
import 'auth/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final box = GetStorage();
    bool isLoggedIn = box.read('isLoggedIn') ?? false;

    return MaterialApp(
      title: 'Satu Sekolah Orang Tua',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Nunito',
        primarySwatch: Colors.orange,
        scaffoldBackgroundColor: const Color(0xFFECEAE3), // AppTheme.bg2
      ),
      home: isLoggedIn ? const MainScreen() : const LoginScreen(),
    );
  }
}
