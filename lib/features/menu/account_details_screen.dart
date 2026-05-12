import 'package:flutter/material.dart';

import '../../shared/theme/paxpayment_colors.dart';
import '../../shared/theme/paxpayment_spacing.dart';

class AccountDetailsScreen extends StatelessWidget {
  const AccountDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PaxPaymentColors.adminBackground,
      appBar: AppBar(
        title: const Text('Account Details'),
        backgroundColor: PaxPaymentColors.white,
        foregroundColor: PaxPaymentColors.darkGrayText,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(PaxPaymentSpacing.sp16),
        children: [
          _row(context, 'Business', '2Burger Bar'),
          _row(context, 'Merchant ID', 'MRC-002-8891'),
          _row(context, 'Registered email', 'owner@2burgerbar.com'),
          _row(context, 'Phone', '+44 121 123 9088'),
          _row(context, 'Region', 'United Kingdom'),
        ],
      ),
    );
  }

  Widget _row(BuildContext context, String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: PaxPaymentSpacing.sp10),
      padding: const EdgeInsets.all(PaxPaymentSpacing.sp14),
      decoration: BoxDecoration(
        color: PaxPaymentColors.white,
        borderRadius: BorderRadius.circular(PaxPaymentSpacing.radiusLg),
        border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: PaxPaymentColors.mediumGray,
                ),
          ),
          const SizedBox(height: PaxPaymentSpacing.sp4),
          Text(
            value,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: PaxPaymentColors.darkGrayText,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }
}
