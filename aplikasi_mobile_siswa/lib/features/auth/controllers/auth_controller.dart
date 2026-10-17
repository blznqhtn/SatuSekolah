// =============================================================================
// auth_controller.dart — Controller Login & Session Management
// =============================================================================

import 'package:dio/dio.dart';
import 'package:get/get.dart' hide Response;
import 'package:get_storage/get_storage.dart';
import 'package:aplikasi_mobile_siswa/core/services/api_service.dart';

/// Model untuk data user yang tersimpan setelah login berhasil.
class UserModel {
  final String id;
  final String name;
  final String email;
  final String role;
  final String? photoUrl;
  final String tenantId;
  final String? phone;
  final String? address;
  final String? nisn;
  final String? className;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.tenantId,
    this.photoUrl,
    this.phone,
    this.address,
    this.nisn,
    this.className,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      role: (json['role'] != null && json['role'].toString().trim().isNotEmpty)
          ? json['role'].toString()
          : (json['category']?.toString() ?? 'Student'),
      tenantId: json['tenant_id']?.toString() ?? '',
      photoUrl: json['photo_url']?.toString() ?? json['avatar_url']?.toString(),
      phone: json['phone']?.toString(),
      address: json['address']?.toString(),
      nisn: json['nisn']?.toString() ?? json['username']?.toString(),
      className: json['class_name']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'role': role,
        'tenant_id': tenantId,
        'photo_url': photoUrl,
        'phone': phone,
        'address': address,
        'nisn': nisn,
        'class_name': className,
      };
}

class AuthController extends GetxController {
  final _storage = GetStorage();

  // Reactive state
  final isLoading = false.obs;
  final errorMessage = ''.obs;
  final currentUser = Rxn<UserModel>();

  @override
  void onInit() {
    super.onInit();
    _loadSavedUser();
  }

  /// Muat ulang data user dari storage (berguna saat app restart).
  void _loadSavedUser() {
    final userData = _storage.read<Map>('user_data');
    if (userData != null) {
      currentUser.value = UserModel.fromJson(Map<String, dynamic>.from(userData));
    }
  }

  /// Apakah user sudah login (ada token yang tersimpan).
  bool get isLoggedIn => _storage.read<String>('jwt_token') != null;

  /// Proses login ke backend.
  /// [identifier] bisa berupa email atau NISN.
  Future<bool> login({
    required String identifier,
    required String password,
  }) async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final response = await ApiService.dio.post(
        '/users/login',
        data: {
          'identifier': identifier,
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;

        // Simpan token JWT ke storage
        final token = data['token']?.toString() ?? '';
        final user = UserModel.fromJson(data['user'] as Map<String, dynamic>);

        _storage.write('jwt_token', token);
        _storage.write('tenant_id', user.tenantId);
        _storage.write('user_data', user.toJson());

        currentUser.value = user;
        return true;
      }

      errorMessage.value = 'Login gagal. Periksa kembali email/password Anda.';
      return false;
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode;
      if (statusCode == 401 || statusCode == 400) {
        errorMessage.value = 'Email/NISN atau password salah.';
      } else if (statusCode == 429) {
        errorMessage.value = 'Terlalu banyak percobaan login. Tunggu 1 menit.';
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        errorMessage.value = 'Koneksi timeout. Periksa jaringan Anda.';
      } else if (e.type == DioExceptionType.connectionError) {
        errorMessage.value = 'Tidak bisa terhubung ke server.';
      } else {
        errorMessage.value = 'Terjadi kesalahan. Coba lagi nanti.';
      }
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Logout: hapus semua data sesi dari storage.
  void logout() {
    _storage.remove('jwt_token');
    _storage.remove('tenant_id');
    _storage.remove('user_data');
    currentUser.value = null;
    ApiService.reset();
    Get.offAllNamed('/login');
  }

  /// Ambil profil terbaru dari server dan update storage.
  Future<void> refreshProfile() async {
    try {
      final response = await ApiService.dio.get('/users/profile');
      if (response.statusCode == 200) {
        final user = UserModel.fromJson(response.data as Map<String, dynamic>);
        _storage.write('user_data', user.toJson());
        currentUser.value = user;
      }
    } catch (_) {
      // Silent fail — profil lokal tetap dipakai
    }
  }
}
