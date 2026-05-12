import 'package:flutter/material.dart';

import '../../shared/theme/paxpayment_colors.dart';
import '../../shared/theme/paxpayment_spacing.dart';
import 'checkout_payment_screen.dart';

class PaymentLinksScreen extends StatelessWidget {
  const PaymentLinksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PaxPaymentColors.adminBackground,
      appBar: AppBar(
        title: const Text('Payment Links'),
        backgroundColor: PaxPaymentColors.white,
        foregroundColor: PaxPaymentColors.darkGrayText,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(PaxPaymentSpacing.sp16),
        children: [
          Container(
            padding: const EdgeInsets.all(PaxPaymentSpacing.sp16),
            decoration: BoxDecoration(
              color: PaxPaymentColors.white,
              borderRadius: BorderRadius.circular(PaxPaymentSpacing.radiusXl),
              border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Create and share payment links',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: PaxPaymentColors.darkGrayText,
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: PaxPaymentSpacing.sp8),
                Text(
                  'Create payment requests and share secure links with customers.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: PaxPaymentColors.mediumGray,
                        height: 1.35,
                      ),
                ),
                const SizedBox(height: PaxPaymentSpacing.sp16),
                FilledButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const CheckoutPaymentScreen(
                          initialMethod: CheckoutPaymentMethod.paymentLink,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.link_rounded),
                  label: const Text('Create payment link'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
