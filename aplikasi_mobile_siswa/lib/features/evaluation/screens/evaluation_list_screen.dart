import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:aplikasi_mobile_siswa/features/evaluation/screens/evaluation_form_screen.dart';
import '../controllers/evaluation_controller.dart';

class EvaluationListScreen extends StatelessWidget {
  const EvaluationListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final EvaluationController ctrl = Get.isRegistered<EvaluationController>()
        ? Get.find<EvaluationController>()
        : Get.put(EvaluationController());

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
          'Kinerja Guru',
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
      body: Obx(() {
        if (ctrl.isLoading.value && ctrl.teachers.isEmpty) {
          return const Center(child: CircularProgressIndicator(color: Color(0xFF055D97)));
        }

        if (ctrl.teachers.isEmpty) {
          return RefreshIndicator(
            onRefresh: () => ctrl.fetchData(),
            color: const Color(0xFF055D97),
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
              children: const [
                SizedBox(height: 120),
                Center(
                  child: Column(
                    children: [
                      Icon(Icons.assignment_turned_in_outlined, size: 64, color: Color(0xFF94A3B8)),
                      SizedBox(height: 16),
                      Text(
                        'Belum ada guru yang perlu dievaluasi.',
                        style: TextStyle(color: Color(0xFF64748B), fontSize: 15),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => ctrl.fetchData(),
          color: const Color(0xFF055D97),
          child: ListView.separated(
            padding: const EdgeInsets.all(20),
            physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
            itemCount: ctrl.teachers.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final teacher = ctrl.teachers[index];
              final bool isEvaluated = teacher.isEvaluated;

              return Container(
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
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.person, color: Color(0xFF64748B)),
                  ),
                  title: Text(
                    teacher.name,
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F172A), fontSize: 15),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      teacher.subject,
                      style: const TextStyle(color: Color(0xFF64748B), fontSize: 13),
                    ),
                  ),
                  trailing: isEvaluated
                      ? const Icon(Icons.check_circle, color: Color(0xFF10B981))
                      : ElevatedButton(
                          onPressed: () {
                            Get.to(() => EvaluationFormScreen(teacherName: teacher.name, subject: teacher.subject));
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF055D97),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: const Text('Nilai', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                        ),
                ),
              );
            },
          ),
        );
      }),
    );
  }
}
