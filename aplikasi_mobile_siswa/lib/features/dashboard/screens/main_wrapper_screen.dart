import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:aplikasi_mobile_siswa/features/dashboard/controllers/main_wrapper_controller.dart';
import 'package:aplikasi_mobile_siswa/features/dashboard/screens/home_screen.dart';
import 'package:aplikasi_mobile_siswa/features/profile/screens/profile_screen.dart';
import 'package:aplikasi_mobile_siswa/features/dashboard/screens/akademik_screen.dart';

class MainWrapperScreen extends StatelessWidget {
  MainWrapperScreen({Key? key}) : super(key: key);

  final MainWrapperController controller = Get.put(MainWrapperController());

  // Layar Dummy untuk Akademik
  final List<Widget> _pages = [
    const HomeScreen(),
    const AkademikScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true, 
      body: Obx(() {
        // Mencegah error jika index controller tertinggal di angka 3 atau 4 saat hot reload
        int safeIndex = controller.currentIndex.value;
        if (safeIndex >= _pages.length) {
          safeIndex = 0;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            controller.currentIndex.value = 0;
          });
        }
        return _pages[safeIndex];
      }),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(left: 40, right: 40, bottom: 20), // Padding ditarik sedikit lebih ke tengah karena cuma 3 menu
          child: ClipRRect(
            borderRadius: BorderRadius.circular(40), 
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12), 
              child: Container(
                height: 70, 
                padding: const EdgeInsets.symmetric(horizontal: 16), // Padding internal agar lebih imbang
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9), 
                  borderRadius: BorderRadius.circular(40),
                  border: Border.all(color: Colors.white.withOpacity(0.5), width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 20,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween, // Jarak antar 3 menu dibuat merata
                  children: [
                    _buildNavItem(Icons.space_dashboard_outlined, Icons.space_dashboard_rounded, 0, 'Beranda'),
                    _buildNavItem(Icons.school_outlined, Icons.school_rounded, 1, 'Akademik'),
                    _buildNavItem(Icons.person_outline_rounded, Icons.person_rounded, 2, 'Profil'),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, IconData activeIcon, int index, String label) {
    return Obx(() {
      // Sama seperti di atas, hindari error index out of bound saat hot reload
      int safeIndex = controller.currentIndex.value;
      if (safeIndex >= _pages.length) safeIndex = 0;
      
      final isSelected = safeIndex == index;
      return GestureDetector(
        onTap: () => controller.changePage(index),
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          padding: EdgeInsets.symmetric(
            horizontal: isSelected ? 20 : 16, 
            vertical: 12,
          ),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF055D97) : const Color(0xFFF1F5F9).withOpacity(0.6), 
            borderRadius: BorderRadius.circular(24),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (child, anim) => ScaleTransition(scale: anim, child: child),
                child: Icon(
                  isSelected ? activeIcon : icon,
                  key: ValueKey(isSelected),
                  color: isSelected ? Colors.white : const Color(0xFF475569), 
                  size: 26, 
                ),
              ),
              AnimatedSize(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutCubic,
                child: SizedBox(
                  width: isSelected ? null : 0,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Text(
                      label,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        letterSpacing: 0.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.clip,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
