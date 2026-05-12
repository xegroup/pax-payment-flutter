import 'package:flutter/material.dart';

import '../theme/pax_colors.dart';
import '../theme/pax_spacing.dart';
import '../theme/pax_text_styles.dart';

class PaxButton extends StatelessWidget {
  const PaxButton._({
    required this.label,
    required this.buttonVariant,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.expand = true,
    this.size = PaxButtonSize.lg,
  });

  factory PaxButton.primary({
    required String label,
    VoidCallback? onPressed,
    IconData? icon,
    bool isLoading = false,
    bool expand = true,
    PaxButtonSize size = PaxButtonSize.lg,
  }) =>
      PaxButton._(
        label: label,
        buttonVariant: PaxButtonVariant.primary,
        onPressed: onPressed,
        icon: icon,
        isLoading: isLoading,
        expand: expand,
        size: size,
      );

  factory PaxButton.secondary({
    required String label,
    VoidCallback? onPressed,
    IconData? icon,
    bool isLoading = false,
    bool expand = true,
    PaxButtonSize size = PaxButtonSize.lg,
  }) =>
      PaxButton._(
        label: label,
        buttonVariant: PaxButtonVariant.secondary,
        onPressed: onPressed,
        icon: icon,
        isLoading: isLoading,
        expand: expand,
        size: size,
      );

  factory PaxButton.tonal({
    required String label,
    VoidCallback? onPressed,
    IconData? icon,
    bool isLoading = false,
    bool expand = true,
    PaxButtonSize size = PaxButtonSize.lg,
  }) =>
      PaxButton._(
        label: label,
        buttonVariant: PaxButtonVariant.tonal,
        onPressed: onPressed,
        icon: icon,
        isLoading: isLoading,
        expand: expand,
        size: size,
      );

  factory PaxButton.destructive({
    required String label,
    VoidCallback? onPressed,
    IconData? icon,
    bool isLoading = false,
    bool expand = true,
    PaxButtonSize size = PaxButtonSize.lg,
  }) =>
      PaxButton._(
        label: label,
        buttonVariant: PaxButtonVariant.destructive,
        onPressed: onPressed,
        icon: icon,
        isLoading: isLoading,
        expand: expand,
        size: size,
      );

  final String label;
  final PaxButtonVariant buttonVariant;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final bool expand;
  final PaxButtonSize size;

  double get _height => switch (size) {
        PaxButtonSize.sm => 36,
        PaxButtonSize.md => 44,
        PaxButtonSize.lg => 52,
      };

  TextStyle get _textStyle => switch (size) {
        PaxButtonSize.sm => PaxTextStyles.buttonSm,
        PaxButtonSize.md => PaxTextStyles.buttonMd,
        PaxButtonSize.lg => PaxTextStyles.buttonLg,
      };

  double get _iconSize => switch (size) {
        PaxButtonSize.sm => 16,
        PaxButtonSize.md => 18,
        PaxButtonSize.lg => 20,
      };

  double get _spinnerSize => switch (size) {
        PaxButtonSize.sm => 14,
        PaxButtonSize.md => 16,
        PaxButtonSize.lg => 18,
      };

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isDisabled = onPressed == null || isLoading;

    final style = _resolveStyle(isDark, isDisabled);
    final child = _buildChild(isDark);

    Widget button = switch (buttonVariant) {
      PaxButtonVariant.primary => FilledButton(
          onPressed: isDisabled ? null : onPressed,
          style: style,
          child: child,
        ),
      PaxButtonVariant.secondary => OutlinedButton(
          onPressed: isDisabled ? null : onPressed,
          style: style,
          child: child,
        ),
      PaxButtonVariant.tonal => ElevatedButton(
          onPressed: isDisabled ? null : onPressed,
          style: style,
          child: child,
        ),
      PaxButtonVariant.destructive => FilledButton(
          onPressed: isDisabled ? null : onPressed,
          style: style,
          child: child,
        ),
    };

