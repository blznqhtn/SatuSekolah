import 'package:flutter/material.dart';
import 'package:get/get.dart';

class EvaluationFormController extends GetxController {
  // Map untuk menyimpan jawaban dari setiap pertanyaan. Key = index pertanyaan, Value = index jawaban yang dipilih
  final answers = <int, int>{}.obs;

  void selectAnswer(int questionIndex, int answerIndex) {
    answers[questionIndex] = answerIndex;
  }
}

class EvaluationFormScreen extends StatelessWidget {
  final String teacherName;
  final String subject;

  EvaluationFormScreen({Key? key, required this.teacherName, required this.subject}) : super(key: key);

  final EvaluationFormController controller = Get.put(EvaluationFormController());

  final List<String> questions = [
    "Bagaimana kejelasan guru dalam menyampaikan materi pelajaran di kelas?",
    "Bagaimana kedisiplinan guru dalam kehadiran dan ketepatan waktu mengajar?",
    "Bagaimana kemampuan guru dalam menjawab pertanyaan dan memberikan solusi?",
    "Bagaimana tingkat interaksi dan keaktifan guru dengan siswa selama proses belajar?",
    "Bagaimana objektivitas guru dalam memberikan nilai ujian dan tugas?",
  ];

  final List<String> options = [
    "Sangat Baik",
    "Baik",
    "Biasa Aja",
    "Buruk",
    "Sangat Buruk"
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF0F172A), size: 20),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Isi Kuesioner',
          style: TextStyle(
            color: Color(0xFF0F172A),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: const Color(0xFFE2E8F0), height: 1.0),
        ),
      ),
      body: Column(
        children: [
          // Info Guru yang dinilai
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Menilai Guru:', style: TextStyle(color: Color(0xFF64748B), fontSize: 13)),
                const SizedBox(height: 4),
                Text(teacherName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF0F172A))),
                Text('Mata Pelajaran: $subject', style: const TextStyle(color: Color(0xFF64748B), fontSize: 14)),
              ],
            ),
          ),
          const Divider(height: 1, thickness: 1, color: Color(0xFFE2E8F0)),

          // List Pertanyaan
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(20),
              physics: const BouncingScrollPhysics(),
              itemCount: questions.length,
              itemBuilder: (context, qIndex) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 24),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.02),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Teks Pertanyaan
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${qIndex + 1}. ',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF055D97)),
                          ),
                          Expanded(
                            child: Text(
                              questions[qIndex],
                              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: Color(0xFF1E293B), height: 1.4),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Pilihan Ganda Custom
                      ...List.generate(options.length, (optIndex) {
                        return Obx(() {
                          final isSelected = controller.answers[qIndex] == optIndex;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: InkWell(
                              onTap: () => controller.selectAnswer(qIndex, optIndex),
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                decoration: BoxDecoration(
                                  color: isSelected ? const Color(0xFFEFF6FF) : Colors.transparent, // Background biru muda jika dipilih
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: isSelected ? const Color(0xFF3B82F6) : const Color(0xFFE2E8F0),
                                    width: isSelected ? 1.5 : 1,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 20,
                                      height: 20,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: isSelected ? const Color(0xFF3B82F6) : const Color(0xFF94A3B8),
                                          width: isSelected ? 6 : 1.5,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      options[optIndex],
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                        color: isSelected ? const Color(0xFF1E3A8A) : const Color(0xFF475569),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        });
                      }),
                    ],
                  ),
                );
              },
            ),
          ),
          
          // Tombol Kirim
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Colors.grey.shade200)),
            ),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Jika semua sudah diisi (contoh sederhana)
                  Get.back();
                  Get.snackbar(
                    'Berhasil', 
                    'Penilaian kinerja guru berhasil dikirim!',
                    backgroundColor: const Color(0xFF10B981),
                    colorText: Colors.white,
                    snackPosition: SnackPosition.BOTTOM,
                    margin: const EdgeInsets.all(20),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0F172A),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  elevation: 0,
                ),
                child: const Text('Kirim Penilaian', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
