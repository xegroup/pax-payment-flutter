import 'package:flutter/material.dart';

import 'pax_colors.dart';

export 'pax_colors.dart' show PaxColors;

/// Legacy names used across feature screens — mapped to [PaxColors] tokens.
class PaxPaymentColors {
  PaxPaymentColors._();

  static const Color primaryBlue = PaxColors.teal500;
  static const Color buttonGreen = PaxColors.success;
  static const Color textGreen = PaxColors.successDark;
  static const Color white = PaxColors.white;
  static const Color black = PaxColors.black;
  static const Color lightGray = PaxColors.grey100;
  static const Color mediumGray = PaxColors.grey500;
  static const Color darkGrayText = PaxColors.grey800;
  static const Color hintText = PaxColors.grey600;
  static const Color errorRed = PaxColors.error;
  static const Color destructiveRed = PaxColors.errorDark;

  static const Color adminBackground = PaxColors.grey50;
  static const Color adminTitle = PaxColors.teal600;
  static const Color adminInputFieldBg = PaxColors.grey50;

  static const Color adminActionCyan = PaxColors.teal400;
  static const Color adminWarningOrange = PaxColors.warning;

  static const Color groupPurple = PaxColors.chart5;
  static const Color groupAmber = PaxColors.warning;
  static const Color groupBlue = PaxColors.info;

  static const Color posButtonPurple = PaxColors.chart5;
  static const Color posButtonCyan = PaxColors.teal400;

  static const Color orderingOrange = PaxColors.warningDark;
  static const Color orderingKeypadTeal = PaxColors.teal500;
  static const Color orderingOffWhite = PaxColors.grey100;
  static const Color orderingSideBg = PaxColors.grey150;
  static const Color orderingLine = PaxColors.grey400;

  /// XePOS / handheld keypay accent (yellow cursor, borders, brand mark).
  static const Color posKeypayAccent = Color(0xFFFFD400);

  static const Color background = PaxColors.grey950;
  static const Color surfaceSolid = PaxColors.grey900;
  static const Color toolbar = PaxColors.grey850;
  static const Color dialog = PaxColors.grey850;
}

typedef XeposColors = PaxPaymentColors;
