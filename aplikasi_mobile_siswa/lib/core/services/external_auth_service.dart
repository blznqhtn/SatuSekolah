// =============================================================================
// external_auth_service.dart — Service Auth untuk SeHadir & AkuSehat
// =============================================================================
// Mengelola login, penyimpanan token, dan penyediaan header auth
// untuk dua API eksternal: SeHadir (JWT) dan AkuSehat (Sanctum).
// =============================================================================

import 'dart:convert';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:aplikasi_mobile_siswa/core/config/api_config.dart';

class ExternalAuthService {
  static final ExternalAuthService _instance = ExternalAuthService._internal();
  factory ExternalAuthService() => _instance;
  ExternalAuthService._internal();

  final _storage = GetStorage();

  // ─── Storage Keys ─────────────────────────────────────────────────────────
  static const _kSeHadirToken    = 'sehadir_access_token';
  static const _kSeHadirSession  = 'sehadir_session_id';
  static const _kAkuSehatToken   = 'akusehat_token';
  static const _kLmsSession      = 'lms_session_cookie';

  // =========================================================================
  // SEHADIR AUTH (JWT)
  // =========================================================================

  /// Login ke SeHadir dengan username & password.
  /// SeHadir menggunakan NIS/username yang sama dengan SeHadir sendiri.
  Future<bool> loginSeHadir({required String username, required String password}) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.seHadir}/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'type': 'user',
          'username': username,
          'password': password,
        }),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          _storage.write(_kSeHadirToken, data['access_token']);
          _storage.write(_kSeHadirSession, data['session_id']);
          return true;
        }
      }
    } catch (e) {
      print('[SeHadir Auth] Error: $e');
    }
    return false;
  }

  /// Mendapatkan header Authorization untuk request ke SeHadir.
  Map<String, String> seHadirHeaders() {
    final token = _storage.read(_kSeHadirToken) ?? '';
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  String? get seHadirToken => _storage.read<String>(_kSeHadirToken);
  bool get isSeHadirLoggedIn => seHadirToken != null && seHadirToken!.isNotEmpty;

  void clearSeHadirAuth() {
    _storage.remove(_kSeHadirToken);
    _storage.remove(_kSeHadirSession);
  }

  // =========================================================================
  // AKUSEHAT AUTH (Sanctum)
  // =========================================================================

  /// Login ke AkuSehat dengan username (nomor_induk) & password.
  Future<bool> loginAkuSehat({required String username, required String password}) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.akuSehat}/login'),
        headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
        body: jsonEncode({
          'username': username,
          'password': password,
        }),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // AkuSehat Sanctum biasanya return {"token": "...", ...}
        final token = data['token'] ?? data['access_token'] ?? data['data']?['token'];
        if (token != null) {
          _storage.write(_kAkuSehatToken, token);
          return true;
        }
      }
    } catch (e) {
      print('[AkuSehat Auth] Error: $e');
    }
    return false;
  }

  /// Mendapatkan header Authorization untuk request ke AkuSehat.
  Map<String, String> akuSehatHeaders() {
    final token = _storage.read(_kAkuSehatToken) ?? '';
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  String? get akuSehatToken => _storage.read<String>(_kAkuSehatToken);
  bool get isAkuSehatLoggedIn => akuSehatToken != null && akuSehatToken!.isNotEmpty;

  void clearAkuSehatAuth() {
    _storage.remove(_kAkuSehatToken);
  }

  // =========================================================================
  // LMS AUTH (Cookie Session via Go Proxy)
  // =========================================================================

  /// Login ke LMS-Tels via backend Go SatuSekolah (proxy).
  /// Go akan menyimpan cookie session LMS di server-side.
  Future<bool> loginLms({required String email, required String password}) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.satuSekolah}/lms/login'),
        headers: ApiConfig.ngrokHeaders,
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          _storage.write(_kLmsSession, data['session'] ?? '');
          return true;
        }
      }
    } catch (e) {
      print('[LMS Auth] Error: $e');
    }
    return false;
  }

  String? get lmsSession => _storage.read<String>(_kLmsSession);
  bool get isLmsLoggedIn => lmsSession != null && lmsSession!.isNotEmpty;

  void clearLmsAuth() {
    _storage.remove(_kLmsSession);
  }

  // =========================================================================
  // UTILITY: Auto-login semua service dengan kredensial SatuSekolah
  // =========================================================================

  /// Mencoba login otomatis ke semua layanan eksternal menggunakan
  /// identifier (NIS/email) dan password yang sama dengan SatuSekolah.
  Future<void> autoLoginAll({
    required String identifier,
    required String password,
    String? email,
  }) async {
    // Login paralel ke SeHadir dan AkuSehat
    await Future.wait([
      loginSeHadir(username: identifier, password: password),
      loginAkuSehat(username: identifier, password: password),
      if (email != null)
        loginLms(email: email, password: password),
    ]);
    print('[ExternalAuth] AutoLogin selesai.'
        ' SeHadir: $isSeHadirLoggedIn'
        ' AkuSehat: $isAkuSehatLoggedIn'
        ' LMS: $isLmsLoggedIn');
  }

  /// Logout dari semua layanan eksternal.
  void logoutAll() {
    clearSeHadirAuth();
    clearAkuSehatAuth();
    clearLmsAuth();
  }
}
