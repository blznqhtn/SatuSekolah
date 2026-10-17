import 'package:flutter/material.dart';
import 'rapor_screen.dart';
import 'penilaian_screen.dart';
import 'jadwal_screen.dart';
import 'kesehatan_screen.dart';
import 'mading_screen.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import 'package:get_storage/get_storage.dart';
import 'cari_sekolah_screen.dart';
import '../models/child_model.dart';
import '../models/activity_model.dart';
import '../widgets/app_badge.dart';
import '../widgets/child_avatar.dart';
import '../widgets/section_header.dart';
import '../services/api_client.dart';

class BerandaScreen extends StatefulWidget {
  final Function(int) onNavigate;

  const BerandaScreen({super.key, required this.onNavigate});

  @override
  State<BerandaScreen> createState() => _BerandaScreenState();
}

class _BerandaScreenState extends State<BerandaScreen> {
  int _selectedChildIndex = 0;
  bool _isLoading = true;
  String? _error;

  List<ChildModel> _children = [];
  List<ActivityModel> _activities = [];
  
  ChildModel? get _child => _children.isNotEmpty && _selectedChildIndex < _children.length ? _children[_selectedChildIndex] : null;

  int _unreadNotifications = 0;

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  Future<void> _loadAllData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final childrenRes = await ApiClient().dio.get('/users/children');
      if (childrenRes.data['data'] != null) {
        final List childrenList = childrenRes.data['data'];
        _children = childrenList.map<ChildModel>((e) {
          final String nama = e['name'] ?? 'Anak';
          return ChildModel(
            id: e['id'] ?? '',
            namaLengkap: nama,
            inisial: nama.isNotEmpty ? nama[0].toUpperCase() : 'A',
            nisn: e['nisn'] ?? '12345',
            kelas: '-', // Fallback, will be replaced by summary API
            sekolah: '-',
            jurusan: '',
            fotoUrl: e['avatar_url'] ?? '',
            avatarColorStart: AppColors.accent,
            avatarColorEnd: const Color(0xFFF5A073),
          );
        }).toList();
      }

      final notifRes = await ApiClient().dio.get('/notifications');
      if (notifRes.data['unread_count'] != null) {
        _unreadNotifications = notifRes.data['unread_count'];
      }

