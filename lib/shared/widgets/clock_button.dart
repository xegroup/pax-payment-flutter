import 'package:flutter/material.dart';
import '../theme/theme_service.dart';
import '../theme/paxpayment_spacing.dart';

class ClockButton extends StatelessWidget {
  final String text;
  final bool enabled;
  final VoidCallback? onPressed;
  final double? verticalPadding;
  final double? fontSize;

  const ClockButton({
    super.key,
    required this.text,
    this.enabled = false,
    this.onPressed,
    this.verticalPadding,
    this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    final vPadding = verticalPadding ?? XeposSpacing.sp15;
    final fSize = fontSize ?? 12.0;

    return GestureDetector(
      onTap: enabled ? onPressed : null,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: vPadding),
        decoration: BoxDecoration(
          color: enabled ? ThemeService.xeposPrimaryBlue : Colors.grey.shade400,
          borderRadius: BorderRadius.circular(XeposSpacing.radiusLg),
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              color: ThemeService.xeposWhite,
              fontSize: fSize,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
