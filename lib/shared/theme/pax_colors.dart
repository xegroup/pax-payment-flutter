import 'package:flutter/material.dart';

/// Single source of truth for brand + semantic colors (Obsidian POS palette).
abstract final class PaxColors {
  static const blueDark = Color(0xFF000846);
  static const blueLight = Color(0xFF0140be);
  static const teal600 = Color(0xFF0F175E);
  static const teal100 = Color(0xFFCCF5EE);
  static const teal50 = Color(0xFFE6FAF6);
  static const grey50 = Color(0xFFF8F9FA);
  static const grey100 = Color(0xFFF1F3F5);
  static const grey150 = Color(0xFFE9ECEF);
  static const grey200 = Color(0xFFDEE2E6);
  static const grey300 = Color(0xFFCED4DA);
  static const grey400 = Color(0xFFADB5BD);
  static const grey500 = Color(0xFF868E96);
  static const grey600 = Color(0xFF495057);
  static const grey700 = Color(0xFF343A40);
  static const grey800 = Color(0xFF212529);
  static const grey850 = Color(0xFF1A1D23);
  static const grey900 = Color(0xFF0F1117);
  static const grey950 = Color(0xFF0A0C10);

  static const success = Color(0xFF000846);
  static const successLight = Color(0xFFE6F9F3);
  static const successDark = Color(0xFF071380);

  static const warning = Color(0xFFFFA940);
  static const warningLight = Color(0xFFFFF3E0);
  static const warningDark = Color(0xFFE8922A);

  static const error = Color(0xFFFF4D4F);
  static const errorLight = Color(0xFFFFECEC);
  static const errorDark = Color(0xFFD9363E);

  static const info = Color(0xFF4096FF);
  static const infoLight = Color(0xFFEAF1FF);
  static const infoDark = Color(0xFF2F7AE0);

  static const visa = Color(0xFF1A1F71);
  static const mastercard = Color(0xFFEB001B);
  static const amex = Color(0xFF2E77BC);
  static const cash = Color(0xFF00159C);

  static const chart1 = Color(0xB07684E1);
  static const chart2 = Color(0xFF4096FF);
  static const chart3 = Color(0xFFFFA940);
  static const chart4 = Color(0xFFFF4D4F);
  static const chart5 = Color(0xFFA855F7);
  static const chart6 = Color(0xFFEC4899);

  static const List<Color> chartPalette = [
    chart1,
    chart2,
    chart3,
    chart4,
    chart5,
    chart6,
  ];

  static const white = Colors.white;
  static const black = Colors.black;
  static const transparent = Colors.transparent;

  static Color darkElevation(int level) {
    final overlayOpacity = switch (level) {
      1 => 0.05,
      2 => 0.08,
      3 => 0.11,
      4 => 0.12,
      _ => 0.14,
    };
    return Colors.white.withValues(alpha: overlayOpacity);
  }
}
