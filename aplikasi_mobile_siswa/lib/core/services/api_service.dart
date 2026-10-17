// =============================================================================
// api_service.dart — HTTP Client Terpusat (Dio + JWT Interceptor)
// =============================================================================
// Bertanggung jawab untuk:
//   1. Menyediakan instance Dio yang sudah dikonfigurasi
//   2. Menyuntikkan Authorization header (JWT) otomatis
//   3. Menangani refresh / redirect ke Login jika token expired (401)
//   4. Menyediakan base URL yang bisa dikonfigurasi dari konstanta
// =============================================================================

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart' hide Response;
import 'package:get_storage/get_storage.dart';

class ApiService {
  // =====================================================================
  // BASE URL — Deteksi platform otomatis:
  // - Windows / Web / macOS / Linux : http://localhost:8080/api/v1
  // - Android Emulator              : http://10.0.2.2:8080/api/v1
  // - HP Fisik Android / Kustom     : Bisa diset via storage / IP LAN (misal: 192.168.1.8:8080)
  // =====================================================================
  static String get baseUrl {
    final storage = GetStorage();
    final customUrl = storage.read<String>('custom_api_url');
    if (customUrl != null && customUrl.trim().isNotEmpty) {
      return customUrl.trim();
    }

    if (kIsWeb) {
      return 'http://localhost:8080/api/v1';
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 'http://10.0.2.2:8080/api/v1';
      case TargetPlatform.windows:
      case TargetPlatform.macOS:
      case TargetPlatform.linux:
      default:
        return 'http://localhost:8080/api/v1';
    }
  }

  /// Memungkinkan user mengubah server URL secara dinamis saat runtime
  static void setCustomBaseUrl(String? url) {
    final storage = GetStorage();
    if (url == null || url.trim().isEmpty) {
      storage.remove('custom_api_url');
    } else {
      storage.write('custom_api_url', url.trim());
    }
    reset();
  }

  static Dio? _dio;

  /// Singleton getter — menggunakan instance yang sama di seluruh app.
  static Dio get dio {
    _dio ??= _createDio();
    return _dio!;
  }

  /// Membuat instance Dio dengan interceptor JWT otomatis.
  static Dio _createDio() {
    final dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Interceptor: Suntikkan JWT token & tenant ID ke setiap request
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          options.baseUrl = baseUrl;
          final storage = GetStorage();
          final token = storage.read<String>('jwt_token');
          final tenantId = storage.read<String>('tenant_id');

          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          if (tenantId != null && tenantId.isNotEmpty) {
            options.headers['X-Tenant-ID'] = tenantId;
          }
          return handler.next(options);
        },
        onError: (DioException error, handler) {
          // Jika token expired (401), logout dan redirect ke halaman login
          if (error.response?.statusCode == 401) {
            _handleUnauthorized();
          }
          return handler.next(error);
        },
      ),
    );

    return dio;
  }

  /// Dipanggil ketika backend mengembalikan 401 (token invalid/expired).
  static void _handleUnauthorized() {
    final storage = GetStorage();
    storage.remove('jwt_token');
    storage.remove('tenant_id');
    storage.remove('user_data');

    // Navigate ke login screen dan hapus semua route sebelumnya
    Get.offAllNamed('/login');
  }

  /// Reset instance (berguna untuk testing atau saat ganti environment).
  static void reset() {
    _dio = null;
  }
}
