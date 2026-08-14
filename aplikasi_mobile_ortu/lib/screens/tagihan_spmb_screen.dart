import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import 'package:get_storage/get_storage.dart';
import '../main.dart'; // To access MainShell
import '../services/api_client.dart';
import 'package:dio/dio.dart';

class TagihanSpmbScreen extends StatefulWidget {
  final String studentName;
  final String schoolName;
  final String major;
  final String spmbRegistrationId;

  const TagihanSpmbScreen({
    super.key,
    required this.studentName,
    required this.schoolName,
    required this.major,
    required this.spmbRegistrationId,
  });

  @override
  State<TagihanSpmbScreen> createState() => _TagihanSpmbScreenState();
}

class _TagihanSpmbScreenState extends State<TagihanSpmbScreen> {
  bool _isLoading = false;

  void _bayarLunas() async {
    setState(() => _isLoading = true);
    
    try {
      // Simulate payment processing via API
      await ApiClient().dio.post('/spmb/registrations/${widget.spmbRegistrationId}/pay');

      if (!mounted) return;
      setState(() => _isLoading = false);

      // Show success dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Pembayaran Berhasil! 🎉', style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.bold)),
          content: Text(
            'Pembayaran tagihan pendaftaran SPMB untuk ${widget.studentName} telah lunas.\n\nAkun siswa berhasil dibuat dan telah terhubung ke akun Anda. Anda sekarang dapat mengakses semua fitur pemantauan akademik.',
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
                
                // Set hasChild to true
                final box = GetStorage();
                box.write('hasChild', true);
                
                // Navigate back to MainShell and clear stack
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
    } on DioException catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        String errMsg = 'Terjadi kesalahan jaringan saat pembayaran.';
        if (e.response != null) {
          errMsg = e.response?.data['error'] ?? 'Pembayaran gagal diproses.';
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errMsg), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Terjadi kesalahan yang tidak terduga.'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.teal,
        elevation: 0,
        title: const Text('Tagihan Pendaftaran', style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.bold, color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              color: AppColors.teal,
              child: Column(
                children: [
                  const Icon(Icons.receipt_long, size: 60, color: Colors.white),
                  const SizedBox(height: 16),
                  const Text('Total Tagihan', style: TextStyle(color: Colors.white70, fontFamily: 'Nunito', fontSize: 14)),
                  const Text('Rp 4.500.000', style: TextStyle(color: Colors.white, fontFamily: 'Nunito', fontSize: 32, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Detail Calon Siswa', style: AppTextStyles.h2),
                  const SizedBox(height: 16),
                  _buildDetailRow('Nama Siswa', widget.studentName),
                  _buildDetailRow('Sekolah Tujuan', widget.schoolName),
                  _buildDetailRow('Pilihan Jurusan', widget.major),
                  
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Divider(),
                  ),
                  
                  const Text('Rincian Biaya', style: AppTextStyles.h2),
                  const SizedBox(height: 16),
                  _buildCostRow('Biaya Formulir Pendaftaran', 'Rp 250.000'),
                  _buildCostRow('Uang Pangkal / Gedung', 'Rp 3.000.000'),
                  _buildCostRow('SPP Bulan Pertama', 'Rp 600.000'),
                  _buildCostRow('Seragam Sekolah (Paket Lengkap)', 'Rp 650.000'),
                  
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Divider(color: AppColors.border2, thickness: 2),
                  ),
                  
                  _buildCostRow('Total Pembayaran', 'Rp 4.500.000', isBold: true),
                  
                  const SizedBox(height: 40),
                  
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _bayarLunas,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accent,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 4,
                      ),
                      child: _isLoading
                          ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Text(
                              'Bayar Lunas Sekarang',
                              style: TextStyle(
                                fontFamily: 'Nunito',
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Center(
                    child: Text(
                      'Pembayaran diproses secara instan.\nAkun anak otomatis aktif setelah pembayaran.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.text3, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(label, style: const TextStyle(color: AppColors.text2, fontSize: 14)),
          ),
          const Text(': ', style: TextStyle(color: AppColors.text2)),
          Expanded(
            child: Text(value, style: const TextStyle(color: AppColors.text, fontWeight: FontWeight.bold, fontSize: 14)),
          ),
        ],
      ),
    );
  }

  Widget _buildCostRow(String title, String price, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                color: isBold ? AppColors.text : AppColors.text2,
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                fontSize: isBold ? 16 : 14,
              ),
            ),
          ),
          Text(
            price,
            style: TextStyle(
              color: isBold ? AppColors.accent : AppColors.text,
              fontWeight: FontWeight.bold,
              fontSize: isBold ? 18 : 14,
            ),
          ),
        ],
      ),
    );
  }
}
