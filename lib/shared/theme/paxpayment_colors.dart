import 'package:flutter/material.dart';

import 'pax_colors.dart';

export 'pax_colors.dart' show PaxColors;

/// Legacy names used across feature screens — mapped to [PaxColors] tokens.
class PaxPaymentColors {
  PaxPaymentColors._();

  static const Color primaryBlue = PaxColors.blueDark;
  static const Color primaryBlueLight = PaxColors.blueLight;
  static const Color buttonGreen = PaxColors.blueLight;
  static const Color textGreen = PaxColors.blueDark;
  static const Color white = PaxColors.white;
  static const Color black = PaxColors.black;
  static const Color lightGray = PaxColors.grey100;
  static const Color mediumGray = PaxColors.grey500;
  static const Color darkGrayText = PaxColors.grey800;
  static const Color hintText = PaxColors.grey600;
  static const Color errorRed = PaxColors.error;
  static const Color destructiveRed = PaxColors.errorDark;

  static const Color adminBackground = PaxColors.grey50;
  static const Color adminTitle = PaxColors.blueDark;
  static const Color adminInputFieldBg = PaxColors.grey50;

  static const Color adminActionCyan = PaxColors.blueDark;
  static const Color adminWarningOrange = PaxColors.warning;

  static const Color groupPurple = PaxColors.chart5;
  static const Color groupAmber = PaxColors.warning;
  static const Color groupBlue = PaxColors.info;

  static const Color posButtonPurple = PaxColors.chart5;
  static const Color posButtonCyan = PaxColors.blueDark;

  static const Color orderingOrange = PaxColors.warningDark;
  static const Color orderingKeypadTeal = PaxColors.blueLight;
  static const Color orderingOffWhite = PaxColors.grey100;
  static const Color orderingSideBg = PaxColors.grey150;
  static const Color orderingLine = PaxColors.grey400;

  /// Brand accent for keypay cursor, borders, charge CTA, and logo mark.
  static const Color posKeypayAccent = PaxColors.blueLight;

  /// Text/icons on [posKeypayAccent] surfaces.
  static const Color onPosKeypayAccent = PaxColors.white;

  static const Color background = PaxColors.grey950;
  static const Color surfaceSolid = PaxColors.grey900;
  static const Color toolbar = PaxColors.grey850;
  static const Color dialog = PaxColors.grey850;
}

typedef XeposColors = PaxPaymentColors;
