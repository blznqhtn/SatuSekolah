import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:aplikasi_mobile_siswa/features/auth/controllers/auth_controller.dart';
import 'package:aplikasi_mobile_siswa/shared/widgets/notification_bell.dart';

class PremiumHeader extends StatelessWidget {
  final String? title;
  final Widget child;
  final double expandedHeight;
  final Widget? action;

  const PremiumHeader({
    Key? key,
    this.title,
    required this.child,
    this.expandedHeight = 220,
    this.action,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const kPrimary = Color(0xFF055D97);

    return SliverAppBar(
      expandedHeight: expandedHeight,
      pinned: true,
      stretch: true,
      backgroundColor: kPrimary,
      elevation: 0,
      centerTitle: true,
      title: title != null ? Text(title!, style: GoogleFonts.nunito(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 18)) : null,
      actions: [
        action ?? const NotificationBell(badgeBorderColor: kPrimary),
      ],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [kPrimary, Color(0xFF023E6A)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Positioned(
                right: -30,
                top: -10,
                child: Icon(Icons.auto_awesome_rounded, size: 160, color: Colors.white.withOpacity(0.05)),
              ),
              SafeArea(
                child: child,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