      if (_children.isNotEmpty) {
        GetStorage().write('hasChild', true);
        await _fetchDashboardForChild(_children[_selectedChildIndex].id);
      } else {
        GetStorage().write('hasChild', false);
      }
    } catch (e) {
      _error = "Gagal memuat data: $e";
      print(_error);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _fetchDashboardForChild(String childId) async {
    try {
      final summaryRes = await ApiClient().dio.get('/dashboard/summary', queryParameters: {'child_id': childId});
      final data = summaryRes.data['data'];
      if (data != null && data['student'] != null) {
        final student = data['student'];
        // Update current child details
        setState(() {
          _children[_selectedChildIndex] = _children[_selectedChildIndex].copyWith(
            kelas: student['class_name']?.split(' ')[0] ?? '-',
            sekolah: student['school'] ?? 'Satu Sekolah',
            jurusan: student['major'] ?? '',
            persentaseKehadiran: (data['attendance_percentage'] ?? 0).toDouble(),
            rataRataNilai: (data['average_score'] ?? 0).toDouble(),
            poinPelanggaran: data['total_violation_points'] ?? 0,
          );
        });
      }

      final actRes = await ApiClient().dio.get('/dashboard/activities', queryParameters: {'child_id': childId});
      if (actRes.data['data'] != null) {
        final List actList = actRes.data['data'];
        setState(() {
          _activities = actList.map((e) {
            BadgeVariant variant = BadgeVariant.blue;
            if (e['badge_color'] == '#FEE2E2') variant = BadgeVariant.red;
            if (e['badge_color'] == '#FEF3C7') variant = BadgeVariant.yellow;
            if (e['badge_color'] == '#D1FAE5') variant = BadgeVariant.green;

            Color iconBg = AppColors.blueBg;
            if (e['badge_color'] == '#FEE2E2') iconBg = AppColors.redBg;
            if (e['badge_color'] == '#FEF3C7') iconBg = AppColors.accentBg;
            if (e['badge_color'] == '#D1FAE5') iconBg = AppColors.tealBg;

            return ActivityModel(
              judul: e['title'] ?? '',
              sub: e['subtitle'] ?? '',
              waktu: e['time_label'] ?? '',
              emoji: e['emoji'] ?? '📝',
              iconBg: iconBg,
              badge: variant,
              badgeLabel: e['badge_label'] ?? '',
              tipe: ActivityType.presensi, // Default placeholder
            );
          }).toList();
        });
      }
    } catch (e) {
      print("Error fetching child dashboard: $e");
    }
  }

  void _onChildSelected(int index) async {
    if (index == _selectedChildIndex) return;
    setState(() {
      _selectedChildIndex = index;
      _isLoading = true;
    });
    await _fetchDashboardForChild(_children[index].id);
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading && _children.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    final box = GetStorage();
    final bool hasChild = box.read('hasChild') ?? false;

    if (!hasChild || _children.isEmpty) {
      return _buildEmptyState(context);
    }

    return Column(
      children: [
        _buildTopSection(),
        Expanded(
          child: _isLoading 
            ? const Center(child: CircularProgressIndicator()) 
            : SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeroCard(),
                _buildQuickMenu(),
                SectionHeader(
                  title: 'Aktivitas Terbaru',
                  actionLabel: 'Lihat semua',
                  onAction: () {},
                ),
                const SizedBox(height: 10),
                _buildActivityList(),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Column(
      children: [
        _buildTopSection(hasChild: false),
        Expanded(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: const BoxDecoration(
                      color: AppColors.accentBg,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: const Text('🏫', style: TextStyle(fontSize: 48)),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Belum Ada Data Siswa',
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: AppColors.text,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (_error != null)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.redBg,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _error!,
                        style: const TextStyle(color: AppColors.red, fontSize: 12),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  const Text(
                    'Silakan daftar SPMB terlebih dahulu untuk menghubungkan akun anak ke akun Anda.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 14,
                      color: AppColors.text2,
                    ),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const CariSekolahScreen()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.teal,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 4,
                        shadowColor: AppColors.teal.withOpacity(0.4),
                      ),
                      child: const Text(
                        'Daftar SPMB',
                        style: TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTopSection({bool hasChild = true}) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeaderContent(),
          if (hasChild) _buildChildSelectorContent(),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildHeaderContent() {
    final namaOrtu = GetStorage().read('namaOrtu') ?? 'Ibu Kartini';
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Selamat pagi, 👋',
                  style: AppTextStyles.bodySmall.copyWith(color: AppColors.text3)),
              Text(namaOrtu, style: AppTextStyles.h1),
            ],
          ),
          _buildNotifButton(),
        ],
      ),
    );
  }

  Widget _buildNotifButton() {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MadingScreen())),
      child: Stack(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: const BoxDecoration(
              color: AppColors.accentBg,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: const Text('🔔', style: TextStyle(fontSize: 18)),
          ),
          if (_unreadNotifications > 0)
            Positioned(
              top: 2,
              right: 2,
              child: Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: AppColors.red,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.white, width: 1.5),
                ),
                alignment: Alignment.center,
                child: Text(
                  '$_unreadNotifications',
                  style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildChildSelectorContent() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
          children: List.generate(_children.length, (i) {
            final child = _children[i];
            final isActive = i == _selectedChildIndex;
            return GestureDetector(
              onTap: () => _onChildSelected(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: EdgeInsets.only(right: i < _children.length - 1 ? 10 : 0),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: isActive ? AppColors.accentBg : AppColors.bg2,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: isActive ? AppColors.accent : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: Row(
                  children: [
                    ChildAvatar(child: child, size: 28, fontSize: 10),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(child.namaDepan,
                            style: const TextStyle(
                              fontFamily: 'Nunito',
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppColors.text,
                            )),
                        Text(child.kelas,
                            style: const TextStyle(
                              fontFamily: 'Nunito',
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              color: AppColors.text3,
                            )),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
    );
  }

  Widget _buildHeroCard() {
    if (_child == null) return const SizedBox();
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.accent, Color(0xFFF5A073)],
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppColors.accent.withOpacity(0.35),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Pantau Anak',
            style: TextStyle(fontSize: 11, color: Colors.white70, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text(
            _child!.namaLengkap,
            style: const TextStyle(
              fontFamily: 'Nunito',
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: -0.5,
            ),
          ),
          Text(
            _child!.kelasLengkap,
            style: const TextStyle(fontSize: 12, color: Colors.white70, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildHeroStat('${_child!.persentaseKehadiran.toInt()}%', 'Kehadiran'),
              Container(width: 1, height: 36, color: Colors.white30, margin: const EdgeInsets.symmetric(horizontal: 8)),
              _buildHeroStat(_child!.rataRataNilai.toStringAsFixed(1), 'Rata Nilai'),
              Container(width: 1, height: 36, color: Colors.white30, margin: const EdgeInsets.symmetric(horizontal: 8)),
              _buildHeroStat('${_child!.poinPelanggaran}', 'Poin Langgar'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeroStat(String value, String label) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontFamily: 'Nunito',
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: -0.5,
            ),
          ),
          Text(
            label,
            style: const TextStyle(fontSize: 10, color: Colors.white70, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickMenu() {
    final items = [
      _QuickMenuItem('📋', 'Presensi', AppColors.tealBg, 1),
      _QuickMenuItem('📊', 'Rapor', AppColors.blueBg, 5),
      _QuickMenuItem('💳', 'Bayar SPP', AppColors.accentBg, 2, hasBadge: true),
      _QuickMenuItem('🩺', 'Kesehatan', AppColors.redBg, 8),
      _QuickMenuItem('📅', 'Jadwal', AppColors.purpleBg, 7),
      _QuickMenuItem('⭐', 'Nilai Guru', AppColors.yellowBg, 6),
      _QuickMenuItem('🗓️', 'Kalender', AppColors.tealBg, 3),
      _QuickMenuItem('💬', 'Pesan', AppColors.bg2, 9),
    ];

    return GridView.count(
      crossAxisCount: 4,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 0.9,
      children: items.map((item) => _buildQuickItem(item)).toList(),
    );
  }

  Widget _buildQuickItem(_QuickMenuItem item) {
    return GestureDetector(
      onTap: () {
        if (item.navIndex >= 0) {
          widget.onNavigate(item.navIndex);
        } else if (item.targetScreen != null) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => item.targetScreen!),
          );
        } else if (item.onTap != null) {
          item.onTap!();
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: item.bgColor,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    alignment: Alignment.center,
                    child: Text(item.emoji, style: const TextStyle(fontSize: 20)),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item.label,
                    style: const TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: AppColors.text,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                  ),
                ],
              ),
            ),
            if (item.hasBadge)
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: AppColors.red,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.white, width: 1.5),
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    '!',
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityList() {
    if (_activities.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Center(
          child: Text('Belum ada aktivitas terbaru', style: TextStyle(color: AppColors.text3)),
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: _activities.map((a) => _buildActivityCard(a)).toList(),
      ),
    );
  }

  Widget _buildActivityCard(ActivityModel a) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: a.iconBg,
                borderRadius: BorderRadius.circular(13),
              ),
              alignment: Alignment.center,
              child: Text(a.emoji, style: const TextStyle(fontSize: 20)),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(a.judul, style: AppTextStyles.bodyBold),
                  const SizedBox(height: 2),
                  Text(a.sub,
                      style: AppTextStyles.bodySmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(a.waktu, style: AppTextStyles.caption),
                const SizedBox(height: 4),
                AppBadge(label: a.badgeLabel, variant: a.badge),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickMenuItem {
  final String emoji;
  final String label;
  final Color bgColor;
  final int navIndex;
  final bool hasBadge;
  final Widget? targetScreen;
  final VoidCallback? onTap;

  const _QuickMenuItem(this.emoji, this.label, this.bgColor, this.navIndex,
      {this.hasBadge = false, this.targetScreen, this.onTap});
}