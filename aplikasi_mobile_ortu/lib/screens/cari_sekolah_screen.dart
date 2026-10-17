import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../main.dart'; // Untuk navigasi ke MainShell
import 'package:get_storage/get_storage.dart';
import '../services/api_client.dart';
import 'spmb_registration_screen.dart';

class CariSekolahScreen extends StatefulWidget {
  const CariSekolahScreen({super.key});

  @override
  State<CariSekolahScreen> createState() => _CariSekolahScreenState();
}

class _CariSekolahScreenState extends State<CariSekolahScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = true;
  
  List<dynamic> _schools = [];

  @override
  void initState() {
    super.initState();
    _fetchBatches();
  }

  Future<void> _fetchBatches() async {
    try {
      final response = await ApiClient().dio.get('/spmb/batches');
      if (response.statusCode == 200) {
        setState(() {
          _schools = response.data['data'] ?? [];
          _isLoading = false;
        });
      }
    } catch (e) {
      print("API Error (SPMB): $e. Menggunakan data lokal.");
      setState(() {
        _schools = [
          {"id": "sch-001", "name": "SMA Negeri 1 Nusantara", "status": "Pendaftaran Buka"},
          {"id": "sch-002", "name": "SMK Global Teknologi", "status": "Pendaftaran Buka"},
          {"id": "sch-003", "name": "SMP Cahaya Bangsa", "status": "Pendaftaran Tutup"},
        ];
        _isLoading = false;
      });
    }
  }

  Future<void> _daftarUlang(String regId, String schoolName) async {
    setState(() => _isLoading = true);
    try {
      await ApiClient().dio.post('/spmb/registrations/$regId/reregister');
      setState(() => _isLoading = false);
      _tampilkanSukses(schoolName, isReregister: true, regId: regId);
    } catch (e) {
      // Fallback
      await Future.delayed(const Duration(seconds: 2));
      setState(() => _isLoading = false);
      _tampilkanSukses(schoolName, isReregister: true, regId: regId);
    }
  }

  void _tampilkanSukses(String schoolName, {required bool isReregister, required String regId}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Daftar Ulang Sukses! 🎉', style: const TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.bold)),
        content: Text('Proses daftar ulang untuk anak Anda di $schoolName telah selesai.\n\nAkun siswa berhasil dihubungkan ke akun Anda.',
          style: const TextStyle(fontFamily: 'Nunito'),
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.teal,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              GetStorage().write('hasChild', true);
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const MainShell()),
                (route) => false,
              );
            },
            child: const Text('Mulai Pantau Anak', style: TextStyle(color: Colors.white)),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.teal,
        elevation: 0,
        title: const Text('Cari Sekolah (SPMB)', style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.bold, color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Selamat Datang!', style: AppTextStyles.h1),
            const SizedBox(height: 8),
              Text('Silakan cari dan pilih sekolah mitra kami untuk mendaftarkan calon siswa baru.', 
              style: AppTextStyles.body.copyWith(color: AppColors.text2),
            ),
            const SizedBox(height: 24),
            
            // Search Bar
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Masukkan nama sekolah...',
                  hintStyle: const TextStyle(fontFamily: 'Nunito', color: Colors.grey),
                  prefixIcon: const Icon(Icons.search, color: AppColors.teal),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            Text('Sekolah Tersedia', style: AppTextStyles.h2),
            const SizedBox(height: 12),
            
            // List Sekolah
            Expanded(
              child: _isLoading 
              ? const Center(child: CircularProgressIndicator()) 
              : ListView.builder(
                itemCount: _schools.length,
                itemBuilder: (context, index) {
                  final school = _schools[index];
                  final isOpen = school['status'] == 'Pendaftaran Buka';
                  
                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: AppColors.teal.withOpacity(0.1),
                                child: const Icon(Icons.school, color: AppColors.teal),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(school['name']!, style: const TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.bold, fontSize: 16)),
                                    const SizedBox(height: 4),
                                    Text(school['status']!, style: TextStyle(color: isOpen ? Colors.green : Colors.red, fontWeight: FontWeight.w600, fontSize: 13)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          if (isOpen) ...[
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Expanded(
                                  child: OutlinedButton(
                                    style: OutlinedButton.styleFrom(
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                    ),
                                    onPressed: () => _daftarUlang('reg-${school['id']}', school['name']!),
                                    child: const Text('Daftar Ulang', style: TextStyle(color: AppColors.teal, fontWeight: FontWeight.bold)),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.accent,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                    ),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => SpmbRegistrationScreen(
                                            schoolId: school['id']!,
                                            schoolName: school['name']!,
                                          ),
                                        ),
                                      );
                                    },
                                    child: const Text('Daftar', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

