import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'screens/page_beranda.dart';
import 'screens/page_presensi.dart';
import 'screens/page_bayar.dart';
import 'screens/page_kalender.dart';
import 'screens/page_profil.dart';
import 'screens/page_rapor.dart';
import 'screens/page_kesehatan.dart';
import 'screens/page_jadwal.dart';
import 'screens/page_penilaian.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  
  // This helps to navigate to subpages that aren't on the bottom nav
  Widget? _subPage;

  final List<Widget> _mainPages = [
    const PageBeranda(),
    const PagePresensi(),
    const PageBayar(),
    const PageKalender(),
    const PageProfil(),
  ];

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
      _subPage = null; // Clear subpage when clicking main tab
    });
  }

  void navigateToSubPage(Widget page) {
    setState(() {
      _subPage = page;
    });
  }
  
  void goBack() {
    setState(() {
      _subPage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: SafeArea(
        child: _subPage ?? _mainPages[_currentIndex],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppTheme.white,
          border: const Border(top: BorderSide(color: AppTheme.border)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              offset: const Offset(0, -4),
              blurRadius: 20,
            )
          ]
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: _onTabTapped,
          type: BottomNavigationBarType.fixed,
          backgroundColor: AppTheme.white,
          selectedItemColor: AppTheme.accent,
          unselectedItemColor: AppTheme.text3,
          selectedFontSize: 10,
          unselectedFontSize: 10,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w700, fontFamily: 'Nunito'),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontFamily: 'Nunito'),
          elevation: 0,
          items: [
            const BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Beranda',
            ),
            BottomNavigationBarItem(
              icon: _buildIconWithDot(Icons.assignment_outlined),
              activeIcon: _buildIconWithDot(Icons.assignment),
              label: 'Presensi',
            ),
            BottomNavigationBarItem(
              icon: _buildIconWithDot(Icons.payment_outlined),
              activeIcon: _buildIconWithDot(Icons.payment),
              label: 'Bayar SPP',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today_outlined),
              activeIcon: Icon(Icons.calendar_today),
              label: 'Kalender',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Profil',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIconWithDot(IconData iconData) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Icon(iconData),
        Positioned(
          top: -2,
          right: -4,
          child: Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              color: AppTheme.red,
              shape: BoxShape.circle,
              border: Border.all(color: AppTheme.white, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}
