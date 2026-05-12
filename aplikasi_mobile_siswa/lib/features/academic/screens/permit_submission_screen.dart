import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class PermitSubmissionScreen extends StatefulWidget {
  const PermitSubmissionScreen({Key? key}) : super(key: key);

  @override
  State<PermitSubmissionScreen> createState() => _PermitSubmissionScreenState();
}

class _PermitSubmissionScreenState extends State<PermitSubmissionScreen> {
  String _permitType = 'Sakit';

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
                    onChanged: (val) => setState(() => _permitType = val!),
                  ),
                ),
                Expanded(
                  child: RadioListTile<String>(
                    title: const Text('Keluarga', style: TextStyle(fontSize: 14)),
                    value: 'Keluarga',
                    groupValue: _permitType,
                    contentPadding: EdgeInsets.zero,
                    onChanged: (val) => setState(() => _permitType = val!),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text('Tanggal Izin', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
            const SizedBox(height: 8),
            TextField(
              readOnly: true,
              decoration: InputDecoration(
                hintText: 'Pilih Tanggal',
                filled: true,
                fillColor: const Color(0xFFF1F5F9),
                suffixIcon: const Icon(Icons.calendar_month_rounded, color: Color(0xFF94A3B8)),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
              onTap: () async {
                await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime.now(), lastDate: DateTime(2030));
              },
            ),
            const SizedBox(height: 24),
            const Text('Keterangan', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
            const SizedBox(height: 8),
            TextField(
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Tuliskan alasan detail...',
                filled: true,
                fillColor: const Color(0xFFF1F5F9),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 24),
            const Text('Bukti Surat (Opsional)', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 24),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0), style: BorderStyle.solid),
              ),
              child: Center(
                child: Column(
                  children: const [
                    Icon(Icons.upload_file_rounded, color: Color(0xFF94A3B8), size: 32),
                    SizedBox(height: 8),
                    Text('Unggah Surat Sakit / Bukti Foto', style: TextStyle(color: Color(0xFF64748B), fontSize: 13)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Get.back();
                  Get.snackbar('Berhasil', 'Pengajuan izin telah dikirim ke Wali Kelas.', backgroundColor: Colors.orange, colorText: Colors.white);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD97706),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Ajukan Izin', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            )
          ],
        ),
      ),
    );
  }
}
