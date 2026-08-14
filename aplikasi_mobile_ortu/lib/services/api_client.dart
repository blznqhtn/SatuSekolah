import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/material.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  late Dio dio;
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();

  // Konfigurasi Global Key untuk Navigation tanpa context (untuk force logout)
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  factory ApiClient() {
    return _instance;
  }

  ApiClient._internal() {
    dio = Dio(BaseOptions(
      // TODO: Ganti dengan Base URL Backend Golang yang sebenarnya
      baseUrl: 'http://10.0.2.2:8080/api/v1', 
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ));

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Ambil token dari Secure Storage setiap kali melakukan request
          final token = await secureStorage.read(key: 'jwt_token');
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (DioException e, handler) async {
          if (e.response != null) {
            if (e.response?.statusCode == 401) {
              final path = e.requestOptions.path;
              if (!path.contains('/users/login') && !path.contains('/users/register')) {
                // Token Kedaluwarsa / Tidak Valid
                await _handleUnauthorized();
              }
            } else if (e.response?.statusCode == 403) {
              // Role bukan Parent atau Data Ownership gagal
              _handleForbidden();
            }
          }
          return handler.next(e);
        },
      ),
    );
  }

  Future<void> _handleUnauthorized() async {
    // Hapus token yang sudah hangus
    await secureStorage.delete(key: 'jwt_token');
    await secureStorage.delete(key: 'user_id');
    
    final context = navigatorKey.currentContext;
    if (context != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sesi Anda telah berakhir. Silakan login kembali.'),
          backgroundColor: Colors.red,
        ),
      );
      // Pindah ke layar Login secara paksa (Hapus semua rute sebelumnya)
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (Route<dynamic> route) => false);
    }
  }

  void _handleForbidden() {
    final context = navigatorKey.currentContext;
    if (context != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Akses Ditolak: Anda tidak memiliki izin untuk melihat data ini.'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }
}
