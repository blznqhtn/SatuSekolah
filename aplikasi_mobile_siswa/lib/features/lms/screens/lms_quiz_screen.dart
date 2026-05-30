import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:aplikasi_mobile_siswa/features/lms/controllers/lms_controller.dart';

class LMSQuizScreen extends StatefulWidget {
  final int quizId;
  final String title;

  const LMSQuizScreen({Key? key, required this.quizId, required this.title}) : super(key: key);

  @override
  State<LMSQuizScreen> createState() => _LMSQuizScreenState();
}

class _LMSQuizScreenState extends State<LMSQuizScreen> {
  final LMSController controller = Get.find<LMSController>();
  Map<String, dynamic> answers = {};

  final List<Map<String, dynamic>> questions = [
    {
      'id': 1,
      'text': 'Berapakah hasil dari 2 + 2?',
      'options': ['2', '3', '4', '5'],
    },
    {
      'id': 2,
      'text': 'Ibukota negara Indonesia adalah?',
      'options': ['Jakarta', 'Bandung', 'Surabaya', 'Medan'],
    },
    {
      'id': 3,
      'text': 'Siapakah penemu bola lampu?',
      'options': ['Thomas Edison', 'Nikola Tesla', 'Albert Einstein', 'Isaac Newton'],
    }
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.close_rounded, color: Color(0xFF0F172A)), onPressed: () => Get.back()),
        title: Text(widget.title, style: GoogleFonts.nunito(color: const Color(0xFF0F172A), fontWeight: FontWeight.w800, fontSize: 18)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
            color: const Color(0xFFEFF6FF),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Sisa Waktu: 45:00', style: GoogleFonts.nunito(color: const Color(0xFF3B82F6), fontWeight: FontWeight.w800)),
                Text('${answers.length} dari ${questions.length} dijawab', style: GoogleFonts.nunito(color: const Color(0xFF64748B), fontWeight: FontWeight.w600, fontSize: 12)),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: questions.length,
              itemBuilder: (context, index) {
                final q = questions[index];
                return _buildQuestionCard(q['id'], index + 1, q['text'], List<String>.from(q['options']));
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -4))]),
            child: Obx(() => SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: controller.isSubmitting.value ? null : () => controller.submitQuiz(widget.quizId, answers),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF10B981),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: controller.isSubmitting.value
                  ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
                  : Text('Submit Jawaban', style: GoogleFonts.nunito(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16)),
              ),
            )),
          )
        ],
      ),
    );
  }

  Widget _buildQuestionCard(int qId, int number, String text, List<String> options) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Pertanyaan $number', style: GoogleFonts.nunito(fontSize: 13, fontWeight: FontWeight.w700, color: const Color(0xFF64748B))),
          const SizedBox(height: 8),
          Text(text, style: GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.w800, color: const Color(0xFF0F172A))),
          const SizedBox(height: 16),
          ...options.map((opt) {
            bool isSelected = answers[qId.toString()] == opt;
            return GestureDetector(
              onTap: () => setState(() => answers[qId.toString()] = opt),
              child: Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFFEFF6FF) : Colors.transparent,
                  border: Border.all(color: isSelected ? const Color(0xFF3B82F6) : const Color(0xFFE2E8F0), width: isSelected ? 2 : 1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Icon(isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked, color: isSelected ? const Color(0xFF3B82F6) : const Color(0xFF94A3B8), size: 20),
                    const SizedBox(width: 12),
                    Expanded(child: Text(opt, style: GoogleFonts.nunito(fontSize: 15, fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600, color: isSelected ? const Color(0xFF3B82F6) : const Color(0xFF0F172A)))),
                  ],
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}
