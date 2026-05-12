import 'package:flutter/material.dart';

import '../../../shared/theme/pax_colors.dart';
import '../../../shared/theme/pax_font_sizes.dart';
import '../../../shared/theme/pax_spacing.dart';
import '../../../shared/theme/pax_text_styles.dart';
import '../models/payment_transaction.dart';

enum PaymentBadgeSize { sm, md, lg }

class PaymentStatusBadge extends StatelessWidget {
  const PaymentStatusBadge({
    super.key,
    required this.status,
    this.compact = false,
    this.isRefund = false,
    this.size,
  });

  final PaymentStatus status;
  final bool compact;
  final bool isRefund;
  final PaymentBadgeSize? size;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final effectiveSize = size ??
        (compact ? PaymentBadgeSize.sm : PaymentBadgeSize.md);
    final config = _configFor(isDark, effectiveSize);

    return AnimatedContainer(
      duration: PaxSpacing.durationFast,
      padding: EdgeInsets.symmetric(
        horizontal: config.hPad,
        vertical: config.vPad,
      ),
      decoration: BoxDecoration(
        color: config.bgColor,
        borderRadius: PaxSpacing.brPill,
        border: Border.all(color: config.borderColor, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (config.showIcon) ...[
            Icon(config.icon, size: config.iconSize, color: config.textColor),
            SizedBox(width: effectiveSize == PaymentBadgeSize.sm ? 3 : 4),
          ],
          Text(
            config.label,
            style: PaxTextStyles.overline.copyWith(
              fontSize: config.fontSize,
              color: config.textColor,
              letterSpacing: 0.6,
            ),
          ),
        ],
      ),
    );
  }

  _BadgeVisual _configFor(bool isDark, PaymentBadgeSize badgeSize) {
    final fontSize = switch (badgeSize) {
      PaymentBadgeSize.sm => PaxFontSizesBadge.sm,
      PaymentBadgeSize.md => PaxFontSizesBadge.md,
      PaymentBadgeSize.lg => PaxFontSizesBadge.lg,
    };
    final iconSize = switch (badgeSize) {
      PaymentBadgeSize.sm => 10.0,
      PaymentBadgeSize.md => 12.0,
      PaymentBadgeSize.lg => 14.0,
    };
    final hPad = switch (badgeSize) {
      PaymentBadgeSize.sm => PaxSpacing.sm - 2,
      PaymentBadgeSize.md => PaxSpacing.sm,
      PaymentBadgeSize.lg => PaxSpacing.sm + 2,
    };
    final vPad = switch (badgeSize) {
      PaymentBadgeSize.sm => PaxSpacing.xxs,
      PaymentBadgeSize.md => PaxSpacing.xxs + 1,
      PaymentBadgeSize.lg => PaxSpacing.xs,
    };

    if (isRefund) {
      return _BadgeVisual(
        label: 'Refunded',
        icon: Icons.undo_rounded,
        bgColor: isDark
            ? PaxColors.info.withValues(alpha: 0.15)
            : PaxColors.infoLight,
        textColor: isDark ? PaxColors.info : PaxColors.infoDark,
        borderColor: isDark
            ? PaxColors.info.withValues(alpha: 0.3)
            : PaxColors.info.withValues(alpha: 0.4),
        fontSize: fontSize,
        iconSize: iconSize,
        hPad: hPad,
        vPad: vPad,
        showIcon: true,
      );
    }

    final success = status == PaymentStatus.success;
    if (success) {
      return _BadgeVisual(
        label: 'Success',
        icon: Icons.check_circle_outline_rounded,
        bgColor: isDark
            ? PaxColors.success.withValues(alpha: 0.15)
            : PaxColors.successLight,
        textColor: isDark ? PaxColors.success : PaxColors.successDark,
        borderColor: isDark
            ? PaxColors.success.withValues(alpha: 0.3)
            : PaxColors.success.withValues(alpha: 0.4),
        fontSize: fontSize,
        iconSize: iconSize,
        hPad: hPad,
        vPad: vPad,
        showIcon: true,
      );
    }

    return _BadgeVisual(
      label: 'Failed',
      icon: Icons.error_outline_rounded,
      bgColor: isDark
          ? PaxColors.error.withValues(alpha: 0.15)
          : PaxColors.errorLight,
      textColor: isDark ? PaxColors.error : PaxColors.errorDark,
      borderColor: isDark
          ? PaxColors.error.withValues(alpha: 0.3)
          : PaxColors.error.withValues(alpha: 0.4),
      fontSize: fontSize,
      iconSize: iconSize,
      hPad: hPad,
      vPad: vPad,
      showIcon: true,
    );
  }
}

class _BadgeVisual {
  const _BadgeVisual({
    required this.label,
    required this.icon,
    required this.bgColor,
    required this.textColor,
    required this.borderColor,
    required this.fontSize,
    required this.iconSize,
    required this.hPad,
    required this.vPad,
    required this.showIcon,
  });

  final String label;
  final IconData icon;
  final Color bgColor;
  final Color textColor;
  final Color borderColor;
  final double fontSize;
  final double iconSize;
  final double hPad;
  final double vPad;
  final bool showIcon;
}
