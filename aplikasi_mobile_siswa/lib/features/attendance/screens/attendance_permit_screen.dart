import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:aplikasi_mobile_siswa/features/attendance/controllers/attendance_controller.dart';

class AttendancePermitScreen extends StatefulWidget {
  const AttendancePermitScreen({Key? key}) : super(key: key);

  @override
  State<AttendancePermitScreen> createState() => _AttendancePermitScreenState();
}

class _AttendancePermitScreenState extends State<AttendancePermitScreen> {
  final AttendanceController controller = Get.find<AttendanceController>();
  final TextEditingController dateCtrl = TextEditingController();
  final TextEditingController descCtrl = TextEditingController();
  String selectedType = 'Sakit';
  File? _selectedFile;

  Future<void> _pickFile() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    
    if (image != null) {
      setState(() {
        _selectedFile = File(image.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF0F172A)), onPressed: () => Get.back()),
        title: Text('Pengajuan Izin', style: GoogleFonts.nunito(color: const Color(0xFF0F172A), fontWeight: FontWeight.w800, fontSize: 18)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Jenis Izin', style: GoogleFonts.nunito(fontWeight: FontWeight.w700, color: const Color(0xFF0F172A), fontSize: 14)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(child: _buildTypeOption('Sakit', Icons.medical_services_rounded, const Color(0xFFEF4444))),
                const SizedBox(width: 12),
                Expanded(child: _buildTypeOption('Izin', Icons.assignment_rounded, const Color(0xFFF59E0B))),
              ],
            ),
            const SizedBox(height: 24),
            
            Text('Tanggal Mulai', style: GoogleFonts.nunito(fontWeight: FontWeight.w700, color: const Color(0xFF0F172A), fontSize: 14)),
            const SizedBox(height: 8),
            TextField(
              controller: dateCtrl,
              readOnly: true,
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 30)),
                );
                if (date != null) {
                  dateCtrl.text = "${date.day}/${date.month}/${date.year}";
                }
              },
              decoration: InputDecoration(
                hintText: 'Pilih Tanggal',
                prefixIcon: const Icon(Icons.calendar_today_rounded, color: Color(0xFF64748B)),
                filled: true, fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
              ),
            ),
            
            const SizedBox(height: 24),
            Text('Keterangan / Alasan', style: GoogleFonts.nunito(fontWeight: FontWeight.w700, color: const Color(0xFF0F172A), fontSize: 14)),
            const SizedBox(height: 8),
            TextField(
              controller: descCtrl,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Jelaskan alasan izin Anda...',
                filled: true, fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
              ),
            ),
            
            const SizedBox(height: 24),
            Text('Lampiran Surat (Opsional)', style: GoogleFonts.nunito(fontWeight: FontWeight.w700, color: const Color(0xFF0F172A), fontSize: 14)),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _pickFile,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF3B82F6).withOpacity(0.3), style: BorderStyle.solid),
                ),
                child: Column(
                  children: [
                    Icon(
                      _selectedFile != null ? Icons.check_circle_rounded : Icons.upload_file_rounded, 
                      color: _selectedFile != null ? const Color(0xFF10B981) : const Color(0xFF3B82F6), 
                      size: 32
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _selectedFile != null ? _selectedFile!.path.split('/').last : 'Upload Surat Dokter / Orang Tua', 
                      style: GoogleFonts.nunito(
                        color: _selectedFile != null ? const Color(0xFF10B981) : const Color(0xFF3B82F6), 
                        fontWeight: FontWeight.w700
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 48),
            Obx(() => SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: controller.isSubmitting.value ? null : () => controller.submitPermit(dateCtrl.text, selectedType, descCtrl.text, filePath: _selectedFile?.path),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF055D97),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: controller.isSubmitting.value
                  ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
                  : Text('Ajukan Izin', style: GoogleFonts.nunito(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16)),
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeOption(String title, IconData icon, Color color) {
    bool isSelected = selectedType == title;
    return GestureDetector(
      onTap: () => setState(() => selectedType = title),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : Colors.white,
          border: Border.all(color: isSelected ? color : const Color(0xFFE2E8F0), width: isSelected ? 2 : 1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: isSelected ? color : const Color(0xFF94A3B8)),
            const SizedBox(height: 8),
            Text(title, style: GoogleFonts.nunito(fontWeight: FontWeight.w700, color: isSelected ? color : const Color(0xFF64748B))),
          ],
        ),
      ),
    );
  }
}
