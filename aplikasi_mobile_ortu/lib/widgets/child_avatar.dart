import 'package:flutter/material.dart';
import '../models/child_model.dart';

class ChildAvatar extends StatelessWidget {
  final ChildModel child;
  final double size;
  final double fontSize;

  const ChildAvatar({
    super.key,
    required this.child,
    this.size = 34,
    this.fontSize = 12,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [child.avatarColorStart, child.avatarColorEnd],
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        child.inisial,
        style: TextStyle(
          fontFamily: 'Nunito',
          fontSize: fontSize,
          fontWeight: FontWeight.w800,
          color: Colors.white,
        ),
      ),
    );
  }
}

/// Avatar generik dengan warna gradient bebas
class GradientAvatar extends StatelessWidget {
  final String inisial;
  final Color colorStart;
  final Color colorEnd;
  final double size;
  final double fontSize;

  const GradientAvatar({
    super.key,
    required this.inisial,
    required this.colorStart,
    required this.colorEnd,
    this.size = 34,
    this.fontSize = 12,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [colorStart, colorEnd],
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        inisial,
        style: TextStyle(
          fontFamily: 'Nunito',
          fontSize: fontSize,
          fontWeight: FontWeight.w800,
          color: Colors.white,
        ),
      ),
    );
  }
}