import 'package:flutter/material.dart';

import 'pax_text_styles.dart';

/// Legacy style names used by a few widgets — backed by [PaxTextStyles].
class PaxPaymentTextStyles {
  PaxPaymentTextStyles._();

  static TextStyle get displayLarge => PaxTextStyles.display;
  static TextStyle get display => PaxTextStyles.h1;
  static TextStyle get headlineLarge => PaxTextStyles.h2;
  static TextStyle get headline => PaxTextStyles.h3;
  static TextStyle get titleLarge => PaxTextStyles.h4;
  static TextStyle get title => PaxTextStyles.h4;
  static TextStyle get titleMedium => PaxTextStyles.h4;
  static TextStyle get subtitle => PaxTextStyles.bodyLarge;
  static TextStyle get subtitleSmall => PaxTextStyles.bodyMedium;

  static TextStyle get bodyLarge => PaxTextStyles.bodyLarge;
  static TextStyle get body => PaxTextStyles.body;
  static TextStyle get bodyRegular => PaxTextStyles.body;
  static TextStyle get bodyMedium => PaxTextStyles.bodyMedium;
  static TextStyle get bodyBold => PaxTextStyles.bodySemiBold;
  static TextStyle get bodySmall => PaxTextStyles.caption;

  static TextStyle get labelLarge => PaxTextStyles.buttonMd;
  static TextStyle get label => PaxTextStyles.label;
  static TextStyle get labelSmall => PaxTextStyles.caption;

  static TextStyle get caption => PaxTextStyles.caption;
  static TextStyle get captionMedium => PaxTextStyles.captionMedium;

  static TextStyle get buttonLarge => PaxTextStyles.buttonLg;
  static TextStyle get button => PaxTextStyles.buttonMd;
  static TextStyle get buttonSmall => PaxTextStyles.buttonSm;

  static TextStyle get orderHeader => PaxTextStyles.labelBold;
  static TextStyle get orderItem => PaxTextStyles.caption;
  static TextStyle get orderItemBold => PaxTextStyles.captionMedium;
  static TextStyle get orderTotal => PaxTextStyles.bodySemiBold;

  static TextStyle get menuCategory => PaxTextStyles.label;
  static TextStyle get menuItem => PaxTextStyles.caption;

  static TextStyle get tabButton => PaxTextStyles.caption;
  static TextStyle get tabButtonSelected => PaxTextStyles.captionMedium;

  static TextStyle get pinTitle => PaxTextStyles.h3;
  static TextStyle get pinEmployeeName => PaxTextStyles.bodySemiBold;
  static TextStyle get pinClock => PaxTextStyles.caption;
  static TextStyle get pinInput => PaxTextStyles.h2;

  static TextStyle withColor(TextStyle style, Color color) {
    return style.copyWith(color: color);
  }

  static TextStyle withWeight(TextStyle style, FontWeight weight) {
    return style.copyWith(fontWeight: weight);
  }

  static TextStyle withSize(TextStyle style, double size) {
    return style.copyWith(fontSize: size);
  }
}

typedef XeposTextStyles = PaxPaymentTextStyles;
