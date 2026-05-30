import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:aplikasi_mobile_siswa/features/lms/controllers/lms_controller.dart';
import 'package:aplikasi_mobile_siswa/features/lms/screens/lms_quiz_screen.dart';
import 'package:aplikasi_mobile_siswa/features/lms/screens/lms_assignment_detail_screen.dart';

class LMSCourseDetailScreen extends StatefulWidget {
  final String courseId;
  const LMSCourseDetailScreen({Key? key, required this.courseId}) : super(key: key);

  @override
  State<LMSCourseDetailScreen> createState() => _LMSCourseDetailScreenState();
}

class _LMSCourseDetailScreenState extends State<LMSCourseDetailScreen> {
  final LMSController controller = Get.find<LMSController>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchCourseDetail(widget.courseId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF0F172A)), onPressed: () => Get.back()),
        title: Obx(() => Text(
          controller.isLoading.value ? 'Memuat...' : (controller.courseDetail['mata_pelajaran'] ?? 'Detail Mata Pelajaran'),
          style: GoogleFonts.nunito(color: const Color(0xFF0F172A), fontWeight: FontWeight.w800, fontSize: 18),
        )),
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final modulList = controller.courseDetail['modul_list'] ?? [];
        final kuisList = controller.courseDetail['kuis_list'] ?? [];
        final tugasList = controller.courseDetail['tugas_list'] ?? [];

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Materi & Modul', style: GoogleFonts.nunito(fontSize: 18, fontWeight: FontWeight.w800, color: const Color(0xFF0F172A))),
              const SizedBox(height: 16),
              if (modulList.isEmpty) Text('Belum ada modul.', style: GoogleFonts.nunito(color: const Color(0xFF64748B))),
              ...modulList.map<Widget>((m) => _buildModuleCard(m['judul'], m['tipe'])).toList(),
              
              const SizedBox(height: 32),
              
              Text('Tugas', style: GoogleFonts.nunito(fontSize: 18, fontWeight: FontWeight.w800, color: const Color(0xFF0F172A))),
              const SizedBox(height: 16),
              if (tugasList.isEmpty) Text('Belum ada tugas.', style: GoogleFonts.nunito(color: const Color(0xFF64748B))),
              ...tugasList.map<Widget>((t) => _buildAssignmentCard(t)).toList(),

              const SizedBox(height: 32),

              Text('Kuis', style: GoogleFonts.nunito(fontSize: 18, fontWeight: FontWeight.w800, color: const Color(0xFF0F172A))),
              const SizedBox(height: 16),
              if (kuisList.isEmpty) Text('Belum ada kuis.', style: GoogleFonts.nunito(color: const Color(0xFF64748B))),
              ...kuisList.map<Widget>((k) => _buildQuizCard(k['id'], k['judul'], k['status'], k['skor'], k['deadline'])).toList(),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildModuleCard(String title, String type) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: const Color(0xFFEFF6FF), borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.picture_as_pdf_rounded, color: Color(0xFF3B82F6)),
          ),
          const SizedBox(width: 16),
          Expanded(child: Text(title, style: GoogleFonts.nunito(fontSize: 15, fontWeight: FontWeight.w700, color: const Color(0xFF0F172A)))),
          IconButton(
            icon: const Icon(Icons.download_rounded, color: Color(0xFF3B82F6)),
            onPressed: () {
              Get.snackbar('Download', 'Mengunduh modul $title...');
            },
          )
        ],
      ),
    );
  }

  Widget _buildQuizCard(int id, String title, String status, dynamic skor, String? deadline) {
    bool isDone = status == 'selesai';
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: isDone ? const Color(0xFFD1FAE5) : const Color(0xFFFEF3C7), borderRadius: BorderRadius.circular(12)),
            child: Icon(Icons.assignment_rounded, color: isDone ? const Color(0xFF10B981) : const Color(0xFFF59E0B)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.nunito(fontSize: 15, fontWeight: FontWeight.w700, color: const Color(0xFF0F172A))),
                const SizedBox(height: 4),
                Text(isDone ? 'Skor: $skor' : 'Deadline: $deadline', style: GoogleFonts.nunito(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFF64748B))),
              ],
            ),
          ),
          if (!isDone)
            ElevatedButton(
              onPressed: () => Get.to(() => LMSQuizScreen(quizId: id, title: title)),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF3B82F6), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8)),
              child: Text('Kerjakan', style: GoogleFonts.nunito(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 13)),
            )
          else
            const Icon(Icons.check_circle_rounded, color: Color(0xFF10B981)),
        ],
      ),
    );
  }

  Widget _buildAssignmentCard(dynamic assignment) {
    bool isDone = assignment['status'] == 'selesai';
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: isDone ? const Color(0xFFD1FAE5) : const Color(0xFFFEE2E2), borderRadius: BorderRadius.circular(12)),
            child: Icon(Icons.upload_file_rounded, color: isDone ? const Color(0xFF10B981) : const Color(0xFFEF4444)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(assignment['judul'], style: GoogleFonts.nunito(fontSize: 15, fontWeight: FontWeight.w700, color: const Color(0xFF0F172A))),
                const SizedBox(height: 4),
                Text(isDone ? 'Selesai (Skor: ${assignment['skor'] ?? '-'})' : 'Tenggat: ${assignment['deadline']}', style: GoogleFonts.nunito(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFF64748B))),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () => Get.to(() => LMSAssignmentDetailScreen(assignment: assignment)),
            style: ElevatedButton.styleFrom(
              backgroundColor: isDone ? const Color(0xFFF1F5F9) : const Color(0xFF3B82F6),
              foregroundColor: isDone ? const Color(0xFF64748B) : Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8)
            ),
            child: Text(isDone ? 'Lihat' : 'Kerjakan', style: GoogleFonts.nunito(fontWeight: FontWeight.w800, fontSize: 13)),
          )
        ],
      ),
    );
  }
}
