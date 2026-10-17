import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:aplikasi_mobile_siswa/features/academic/controllers/academic_activity_controller.dart';
import 'package:aplikasi_mobile_siswa/features/academic/screens/extracurricular_registration_screen.dart';

class ExtracurricularScreen extends StatelessWidget {
  const ExtracurricularScreen({Key? key}) : super(key: key);

  AcademicActivityController get _ctrl =>
      Get.isRegistered<AcademicActivityController>()
          ? Get.find<AcademicActivityController>()
          : Get.put(AcademicActivityController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF0F172A), size: 20),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Ekstrakurikuler',
          style: TextStyle(
            color: Color(0xFF0F172A),
            fontWeight: FontWeight.bold,
            fontSize: 20,
            letterSpacing: -0.5,
          ),
        ),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        color: const Color(0xFF055D97),
        onRefresh: () async {
          await Future.wait([
            _ctrl.fetchExtracurriculars(),
            _ctrl.fetchMyRegistrations(),
          ]);
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Ekskul yang Diikuti',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 16),
              Obx(() {
                if (_ctrl.myRegistrations.isEmpty) {
                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.sports_soccer_rounded, color: Color(0xFF64748B)),
                        ),
                        const SizedBox(width: 14),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Belum Bergabung',
                                style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F172A), fontSize: 14),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Pilih ekstrakurikuler di bawah untuk mulai mendaftar.',
                                style: TextStyle(color: Color(0xFF64748B), fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return Column(
                  children: _ctrl.myRegistrations.map((reg) {
                    final extraName = reg.extracurricular?.name ?? 'Ekstrakurikuler';
                    final schedule = reg.extracurricular != null
                        ? '${reg.extracurricular!.scheduleDay}, ${reg.extracurricular!.scheduleTime}'
                        : 'Jadwal Reguler';

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF055D97), Color(0xFF2563EB)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF055D97).withOpacity(0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(Icons.star_rounded, color: Colors.white),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      extraName,
                                      style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      reg.status == 'APPROVED' ? 'Anggota Aktif' : 'Status: ${reg.status}',
                                      style: const TextStyle(color: Colors.white70, fontSize: 13),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.schedule_rounded, color: Colors.white, size: 16),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Jadwal: $schedule',
                                    style: const TextStyle(color: Colors.white, fontSize: 13),
                                  ),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    );
                  }).toList(),
                );
              }),
              const SizedBox(height: 32),
              const Text(
                'Daftar Ekstrakurikuler',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 16),
              Obx(() {
                if (_ctrl.isLoadingExtras.value) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: Center(
                      child: CircularProgressIndicator(color: Color(0xFF055D97)),
                    ),
                  );
                }

                if (_ctrl.extrasError.value.isNotEmpty) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Center(
                      child: Column(
                        children: [
                          const Icon(Icons.error_outline_rounded, color: Colors.red, size: 36),
                          const SizedBox(height: 8),
                          Text(_ctrl.extrasError.value, style: const TextStyle(color: Color(0xFF64748B))),
                          const SizedBox(height: 8),
                          TextButton(
                            onPressed: () => _ctrl.fetchExtracurriculars(),
                            child: const Text('Coba Lagi'),
                          )
                        ],
                      ),
                    ),
                  );
                }

                if (_ctrl.extracurriculars.isEmpty) {
                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      children: const [
                        Icon(Icons.sports_handball_rounded, size: 48, color: Color(0xFF94A3B8)),
                        SizedBox(height: 12),
                        Text(
                          'Belum Ada Daftar Ekstrakurikuler',
                          style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F172A), fontSize: 16),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Daftar ekstrakurikuler sekolah akan segera diumumkan.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Color(0xFF64748B), fontSize: 13),
                        ),
                      ],
                    ),
                  );
                }

                return Column(
                  children: _ctrl.extracurriculars.map((extra) {
                    final isRegistered = _ctrl.myRegistrations.any((r) => r.extracurricularId == extra.id);
                    return _buildEkskulItem(extra, isRegistered);
                  }).toList(),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEkskulItem(ExtracurricularModel extra, bool isRegistered) {
    final iconConfig = _getExtraIcon(extra.name);

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
            decoration: BoxDecoration(
              color: iconConfig.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(iconConfig.icon, color: iconConfig.color),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  extra.name,
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F172A), fontSize: 15),
                ),
                const SizedBox(height: 4),
                Text(
                  '${extra.category} • ${extra.scheduleDay}',
                  style: const TextStyle(color: Color(0xFF64748B), fontSize: 13),
                ),
              ],
            ),
          ),
          if (isRegistered)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                'Terdaftar',
                style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 12),
              ),
            )
          else
            ElevatedButton(
              onPressed: () {
                Get.to(() => ExtracurricularRegistrationScreen(extra: extra));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF1F5F9),
                foregroundColor: const Color(0xFF055D97),
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Daftar', style: TextStyle(fontWeight: FontWeight.bold)),
            )
        ],
      ),
    );
  }

  _ExtraIcon _getExtraIcon(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('pramuka')) {
      return _ExtraIcon(icon: Icons.nature_people_rounded, color: Colors.brown);
    } else if (lower.contains('pmr') || lower.contains('kesehatan')) {
      return _ExtraIcon(icon: Icons.local_hospital_rounded, color: Colors.red);
    } else if (lower.contains('basket')) {
      return _ExtraIcon(icon: Icons.sports_basketball_rounded, color: Colors.orange);
    } else if (lower.contains('futsal') || lower.contains('bola')) {
      return _ExtraIcon(icon: Icons.sports_soccer_rounded, color: Colors.green);
    } else if (lower.contains('it') || lower.contains('coding') || lower.contains('robotik')) {
      return _ExtraIcon(icon: Icons.computer_rounded, color: Colors.blue);
    } else if (lower.contains('rohis') || lower.contains('islam')) {
      return _ExtraIcon(icon: Icons.mosque_rounded, color: Colors.teal);
    }
    return _ExtraIcon(icon: Icons.star_rounded, color: const Color(0xFF055D97));
  }
}

class _ExtraIcon {
  final IconData icon;
  final Color color;
  const _ExtraIcon({required this.icon, required this.color});
}
