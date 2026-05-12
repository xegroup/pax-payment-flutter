import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'pax_font_sizes.dart';

/// Composable text styles (DM Sans via google_fonts).
abstract final class PaxTextStyles {
  static TextStyle get hero => GoogleFonts.dmSans(
        fontSize: PaxFontSizes.hero,
        fontWeight: FontWeight.w700,
        letterSpacing: PaxFontSizes.trackingTight,
        height: PaxFontSizes.lineHeightTight,
      );

  static TextStyle get display => GoogleFonts.dmSans(
        fontSize: PaxFontSizes.display,
        fontWeight: FontWeight.w700,
        letterSpacing: PaxFontSizes.trackingTight,
        height: PaxFontSizes.lineHeightTight,
      );

  static TextStyle get h1 => GoogleFonts.dmSans(
        fontSize: PaxFontSizes.headline,
        fontWeight: FontWeight.w700,
        letterSpacing: PaxFontSizes.trackingTight,
        height: PaxFontSizes.lineHeightTight,
      );

  static TextStyle get h2 => GoogleFonts.dmSans(
        fontSize: PaxFontSizes.titleLarge,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.3,
        height: PaxFontSizes.lineHeightTight,
      );

  static TextStyle get h3 => GoogleFonts.dmSans(
        fontSize: PaxFontSizes.title,
        fontWeight: FontWeight.w600,
        letterSpacing: PaxFontSizes.trackingNormal,
        height: 1.3,
      );

  static TextStyle get h4 => GoogleFonts.dmSans(
        fontSize: PaxFontSizes.subtitle,
        fontWeight: FontWeight.w600,
        letterSpacing: PaxFontSizes.trackingNormal,
        height: 1.3,
      );

  static TextStyle get bodyLarge => GoogleFonts.dmSans(
        fontSize: PaxFontSizes.bodyLarge,
        fontWeight: FontWeight.w400,
        letterSpacing: PaxFontSizes.trackingNormal,
        height: PaxFontSizes.lineHeightNormal,
      );

  static TextStyle get body => GoogleFonts.dmSans(
        fontSize: PaxFontSizes.body,
        fontWeight: FontWeight.w400,
        letterSpacing: PaxFontSizes.trackingNormal,
        height: PaxFontSizes.lineHeightNormal,
      );

  static TextStyle get bodyMedium => GoogleFonts.dmSans(
        fontSize: PaxFontSizes.body,
        fontWeight: FontWeight.w500,
        letterSpacing: PaxFontSizes.trackingNormal,
        height: PaxFontSizes.lineHeightNormal,
      );

  static TextStyle get bodySemiBold => GoogleFonts.dmSans(
        fontSize: PaxFontSizes.body,
        fontWeight: FontWeight.w600,
        letterSpacing: PaxFontSizes.trackingNormal,
        height: PaxFontSizes.lineHeightNormal,
      );

  static TextStyle get label => GoogleFonts.dmSans(
        fontSize: PaxFontSizes.label,
        fontWeight: FontWeight.w500,
        letterSpacing: PaxFontSizes.trackingWide,
        height: PaxFontSizes.lineHeightNormal,
      );

  static TextStyle get labelBold => GoogleFonts.dmSans(
        fontSize: PaxFontSizes.label,
        fontWeight: FontWeight.w700,
        letterSpacing: PaxFontSizes.trackingWide,
      );

  static TextStyle get caption => GoogleFonts.dmSans(
        fontSize: PaxFontSizes.caption,
        fontWeight: FontWeight.w400,
        letterSpacing: PaxFontSizes.trackingWide,
        height: PaxFontSizes.lineHeightNormal,
      );

  static TextStyle get captionMedium => GoogleFonts.dmSans(
        fontSize: PaxFontSizes.caption,
        fontWeight: FontWeight.w500,
        letterSpacing: PaxFontSizes.trackingWide,
      );

  static TextStyle get overline => GoogleFonts.dmSans(
        fontSize: PaxFontSizes.caption,
        fontWeight: FontWeight.w600,
        letterSpacing: PaxFontSizes.trackingCaps,
        height: 1.4,
      );

  static TextStyle get buttonLg => GoogleFonts.dmSans(
        fontSize: PaxFontSizes.md,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.2,
      );

  static TextStyle get buttonMd => GoogleFonts.dmSans(
        fontSize: PaxFontSizes.base,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.2,
      );

  static TextStyle get buttonSm => GoogleFonts.dmSans(
        fontSize: PaxFontSizes.sm,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.3,
      );

  static TextStyle get mono => GoogleFonts.robotoMono(
        fontSize: PaxFontSizes.base,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
      );

  static TextStyle get monoLarge => GoogleFonts.robotoMono(
        fontSize: PaxFontSizes.xxl,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
      );

  static TextStyle get navLabel => GoogleFonts.dmSans(
        fontSize: 10,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.3,
        height: 1.2,
      );

  static TextStyle get amount => GoogleFonts.dmSans(
        fontSize: PaxFontSizes.amount,
        fontWeight: FontWeight.w700,
        letterSpacing: -1.5,
        height: 1.1,
      );

  static TextStyle get amountMd => GoogleFonts.dmSans(
        fontSize: PaxFontSizes.xxxl,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.8,
        height: 1.1,
      );
}
