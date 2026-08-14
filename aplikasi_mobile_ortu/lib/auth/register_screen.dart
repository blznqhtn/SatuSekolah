import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../services/api_client.dart';
import 'package:dio/dio.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:get_storage/get_storage.dart';
import '../main.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  Future<void> _register() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Harap isi semua kolom')),
      );
      return;
    }

    setState(() => _isLoading = true);
    
    try {
      // 1. Panggil API Register
      await ApiClient().dio.post(
        '/users/register',
        data: {
          'name': name,
          'email': email,
          'password': password,
        },
      );

      // 2. Langsung otomatis Login setelah Register berhasil
      final loginResponse = await ApiClient().dio.post(
        '/users/login',
        data: {
          'identifier': email,
          'password': password,
        },
      );

      final token = loginResponse.data['token'];
      final user = loginResponse.data['user'];

      if (token != null) {
        // Simpan token
        await ApiClient().secureStorage.write(key: 'jwt_token', value: token);
        await ApiClient().secureStorage.write(key: 'user_id', value: user['id'].toString());

        if (mounted) {
          // Beralih ke Beranda
          Navigator.pushReplacementNamed(context, '/beranda');
        }
      }

    } on DioException catch (e) {
      String message = 'Terjadi kesalahan jaringan';
      if (e.response != null) {
        message = e.response?.data['error'] ?? 'Gagal mendaftar';
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _loginGoogleProses() async {
    setState(() => _isLoading = true);
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn(
        serverClientId: '224990005515-44rfo04eoc816ibjrp4br2u7si5pnd6m.apps.googleusercontent.com', // GANTI INI DENGAN WEB CLIENT ID DARI GOOGLE CLOUD CONSOLE
        scopes: ['email', 'profile'],
      );

      // Force sign out to ensure user can choose account
      await googleSignIn.signOut();
      
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      
      if (googleUser == null) {
        // User canceled the login
        setState(() => _isLoading = false);
        return;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final idToken = googleAuth.idToken;

      if (idToken == null) {
        throw Exception('Tidak bisa mendapatkan id_token dari Google');
      }

      // Kirim idToken ke Backend Golang
      final response = await ApiClient().dio.post(
        '/users/auth/google',
        data: {'id_token': idToken},
      );

      final token = response.data['token'];
      final user = response.data['user'];

      if (token != null) {
        await ApiClient().secureStorage.write(key: 'jwt_token', value: token);
        await ApiClient().secureStorage.write(key: 'user_id', value: user['id'].toString());

        final box = GetStorage();
        box.write('isLoggedIn', true);
        box.write('namaOrtu', user['name'] ?? 'Google User');
        box.write('hasChild', false); // Dummy untuk sementara

        if (mounted) {
          // Arahkan ke MainShell agar alur SPMB berjalan otomatis
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const MainShell()),
            (Route<dynamic> route) => false,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        String errMsg = 'Google Login Gagal';
        if (e is DioException) {
          errMsg = e.response?.data['error'] ?? 'Koneksi ke server gagal';
        } else {
          errMsg = e.toString();
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errMsg), backgroundColor: AppColors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: const Text('Pendaftaran Orang Tua'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(
                Icons.family_restroom,
                size: 80,
                color: AppColors.teal,
              ),
              const SizedBox(height: 24),
              const Text(
                'Buat Akun Baru',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.text,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'Daftar untuk mengelola informasi pendidikan anak Anda',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.text2,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),

              // Form Nama
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Nama Lengkap',
                  prefixIcon: const Icon(Icons.person_outline),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Form Email
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Alamat Email',
                  prefixIcon: const Icon(Icons.email_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Form Password
              TextFormField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: 'Kata Sandi',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Tombol Daftar
              ElevatedButton(
                onPressed: _isLoading ? null : _register,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  backgroundColor: AppColors.teal,
                  foregroundColor: Colors.white,
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text(
                        'Daftar',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
              ),
              
              const SizedBox(height: 24),
              const Row(
                children: [
                  Expanded(child: Divider()),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text('ATAU', style: TextStyle(color: AppColors.text2)),
                  ),
                  Expanded(child: Divider()),
                ],
              ),
              const SizedBox(height: 24),

              // Tombol Google
              OutlinedButton.icon(
                onPressed: _isLoading ? null : _loginGoogleProses,
                icon: SvgPicture.network('https://cdn.jsdelivr.net/gh/glincker/thesvg@main/public/icons/google/default.svg', width: 24, height: 24),
                label: const Text('Daftar dengan Google'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Kembali ke Login
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Sudah punya akun?',
                    style: TextStyle(color: AppColors.text2),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text(
                      'Masuk',
                      style: TextStyle(
                        color: AppColors.teal,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
