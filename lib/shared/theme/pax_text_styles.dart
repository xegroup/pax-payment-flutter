import 'package:flutter/material.dart';

import 'pax_font_sizes.dart';

/// Composable text styles using bundled DM Sans (see assets/fonts in pubspec).
abstract final class PaxTextStyles {
  static const _family = 'DMSans';
  static const _fallback = <String>['Roboto', 'sans-serif'];

  static TextStyle _sans({
    required double fontSize,
    FontWeight fontWeight = FontWeight.w400,
    double? letterSpacing,
    double? height,
  }) =>
      TextStyle(
        fontFamily: _family,
        fontFamilyFallback: _fallback,
        fontSize: fontSize,
        fontWeight: fontWeight,
        letterSpacing: letterSpacing,
        height: height,
      );

  static TextStyle get hero => _sans(
        fontSize: PaxFontSizes.hero,
        fontWeight: FontWeight.w700,
        letterSpacing: PaxFontSizes.trackingTight,
        height: PaxFontSizes.lineHeightTight,
      );

  static TextStyle get display => _sans(
        fontSize: PaxFontSizes.display,
        fontWeight: FontWeight.w700,
        letterSpacing: PaxFontSizes.trackingTight,
        height: PaxFontSizes.lineHeightTight,
      );

  static TextStyle get h1 => _sans(
        fontSize: PaxFontSizes.headline,
        fontWeight: FontWeight.w700,
        letterSpacing: PaxFontSizes.trackingTight,
        height: PaxFontSizes.lineHeightTight,
      );

  static TextStyle get h2 => _sans(
        fontSize: PaxFontSizes.titleLarge,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.3,
        height: PaxFontSizes.lineHeightTight,
      );

  static TextStyle get h3 => _sans(
        fontSize: PaxFontSizes.title,
        fontWeight: FontWeight.w600,
        letterSpacing: PaxFontSizes.trackingNormal,
        height: 1.3,
      );

  static TextStyle get h4 => _sans(
        fontSize: PaxFontSizes.subtitle,
        fontWeight: FontWeight.w600,
        letterSpacing: PaxFontSizes.trackingNormal,
        height: 1.3,
      );

  static TextStyle get bodyLarge => _sans(
        fontSize: PaxFontSizes.bodyLarge,
        letterSpacing: PaxFontSizes.trackingNormal,
        height: PaxFontSizes.lineHeightNormal,
      );

  static TextStyle get body => _sans(
        fontSize: PaxFontSizes.body,
        letterSpacing: PaxFontSizes.trackingNormal,
        height: PaxFontSizes.lineHeightNormal,
      );

  static TextStyle get bodyMedium => _sans(
        fontSize: PaxFontSizes.body,
        fontWeight: FontWeight.w500,
        letterSpacing: PaxFontSizes.trackingNormal,
        height: PaxFontSizes.lineHeightNormal,
      );

  static TextStyle get bodySemiBold => _sans(
        fontSize: PaxFontSizes.body,
        fontWeight: FontWeight.w600,
        letterSpacing: PaxFontSizes.trackingNormal,
        height: PaxFontSizes.lineHeightNormal,
      );

  static TextStyle get label => _sans(
        fontSize: PaxFontSizes.label,
        fontWeight: FontWeight.w500,
        letterSpacing: PaxFontSizes.trackingWide,
        height: PaxFontSizes.lineHeightNormal,
      );

  static TextStyle get labelBold => _sans(
        fontSize: PaxFontSizes.label,
        fontWeight: FontWeight.w700,
        letterSpacing: PaxFontSizes.trackingWide,
      );

  static TextStyle get caption => _sans(
        fontSize: PaxFontSizes.caption,
        letterSpacing: PaxFontSizes.trackingWide,
        height: PaxFontSizes.lineHeightNormal,
      );

  static TextStyle get captionMedium => _sans(
        fontSize: PaxFontSizes.caption,
        fontWeight: FontWeight.w500,
        letterSpacing: PaxFontSizes.trackingWide,
      );

  static TextStyle get overline => _sans(
        fontSize: PaxFontSizes.caption,
        fontWeight: FontWeight.w600,
        letterSpacing: PaxFontSizes.trackingCaps,
        height: 1.4,
      );

  static TextStyle get buttonLg => _sans(
        fontSize: PaxFontSizes.md,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.2,
      );

  static TextStyle get buttonMd => _sans(
        fontSize: PaxFontSizes.base,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.2,
      );

  static TextStyle get buttonSm => _sans(
        fontSize: PaxFontSizes.sm,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.3,
      );

  static TextStyle get mono => const TextStyle(
        fontFamily: 'monospace',
        fontSize: PaxFontSizes.base,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
      );

  static TextStyle get monoLarge => const TextStyle(
        fontFamily: 'monospace',
        fontSize: PaxFontSizes.xxl,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
      );

  static TextStyle get navLabel => _sans(
        fontSize: 10,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.3,
        height: 1.2,
      );

  static TextStyle get amount => _sans(
        fontSize: PaxFontSizes.amount,
        fontWeight: FontWeight.w700,
        letterSpacing: -1.5,
        height: 1.1,
      );

  static TextStyle get amountMd => _sans(
        fontSize: PaxFontSizes.xxxl,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.8,
        height: 1.1,
      );
}
