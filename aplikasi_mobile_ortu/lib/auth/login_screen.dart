import 'dart:convert';
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
    if (_identifierController.text.isEmpty ||
        _passwordController.text.isEmpty) {
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
      final url = Uri.parse('http://192.168.1.6:8080/api/login/ortu');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'identifier': _identifierController.text,
          'password': _passwordController.text,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        // --- TAMBAHKAN 3 BARIS INI ---
        final box = GetStorage();
        box.write('isLoggedIn', true);
        box.write('namaOrtu', data['data']['nama']);
        // -----------------------------

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Selamat datang, ${data['data']['nama']}!'),
              backgroundColor: Colors.green),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainScreen()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(data['message'] ?? 'Login Gagal'),
              backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                'Gagal terhubung ke server lokal. Pastikan Go API menyala.'),
            backgroundColor: Colors.orange),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
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

      final url = Uri.parse('http://192.168.1.6:8080/api/login/google/ortu');

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

      if (response.statusCode == 200 && data['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Selamat datang, ${data['data']['nama']}!'),
              backgroundColor: Colors.green),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainScreen()),
        );
      } else {
        await googleSignIn.signOut();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(data['message'] ?? 'Login Gagal'),
              backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors
                .orange), // <--- Agar kita tahu persis apa error dari Google-nya
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
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
