import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:aplikasi_mobile_siswa/features/dashboard/screens/main_wrapper_screen.dart';
import 'package:aplikasi_mobile_siswa/core/services/notification_service.dart';
import 'package:aplikasi_mobile_siswa/core/services/external_auth_service.dart';

class AuthController extends GetxController {
  final TextEditingController identifierController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  
  var isLoading = false.obs;
  var isPasswordVisible = false.obs; // State untuk ikon mata password
  var isAuthenticated = false.obs;
  Rx<Map<String, dynamic>> userData = Rx<Map<String, dynamic>>({}); // State profil

  @override
  void onInit() {
    super.onInit();
    checkLoginStatus();
  }

  Future<void> checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');
    if (token != null && token.isNotEmpty) {
      isAuthenticated.value = true;
      await loadUserData();
      // Minta izin notifikasi jika user sudah dalam keadaan login (misal dari cache)
      await NotificationService().requestPermission();
    }
  }

  Future<void> loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userStr = prefs.getString('user_data');
    if (userStr != null) {
      final decoded = jsonDecode(userStr) as Map<String, dynamic>;
      userData.value = decoded;
      print('=== loadUserData: berhasil load ${decoded} ===');
    } else {
      print('=== loadUserData: user_data di SharedPreferences KOSONG! ===');
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt_token');
    await prefs.remove('user_data');
    isAuthenticated.value = false;
    userData.value = {};
    // Logout dari semua layanan eksternal
    ExternalAuthService().logoutAll();
    await GoogleSignIn.instance.signOut();
    // Jika perlu navigasi ke halaman login:
    // Get.offAll(() => LoginScreen()); 
  }

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
      // === DEBUG: Lihat response backend ===
      print('=== RESPONSE STATUS: ${response.statusCode} ===');
      print('=== RESPONSE BODY: ${response.body} ===');

      if (response.statusCode == 200) {
        if (data['token'] != null && data['data'] != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('jwt_token', data['token']);
          final userJson = jsonEncode(data['data']);
          await prefs.setString('user_data', userJson);
          print('=== SAVED user_data: $userJson ===');
          isAuthenticated.value = true;
          await loadUserData();
          print('=== userData setelah load: ${userData.value} ===');

          // ── Auto-login ke semua layanan eksternal ──
          final userEmail = data['data']['email']?.toString();
          ExternalAuthService().autoLoginAll(
            identifier: identifier,
            password: password,
            email: userEmail,
          );
        } else {
          print('=== PERINGATAN: data[token] atau data[data] null! ===');
          print('=== token: ${data['token']} ===');
          print('=== data: ${data['data']} ===');
        }

        Get.snackbar(
          "Sukses", 
          "Login berhasil",
          backgroundColor: Colors.green.shade100,
          colorText: Colors.green.shade900,
        );
        // Navigate ke MainWrapperScreen
        await NotificationService().requestPermission();
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
          if (data['token'] != null) {
            final prefs = await SharedPreferences.getInstance();
            await prefs.setString('jwt_token', data['token']);
            await prefs.setString('user_data', jsonEncode(data['data']));
            isAuthenticated.value = true;
            await loadUserData();
          }

          Get.snackbar(
            "Sukses", 
            "Login Google berhasil",
            backgroundColor: Colors.green.shade100,
            colorText: Colors.green.shade900,
          );
          await NotificationService().requestPermission();
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

  // ===============================================
  // PROFILE API INTEGRATION
  // ===============================================

  Future<bool> updateProfile(String noHp, String alamat) async {
    isLoading.value = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt_token');
      if (token == null) return false;

      final response = await http.put(
        Uri.parse("https://remold-nutshell-extortion.ngrok-free.dev/api/profile/update"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
          "ngrok-skip-browser-warning": "69420"
        },
        body: jsonEncode({"no_hp": noHp, "alamat": alamat}),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        if (data['data'] != null) {
          await prefs.setString('user_data', jsonEncode(data['data']));
          await loadUserData();
        }
        Get.snackbar("Sukses", "Profil berhasil diperbarui", backgroundColor: Colors.green.shade100);
        return true;
      } else {
        Get.snackbar("Gagal", data['error'] ?? "Gagal update", backgroundColor: Colors.red.shade100);
        return false;
      }
    } catch (e) {
      Get.snackbar("Error", "Koneksi server gagal", backgroundColor: Colors.red.shade100);
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> requestPasswordToken() async {
    isLoading.value = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt_token');
      if (token == null) return false;

      final response = await http.post(
        Uri.parse("https://remold-nutshell-extortion.ngrok-free.dev/api/profile/password/request-token"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
          "ngrok-skip-browser-warning": "69420"
        },
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        Get.snackbar("Terkirim", "Kode OTP telah dikirim", backgroundColor: Colors.green.shade100);
        return true;
      } else {
        Get.snackbar("Gagal", data['error'] ?? "Gagal kirim token", backgroundColor: Colors.red.shade100);
        return false;
      }
    } catch (e) {
      Get.snackbar("Error", "Koneksi server gagal", backgroundColor: Colors.red.shade100);
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> changePassword(String oldPass, String newPass, String tokenOtp) async {
    isLoading.value = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt_token');
      if (token == null) return false;

      final response = await http.put(
        Uri.parse("https://remold-nutshell-extortion.ngrok-free.dev/api/profile/password"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
          "ngrok-skip-browser-warning": "69420"
        },
        body: jsonEncode({"old_password": oldPass, "new_password": newPass, "verification_token": tokenOtp}),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        Get.snackbar("Sukses", "Kata sandi diubah", backgroundColor: Colors.green.shade100);
        return true;
      } else {
        Get.snackbar("Gagal", data['error'] ?? "Gagal ubah sandi", backgroundColor: Colors.red.shade100);
        return false;
      }
    } catch (e) {
      Get.snackbar("Error", "Koneksi server gagal", backgroundColor: Colors.red.shade100);
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> uploadProfilePhoto(String filePath) async {
    isLoading.value = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt_token');
      if (token == null) return false;

      final request = http.MultipartRequest(
        "PUT", Uri.parse("https://remold-nutshell-extortion.ngrok-free.dev/api/profile/photo"),
      )
        ..headers["Authorization"] = "Bearer $token"
        ..headers["ngrok-skip-browser-warning"] = "69420"
        ..files.add(await http.MultipartFile.fromPath("foto", filePath));

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        if (data['data'] != null) {
          await prefs.setString('user_data', jsonEncode(data['data']));
          await loadUserData();
        }
        Get.snackbar("Sukses", "Foto diperbarui", backgroundColor: Colors.green.shade100);
        return true;
      } else {
        Get.snackbar("Gagal", data['error'] ?? "Gagal upload", backgroundColor: Colors.red.shade100);
        return false;
      }
    } catch (e) {
      Get.snackbar("Error", "Gagal upload: $e", backgroundColor: Colors.red.shade100);
      return false;
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
