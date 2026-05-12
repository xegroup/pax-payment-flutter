import 'package:flutter/material.dart';

import '../../shared/theme/paxpayment_colors.dart';
import '../../shared/theme/paxpayment_spacing.dart';

/// Placeholder admin area for future merchant tools.
class AdminScreen extends StatelessWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PaxPaymentColors.adminBackground,
      appBar: AppBar(
        title: const Text('Admin'),
        backgroundColor: PaxPaymentColors.white,
        surfaceTintColor: Colors.transparent,
        foregroundColor: PaxPaymentColors.darkGrayText,
      ),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(PaxPaymentSpacing.sp24),
          child: Text(
            'Coming soon',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: PaxPaymentColors.darkGrayText,
            ),
          ),
        ),
      ),
    );
  }
}
