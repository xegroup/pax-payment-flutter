import 'dart:async';

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
  static const int _retryDelaySeconds = 30;

  Timer? _countdown;
  int _secondsRemaining = _retryDelaySeconds;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  @override
  void dispose() {
    _countdown?.cancel();
    super.dispose();
  }

  void _startCountdown() {
    _countdown?.cancel();
    _countdown = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted || _isProcessing) {
        timer.cancel();
        return;
      }
      if (_secondsRemaining <= 1) {
        timer.cancel();
        _startCardPayment();
        return;
      }
      setState(() => _secondsRemaining -= 1);
    });
  }

  Future<void> _startCardPayment() async {
    if (_isProcessing) return;
    _countdown?.cancel();

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

  void _cancel() {
    if (_isProcessing) return;
    _countdown?.cancel();
    if (widget.popWithResult) {
      Navigator.of(context).pop(false);
    } else {
      navigateToCheckout(context);
    }
  }

  String get _countdownLabel {
    if (_isProcessing) return 'Retrying payment…';
    final unit = _secondsRemaining == 1 ? 'second' : 'seconds';
    return 'Retrying in $_secondsRemaining $unit';
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
            const SizedBox(height: 8),
            Text(
              _countdownLabel,
              textAlign: TextAlign.center,
              style: PaxTextStyles.bodyMedium.copyWith(
                color: TeyaColors.textDark,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: const BorderRadius.all(Radius.circular(4)),
              child: LinearProgressIndicator(
                value: _isProcessing
                    ? null
                    : (_retryDelaySeconds - _secondsRemaining) /
                        _retryDelaySeconds,
                minHeight: 6,
                backgroundColor: TeyaColors.borderGrey,
                color: TeyaColors.accent,
              ),
            ),
            const TeyaDivider(),
            TeyaSecondaryButton(
              label: 'Cancel',
              onPressed: _cancel,
            ),
          ],
        ),
      ),
    );
  }
}
