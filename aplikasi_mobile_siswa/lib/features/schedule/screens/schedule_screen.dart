import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:aplikasi_mobile_siswa/features/schedule/controllers/schedule_controller.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({Key? key}) : super(key: key);

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ScheduleController _ctrl = Get.isRegistered<ScheduleController>()
      ? Get.find<ScheduleController>()
      : Get.put(ScheduleController());

  @override
  void initState() {
    super.initState();
    final initialIndex = _ctrl.selectedDay.value.clamp(0, 4);
    _tabController = TabController(length: 5, vsync: this, initialIndex: initialIndex);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        _ctrl.selectDay(_tabController.index);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));

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
          'Jadwal Pelajaran',
          style: TextStyle(
            color: Color(0xFF0F172A),
            fontWeight: FontWeight.bold,
            fontSize: 20,
            letterSpacing: -0.5,
          ),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(bottom: BorderSide(color: const Color(0xFFE2E8F0))),
            ),
            child: TabBar(
              controller: _tabController,
              labelColor: const Color(0xFF055D97),
              unselectedLabelColor: const Color(0xFF64748B),
              indicatorColor: const Color(0xFF055D97),
              indicatorWeight: 3,
              indicatorSize: TabBarIndicatorSize.tab,
              labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
              tabs: const [
                Tab(text: 'Senin'),
                Tab(text: 'Selasa'),
                Tab(text: 'Rabu'),
                Tab(text: 'Kamis'),
                Tab(text: 'Jumat'),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        physics: const BouncingScrollPhysics(),
        children: [
          _buildDaySchedule(0),
          _buildDaySchedule(1),
          _buildDaySchedule(2),
          _buildDaySchedule(3),
          _buildDaySchedule(4),
        ],
      ),
    );
  }

  Widget _buildDaySchedule(int dayIndex) {
    return RefreshIndicator(
      color: const Color(0xFF055D97),
      onRefresh: () => _ctrl.fetchSchedules(),
      child: Obx(() {
        if (_ctrl.isLoading.value && _ctrl.selectedDay.value == dayIndex) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF055D97)),
          );
        }

        final schedules = _ctrl.schedules;
        if (schedules.isEmpty && _ctrl.selectedDay.value == dayIndex) {
          return Center(
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(40),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: const BoxDecoration(
                        color: Color(0xFFF1F5F9),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.event_busy_rounded, size: 48, color: Color(0xFF94A3B8)),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Tidak ada jadwal pelajaran',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF0F172A)),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Hari ini bebas kelas atau libur.',
                      style: TextStyle(color: Color(0xFF64748B), fontSize: 13),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        return ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
          padding: const EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 100),
          itemCount: schedules.length,
          itemBuilder: (context, index) {
            final item = schedules[index];
            return _buildScheduleItem(
              jamKe: '${index + 1}',
              time: item.formattedTime,
              subject: item.subject,
              teacher: item.teacherName,
              kode: item.room,
              room: item.room,
              color: item.color,
              icon: item.icon,
            );
          },
        );
      }),
    );
  }

  Widget _buildScheduleItem({
    required String jamKe,
    required String time,
    required String subject,
    required String teacher,
    required String kode,
    required String room,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Row(
        children: [
          // Indikator Warna Jam
          Container(
            width: 50,
            height: 120,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                bottomLeft: Radius.circular(16),
              ),
              border: Border(
                right: BorderSide(color: color.withOpacity(0.3), width: 2),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Jam',
                  style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
                ),
                Text(
                  jamKe,
                  style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.w900),
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.access_time_rounded, size: 12, color: Color(0xFF64748B)),
                            const SizedBox(width: 4),
                            Text(
                              time,
                              style: const TextStyle(
                                color: Color(0xFF475569),
                                fontWeight: FontWeight.w600,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(icon, color: color.withOpacity(0.5), size: 20),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    subject,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (teacher != '-')
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE2E8F0),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'Kode: $kode',
                            style: const TextStyle(color: Color(0xFF334155), fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            teacher,
                            style: const TextStyle(color: Color(0xFF64748B), fontSize: 12),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    )
                  else
                    const Text(
                      'Istirahat / Kegiatan Bersama',
                      style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12, fontStyle: FontStyle.italic),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
