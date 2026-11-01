import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:google_sign_in/google_sign_in.dart';
import '../main_screen.dart';
import 'package:get_storage/get_storage.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Controller untuk mengambil teks dari inputan
  final TextEditingController _identifierController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;

  // Fungsi Login Biasa
  Future<void> _loginProses() async {
    final identifier = _identifierController.text.trim();
    final password = _passwordController.text.trim();

    if (identifier.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Email/No HP dan Password harus diisi!'),
            backgroundColor: Colors.red),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Menentukan host API (localhost untuk Web, 10.0.2.2 untuk Android emulator)
      String host = 'http://localhost:8080';
      if (!kIsWeb) {
        host = 'http://10.0.2.2:8080';
      }
      final url = Uri.parse('$host/api/login/ortu');

      final response = await http
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'identifier': identifier,
              'password': password,
            }),
          )
          .timeout(const Duration(seconds: 5));

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 &&
          (data['success'] == true || data['token'] != null)) {
        final box = GetStorage();
        box.write('isLoggedIn', true);
        final nama = data['data']?['nama'] ?? data['user']?['name'] ?? 'Kartini Rahayu';
        box.write('namaOrtu', nama);
        box.write('token', data['token'] ?? '');
        box.write('userId', data['data']?['id'] ?? data['user']?['id'] ?? '');
        box.write('email', data['data']?['email'] ?? data['user']?['email'] ?? 'ortu@sekolah.id');
        box.write('phone', data['data']?['phone'] ?? data['user']?['phone'] ?? '081234567890');

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Selamat datang, $nama!'),
              backgroundColor: Colors.green),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainScreen()),
        );
        return;
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(data['message'] ?? data['error'] ?? 'Login Gagal'),
              backgroundColor: Colors.red),
        );
        return;
      }
    } catch (e) {
      // Jika server lokal tidak terjangkau, periksa apakah kredensial demo valid
      if ((identifier == 'ortu@sekolah.id' ||
              identifier == '081234567890' ||
              identifier == 'kartini.r@email.com') &&
          (password == 'ortu123' || password == 'password123')) {
        final box = GetStorage();
        box.write('isLoggedIn', true);
        box.write('namaOrtu', 'Kartini Rahayu');
        box.write('email', 'ortu@sekolah.id');
        box.write('phone', '081234567890');

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Selamat datang, Kartini Rahayu! (Mode Demo)'),
              backgroundColor: Colors.green),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainScreen()),
        );
        return;
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                'Gagal terhubung ke server lokal. Pastikan Go API menyala.'),
            backgroundColor: Colors.orange),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Fungsi Login dengan Google
  Future<void> _loginGoogleProses() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final GoogleSignIn googleSignIn = GoogleSignIn(
        clientId: 'YOUR_CLIENT_ID.apps.googleusercontent.com', // TODO: Ganti dengan Client ID Google Anda
      );
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      String host = 'http://localhost:8080';
      if (!kIsWeb) {
        host = 'http://10.0.2.2:8080';
      }
      final url = Uri.parse('$host/api/login/google/ortu');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': googleUser.email,
          'google_id': googleUser.id,
          'nama': googleUser.displayName ?? 'Pengguna Google',
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && (data['success'] == true || data['token'] != null)) {
        final box = GetStorage();
        box.write('isLoggedIn', true);
        final nama = data['data']?['nama'] ?? googleUser.displayName ?? 'Pengguna Google';
        box.write('namaOrtu', nama);

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Selamat datang, $nama!'),
              backgroundColor: Colors.green),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainScreen()),
        );
      } else {
        await googleSignIn.signOut();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(data['message'] ?? 'Login Gagal'),
              backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.orange),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
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
                  const SizedBox(height: 30),

                  // Form Input dengan penambahan parameter controller
                  _buildInput(
                    controller: _identifierController,
                    label: "Email atau Nomor HP",
                    icon: Icons.person_outline,
                  ),
                  const SizedBox(height: 20),
                  _buildInput(
                    controller: _passwordController,
                    label: "Password",
                    icon: Icons.lock_outline,
                    isPassword: true,
                  ),

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
                      onPressed: _isLoading ? null : _loginProses,
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              "MASUK",
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                    ),
                  ),

                  const SizedBox(height: 25),

                  Row(
                    children: [
                      Expanded(child: Divider(color: Colors.grey[400])),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        child: Text(
                          "atau",
                          style:
                              TextStyle(color: Colors.grey[600], fontSize: 14),
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
                      onPressed: _isLoading ? null : _loginGoogleProses,
                      icon: Image.asset(
                        'assets/images/Google_Favicon_2025.png',
                        height: 24,
                        errorBuilder: (context, error, stackTrace) =>
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

                  const SizedBox(height: 30),

                  // Informasi Akun Demo & Tombol Isi Cepat
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0F4FF),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: const Color(0xFFD0DBF5)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.info_outline, size: 18, color: Color(0xFF4A68C2)),
                            SizedBox(width: 8),
                            Text(
                              "Kredensial Akun Orang Tua (Demo):",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                color: Color(0xFF2C3E6B),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          "• No HP : 081234567890\n• Email : ortu@sekolah.id\n• Sandi : ortu123",
                          style: TextStyle(fontSize: 12, color: Color(0xFF4A5568), height: 1.4),
                        ),
                        const SizedBox(height: 10),
                        InkWell(
                          onTap: () {
                            setState(() {
                              _identifierController.text = "081234567890";
                              _passwordController.text = "ortu123";
                            });
                          },
                          child: Container(
                            alignment: Alignment.center,
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF6F86D6),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              "Gunakan Akun Demo Otomatis",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
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

  // Modifikasi _buildInput untuk menerima TextEditingController
  Widget _buildInput(
      {required TextEditingController controller,
      required String label,
      required IconData icon,
      bool isPassword = false}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(15),
      ),
      child: TextField(
        controller: controller,
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
