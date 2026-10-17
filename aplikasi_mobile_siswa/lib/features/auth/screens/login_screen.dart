// =============================================================================
// login_screen.dart — Layar Login Siswa (terhubung ke AuthController)
// =============================================================================

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:aplikasi_mobile_siswa/core/services/api_service.dart';
import 'package:aplikasi_mobile_siswa/features/auth/controllers/auth_controller.dart';
import 'package:aplikasi_mobile_siswa/features/dashboard/screens/main_wrapper_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _identifierCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _authCtrl = Get.put(AuthController());
  bool _obscurePassword = true;

  void _showServerConfigDialog() {
    final urlCtrl = TextEditingController(text: ApiService.baseUrl);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.dns, color: Color(0xFF48C6EF)),
            SizedBox(width: 10),
            Text('Pengaturan Server', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Sesuaikan Base URL backend sesuai perangkat yang digunakan:',
              style: TextStyle(fontSize: 13, color: Colors.black54),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: urlCtrl,
              decoration: InputDecoration(
                labelText: 'Base URL API',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
            ),
            const SizedBox(height: 14),
            const Text('Pilihan Cepat:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                ActionChip(
                  label: const Text('🖥️ Localhost (Windows/Web)', style: TextStyle(fontSize: 11)),
                  onPressed: () => urlCtrl.text = 'http://localhost:8080/api/v1',
                ),
                ActionChip(
                  label: const Text('📱 Emulator (10.0.2.2)', style: TextStyle(fontSize: 11)),
                  onPressed: () => urlCtrl.text = 'http://10.0.2.2:8080/api/v1',
                ),
                ActionChip(
                  label: const Text('📶 Wi-Fi Fisik (192.168.1.8)', style: TextStyle(fontSize: 11)),
                  onPressed: () => urlCtrl.text = 'http://192.168.1.8:8080/api/v1',
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              ApiService.setCustomBaseUrl(null);
              setState(() {});
              Navigator.pop(ctx);
              Get.snackbar('Reset', 'Server URL dikembalikan ke deteksi otomatis.', snackPosition: SnackPosition.BOTTOM);
            },
            child: const Text('Reset Auto', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF48C6EF),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              ApiService.setCustomBaseUrl(urlCtrl.text.trim());
              setState(() {});
              Navigator.pop(ctx);
              Get.snackbar('Tersimpan', 'Server URL diperbarui ke: ${urlCtrl.text.trim()}', snackPosition: SnackPosition.BOTTOM);
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _identifierCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _doLogin() async {
    final identifier = _identifierCtrl.text.trim();
    final password = _passwordCtrl.text;

    if (identifier.isEmpty || password.isEmpty) {
      Get.snackbar(
        'Perhatian',
        'Email/NISN dan password tidak boleh kosong.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange.shade600,
        colorText: Colors.white,
      );
      return;
    }

    final success = await _authCtrl.login(
      identifier: identifier,
      password: password,
    );

    if (success) {
      Get.offAllNamed('/home');
    } else {
      Get.snackbar(
        'Login Gagal',
        _authCtrl.errorMessage.value,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade600,
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header Gradient dengan Logo
            Stack(
              children: [
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
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.school,
                          size: 100,
                          color: Colors.white,
                        ),
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
                        "Student Portal",
                        style: TextStyle(color: Colors.white70, fontSize: 16),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  top: 35,
                  right: 20,
                  child: IconButton(
                    tooltip: 'Pengaturan Server API',
                    icon: const Icon(Icons.settings, color: Colors.white70),
                    onPressed: _showServerConfigDialog,
                  ),
                ),
              ],
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
                  const SizedBox(height: 30),

                  // Email / NISN Input
                  _buildInput(
                    controller: _identifierCtrl,
                    label: "Email atau NISN",
                    icon: Icons.person_outline,
                  ),
                  const SizedBox(height: 20),

                  // Password Input
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: TextField(
                      controller: _passwordCtrl,
                      obscureText: _obscurePassword,
                      onSubmitted: (_) => _doLogin(),
                      decoration: InputDecoration(
                        hintText: "Password",
                        prefixIcon:
                            const Icon(Icons.lock_outline, color: Colors.blueGrey),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: Colors.blueGrey,
                          ),
                          onPressed: () {
                            setState(() => _obscurePassword = !_obscurePassword);
                          },
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 15, horizontal: 20),
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Tombol Masuk
                  Obx(() => SizedBox(
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
                          onPressed:
                              _authCtrl.isLoading.value ? null : _doLogin,
                          child: _authCtrl.isLoading.value
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2.5,
                                  ),
                                )
                              : const Text(
                                  "MASUK",
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                        ),
                      )),

                  const SizedBox(height: 25),

                  // Pembatas "atau"
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

                  // Tombol Masuk dengan Google
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        // TODO: Implementasi Google Sign-In
                        Get.snackbar(
                          'Segera Hadir',
                          'Login dengan Google akan segera tersedia.',
                          snackPosition: SnackPosition.BOTTOM,
                        );
                      },
                      icon: Image.asset(
                        'assets/images/Google_Favicon_2025.png',
                        height: 24,
                        errorBuilder: (_, __, ___) =>
                            const Icon(Icons.g_mobiledata,
                                size: 36, color: Colors.red),
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

                  const SizedBox(height: 18),

                  // Info server aktif
                  Center(
                    child: TextButton.icon(
                      onPressed: _showServerConfigDialog,
                      icon: const Icon(Icons.dns_outlined, size: 14, color: Colors.grey),
                      label: Text(
                        'Server: ${ApiService.baseUrl}',
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInput({
    required TextEditingController controller,
    required String label,
    required IconData icon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(15),
      ),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.emailAddress,
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