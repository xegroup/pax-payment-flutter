import 'package:flutter/material.dart';
import 'package:pax_payment/features/menu/checkout_payment_screen.dart';

import '../shared/theme/pax_text_styles.dart';
import 'payment_method_screen.dart';
import 'payment_navigation.dart';
import 'teya_ui.dart';

/// Card payment declined.
class PaymentDeclinedScreen extends StatelessWidget {
  const PaymentDeclinedScreen({
    super.key,
    required this.amount,
    this.declineReason,
    this.popWithResult = false,
  });

  final double amount;
  final String? declineReason;
  final bool popWithResult;

  @override
  Widget build(BuildContext context) {
    final reason = declineReason?.trim().isNotEmpty == true
        ? declineReason!.trim()
        : 'Payment could not be processed';

    return PopScope(
      canPop: false,
      child: TeyaScreenScaffold(
        body: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          children: [
            Text(
              'POSLink Testing - XePOS',
              textAlign: TextAlign.center,
              style: PaxTextStyles.caption.copyWith(color: TeyaColors.textGrey),
            ),
            const SizedBox(height: 40),
            const Center(child: TeyaAnimatedResultIcon(success: false)),
            const SizedBox(height: 24),
            Text(
              'Payment declined',
              textAlign: TextAlign.center,
              style: PaxTextStyles.h2.copyWith(
                color: TeyaColors.textDark,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              reason,
              textAlign: TextAlign.center,
              style: PaxTextStyles.bodyMedium.copyWith(color: TeyaColors.textGrey),
            ),
            const SizedBox(height: 16),
            Text(
              TeyaUi.formatAmount(amount),
              textAlign: TextAlign.center,
              style: PaxTextStyles.amountMd.copyWith(color: TeyaColors.textDark),
            ),
            const TeyaDivider(),
            TeyaPrimaryButton(
              label: 'Try again',
              onPressed: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute<void>(
                    builder: (_) => CheckoutPaymentScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            TeyaSecondaryButton(
              label: 'Cancel',
              onPressed: () {
                if (popWithResult) {
                  Navigator.of(context).pop(false);
                } else {
                  navigateToCheckout(context);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
