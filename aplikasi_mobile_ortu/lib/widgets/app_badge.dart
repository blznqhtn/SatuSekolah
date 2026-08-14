import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../models/activity_model.dart';

class AppBadge extends StatelessWidget {
  final String label;
  final BadgeVariant variant;

  const AppBadge({super.key, required this.label, required this.variant});

  Color get _bg => switch (variant) {
    BadgeVariant.green  => AppColors.tealBg,
    BadgeVariant.red    => AppColors.redBg,
    BadgeVariant.yellow => AppColors.yellowBg,
    BadgeVariant.blue   => AppColors.blueBg,
    BadgeVariant.orange => AppColors.accentBg,
    BadgeVariant.purple => AppColors.purpleBg,
    BadgeVariant.gray   => AppColors.bg2,
  };

  Color get _fg => switch (variant) {
    BadgeVariant.green  => AppColors.teal,
    BadgeVariant.red    => AppColors.red,
    BadgeVariant.yellow => AppColors.yellow,
    BadgeVariant.blue   => AppColors.blue,
    BadgeVariant.orange => AppColors.accent,
    BadgeVariant.purple => AppColors.purple,
    BadgeVariant.gray   => AppColors.text3,
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: _bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 5,
            height: 5,
            margin: const EdgeInsets.only(right: 4),
            decoration: BoxDecoration(color: _fg, shape: BoxShape.circle),
          ),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Nunito',
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: _fg,
            ),
          ),
        ],
      ),
    );
  }
}

/// Badge untuk status presensi
class PresensiStatusBadge extends StatelessWidget {
  final PresensiStatus status;

  const PresensiStatusBadge({super.key, required this.status});

  BadgeVariant get _variant => switch (status) {
    PresensiStatus.hadir  => BadgeVariant.green,
    PresensiStatus.sakit  => BadgeVariant.yellow,
    PresensiStatus.izin   => BadgeVariant.blue,
    PresensiStatus.alpha  => BadgeVariant.red,
    PresensiStatus.libur  => BadgeVariant.gray,
  };

  String get _label => switch (status) {
    PresensiStatus.hadir  => 'Hadir',
    PresensiStatus.sakit  => 'Sakit',
    PresensiStatus.izin   => 'Izin',
    PresensiStatus.alpha  => 'Alpha',
    PresensiStatus.libur  => 'Libur',
  };

  @override
  Widget build(BuildContext context) =>
      AppBadge(label: _label, variant: _variant);
}