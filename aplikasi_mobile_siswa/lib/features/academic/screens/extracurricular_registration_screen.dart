import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:aplikasi_mobile_siswa/features/academic/controllers/academic_activity_controller.dart';

class ExtracurricularRegistrationScreen extends StatefulWidget {
  final ExtracurricularModel extra;
  const ExtracurricularRegistrationScreen({Key? key, required this.extra}) : super(key: key);

  @override
  State<ExtracurricularRegistrationScreen> createState() => _ExtracurricularRegistrationScreenState();
}

class _ExtracurricularRegistrationScreenState extends State<ExtracurricularRegistrationScreen> {
  final AcademicActivityController _ctrl = Get.isRegistered<AcademicActivityController>()
      ? Get.find<AcademicActivityController>()
      : Get.put(AcademicActivityController());

  final _reasonCtrl = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _reasonCtrl.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    setState(() => _isSubmitting = true);
    final success = await _ctrl.registerExtracurricular(widget.extra.id);
    setState(() => _isSubmitting = false);

    if (success) {
      Get.back();
      Get.snackbar(
        'Pendaftaran Berhasil',
        'Pendaftaran ekstrakurikuler ${widget.extra.name} berhasil diajukan.',
        backgroundColor: Colors.green.shade600,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

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
        title: Text(
          'Daftar ${widget.extra.name}',
          style: const TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.info_outline_rounded, color: Color(0xFF055D97), size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Informasi Kegiatan ${widget.extra.name}',
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F172A), fontSize: 14),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (widget.extra.description.isNotEmpty) ...[
                    Text(
                      widget.extra.description,
                      style: const TextStyle(color: Color(0xFF64748B), height: 1.5, fontSize: 13),
                    ),
                    const SizedBox(height: 12),
                  ],
                  Row(
                    children: [
                      const Icon(Icons.schedule_rounded, size: 16, color: Color(0xFF64748B)),
                      const SizedBox(width: 8),
                      Text(
                        '${widget.extra.scheduleDay}, ${widget.extra.scheduleTime}',
                        style: const TextStyle(color: Color(0xFF334155), fontSize: 13, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                  if (widget.extra.location.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined, size: 16, color: Color(0xFF64748B)),
                        const SizedBox(width: 8),
                        Text(
                          widget.extra.location,
                          style: const TextStyle(color: Color(0xFF334155), fontSize: 13),
                        ),
                      ],
                    ),
                  ],
                  if (widget.extra.coachName.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.person_outline_rounded, size: 16, color: Color(0xFF64748B)),
                        const SizedBox(width: 8),
                        Text(
                          'Pembina: ${widget.extra.coachName}',
                          style: const TextStyle(color: Color(0xFF334155), fontSize: 13),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text('Alasan Bergabung (Opsional)', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
            const SizedBox(height: 8),
            TextField(
              controller: _reasonCtrl,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Tuliskan minat atau pengalaman Anda terkait ekstrakurikuler ini...',
                filled: true,
                fillColor: const Color(0xFFF1F5F9),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _register,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF055D97),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Text('Kirim Pendaftaran', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            )
          ],
        ),
      ),
    );
  }
}
