import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:aplikasi_mobile_siswa/features/auth/controllers/auth_controller.dart';
import 'package:aplikasi_mobile_siswa/features/dashboard/controllers/dashboard_controller.dart';
import 'package:aplikasi_mobile_siswa/features/dashboard/controllers/notification_controller.dart';
import 'package:aplikasi_mobile_siswa/features/evaluation/screens/evaluation_list_screen.dart';
import 'package:aplikasi_mobile_siswa/features/library/screens/library_screen.dart';
import 'package:aplikasi_mobile_siswa/features/violation/screens/violation_screen.dart';
import 'package:aplikasi_mobile_siswa/features/schedule/screens/schedule_screen.dart';
import 'package:aplikasi_mobile_siswa/features/report_card/screens/report_card_screen.dart';
import 'package:aplikasi_mobile_siswa/features/career/screens/career_screen.dart';
import 'package:aplikasi_mobile_siswa/features/dashboard/screens/notification_screen.dart';
import 'package:aplikasi_mobile_siswa/features/academic/screens/student_permit_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  DashboardController get _dashCtrl =>
      Get.isRegistered<DashboardController>()
          ? Get.find<DashboardController>()
          : Get.put(DashboardController());

  AuthController get _authCtrl =>
      Get.isRegistered<AuthController>()
          ? Get.find<AuthController>()
          : Get.put(AuthController());

  NotificationController get _notifCtrl =>
      Get.isRegistered<NotificationController>()
          ? Get.find<NotificationController>()
          : Get.put(NotificationController());

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour >= 4 && hour < 11) return 'Selamat Pagi,';
    if (hour >= 11 && hour < 15) return 'Selamat Siang,';
    if (hour >= 15 && hour < 18) return 'Selamat Sore,';
    return 'Selamat Malam,';
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
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'SatuSekolah',
          style: TextStyle(
            color: Color(0xFF0F172A),
            fontWeight: FontWeight.w800,
            fontSize: 24,
            letterSpacing: -0.5,
          ),
        ),
        actions: [
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined, color: Color(0xFF334155), size: 26),
                onPressed: () {
                  Get.to(() => const NotificationScreen());
                },
              ),
              Obx(() {
                final unread = _notifCtrl.unreadCount;
                if (unread == 0) return const SizedBox.shrink();
                return Positioned(
                  right: 12,
                  top: 12,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEF4444),
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFFF8FAFC), width: 1.5),
                    ),
                  ),
                );
              }),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        color: const Color(0xFF055D97),
        onRefresh: () async {
          await Future.wait([
            _dashCtrl.fetchAll(),
            _authCtrl.refreshProfile(),
            _notifCtrl.fetchNotifications(),
          ]);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
          padding: const EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. KARTU SAMBUTAN REAKTIF (Terhubung ke AuthController & DashboardController)
              Obx(() {
                final user = _authCtrl.currentUser.value;
                final summary = _dashCtrl.summary.value;

                final userName = (user?.name != null && user!.name.isNotEmpty)
                    ? user.name
                    : (summary?.userName ?? 'Siswa');

                final userAvatar = (user?.photoUrl != null && user!.photoUrl!.isNotEmpty)
                    ? user.photoUrl!
                    : (summary?.userPhotoUrl ??
                        'https://ui-avatars.com/api/?name=${Uri.encodeComponent(userName)}&background=055D97&color=fff&bold=true');

                final attendanceText = summary != null
                    ? 'Kehadiran: ${summary.attendanceRate.toStringAsFixed(0)}%'
                    : 'Kehadiran: 100%';

                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
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
                      // Foto Profil
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0xFFF1F5F9), width: 2),
                          image: DecorationImage(
                            image: NetworkImage(userAvatar),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Teks Sambutan
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _getGreeting(),
                              style: const TextStyle(
                                color: Color(0xFF64748B),
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              userName,
                              style: const TextStyle(
                                color: Color(0xFF0F172A),
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                letterSpacing: -0.5,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 10),
                            // Badge Status Minimalis
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.check_circle, color: Color(0xFF10B981), size: 12),
                                  const SizedBox(width: 4),
                                  Text(
                                    attendanceText,
                                    style: const TextStyle(
                                      color: Color(0xFF334155),
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 24),

              // Carousel Banner (Dynamic from Backend Announcements)
              Obx(() => AnnouncementBannerCarousel(
                announcements: _dashCtrl.announcements.toList(),
              )),

              const SizedBox(height: 32),

              const Text(
                'Akses Cepat',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 16),

              // 2. GRID MENU MINIMALIS
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 3,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 0.85,
                children: [
                  _buildMinimalMenuCard(Icons.menu_book_rounded, 'LMS\n& Tugas', const Color(0xFF2563EB), const Color(0xFFEFF6FF)),
                  _buildMinimalMenuCard(Icons.monitor_heart_rounded, 'Kesehatan', const Color(0xFFDC2626), const Color(0xFFFEF2F2)),
                  _buildMinimalMenuCard(Icons.fact_check_rounded, 'Presensi &\nIzin', const Color(0xFF059669), const Color(0xFFECFDF5)),
                  _buildMinimalMenuCard(Icons.local_library_rounded, 'E-Perpus', const Color(0xFFD97706), const Color(0xFFFFFBEB)),
                  _buildMinimalMenuCard(Icons.warning_rounded, 'Poin\nPelanggaran', const Color(0xFFE11D48), const Color(0xFFFFF1F2)),
                  _buildMinimalMenuCard(Icons.calendar_month_rounded, 'Jadwal\nPelajaran', const Color(0xFF7C3AED), const Color(0xFFF5F3FF)),
                  _buildMinimalMenuCard(Icons.assignment_ind_rounded, 'Rapor\nDigital', const Color(0xFF0D9488), const Color(0xFFF0FDFA)),
                  _buildMinimalMenuCard(Icons.work_rounded, 'Karir\n& PKL', const Color(0xFFB45309), const Color(0xFFFEF3C7)),
                  _buildMinimalMenuCard(Icons.rate_review_rounded, 'Kinerja\nGuru', const Color(0xFF4F46E5), const Color(0xFFEEF2FF)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMinimalMenuCard(IconData icon, String label, Color primaryColor, Color lightBackgroundColor) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          splashColor: primaryColor.withOpacity(0.1),
          highlightColor: primaryColor.withOpacity(0.05),
          onTap: () {
            if (label.contains('Kinerja')) {
              Get.to(() => const EvaluationListScreen());
            } else if (label.contains('E-Perpus')) {
              Get.to(() => const LibraryScreen());
            } else if (label.contains('Poin')) {
              Get.to(() => const ViolationScreen());
            } else if (label.contains('Jadwal')) {
              Get.to(() => const ScheduleScreen());
            } else if (label.contains('Rapor')) {
              Get.to(() => const ReportCardScreen());
            } else if (label.contains('Karir')) {
              Get.to(() => const CareerScreen());
            } else if (label.contains('Presensi') || label.contains('Izin')) {
              Get.to(() => const StudentPermitScreen());
            }
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: lightBackgroundColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: primaryColor, size: 28),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF475569),
                    height: 1.2,
                    letterSpacing: -0.2,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AnnouncementBannerCarousel extends StatefulWidget {
  final List<AnnouncementItem> announcements;

  const AnnouncementBannerCarousel({
    Key? key,
    required this.announcements,
  }) : super(key: key);

  @override
  State<AnnouncementBannerCarousel> createState() => _AnnouncementBannerCarouselState();
}

class _AnnouncementBannerCarouselState extends State<AnnouncementBannerCarousel> {
  late final PageController _pageController;
  Timer? _timer;
  int _currentPage = 0;

  static const List<String> _bannerImages = [
    'https://images.unsplash.com/photo-1523050854058-8df90110c9f1?q=80&w=600&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1509062522246-3755977927d7?q=80&w=600&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1427504494785-3a9ca7044f45?q=80&w=600&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1516321318423-f06f85e504b3?q=80&w=600&auto=format&fit=crop',
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    final count = widget.announcements.isNotEmpty ? widget.announcements.length : 1;
    if (count > 1) {
      _timer = Timer.periodic(const Duration(seconds: 4), (timer) {
        if (!mounted || !_pageController.hasClients) return;
        final next = (_currentPage + 1) % count;
        _pageController.animateToPage(
          next,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOutCubic,
        );
      });
    }
  }

  @override
  void didUpdateWidget(AnnouncementBannerCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.announcements.length != widget.announcements.length) {
      _startTimer();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final list = widget.announcements;
    final count = list.isNotEmpty ? list.length : 1;

    return Column(
      children: [
        SizedBox(
          height: 140,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (idx) {
              if (mounted) setState(() => _currentPage = idx);
            },
            itemCount: count,
            itemBuilder: (context, index) {
              final img = _bannerImages[index % _bannerImages.length];
              final title = list.isNotEmpty ? list[index].title : 'Selamat Datang di SatuSekolah';
              final desc = list.isNotEmpty ? list[index].content : 'Portal akademik terpadu siswa dan orang tua.';

              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 2),
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  image: DecorationImage(
                    image: NetworkImage(img),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: LinearGradient(
                      colors: [Colors.black.withOpacity(0.7), Colors.transparent],
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                    ),
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        desc,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        if (count > 1) ...[
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(count, (idx) {
              final isActive = idx == _currentPage;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: isActive ? 16 : 6,
                height: 6,
                decoration: BoxDecoration(
                  color: isActive ? const Color(0xFF055D97) : const Color(0xFFCBD5E1),
                  borderRadius: BorderRadius.circular(3),
                ),
              );
            }),
          ),
        ],
      ],
    );
  }
}
