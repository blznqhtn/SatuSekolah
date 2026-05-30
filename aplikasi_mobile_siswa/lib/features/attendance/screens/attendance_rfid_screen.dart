import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:aplikasi_mobile_siswa/features/attendance/controllers/attendance_controller.dart';

class AttendanceRfidScreen extends StatelessWidget {
  const AttendanceRfidScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final AttendanceController controller = Get.find<AttendanceController>();
    
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF0F172A)), onPressed: () => Get.back()),
        title: Text('Kartu RFID & Digital ID', style: GoogleFonts.nunito(color: const Color(0xFF0F172A), fontWeight: FontWeight.w800, fontSize: 18)),
        centerTitle: true,
      ),
      body: Obx(() {
        final rfidData = controller.rfidData;
        final bool isLinked = rfidData['is_linked'] == true;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Virtual ID Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [BoxShadow(color: const Color(0xFF0F172A).withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10))],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('KARTU PELAJAR', style: GoogleFonts.nunito(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 2)),
                        const Icon(Icons.contactless_rounded, color: Colors.white70),
                      ],
                    ),
                    const SizedBox(height: 32),
                    Text('ADRIANUS', style: GoogleFonts.nunito(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800)),
                    Text('NIS: 2024001', style: GoogleFonts.nunito(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 32),
                    
                    // Barcode Simulasi
                    Container(
                      height: 60,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          '|| ||| | ||| || || | | || |||',
                          style: GoogleFonts.libreBarcode39(fontSize: 48, color: Colors.black),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Status RFID
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Status Kartu Fisik', style: GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.w800, color: const Color(0xFF0F172A))),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isLinked ? const Color(0xFFD1FAE5) : const Color(0xFFFEE2E2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            isLinked ? Icons.check_circle_rounded : Icons.cancel_rounded,
                            color: isLinked ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(isLinked ? 'Terhubung' : 'Belum Terhubung', style: GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.w800, color: const Color(0xFF0F172A))),
                              Text(
                                isLinked ? 'No: ${rfidData['rfid_number']}' : 'Silakan hubungi admin sekolah',
                                style: GoogleFonts.nunito(fontSize: 14, color: const Color(0xFF64748B)),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 32),
              
              Text(
                'Anda dapat menggunakan Barcode di atas pada alat scanner sekolah jika lupa membawa kartu RFID fisik.',
                textAlign: TextAlign.center,
                style: GoogleFonts.nunito(fontSize: 14, color: const Color(0xFF64748B), height: 1.5),
              ),
            ],
          ),
        );
      }),
    );
  }
}
