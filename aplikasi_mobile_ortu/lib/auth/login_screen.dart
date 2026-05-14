import 'package:flutter/material.dart';
import '../main_navigation.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header Gradient dengan Logo
            Container(
              height: MediaQuery.of(context).size.height * 0.4,
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF48C6EF), Color(0xFF6F86D6)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(80),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/LogoSatuSekolah.png',
                    height: 100, 
                  ),
                  const SizedBox(height: 15),
                  const Text(
                    "SATU SEKOLAH",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                  const Text(
                    "Parent Portal",
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(30.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Selamat Datang",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  // PERBAIKAN: Teks subtitle dihapus
                  const SizedBox(height: 30),

                  // Form Input
                  _buildInput(
                    label: "Email atau Nomor HP",
                    icon: Icons.person_outline,
                  ),
                  const SizedBox(height: 20),
                  _buildInput(
                    label: "Password",
                    icon: Icons.lock_outline,
                    isPassword: true,
                  ),

                  // PERBAIKAN: Tombol Lupa Password dihapus
                  const SizedBox(height: 30),

                  // Tombol Masuk
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6F86D6),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        elevation: 5,
                      ),
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const MainNavigation()),
                        );
                      },
                      child: const Text(
                        "MASUK",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),

                  const SizedBox(height: 25),

                  // PERBAIKAN: Pembatas "atau"
                  Row(
                    children: [
                      Expanded(child: Divider(color: Colors.grey[400])),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        child: Text(
                          "atau",
                          style: TextStyle(color: Colors.grey[600], fontSize: 14),
                        ),
                      ),
                      Expanded(child: Divider(color: Colors.grey[400])),
                    ],
                  ),

                  const SizedBox(height: 25),

                  // PERBAIKAN: Tombol Masuk dengan Google ditambahkan
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        // TODO: Implementasi fungsi autentikasi Google
                      },
                      icon: Image.asset(
                        'assets/images/Google_Favicon_2025.png', // Pastikan Anda menambahkan logo google di folder assets
                        height: 24,
                        // Fallback icon jika gambar google_logo.png belum ada
                        errorBuilder: (context, error, stackTrace) => 
                            const Icon(Icons.g_mobiledata, size: 36, color: Colors.red),
                      ),
                      label: const Text(
                        "Masuk dengan Google",
                        style: TextStyle(
                          color: Colors.black87,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.black26),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                    ),
                  ),
                  // PERBAIKAN: Baris Daftar Sekarang dihapus
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInput(
      {required String label,
      required IconData icon,
      bool isPassword = false}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(15),
      ),
      child: TextField(
        obscureText: isPassword,
        decoration: InputDecoration(
          hintText: label,
          prefixIcon: Icon(icon, color: Colors.blueGrey),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        ),
      ),
    );
  }
}