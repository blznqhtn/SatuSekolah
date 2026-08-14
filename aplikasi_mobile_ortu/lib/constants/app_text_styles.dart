import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  // Headings
  static const TextStyle h1 = TextStyle(
    fontFamily: 'Nunito',
    fontSize: 22,
    fontWeight: FontWeight.w900,
    color: AppColors.text,
    letterSpacing: -0.5,
  );

  static const TextStyle h2 = TextStyle(
    fontFamily: 'Nunito',
    fontSize: 18,
    fontWeight: FontWeight.w800,
    color: AppColors.text,
    letterSpacing: -0.3,
  );

  static const TextStyle h3 = TextStyle(
    fontFamily: 'Nunito',
    fontSize: 15,
    fontWeight: FontWeight.w800,
    color: AppColors.text,
  );

  // Body
  static const TextStyle body = TextStyle(
    fontFamily: 'Nunito',
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: AppColors.text,
  );

  static const TextStyle bodyBold = TextStyle(
    fontFamily: 'Nunito',
    fontSize: 13,
    fontWeight: FontWeight.w700,
    color: AppColors.text,
  );

  static const TextStyle bodySmall = TextStyle(
    fontFamily: 'Nunito',
    fontSize: 11,
    fontWeight: FontWeight.w500,
    color: AppColors.text2,
  );

  // Caption
  static const TextStyle caption = TextStyle(
    fontFamily: 'Nunito',
    fontSize: 10,
    fontWeight: FontWeight.w700,
    color: AppColors.text3,
    letterSpacing: 0.3,
  );

  // Mono (for dates, times, codes)
  static const TextStyle mono = TextStyle(
    fontFamily: 'monospace',
    fontSize: 11,
    fontWeight: FontWeight.w400,
    color: AppColors.text3,
  );

  // Nav label
  static const TextStyle navLabel = TextStyle(
    fontFamily: 'Nunito',
    fontSize: 10,
    fontWeight: FontWeight.w600,
    color: AppColors.text3,
    letterSpacing: 0.2,
  );
}