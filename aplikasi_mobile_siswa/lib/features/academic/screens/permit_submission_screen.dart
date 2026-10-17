import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:aplikasi_mobile_siswa/features/academic/controllers/academic_activity_controller.dart';

class PermitSubmissionScreen extends StatefulWidget {
  const PermitSubmissionScreen({Key? key}) : super(key: key);

  @override
  State<PermitSubmissionScreen> createState() => _PermitSubmissionScreenState();
}

class _PermitSubmissionScreenState extends State<PermitSubmissionScreen> {
  final AcademicActivityController _ctrl = Get.isRegistered<AcademicActivityController>()
      ? Get.find<AcademicActivityController>()
      : Get.put(AcademicActivityController());

  String _permitType = 'Sakit';
  DateTime? _startDate;
  DateTime? _endDate;
  final _reasonCtrl = TextEditingController();
  final _dateDisplayCtrl = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _reasonCtrl.dispose();
    _dateDisplayCtrl.dispose();
    super.dispose();
  }

  String _mapTypeToBackend(String uiType) {
    switch (uiType) {
      case 'Sakit':
        return 'SICK';
      case 'Keluarga':
        return 'FAMILY';
      case 'Dispensasi':
        return 'DISPENSATION';
      default:
        return 'OTHER';
    }
  }

  Future<void> _selectDateRange() async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: now.subtract(const Duration(days: 7)),
      lastDate: now.add(const Duration(days: 90)),
      initialDateRange: DateTimeRange(
        start: _startDate ?? now,
        end: _endDate ?? now,
      ),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFD97706),
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
        _startDate = picked.start;
        _endDate = picked.end;
        final format = DateFormat('dd MMM yyyy');
        if (picked.start == picked.end) {
          _dateDisplayCtrl.text = format.format(picked.start);
        } else {
          _dateDisplayCtrl.text = '${format.format(picked.start)} - ${format.format(picked.end)}';
        }
      });
    }
  }

  Future<void> _submit() async {
    if (_startDate == null || _endDate == null) {
      Get.snackbar(
        'Perhatian',
        'Silakan pilih tanggal izin terlebih dahulu.',
        backgroundColor: Colors.orange.shade600,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final reason = _reasonCtrl.text.trim();
    if (reason.isEmpty) {
      Get.snackbar(
        'Perhatian',
        'Keterangan / alasan izin tidak boleh kosong.',
        backgroundColor: Colors.orange.shade600,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final dateFormat = DateFormat('yyyy-MM-dd');
    final success = await _ctrl.submitPermit(
      type: _mapTypeToBackend(_permitType),
      reason: reason,
      startDate: dateFormat.format(_startDate!),
      endDate: dateFormat.format(_endDate!),
    );

    setState(() => _isSubmitting = false);

    if (success) {
      Get.back();
      Get.snackbar(
        'Berhasil Diajukan',
        'Pengajuan izin telah dikirim dan menunggu persetujuan wali kelas.',
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
        title: const Text(
          'Buat Pengajuan Izin',
          style: TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Jenis Izin', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: RadioListTile<String>(
                    title: const Text('Sakit', style: TextStyle(fontSize: 14)),
                    value: 'Sakit',
                    groupValue: _permitType,
                    contentPadding: EdgeInsets.zero,
                    activeColor: const Color(0xFFD97706),
                    onChanged: (val) => setState(() => _permitType = val!),
                  ),
                ),
                Expanded(
                  child: RadioListTile<String>(
                    title: const Text('Keluarga', style: TextStyle(fontSize: 14)),
                    value: 'Keluarga',
                    groupValue: _permitType,
                    contentPadding: EdgeInsets.zero,
                    activeColor: const Color(0xFFD97706),
                    onChanged: (val) => setState(() => _permitType = val!),
                  ),
                ),
                Expanded(
                  child: RadioListTile<String>(
                    title: const Text('Dispensasi', style: TextStyle(fontSize: 14)),
                    value: 'Dispensasi',
                    groupValue: _permitType,
                    contentPadding: EdgeInsets.zero,
                    activeColor: const Color(0xFFD97706),
                    onChanged: (val) => setState(() => _permitType = val!),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text('Tanggal Izin', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
            const SizedBox(height: 8),
            TextField(
              controller: _dateDisplayCtrl,
              readOnly: true,
              decoration: InputDecoration(
                hintText: 'Pilih rentang tanggal izin',
                filled: true,
                fillColor: const Color(0xFFF1F5F9),
                suffixIcon: const Icon(Icons.calendar_month_rounded, color: Color(0xFF94A3B8)),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
              onTap: _selectDateRange,
            ),
            const SizedBox(height: 24),
            const Text('Keterangan', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
            const SizedBox(height: 8),
            TextField(
              controller: _reasonCtrl,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Tuliskan alasan detail...',
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
                  backgroundColor: const Color(0xFFD97706),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Text('Ajukan Izin', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            )
          ],
        ),
      ),
    );
  }
}
