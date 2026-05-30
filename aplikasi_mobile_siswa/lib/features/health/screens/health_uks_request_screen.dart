import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:aplikasi_mobile_siswa/features/health/controllers/health_controller.dart';

class HealthUksRequestScreen extends StatefulWidget {
  const HealthUksRequestScreen({Key? key}) : super(key: key);

  @override
  State<HealthUksRequestScreen> createState() => _HealthUksRequestScreenState();
}

class _HealthUksRequestScreenState extends State<HealthUksRequestScreen> {
  final HealthController controller = Get.find<HealthController>();
  final TextEditingController keluhanCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF0F172A)), onPressed: () => Get.back()),
        title: Text('Pengajuan UKS', style: GoogleFonts.nunito(color: const Color(0xFF0F172A), fontWeight: FontWeight.w800, fontSize: 18)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: const Color(0xFFFEF2F2), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFFECACA))),
              child: Row(children: [
                const Icon(Icons.medical_services_rounded, color: Color(0xFFEF4444)),
                const SizedBox(width: 12),
                Expanded(child: Text('Jika Anda merasa kurang sehat, silakan isi form keluhan ini dan segera menuju ruang UKS.', style: GoogleFonts.nunito(color: const Color(0xFFEF4444), fontSize: 13, fontWeight: FontWeight.w600, height: 1.4))),
              ]),
            ),
            const SizedBox(height: 32),
            
            Text('Keluhan yang Dirasakan', style: GoogleFonts.nunito(fontWeight: FontWeight.w700, color: const Color(0xFF0F172A), fontSize: 14)),
            const SizedBox(height: 8),
            TextField(
              controller: keluhanCtrl,
              maxLines: 5,
              style: GoogleFonts.nunito(fontWeight: FontWeight.w600, fontSize: 15),
              decoration: InputDecoration(
                hintText: 'Jelaskan apa yang Anda rasakan secara singkat... (Contoh: Pusing, mual, sakit perut)',
                filled: true, fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFEF4444), width: 2)),
              ),
            ),
            
            const Spacer(),
            Obx(() => SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: controller.isSubmitting.value ? null : () {
                  if(keluhanCtrl.text.isNotEmpty) controller.requestUks(keluhanCtrl.text);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFEF4444),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: controller.isSubmitting.value
                  ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
                  : Text('Kirim Pengajuan UKS', style: GoogleFonts.nunito(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16)),
              ),
            )),
          ],
        ),
      ),
    );
  }
}
