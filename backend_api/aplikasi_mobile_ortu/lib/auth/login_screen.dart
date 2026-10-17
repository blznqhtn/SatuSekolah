import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../main.dart';
import 'package:get_storage/get_storage.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../screens/cari_sekolah_screen.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../services/api_client.dart';
import 'package:dio/dio.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _identifierController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;

  Future<void> _loginProses() async {
    if (_identifierController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Email/No HP dan Password harus diisi!', style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.bold)),
          backgroundColor: AppColors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await ApiClient().dio.post(
        '/users/login',
        data: {
          'identifier': _identifierController.text.trim(),
          'password': _passwordController.text,
        },
      );

      final token = response.data['token'];
      final user = response.data['user'];

      if (token != null) {
        await ApiClient().secureStorage.write(key: 'jwt_token', value: token);
        await ApiClient().secureStorage.write(key: 'user_id', value: user['id'].toString());

        // Get Profile to check SPMB Status
        final profileResponse = await ApiClient().dio.get('/users/profile');
        final profileData = profileResponse.data['data'];
        bool spmbCompleted = profileData['spmb_completed'] ?? false;

        final box = GetStorage();
        box.write('isLoggedIn', true);
        box.write('namaOrtu', user['name'] ?? 'Orang Tua');
        box.write('hasChild', spmbCompleted); // Map spmb_completed to hasChild for now
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Selamat datang kembali, ${user['name']}!', style: const TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.bold)),
              backgroundColor: AppColors.teal,
            ),
          );

          if (spmbCompleted) {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const MainShell()));
          } else {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const CariSekolahScreen()));
          }
        }
      }
    } on DioException catch (e) {
      if (mounted) {
        String errMsg = 'Terjadi kesalahan saat login';
        if (e.response != null) {
          errMsg = e.response?.data['error'] ?? 'Email atau password salah';
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errMsg, style: const TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.bold)),
            backgroundColor: AppColors.red,
          ),
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
          // Arahkan ke MainShell (bukan CariSekolahScreen) agar alur SPMB berjalan otomatis
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
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            _buildHeaderHero(context),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 30.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Selamat Datang 👋",
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      color: AppColors.text,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Silakan masuk untuk memantau perkembangan belajar anak Anda.",
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 14,
                      color: AppColors.text2,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 35),

                  _buildInput(
                    controller: _identifierController,
                    label: "Email",
                    icon: Icons.email_outlined,
                  ),
                  const SizedBox(height: 16),
                  _buildInput(
                    controller: _passwordController,
                    label: "Password",
                    icon: Icons.lock_outline_rounded,
                    isPassword: true,
                  ),

                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      "Lupa Password?",
                      style: TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: AppColors.accent,
                      ),
                    ),
                  ),

                  const SizedBox(height: 35),

                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accent,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      onPressed: _isLoading ? null : _loginProses,
                      child: _isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                            )
                          : const Text(
                              "MASUK",
                              style: TextStyle(
                                fontFamily: 'Nunito',
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1,
                              ),
                            ),
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Tombol Google (Mock)
                  OutlinedButton.icon(
                    onPressed: _isLoading ? _loginGoogleProses : _loginGoogleProses,
                    icon: SvgPicture.network('https://cdn.jsdelivr.net/gh/glincker/thesvg@main/public/icons/google/default.svg', width: 24, height: 24),
                    label: const Text('Masuk dengan Google'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      minimumSize: const Size(double.infinity, 55),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Register Button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Belum punya akun? ",
                        style: TextStyle(
                          fontFamily: 'Nunito',
                          color: AppColors.text2,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(context, '/register');
                        },
                        child: const Text(
                          "Daftar",
                          style: TextStyle(
                            fontFamily: 'Nunito',
                            color: AppColors.teal,
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderHero(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.accent, Color(0xFFF5A073)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
      ),
      padding: const EdgeInsets.only(top: 80, bottom: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/images/LogoSatuSekolah.png',
            height: 80,
          ),
          const SizedBox(height: 16),
          const Text(
            "Satu Sekolah",
            style: TextStyle(
              fontFamily: 'Nunito',
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            "Aplikasi Orang Tua & Wali",
            style: TextStyle(
              fontFamily: 'Nunito',
              color: Colors.white70,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInput({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        style: const TextStyle(
          fontFamily: 'Nunito',
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: AppColors.text,
        ),
        decoration: InputDecoration(
          hintText: label,
          hintStyle: const TextStyle(
            fontFamily: 'Nunito',
            color: AppColors.text3,
            fontWeight: FontWeight.w500,
          ),
          prefixIcon: Icon(icon, color: AppColors.text3, size: 22),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
        ),
      ),
    );
  }
}
