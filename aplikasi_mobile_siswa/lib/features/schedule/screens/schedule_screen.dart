import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import '../controllers/schedule_controller.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({Key? key}) : super(key: key);

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ScheduleController controller = Get.put(ScheduleController());

  @override
  void initState() {
    super.initState();
    // Default to today's tab
    int initialIndex = controller.todayTabIndex;
    _tabController = TabController(length: 5, vsync: this, initialIndex: initialIndex);
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
          _buildDaySchedule('Senin'),
          _buildDaySchedule('Selasa'),
          _buildDaySchedule('Rabu'),
          _buildDaySchedule('Kamis'),
          _buildDaySchedule('Jumat'),
        ],
      ),
    );
  }

  Widget _buildDaySchedule(String day) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      final scheduleItems = controller.getJadwalHari(day);

      if (scheduleItems.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.event_busy_rounded, size: 64, color: Colors.grey[300]),
              const SizedBox(height: 16),
              Text(
                'Tidak ada jadwal untuk hari $day',
                style: const TextStyle(color: Colors.grey, fontSize: 16),
              ),
            ],
          ),
        );
      }

      List<Widget> widgets = [];

      // Tambahkan kegiatan rutin pagi (contoh)
      if (day == 'Senin') {
        widgets.add(_buildScheduleItemWidget(
          jamKe: '-',
          time: '07:00 - 08:00',
          subject: 'Upacara Bendera',
          teacher: '-',
          kode: '-',
          room: 'Lapangan Utama',
          color: const Color(0xFFE11D48),
          icon: FontAwesomeIcons.flag,
        ));
      } else {
        widgets.addAll([
          _buildScheduleItemWidget(
            jamKe: '-',
            time: '07:00 - 07:30',
            subject: 'Dhuha & Tadarus',
            teacher: '-',
            kode: '-',
            room: 'Masjid',
            color: const Color(0xFF14B8A6),
            icon: FontAwesomeIcons.mosque,
          ),
        ]);
      }

      // Tambahkan item dari DB
      for (int i = 0; i < scheduleItems.length; i++) {
        final item = scheduleItems[i];
        
        // Cek jika butuh sisipkan istirahat berdasarkan jam
        if (i > 0 && item.jamMulai.compareTo('09:40') >= 0 && scheduleItems[i-1].jamSelesai.compareTo('09:40') <= 0) {
           // Contoh sisipan istirahat, di real app bisa diatur lebih dinamis
        }

        widgets.add(_buildScheduleItemWidget(
          jamKe: item.jamKeLabel,
          time: '${item.jamMulai} - ${item.jamSelesai}',
          subject: item.mataPelajaran,
          teacher: item.guru,
          kode: item.courseId.isNotEmpty ? item.courseId.substring(0, 4) : '-',
          room: item.ruangan,
          color: item.color,
          icon: item.icon,
        ));
      }

      return ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 100),
        children: widgets,
      );
    });
  }

  Widget _buildScheduleItemWidget({
    required String jamKe,
    required String time,
    required String subject,
    required String teacher,
    required String kode,
    required String room,
    required Color color,
    required dynamic icon,
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
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: FaIcon(
                          icon,
                          color: color,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 8),
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
