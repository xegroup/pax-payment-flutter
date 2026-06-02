import 'package:flutter/material.dart';

import 'pax_colors.dart';
import 'pax_font_sizes.dart';
import 'pax_text_styles.dart';

TextTheme buildPaxColoredTextTheme({required bool isLight}) {
  final base = isLight ? PaxColors.grey900 : PaxColors.grey50;
  final muted = isLight ? PaxColors.grey500 : PaxColors.grey400;

  return TextTheme(
    displayLarge: PaxTextStyles.hero.copyWith(color: base),
    displayMedium: PaxTextStyles.display.copyWith(color: base),
    displaySmall: PaxTextStyles.h1.copyWith(color: base),
    headlineLarge: PaxTextStyles.h2.copyWith(color: base),
    headlineMedium: PaxTextStyles.h3.copyWith(color: base),
    headlineSmall: PaxTextStyles.h4.copyWith(color: base),
    titleLarge: PaxTextStyles.h4.copyWith(color: base),
    titleMedium: PaxTextStyles.bodyMedium.copyWith(color: base),
    titleSmall: PaxTextStyles.bodyMedium.copyWith(
      color: base,
      fontSize: PaxFontSizes.sm,
    ),
    bodyLarge: PaxTextStyles.bodyLarge.copyWith(color: base),
    bodyMedium: PaxTextStyles.body.copyWith(color: base),
    bodySmall: PaxTextStyles.body.copyWith(
      color: muted,
      fontSize: PaxFontSizes.sm,
    ),
    labelLarge: PaxTextStyles.buttonMd.copyWith(color: base),
    labelMedium: PaxTextStyles.label.copyWith(color: muted),
    labelSmall: PaxTextStyles.caption.copyWith(color: muted),
  );
}

TextTheme buildPaxTextTheme({required bool isLight}) {
  return buildPaxColoredTextTheme(isLight: isLight);
}
