import 'package:flutter/material.dart';

import '../../shared/theme/paxpayment_colors.dart';
import '../../shared/theme/paxpayment_spacing.dart';

/// Simple placeholder for secondary bottom-nav tabs (demo flow).
class PlaceholderTab extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const PlaceholderTab({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: PaxPaymentColors.adminBackground,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(PaxPaymentSpacing.sp24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 56, color: PaxPaymentColors.adminTitle),
              const SizedBox(height: PaxPaymentSpacing.sp20),
              Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: PaxPaymentColors.darkGrayText,
                    ),
              ),
              const SizedBox(height: PaxPaymentSpacing.sp12),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: PaxPaymentColors.hintText,
                      height: 1.4,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
