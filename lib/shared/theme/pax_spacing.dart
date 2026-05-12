import 'package:flutter/material.dart';

/// 4-point spatial grid for new UI components.
abstract final class PaxSpacing {
  static const double xxs = 2;
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;
  static const double xxxl = 64;

  static const double screenH = md;
  static const double screenV = lg;
  static const double section = xl;
  static const double cardGap = sm + xs;
  static const double cardPad = md;
  static const double labelGap = xs;
  static const double iconGap = sm;
  static const double fieldGap = md;

  static const double radiusXs = 4;
  static const double radiusSm = 8;
  static const double radiusMd = 12;
  static const double radiusLg = 16;
  static const double radiusXl = 20;
  static const double radiusXxl = 24;
  static const double radiusPill = 999;

  static BorderRadius get brXs => BorderRadius.circular(radiusXs);
  static BorderRadius get brSm => BorderRadius.circular(radiusSm);
  static BorderRadius get brMd => BorderRadius.circular(radiusMd);
  static BorderRadius get brLg => BorderRadius.circular(radiusLg);
  static BorderRadius get brXl => BorderRadius.circular(radiusXl);
  static BorderRadius get brXxl => BorderRadius.circular(radiusXxl);
  static BorderRadius get brPill => BorderRadius.circular(radiusPill);

  static EdgeInsets get screenPadding =>
      const EdgeInsets.symmetric(horizontal: screenH, vertical: screenV);

  static EdgeInsets get cardPadding => const EdgeInsets.all(cardPad);

  static EdgeInsets get listItemPadding =>
      const EdgeInsets.symmetric(horizontal: screenH, vertical: md);

  static List<BoxShadow> get shadowSm => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.06),
          blurRadius: 6,
          offset: const Offset(0, 2),
        ),
      ];

  static List<BoxShadow> get shadowMd => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.08),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.04),
          blurRadius: 4,
          offset: const Offset(0, 1),
        ),
      ];

  static List<BoxShadow> get shadowLg => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.12),
          blurRadius: 24,
          offset: const Offset(0, 8),
        ),
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.06),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ];

  static List<BoxShadow> get shadowXl => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.18),
          blurRadius: 40,
          offset: const Offset(0, 16),
        ),
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.08),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ];

  static List<BoxShadow> shadowDark(Color accentColor) => [
        BoxShadow(
          color: accentColor.withValues(alpha: 0.15),
          blurRadius: 16,
          offset: const Offset(0, 4),
        ),
      ];

  static const Duration durationFast = Duration(milliseconds: 150);
  static const Duration durationNormal = Duration(milliseconds: 250);
  static const Duration durationSlow = Duration(milliseconds: 400);

  static const Curve curveDefault = Curves.easeOutCubic;
  static const Curve curveSpring = Curves.elasticOut;
  static const Curve curveSharp = Curves.easeInOutCubic;
}
