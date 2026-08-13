import 'package:flutter/material.dart';

import '../shared/theme/pax_text_styles.dart';
import 'payment_flow_helpers.dart';
import 'payment_navigation.dart';
import 'teya_ui.dart';

/// Card payment declined.
class PaymentDeclinedScreen extends StatefulWidget {
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
  State<PaymentDeclinedScreen> createState() => _PaymentDeclinedScreenState();
}

class _PaymentDeclinedScreenState extends State<PaymentDeclinedScreen> {
  bool _isProcessing = false;

  Future<void> _startCardPayment() async {
    if (_isProcessing) return;

    setState(() => _isProcessing = true);
    try {
      await startCardPaymentFlow(
        context,
        amount: widget.amount,
        popWithResult: widget.popWithResult,
      );
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final reason = widget.declineReason?.trim().isNotEmpty == true
        ? widget.declineReason!.trim()
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
              TeyaUi.formatAmount(widget.amount),
              textAlign: TextAlign.center,
              style: PaxTextStyles.amountMd.copyWith(color: TeyaColors.textDark),
            ),
            const TeyaDivider(),
            TeyaPrimaryButton(
              label: _isProcessing ? 'Processing…' : 'Try again',
              onPressed: _isProcessing ? null : _startCardPayment,
            ),
            const SizedBox(height: 12),
            TeyaSecondaryButton(
              label: 'Cancel',
              onPressed: () {
                if (_isProcessing) return;
                if (widget.popWithResult) {
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
