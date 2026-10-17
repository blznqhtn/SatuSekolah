// =============================================================================
// profile_controller.dart — Profil User & Update Password
// =============================================================================
// Endpoint: GET  /api/v1/users/profile
//           PUT  /api/v1/users/profile
//           PUT  /api/v1/users/password
// =============================================================================

import 'package:dio/dio.dart';
import 'package:get/get.dart' hide Response;
import 'package:get_storage/get_storage.dart';
import 'package:aplikasi_mobile_siswa/core/services/api_service.dart';

class ProfileData {
  final String id;
  final String name;
  final String email;
  final String role;
  final String? phone;
  final String? photoUrl;
  final String? className;
  final String? nisn;
  final String tenantId;

  const ProfileData({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.tenantId,
    this.phone,
    this.photoUrl,
    this.className,
    this.nisn,
  });

  factory ProfileData.fromJson(Map<String, dynamic> json) {
    return ProfileData(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      role: json['role']?.toString() ?? '',
      tenantId: json['tenant_id']?.toString() ?? '',
      phone: json['phone']?.toString(),
      photoUrl: json['photo_url']?.toString(),
      className: json['class_name']?.toString(),
      nisn: json['nisn']?.toString(),
    );
  }
}

class ProfileController extends GetxController {
  final _storage = GetStorage();

  final isLoading = false.obs;
  final isUpdating = false.obs;
  final profile = Rxn<ProfileData>();
  final errorMessage = ''.obs;
  final successMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _loadFromStorage();
    fetchProfile();
  }

  void _loadFromStorage() {
    final saved = _storage.read<Map>('user_data');
    if (saved != null) {
      try {
        profile.value = ProfileData.fromJson(Map<String, dynamic>.from(saved));
      } catch (_) {}
    }
  }

  Future<void> fetchProfile() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final response = await ApiService.dio.get('/users/profile');
      if (response.statusCode == 200) {
        final raw = response.data;
        final map = (raw is Map && raw['data'] is Map)
            ? raw['data'] as Map<String, dynamic>
            : (raw as Map<String, dynamic>);
        profile.value = ProfileData.fromJson(map);
        // Update storage
        _storage.write('user_data', map);
      }
    } on DioException catch (e) {
      errorMessage.value =
          e.response?.data?['error']?.toString() ?? 'Gagal memuat profil.';
    } finally {
      isLoading.value = false;
    }
  }

  /// Update nama dan nomor telepon.
  Future<bool> updateProfile({required String name, String? phone}) async {
    isUpdating.value = true;
    errorMessage.value = '';
    successMessage.value = '';
    try {
      final response = await ApiService.dio.put(
        '/users/profile',
        data: {
          'name': name,
          if (phone != null && phone.isNotEmpty) 'phone': phone,
        },
      );
      if (response.statusCode == 200) {
        await fetchProfile();
        successMessage.value = 'Profil berhasil diperbarui.';
        return true;
      }
      return false;
    } on DioException catch (e) {
      errorMessage.value =
          e.response?.data?['error']?.toString() ?? 'Gagal memperbarui profil.';
      return false;
    } finally {
      isUpdating.value = false;
    }
  }

  /// Ganti password.
  Future<bool> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    isUpdating.value = true;
    errorMessage.value = '';
    successMessage.value = '';
    try {
      final response = await ApiService.dio.put(
        '/users/password',
        data: {
          'old_password': oldPassword,
          'new_password': newPassword,
        },
      );
      if (response.statusCode == 200) {
        successMessage.value = 'Password berhasil diubah.';
        return true;
      }
      return false;
    } on DioException catch (e) {
      final msg = e.response?.data?['error']?.toString();
      errorMessage.value = msg ?? 'Gagal mengubah password.';
      return false;
    } finally {
      isUpdating.value = false;
    }
  }
}
