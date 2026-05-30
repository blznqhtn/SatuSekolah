import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:aplikasi_mobile_siswa/features/health/controllers/health_controller.dart';

class HealthUpdateScreen extends StatefulWidget {
  const HealthUpdateScreen({Key? key}) : super(key: key);

  @override
  State<HealthUpdateScreen> createState() => _HealthUpdateScreenState();
}

class _HealthUpdateScreenState extends State<HealthUpdateScreen> {
  final HealthController controller = Get.find<HealthController>();
  late TextEditingController tinggiCtrl;
  late TextEditingController beratCtrl;
  late TextEditingController hbCtrl;

  @override
  void initState() {
    super.initState();
    tinggiCtrl = TextEditingController(text: controller.tinggiBadan.value.toString());
    beratCtrl = TextEditingController(text: controller.beratBadan.value.toString());
    hbCtrl = TextEditingController(text: controller.hemoglobin.value.toString());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF0F172A)), onPressed: () => Get.back()),
        title: Text('Update Data Fisik', style: GoogleFonts.nunito(color: const Color(0xFF0F172A), fontWeight: FontWeight.w800, fontSize: 18)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: const Color(0xFFEFF6FF), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFDBEAFE))),
              child: Row(children: [
                const Icon(Icons.info_outline_rounded, color: Color(0xFF3B82F6)),
                const SizedBox(width: 12),
                Expanded(child: Text('Data Fisik digunakan untuk menghitung Indeks Massa Tubuh (BMI). Data Hemoglobin untuk catatan rekam medis berkala.', style: GoogleFonts.nunito(color: const Color(0xFF3B82F6), fontSize: 13, fontWeight: FontWeight.w600, height: 1.4))),
              ]),
            ),
            const SizedBox(height: 32),
            
            Text('Tinggi Badan (cm)', style: GoogleFonts.nunito(fontWeight: FontWeight.w700, color: const Color(0xFF0F172A), fontSize: 14)),
            const SizedBox(height: 8),
            TextField(
              controller: tinggiCtrl,
              keyboardType: TextInputType.number,
              style: GoogleFonts.nunito(fontWeight: FontWeight.w800, fontSize: 16),
              decoration: InputDecoration(
                hintText: 'Misal: 165',
                suffixText: 'cm',
                filled: true, fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF10B981), width: 2)),
              ),
            ),
            
            const SizedBox(height: 24),
            Text('Berat Badan (kg)', style: GoogleFonts.nunito(fontWeight: FontWeight.w700, color: const Color(0xFF0F172A), fontSize: 14)),
            const SizedBox(height: 8),
            TextField(
              controller: beratCtrl,
              keyboardType: TextInputType.number,
              style: GoogleFonts.nunito(fontWeight: FontWeight.w800, fontSize: 16),
              decoration: InputDecoration(
                hintText: 'Misal: 55',
                suffixText: 'kg',
                filled: true, fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF10B981), width: 2)),
              ),
            ),
            const SizedBox(height: 24),
            Text('Kadar Hemoglobin (g/dL)', style: GoogleFonts.nunito(fontWeight: FontWeight.w700, color: const Color(0xFF0F172A), fontSize: 14)),
            const SizedBox(height: 8),
            TextField(
              controller: hbCtrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              style: GoogleFonts.nunito(fontWeight: FontWeight.w800, fontSize: 16),
              decoration: InputDecoration(
                hintText: 'Misal: 12.5',
                suffixText: 'g/dL',
                filled: true, fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF10B981), width: 2)),
              ),
            ),
            
            const SizedBox(height: 40),
            Obx(() => SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: controller.isSubmitting.value ? null : () {
                  final t = int.tryParse(tinggiCtrl.text) ?? 0;
                  final b = int.tryParse(beratCtrl.text) ?? 0;
                  final h = double.tryParse(hbCtrl.text) ?? 0.0;
                  
                  if(t > 0 && b > 0) controller.updateBMI(t, b);
                  if(h > 0) controller.updateHemoglobin(h);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF10B981),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: controller.isSubmitting.value
                  ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
                  : Text('Simpan Data', style: GoogleFonts.nunito(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16)),
              ),
            )),
          ],
        ),
      ),
    );
  }
}
