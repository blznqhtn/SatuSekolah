import 'package:flutter/material.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF48C6EF),
        foregroundColor: Colors.white,
        title: const Text("Pendaftaran Orang Tua"),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Top Curve
            Container(
              height: 40,
              decoration: const BoxDecoration(
                color: Color(0xFF48C6EF),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40),
                ),
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.all(30.0),
              child: Column(
                children: [
                  const Text(
                    "Buat Akun Baru",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Lengkapi data di bawah ini untuk mengakses layanan SatuSekolah",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 30),

                  _buildRegisterInput("Nama Lengkap", Icons.person_outline),
                  const SizedBox(height: 15),
                  _buildRegisterInput("Alamat Email", Icons.email_outlined),
                  const SizedBox(height: 15),
                  _buildRegisterInput("Nomor WhatsApp", Icons.phone_android_outlined),
                  const SizedBox(height: 15),
                  _buildRegisterInput("Nama Lengkap Anak", Icons.child_care_outlined),
                  const SizedBox(height: 15),
                  _buildRegisterInput("Password", Icons.lock_outline, isPassword: true),
                  
                  const SizedBox(height: 30),

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
                      ),
                      onPressed: () {
                        // Kembali ke login setelah daftar (mockup)
                        Navigator.pop(context);
                      },
                      child: const Text(
                        "DAFTAR SEKARANG",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  const Text(
                    "Dengan mendaftar, Anda menyetujui Syarat & Ketentuan kami.",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRegisterInput(String label, IconData icon, {bool isPassword = false}) {
    return TextField(
      obscureText: isPassword,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFF6F86D6)),
        filled: true,
        fillColor: Colors.grey[50],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
      ),
    );
  }
}