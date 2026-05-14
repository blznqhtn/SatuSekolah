import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PklRequirementScreen extends StatelessWidget {
  const PklRequirementScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF0F172A), size: 20),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Persyaratan PKL (Hubin)',
          style: TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFBFDBFE)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline_rounded, color: Color(0xFF1D4ED8)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: const Text(
                      'Pastikan semua dokumen fisik diserahkan ke ruang Hubin paling lambat 30 November 2025.',
                      style: TextStyle(color: Color(0xFF1E3A8A), height: 1.5, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text('Syarat Administrasi', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF0F172A))),
            const SizedBox(height: 12),
            _buildReqItem('Surat Persetujuan Orang Tua bermaterai Rp 10.000'),
            _buildReqItem('Fotokopi Rapor Semester 1 - 4'),
            _buildReqItem('Pas foto 3x4 (2 lembar, seragam sekolah background merah)'),
            _buildReqItem('Surat Keterangan Sehat dari Puskesmas/Klinik'),
            const SizedBox(height: 24),
            const Text('Syarat Akademik', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF0F172A))),
            const SizedBox(height: 12),
            _buildReqItem('Tidak memiliki nilai di bawah KKM pada mapel produktif (Kejuruan)'),
            _buildReqItem('Tingkat kehadiran minimal 90% selama semester 3 & 4'),
            _buildReqItem('Telah menyelesaikan Portofolio projek akhir semester'),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Get.snackbar('Unduh Berhasil', 'Format Surat Persetujuan Orang Tua telah diunduh', backgroundColor: Colors.white);
                },
                icon: const Icon(Icons.download_rounded),
                label: const Text('Unduh Format Surat Persetujuan'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF055D97),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  foregroundColor: Colors.white,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildReqItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 4),
            child: Icon(Icons.check_circle_rounded, size: 16, color: Color(0xFF10B981)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: Color(0xFF475569), height: 1.5),
            ),
          )
        ],
      ),
    );
  }
}
