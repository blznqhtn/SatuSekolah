import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({Key? key}) : super(key: key);

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
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
    // Data dummy berdasarkan gambar dan kondisi hari
    List<Widget> scheduleItems = [];

    if (day == 'Senin') {
      scheduleItems.add(
        _buildScheduleItem(
          jamKe: '-',
          time: '07:00 - 08:00',
          subject: 'Upacara Bendera',
          teacher: '-',
          kode: '-',
          room: 'Lapangan Utama',
          color: const Color(0xFFE11D48),
          icon: Icons.flag_rounded,
        ),
      );
    } else {
      scheduleItems.addAll([
        _buildScheduleItem(
          jamKe: '-',
          time: '07:00 - 07:30',
          subject: 'Dhuha & Tadarus',
          teacher: '-',
          kode: '-',
          room: 'Masjid',
          color: const Color(0xFF14B8A6),
          icon: Icons.mosque_rounded,
        ),
        _buildScheduleItem(
          jamKe: '-',
          time: '07:30 - 08:00',
          subject: 'Pembinaan Walas',
          teacher: 'Wali Kelas',
          kode: '-',
          room: 'Ruang Kelas',
          color: const Color(0xFF8B5CF6),
          icon: Icons.groups_rounded,
        ),
      ]);
    }

    scheduleItems.addAll([
      _buildScheduleItem(
        jamKe: '1',
        time: '08:00 - 08:40',
        subject: 'Matematika',
        teacher: 'Monica Irawati. R, S.Pd.',
        kode: '03',
        room: 'Ruang X RPL 1',
        color: const Color(0xFF2563EB),
        icon: Icons.calculate_rounded,
      ),
      _buildScheduleItem(
        jamKe: '2',
        time: '08:40 - 09:10',
        subject: 'Matematika',
        teacher: 'Monica Irawati. R, S.Pd.',
        kode: '03',
        room: 'Ruang X RPL 1',
        color: const Color(0xFF2563EB),
        icon: Icons.calculate_rounded,
      ),
      _buildScheduleItem(
        jamKe: '-',
        time: '09:10 - 09:40',
        subject: 'Istirahat',
        teacher: '-',
        kode: '-',
        room: 'Kantin',
        color: const Color(0xFFF59E0B),
        icon: Icons.fastfood_rounded,
      ),
      _buildScheduleItem(
        jamKe: '3',
        time: '09:40 - 10:10',
        subject: 'Bahasa Indonesia',
        teacher: 'Ine Yulianti, S.Pd.',
        kode: '02',
        room: 'Ruang X RPL 1',
        color: const Color(0xFF059669),
        icon: Icons.menu_book_rounded,
      ),
      _buildScheduleItem(
        jamKe: '4',
        time: '10:10 - 10:50',
        subject: 'Bahasa Indonesia',
        teacher: 'Ine Yulianti, S.Pd.',
        kode: '02',
        room: 'Ruang X RPL 1',
        color: const Color(0xFF059669),
        icon: Icons.menu_book_rounded,
      ),
      _buildScheduleItem(
        jamKe: '5',
        time: '10:50 - 11:30',
        subject: 'Pendidikan Agama Islam',
        teacher: 'Drs. H. Ahmad',
        kode: '05',
        room: 'Ruang X RPL 1',
        color: const Color(0xFF055D97),
        icon: Icons.mosque_rounded,
      ),
      _buildScheduleItem(
        jamKe: '-',
        time: '11:30 - 12:30',
        subject: 'Ishoma',
        teacher: '-',
        kode: '-',
        room: 'Masjid & Kantin',
        color: const Color(0xFFF59E0B),
        icon: Icons.fastfood_rounded,
      ),
      _buildScheduleItem(
        jamKe: '6',
        time: '12:30 - 13:10',
        subject: 'Pemrograman Web',
        teacher: 'Budi Santoso, M.Kom.',
        kode: '10',
        room: 'Lab Komputer 1',
        color: const Color(0xFF7C3AED),
        icon: Icons.computer_rounded,
      ),
      _buildScheduleItem(
        jamKe: '7',
        time: '13:10 - 13:50',
        subject: 'Pemrograman Web',
        teacher: 'Budi Santoso, M.Kom.',
        kode: '10',
        room: 'Lab Komputer 1',
        color: const Color(0xFF7C3AED),
        icon: Icons.computer_rounded,
      ),
      _buildScheduleItem(
        jamKe: '8',
        time: '13:50 - 14:30',
        subject: 'Bahasa Inggris',
        teacher: 'Siti Aminah, M.Pd.',
        kode: '08',
        room: 'Ruang X RPL 1',
        color: const Color(0xFFDC2626),
        icon: Icons.language_rounded,
      ),
      _buildScheduleItem(
        jamKe: '9',
        time: '14:30 - 15:10',
        subject: 'Basis Data',
        teacher: 'Rini Astuti, S.T.',
        kode: '12',
        room: 'Lab Komputer 2',
        color: const Color(0xFF0D9488),
        icon: Icons.storage_rounded,
      ),
      _buildScheduleItem(
        jamKe: '10',
        time: '15:10 - 15:50',
        subject: 'Basis Data',
        teacher: 'Rini Astuti, S.T.',
        kode: '12',
        room: 'Lab Komputer 2',
        color: const Color(0xFF0D9488),
        icon: Icons.storage_rounded,
      ),
    ]);

    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 100),
      children: scheduleItems,
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
