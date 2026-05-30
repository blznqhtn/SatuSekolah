import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:aplikasi_mobile_siswa/features/dashboard/screens/notification_screen.dart';

class NotificationBell extends StatelessWidget {
  final Color iconColor;
  final Color badgeColor;
  final Color badgeBorderColor;

  const NotificationBell({
    Key? key,
    this.iconColor = Colors.white,
    this.badgeColor = const Color(0xFFEF4444),
    this.badgeBorderColor = const Color(0xFF055D97),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => Get.to(() => const NotificationScreen()),
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Icon(Icons.notifications_rounded, color: iconColor, size: 24),
              ),
            ),
          ),
          Positioned(
            right: 8,
            top: 8,
            child: Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: badgeColor,
                shape: BoxShape.circle,
                border: Border.all(color: badgeBorderColor, width: 2),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
