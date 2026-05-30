import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:aplikasi_mobile_siswa/features/auth/controllers/auth_controller.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({Key? key}) : super(key: key);

  final AuthController authController = Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), 
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400), 
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)), 
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: AutofillGroup(
              child: Column(
                mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // LOGO SATUSEKOLAH (menggunakan logo dari Ortu)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/LogoSatuSekolah.png',
                      height: 48,
                      errorBuilder: (context, error, stackTrace) => Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F172A), 
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.school, color: Colors.white, size: 28),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'SatuSekolah',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'Student & Parent Portal',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 32),

                // INPUT EMAIL ATAU USERNAME
                TextFormField(
                  controller: authController.identifierController,
                  autofillHints: const [AutofillHints.email, AutofillHints.username],
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    hintText: 'Email atau Username',
                    hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14), 
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Color(0xFFCBD5E1)), 
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Color(0xFF0F172A), width: 1.5), 
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // INPUT KATA SANDI
                Obx(() => TextFormField(
                  controller: authController.passwordController,
                  obscureText: !authController.isPasswordVisible.value,
                  autofillHints: const [AutofillHints.password],
                  onEditingComplete: () => TextInput.finishAutofillContext(),
                  decoration: InputDecoration(
                    hintText: 'Kata Sandi',
                    hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    suffixIcon: IconButton(
                      icon: Icon(
                        authController.isPasswordVisible.value 
                            ? Icons.visibility 
                            : Icons.visibility_off,
                        color: const Color(0xFF94A3B8),
                      ),
                      onPressed: () {
                        authController.isPasswordVisible.value = !authController.isPasswordVisible.value;
                      },
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Color(0xFF0F172A), width: 1.5),
                    ),
                  ),
                )),
                const SizedBox(height: 24),

                // TOMBOL MASUK
                Obx(() => ElevatedButton(
                  onPressed: authController.isLoading.value ? null : () => authController.login(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F172A), 
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: authController.isLoading.value 
                      ? const SizedBox(
                          height: 20, 
                          width: 20, 
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                        )
                      : const Text(
                          'Masuk ke Akun',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                        ),
                )),
                const SizedBox(height: 16),

                // TOMBOL MASUK DENGAN GOOGLE
                OutlinedButton(
                  onPressed: () => authController.loginWithGoogle(),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF0F172A),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: const BorderSide(color: Color(0xFFE2E8F0)), 
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SvgPicture.network(
                        'https://upload.wikimedia.org/wikipedia/commons/c/c1/Google_%22G%22_logo.svg',
                        height: 20,
                        width: 20,
                        placeholderBuilder: (BuildContext context) => const Icon(Icons.g_mobiledata, size: 24),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        'Masuk dengan Google',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // TEKS BAWAH
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Lupa kata sandi? ',
                      style: TextStyle(color: Color(0xFF64748B), fontSize: 13), 
                    ),
                    GestureDetector(
                      onTap: () {
                        Get.snackbar("Hubungi Sekolah", "Silakan hubungi Admin Sekolah untuk mereset kata sandi Anda.");
                      },
                      child: const Text(
                        'Hubungi Admin Sekolah',
                        style: TextStyle(
                          color: Color(0xFF0F172A), 
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
             ),
            ),
          ),
        ),
      ),
    );
  }
}
