import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:aplikasi_mobile_siswa/features/health/controllers/health_controller.dart';

class HealthMenstruationScreen extends StatefulWidget {
  const HealthMenstruationScreen({Key? key}) : super(key: key);

  @override
  State<HealthMenstruationScreen> createState() => _HealthMenstruationScreenState();
}

class _HealthMenstruationScreenState extends State<HealthMenstruationScreen> {
  final HealthController controller = Get.find<HealthController>();

  void _showDatePicker() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFEC4899), // Pink
              onPrimary: Colors.white,
              onSurface: Color(0xFF0F172A),
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (date != null) {
      String formattedDate = "${date.day} ${_getMonth(date.month)} ${date.year}";
      controller.logMenstruation(formattedDate);
    }
  }

  String _getMonth(int month) {
    const months = ['Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni', 'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'];
    return months[month - 1];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF0F172A)), onPressed: () => Get.back()),
        title: Text('Siklus Haid', style: GoogleFonts.nunito(color: const Color(0xFF0F172A), fontWeight: FontWeight.w800, fontSize: 18)),
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.isMensLoading.value) {
          return const Center(child: CircularProgressIndicator(color: Color(0xFFEC4899)));
        }

        final data = controller.mensData;
        final List riwayat = data['riwayat'] ?? [];

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Kartu Prediksi
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFBCFE8), Color(0xFFF472B6)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [BoxShadow(color: const Color(0xFFF472B6).withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10))],
                ),
                child: Column(
                  children: [
                    const Icon(Icons.water_drop_rounded, color: Colors.white, size: 48),
                    const SizedBox(height: 16),
                    Text('Prediksi Haid Berikutnya', style: GoogleFonts.nunito(color: Colors.white.withOpacity(0.9), fontSize: 14, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 4),
                    Text(data['prediksi_haid_selanjutnya'] ?? '-', style: GoogleFonts.nunito(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
                      child: Text('Status: ${data['status_siklus'] ?? '-'}', style: GoogleFonts.nunito(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13)),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Catat Baru
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: controller.isSubmitting.value ? null : _showDatePicker,
                  icon: const Icon(Icons.add_circle_outline_rounded),
                  label: Text('Mulai Haid Hari Ini', style: GoogleFonts.nunito(fontWeight: FontWeight.w800, fontSize: 16)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFEC4899),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                ),
              ),

              const SizedBox(height: 40),

              Text('Riwayat Siklus', style: GoogleFonts.nunito(fontSize: 18, fontWeight: FontWeight.w800, color: const Color(0xFF0F172A))),
              const SizedBox(height: 16),

              if (riwayat.isEmpty)
                Center(child: Text('Belum ada riwayat', style: GoogleFonts.nunito(color: const Color(0xFF64748B))))
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: riwayat.length,
                  itemBuilder: (context, index) {
                    final item = riwayat[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(color: const Color(0xFFFDF2F8), borderRadius: BorderRadius.circular(12)),
                            child: const Icon(Icons.calendar_month_rounded, color: Color(0xFFEC4899)),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(item['bulan'] ?? '-', style: GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.w800, color: const Color(0xFF0F172A))),
                                const SizedBox(height: 4),
                                Text('${item['mulai']} - ${item['selesai']}', style: GoogleFonts.nunito(fontSize: 13, color: const Color(0xFF64748B))),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text('${item['siklus']} Hari', style: GoogleFonts.nunito(fontSize: 14, fontWeight: FontWeight.w800, color: const Color(0xFFEC4899))),
                              Text('Siklus', style: GoogleFonts.nunito(fontSize: 11, color: const Color(0xFF94A3B8))),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
            ],
          ),
        );
      }),
    );
  }
}
