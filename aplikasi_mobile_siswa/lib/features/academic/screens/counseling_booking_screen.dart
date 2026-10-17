import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:aplikasi_mobile_siswa/features/academic/controllers/academic_activity_controller.dart';

class CounselingBookingScreen extends StatefulWidget {
  const CounselingBookingScreen({Key? key}) : super(key: key);

  @override
  State<CounselingBookingScreen> createState() => _CounselingBookingScreenState();
}

class _CounselingBookingScreenState extends State<CounselingBookingScreen> {
  final AcademicActivityController _ctrl = Get.isRegistered<AcademicActivityController>()
      ? Get.find<AcademicActivityController>()
      : Get.put(AcademicActivityController());

  String _topic = 'Karir & PKL';
  DateTime? _preferredDate;
  final _descriptionCtrl = TextEditingController();
  final _dateDisplayCtrl = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _descriptionCtrl.dispose();
    _dateDisplayCtrl.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _preferredDate ?? now.add(const Duration(days: 1)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 60)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF7C3AED),
              onPrimary: Colors.white,
              onSurface: Color(0xFF0F172A),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _preferredDate = picked;
        _dateDisplayCtrl.text = DateFormat('dd MMM yyyy').format(picked);
      });
    }
  }

  Future<void> _submit() async {
    if (_preferredDate == null) {
      Get.snackbar(
        'Perhatian',
        'Silakan pilih perkiraan tanggal pertemuan konseling.',
        backgroundColor: Colors.orange.shade600,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final description = _descriptionCtrl.text.trim();
    if (description.isEmpty) {
      Get.snackbar(
        'Perhatian',
        'Silakan ceritakan sedikit topik permasalahan Anda.',
        backgroundColor: Colors.orange.shade600,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final dateFormat = DateFormat('yyyy-MM-dd');
    final success = await _ctrl.bookCounselingSession(
      topic: _topic,
      description: description,
      preferredDate: dateFormat.format(_preferredDate!),
    );

    setState(() => _isSubmitting = false);

    if (success) {
      Get.back();
      Get.snackbar(
        'Pengajuan Terkirim',
        'Jadwal konseling telah diajukan dan akan segera dikonfirmasi oleh Guru BK.',
        backgroundColor: Colors.purple.shade600,
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
        title: const Text(
          'Ajukan Konseling BK',
          style: TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Topik Konseling', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _topic,
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFFF1F5F9),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
              items: ['Karir & PKL', 'Akademik', 'Pribadi / Sosial', 'Kedisiplinan'].map((String value) {
                return DropdownMenuItem<String>(value: value, child: Text(value));
              }).toList(),
              onChanged: (val) {
                if (val != null) setState(() => _topic = val);
              },
            ),
            const SizedBox(height: 24),
            const Text('Perkiraan Tanggal Konseling', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
            const SizedBox(height: 8),
            TextField(
              controller: _dateDisplayCtrl,
              readOnly: true,
              decoration: InputDecoration(
                hintText: 'Pilih tanggal yang diharapkan',
                filled: true,
                fillColor: const Color(0xFFF1F5F9),
                suffixIcon: const Icon(Icons.calendar_month_rounded, color: Color(0xFF94A3B8)),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
              onTap: _selectDate,
            ),
            const SizedBox(height: 24),
            const Text('Ceritakan Sedikit Masalahmu', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
            const SizedBox(height: 8),
            TextField(
              controller: _descriptionCtrl,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: 'Tuliskan secara terbuka atau poin-poin yang ingin didiskusikan...',
                filled: true,
                fillColor: const Color(0xFFF1F5F9),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7C3AED),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Text('Kirim Pengajuan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            )
          ],
        ),
      ),
    );
  }
}
