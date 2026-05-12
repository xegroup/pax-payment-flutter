import 'package:flutter/material.dart';

import 'paxpayment_colors.dart';

/// Theme extension for ordering / legacy surfaces.
class OrderingThemeColors extends ThemeExtension<OrderingThemeColors> {
  final Color textPrimary;
  final Color textSecondary;
  final Color surface;
  final Color surfaceAlt;
  final Color sidePanelBg;
  final Color dialogBg;
  final Color borderColor;
  final Color dividerColor;
  final Color textOnSurface;
  final Color rowAlternate;
  final Color inputFill;

  const OrderingThemeColors({
    required this.textPrimary,
    required this.textSecondary,
    required this.surface,
    required this.surfaceAlt,
    required this.sidePanelBg,
    required this.dialogBg,
    required this.borderColor,
    required this.dividerColor,
    required this.textOnSurface,
    required this.rowAlternate,
    required this.inputFill,
  });

  factory OrderingThemeColors.light() => OrderingThemeColors(
        textPrimary: PaxColors.grey900,
        textSecondary: PaxColors.grey600,
        surface: PaxColors.white,
        surfaceAlt: PaxColors.grey100,
        sidePanelBg: PaxColors.grey150,
        dialogBg: PaxColors.white,
        borderColor: PaxColors.grey200,
        dividerColor: PaxColors.grey300,
        textOnSurface: PaxColors.grey800,
        rowAlternate: PaxColors.grey50,
        inputFill: PaxColors.grey50,
      );

  factory OrderingThemeColors.dark() => OrderingThemeColors(
        textPrimary: PaxColors.grey50,
        textSecondary: PaxColors.grey400,
        surface: PaxPaymentColors.surfaceSolid,
        surfaceAlt: PaxPaymentColors.background,
        sidePanelBg: PaxPaymentColors.background,
        dialogBg: PaxPaymentColors.dialog,
        borderColor: PaxColors.grey700,
        dividerColor: PaxColors.grey600,
        textOnSurface: PaxColors.grey100,
        rowAlternate: PaxColors.grey850,
        inputFill: PaxPaymentColors.surfaceSolid,
      );

  static OrderingThemeColors of(BuildContext context) {
    return Theme.of(context).extension<OrderingThemeColors>() ??
        OrderingThemeColors.light();
  }

  @override
  OrderingThemeColors copyWith({
    Color? textPrimary,
    Color? textSecondary,
    Color? surface,
    Color? surfaceAlt,
    Color? sidePanelBg,
    Color? dialogBg,
    Color? borderColor,
    Color? dividerColor,
    Color? textOnSurface,
    Color? rowAlternate,
    Color? inputFill,
  }) {
    return OrderingThemeColors(
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      surface: surface ?? this.surface,
      surfaceAlt: surfaceAlt ?? this.surfaceAlt,
      sidePanelBg: sidePanelBg ?? this.sidePanelBg,
      dialogBg: dialogBg ?? this.dialogBg,
      borderColor: borderColor ?? this.borderColor,
      dividerColor: dividerColor ?? this.dividerColor,
      textOnSurface: textOnSurface ?? this.textOnSurface,
      rowAlternate: rowAlternate ?? this.rowAlternate,
      inputFill: inputFill ?? this.inputFill,
    );
  }

  @override
  OrderingThemeColors lerp(OrderingThemeColors? other, double t) {
    if (other == null) return this;
    return OrderingThemeColors(
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceAlt: Color.lerp(surfaceAlt, other.surfaceAlt, t)!,
      sidePanelBg: Color.lerp(sidePanelBg, other.sidePanelBg, t)!,
      dialogBg: Color.lerp(dialogBg, other.dialogBg, t)!,
      borderColor: Color.lerp(borderColor, other.borderColor, t)!,
      dividerColor: Color.lerp(dividerColor, other.dividerColor, t)!,
      textOnSurface: Color.lerp(textOnSurface, other.textOnSurface, t)!,
      rowAlternate: Color.lerp(rowAlternate, other.rowAlternate, t)!,
      inputFill: Color.lerp(inputFill, other.inputFill, t)!,
    );
  }
}
