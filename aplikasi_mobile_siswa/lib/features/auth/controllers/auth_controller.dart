import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:aplikasi_mobile_siswa/features/dashboard/screens/main_wrapper_screen.dart';

class AuthController extends GetxController {
  final TextEditingController identifierController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  
  var isLoading = false.obs;
  var isPasswordVisible = false.obs; // State untuk ikon mata password

  // Menggunakan URL publik (Ngrok) agar bisa diakses dari jaringan internet manapun
  final String apiUrl = "https://remold-nutshell-extortion.ngrok-free.dev/api/auth/login";

  Future<void> login() async {
    final identifier = identifierController.text.trim();
    final password = passwordController.text;

    if (identifier.isEmpty || password.isEmpty) {
      Get.snackbar(
        "Kesalahan", 
        "Email/Username dan Kata Sandi wajib diisi!",
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
      );
      return;
    }

    isLoading.value = true;
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          "Content-Type": "application/json",
          "ngrok-skip-browser-warning": "69420"
        },
        body: jsonEncode({
          "identifier": identifier,
          "password": password,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        Get.snackbar(
          "Sukses", 
          "Login berhasil",
          backgroundColor: Colors.green.shade100,
          colorText: Colors.green.shade900,
        );
        // Navigate ke MainWrapperScreen
        Get.offAll(() => MainWrapperScreen());
      } else {
        Get.snackbar(
          "Gagal Login", 
          data['error'] ?? "Terjadi kesalahan",
          backgroundColor: Colors.red.shade100,
          colorText: Colors.red.shade900,
        );
      }
    } catch (e) {
      Get.snackbar(
        "Error", 
        "Tidak dapat terhubung ke server",
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loginWithGoogle() async {
    isLoading.value = true;
    try {
      // Masukkan Web Client ID dari Firebase/Google Cloud Console Anda di sini
      await GoogleSignIn.instance.initialize(
        serverClientId: "545636326515-g6hh48ltgektt0hc23v9cqiruk6ibg24.apps.googleusercontent.com",
      );
      
      // Memicu dialog login akun Google bawaan Android/iOS
      final GoogleSignInAccount? googleUser = await GoogleSignIn.instance.authenticate();
      
      if (googleUser == null) {
        isLoading.value = false;
        return; // Dibatalkan oleh pengguna
      }

      // Mendapatkan autentikasi token dari akun Google
      final googleAuth = googleUser.authentication;
      final String? idToken = googleAuth.idToken;

      if (idToken != null) {
        // Mengirimkan ID Token Google ke backend Go
        final response = await http.post(
          Uri.parse("https://remold-nutshell-extortion.ngrok-free.dev/api/auth/login/google"),
          headers: {
            "Content-Type": "application/json",
            "ngrok-skip-browser-warning": "69420"
          },
          body: jsonEncode({
            "google_token": idToken,
          }),
        );

        final data = jsonDecode(response.body);

        if (response.statusCode == 200) {
          Get.snackbar(
            "Sukses", 
            "Login Google berhasil",
            backgroundColor: Colors.green.shade100,
            colorText: Colors.green.shade900,
          );
          Get.offAll(() => MainWrapperScreen());
        } else {
          Get.snackbar(
            "Gagal Login", 
            data['error'] ?? "Akun Google tidak terdaftar",
            backgroundColor: Colors.red.shade100,
            colorText: Colors.red.shade900,
          );
          // Logout akun Google agar tidak nyangkut jika gagal
          await GoogleSignIn.instance.signOut();
        }
      } else {
        Get.snackbar("Error", "Gagal mendapatkan token dari Google", backgroundColor: Colors.red.shade100);
      }
    } catch (e) {
      Get.snackbar(
        "Error", 
        "Terjadi kesalahan: $e",
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
        duration: const Duration(seconds: 5),
      );
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    identifierController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
