import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:aplikasi_mobile_siswa/features/lms/controllers/lms_controller.dart';

class LMSAssignmentDetailScreen extends StatefulWidget {
  final dynamic assignment;
  const LMSAssignmentDetailScreen({Key? key, required this.assignment}) : super(key: key);

  @override
  State<LMSAssignmentDetailScreen> createState() => _LMSAssignmentDetailScreenState();
}

class _LMSAssignmentDetailScreenState extends State<LMSAssignmentDetailScreen> {
  final LMSController controller = Get.find<LMSController>();
  File? _selectedFile;

  Future<void> _pickFile() async {
    // Sebagai simulasi, kita gunakan image_picker untuk memilih foto jawaban tugas
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    
    if (image != null) {
      setState(() {
        _selectedFile = File(image.path);
      });
    }
  }

  void _submitAssignment() {
    if (_selectedFile == null) {
      Get.snackbar('Peringatan', 'Silakan lampirkan file tugas terlebih dahulu');
      return;
    }
    controller.submitAssignment(widget.assignment['id'].toString(), _selectedFile!.path);
  }

  @override
  Widget build(BuildContext context) {
    bool isDone = widget.assignment['status'] == 'selesai';
    
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF0F172A)), onPressed: () => Get.back()),
        title: Text('Detail Tugas', style: GoogleFonts.nunito(color: const Color(0xFF0F172A), fontWeight: FontWeight.w800, fontSize: 18)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isDone ? const Color(0xFFD1FAE5) : const Color(0xFFFEE2E2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                isDone ? 'Sudah Dikerjakan' : 'Belum Dikerjakan',
                style: GoogleFonts.nunito(fontSize: 12, fontWeight: FontWeight.w800, color: isDone ? const Color(0xFF10B981) : const Color(0xFFEF4444)),
              ),
            ),
            const SizedBox(height: 16),
            
            // Judul Tugas
            Text(widget.assignment['judul'], style: GoogleFonts.nunito(fontSize: 22, fontWeight: FontWeight.w800, color: const Color(0xFF0F172A))),
            const SizedBox(height: 8),
            
            // Deadline
            Row(
              children: [
                const Icon(Icons.calendar_today_rounded, size: 16, color: Color(0xFF64748B)),
                const SizedBox(width: 8),
                Text('Tenggat: ${widget.assignment['deadline']}', style: GoogleFonts.nunito(fontSize: 14, fontWeight: FontWeight.w700, color: const Color(0xFF64748B))),
              ],
            ),
            
            if (isDone) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.star_rounded, size: 16, color: Color(0xFFF59E0B)),
                  const SizedBox(width: 8),
                  Text('Nilai: ${widget.assignment['skor'] ?? 'Belum dinilai'}', style: GoogleFonts.nunito(fontSize: 14, fontWeight: FontWeight.w800, color: const Color(0xFFF59E0B))),
                ],
              ),
            ],

            const SizedBox(height: 24),
            const Divider(color: Color(0xFFE2E8F0)),
            const SizedBox(height: 24),

            // Deskripsi
            Text('Instruksi Tugas', style: GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.w800, color: const Color(0xFF0F172A))),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Text(
                widget.assignment['deskripsi'] ?? 'Tidak ada instruksi khusus.',
                style: GoogleFonts.nunito(fontSize: 14, color: const Color(0xFF475569), height: 1.5),
              ),
            ),

            const SizedBox(height: 32),

            // Form Upload (Hanya jika belum dikerjakan)
            if (!isDone) ...[
              Text('Lembar Jawaban', style: GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.w800, color: const Color(0xFF0F172A))),
              const SizedBox(height: 12),
              
              // Attachment Box
              GestureDetector(
                onTap: _pickFile,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFCBD5E1), style: BorderStyle.solid),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        _selectedFile != null ? Icons.check_circle_rounded : Icons.upload_file_rounded,
                        size: 48,
                        color: _selectedFile != null ? const Color(0xFF10B981) : const Color(0xFF94A3B8),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _selectedFile != null ? _selectedFile!.path.split('/').last : 'Tekan untuk melampirkan foto/file',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.nunito(
                          fontSize: 14,
                          fontWeight: _selectedFile != null ? FontWeight.w700 : FontWeight.w600,
                          color: _selectedFile != null ? const Color(0xFF0F172A) : const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
      bottomNavigationBar: !isDone ? Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))],
        ),
        child: Obx(() => ElevatedButton(
          onPressed: controller.isSubmitting.value ? null : _submitAssignment,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF055D97),
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          child: controller.isSubmitting.value
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              : Text('Kumpulkan Tugas', style: GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white)),
        )),
      ) : null,
    );
  }
}