    if (expand) {
      button = SizedBox(width: double.infinity, child: button);
    }

    return AnimatedOpacity(
      opacity: isDisabled ? 0.6 : 1.0,
      duration: PaxSpacing.durationFast,
      child: button,
    );
  }

  ButtonStyle _resolveStyle(bool isDark, bool isDisabled) {
    final baseShape = RoundedRectangleBorder(
      borderRadius: switch (size) {
        PaxButtonSize.sm => PaxSpacing.brSm,
        _ => PaxSpacing.brMd,
      },
    );

    final basePadding = switch (size) {
      PaxButtonSize.sm => const EdgeInsets.symmetric(
          horizontal: PaxSpacing.md,
          vertical: PaxSpacing.xs,
        ),
      PaxButtonSize.md => const EdgeInsets.symmetric(
          horizontal: PaxSpacing.lg,
          vertical: PaxSpacing.sm,
        ),
      PaxButtonSize.lg => const EdgeInsets.symmetric(horizontal: PaxSpacing.lg),
    };

    return switch (buttonVariant) {
      PaxButtonVariant.primary => FilledButton.styleFrom(
          backgroundColor: isDark ? PaxColors.teal400 : PaxColors.teal500,
          foregroundColor: isDark ? PaxColors.grey950 : PaxColors.white,
          minimumSize: Size(0, _height),
          shape: baseShape,
          textStyle: _textStyle,
          elevation: 0,
          shadowColor: PaxColors.transparent,
          padding: basePadding,
        ),
      PaxButtonVariant.secondary => OutlinedButton.styleFrom(
          foregroundColor: isDark ? PaxColors.grey100 : PaxColors.grey800,
          minimumSize: Size(0, _height),
          shape: baseShape,
          side: BorderSide(
            color: isDark ? PaxColors.grey700 : PaxColors.grey300,
          ),
          textStyle: _textStyle,
          padding: basePadding,
        ),
      PaxButtonVariant.tonal => ElevatedButton.styleFrom(
          backgroundColor: isDark ? PaxColors.grey800 : PaxColors.grey100,
          foregroundColor: isDark ? PaxColors.grey100 : PaxColors.grey800,
          minimumSize: Size(0, _height),
          shape: baseShape,
          textStyle: _textStyle,
          elevation: 0,
          shadowColor: PaxColors.transparent,
          padding: basePadding,
        ),
      PaxButtonVariant.destructive => FilledButton.styleFrom(
          backgroundColor: PaxColors.error,
          foregroundColor: PaxColors.white,
          minimumSize: Size(0, _height),
          shape: baseShape,
          textStyle: _textStyle,
          elevation: 0,
          shadowColor: PaxColors.transparent,
          padding: basePadding,
        ),
    };
  }

  Widget _buildChild(bool isDark) {
    if (isLoading) {
      final spinnerColor = switch (buttonVariant) {
        PaxButtonVariant.primary =>
          isDark ? PaxColors.grey950 : PaxColors.white,
        PaxButtonVariant.secondary =>
          isDark ? PaxColors.grey100 : PaxColors.grey800,
        PaxButtonVariant.tonal =>
          isDark ? PaxColors.grey100 : PaxColors.grey700,
        PaxButtonVariant.destructive => PaxColors.white,
      };

      return SizedBox(
        width: _spinnerSize,
        height: _spinnerSize,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(spinnerColor),
        ),
      );
    }

    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: _iconSize),
          const SizedBox(width: PaxSpacing.sm),
          Text(label),
        ],
      );
    }

    return Text(label);
  }
}

enum PaxButtonSize { sm, md, lg }

enum PaxButtonVariant { primary, secondary, tonal, destructive }

/// Legacy name — prefer [PaxButton].
typedef PaxPaymentButton = PaxButton;
typedef XeposButton = PaxButton;
