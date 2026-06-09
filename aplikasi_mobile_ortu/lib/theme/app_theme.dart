import 'package:flutter/material.dart';

class AppTheme {
  // Colors
  static const Color bg = Color(0xFFF5F3EE);
  static const Color bg2 = Color(0xFFECEAE3);
  static const Color white = Color(0xFFFFFFFF);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surface2 = Color(0xFFF9F8F5);
  
  static const Color border = Color(0x14000000); // rgba(0, 0, 0, 0.08)
  static const Color border2 = Color(0x23000000); // rgba(0, 0, 0, 0.14)
  
  static const Color text = Color(0xFF1C1C1E);
  static const Color text2 = Color(0xFF6B6966);
  static const Color text3 = Color(0xFFA8A5A0);
  
  static const Color accent = Color(0xFFE8784A); // warm orange
  static const Color accent2 = Color(0xFFD4623A);
  static const Color accentBg = Color(0xFFFDF0EA);
  
  static const Color teal = Color(0xFF2BA38A);
  static const Color tealBg = Color(0xFFE8F5F2);
  
  static const Color blue = Color(0xFF3B82C4);
  static const Color blueBg = Color(0xFFEBF3FB);
  
  static const Color red = Color(0xFFE05252);
  static const Color redBg = Color(0xFFFDEAEA);
  
  static const Color yellow = Color(0xFFD4A017);
  static const Color yellowBg = Color(0xFFFDF5E0);
  
  static const Color purple = Color(0xFF7C5CBF);
  static const Color purpleBg = Color(0xFFF0EAFB);

  // Radii
  static const double radius = 18.0;
  static const double radiusSm = 12.0;
  static const double radiusXs = 8.0;

  // Text Styles
  static const TextStyle headerName = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w900,
    color: text,
    letterSpacing: -0.5,
    fontFamily: 'Nunito',
  );
  
  static const TextStyle headerGreeting = TextStyle(
    fontSize: 13,
    color: text3,
    fontWeight: FontWeight.w500,
    fontFamily: 'Nunito',
  );

  static const TextStyle headerTitle = TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w800,
    color: text,
    fontFamily: 'Nunito',
  );

  static const TextStyle sectionTitle = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w800,
    color: text,
    fontFamily: 'Nunito',
  );

  static const TextStyle sectionMore = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w700,
    color: accent,
    fontFamily: 'Nunito',
  );

  // Box Shadows
  static List<BoxShadow> shadow = [
    BoxShadow(
      color: Colors.black.withOpacity(0.08),
      blurRadius: 20,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> shadowSm = [
    BoxShadow(
      color: Colors.black.withOpacity(0.06),
      blurRadius: 10,
      offset: const Offset(0, 2),
    ),
  ];

  // Decorations
  static BoxDecoration cardDecoration = BoxDecoration(
    color: white,
    borderRadius: BorderRadius.circular(radius),
    boxShadow: shadowSm,
  );

  static BoxDecoration cardSmDecoration = BoxDecoration(
    color: white,
    borderRadius: BorderRadius.circular(radiusSm),
    boxShadow: shadowSm,
  );
}
