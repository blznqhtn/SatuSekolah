import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:aplikasi_mobile_siswa/features/attendance/controllers/attendance_controller.dart';

class AttendanceCheckInScreen extends StatefulWidget {
  const AttendanceCheckInScreen({Key? key}) : super(key: key);

  @override
  State<AttendanceCheckInScreen> createState() => _AttendanceCheckInScreenState();
}

class _AttendanceCheckInScreenState extends State<AttendanceCheckInScreen> {
  final AttendanceController controller = Get.find<AttendanceController>();
  late Timer _timer;
  late DateTime _now;
  File? _selfieImage;

  Future<void> _takeSelfie() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.camera,
      preferredCameraDevice: CameraDevice.front,
    );
    
    if (image != null) {
      setState(() {
        _selfieImage = File(image.path);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _now = DateTime.now();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) setState(() => _now = DateTime.now());
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String timeString = DateFormat('HH:mm:ss').format(_now);
    String dateString = DateFormat('EEEE, dd MMMM yyyy', 'id_ID').format(_now);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF0F172A)), onPressed: () => Get.back()),
        title: Text('Check-In Kehadiran', style: GoogleFonts.nunito(color: const Color(0xFF0F172A), fontWeight: FontWeight.w800, fontSize: 18)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Spacer(),
            GestureDetector(
              onTap: _takeSelfie,
              child: Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: const Color(0xFF10B981).withOpacity(0.2), blurRadius: 40, spreadRadius: 10),
                  ],
                  image: _selfieImage != null
                      ? DecorationImage(
                          image: FileImage(_selfieImage!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: _selfieImage == null
                    ? const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.camera_alt_rounded, size: 50, color: Color(0xFF10B981)),
                          SizedBox(height: 8),
                          Text('Ambil Selfie', style: TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.bold)),
                        ],
                      )
                    : null,
              ),
            ),
            const SizedBox(height: 32),
            Text(timeString, style: GoogleFonts.nunito(fontSize: 48, fontWeight: FontWeight.w800, color: const Color(0xFF0F172A), letterSpacing: 2)),
            const SizedBox(height: 8),
            Text(dateString, style: GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.w600, color: const Color(0xFF64748B))),
            
            const SizedBox(height: 48),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: const Color(0xFFEFF6FF), borderRadius: BorderRadius.circular(16)),
              child: Row(
                children: [
                  const Icon(Icons.location_on_rounded, color: Color(0xFF3B82F6)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Lokasi Saat Ini', style: GoogleFonts.nunito(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFF64748B))),
                        Text('SMK Telkom (Sesuai Radius)', style: GoogleFonts.nunito(fontSize: 14, fontWeight: FontWeight.w800, color: const Color(0xFF0F172A))),
                      ],
                    ),
                  ),
                  const Icon(Icons.check_circle_rounded, color: Color(0xFF10B981)),
                ],
              ),
            ),
            const Spacer(),
            
            Obx(() => SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: (controller.isSubmitting.value || _selfieImage == null) 
                    ? null 
                    : () => controller.submitCheckIn(-6.2, 106.8, _selfieImage!.path),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF10B981),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  disabledBackgroundColor: const Color(0xFFE2E8F0),
                  disabledForegroundColor: const Color(0xFF94A3B8),
                ),
                child: controller.isSubmitting.value
                  ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
                  : Text(
                      _selfieImage == null ? 'Ambil Foto Terlebih Dahulu' : 'Check-In Sekarang', 
                      style: GoogleFonts.nunito(fontWeight: FontWeight.w800, fontSize: 16)
                    ),
              ),
            )),
          ],
        ),
      ),
    );
  }
}
