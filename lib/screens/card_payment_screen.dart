import 'package:flutter/material.dart';

import '../core/services/payment_service.dart';
import '../features/menu/models/payment_transaction.dart';
import '../shared/theme/pax_text_styles.dart';
import 'payment_flow_helpers.dart';
import 'payment_navigation.dart';
import 'teya_ui.dart';

/// Launches card payment immediately (skips payment method selection).
class CardPaymentScreen extends StatefulWidget {
  const CardPaymentScreen({
    super.key,
    required this.totalAmount,
    this.splitLabel,
    this.completeWithPopResult = false,
  });

  final double totalAmount;
  final String? splitLabel;
  final bool completeWithPopResult;

  @override
  State<CardPaymentScreen> createState() => _CardPaymentScreenState();
}

class _CardPaymentScreenState extends State<CardPaymentScreen> {
  final _paymentService = PaymentService();
  bool _isProcessing = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _startCardPayment());
  }

  Future<void> _startCardPayment() async {
    setState(() {
      _isProcessing = true;
      _errorMessage = null;
    });

    try {
      final result = await _paymentService.startPayment(
        amount: (widget.totalAmount * 100).round(),
        title: 'Payment',
        paymentMethod: 'card',
      );

      if (!mounted) return;

      final status = parsePaymentStatus(result);
      if (status == null) {
        _onPaymentCancelled();
        return;
      }

      final nativeId = result['transactionId']?.toString().trim();
      final transactionId = (nativeId != null && nativeId.isNotEmpty)
          ? nativeId
          : generateTransactionId();
      final last4 = extractCardLast4(result['cardNumber']);
      final cardType = parseCardType(result);
      final evoRef = nativeId?.isNotEmpty == true ? nativeId : null;

      if (status == PaymentStatus.success) {
        await saveCardTransaction(
          amount: widget.totalAmount,
          status: PaymentStatus.success,
          transactionId: transactionId,
          cardLast4: last4,
          cardType: cardType,
          evoTransactionRef: evoRef,
        );
        if (!mounted) return;
        navigateToPaymentSuccess(
          context,
          amount: widget.totalAmount,
          cardLast4: last4,
          cardType: cardType,
          transactionId: transactionId,
          popWithResult: widget.completeWithPopResult,
        );
      } else {
        await saveCardTransaction(
          amount: widget.totalAmount,
          status: PaymentStatus.failed,
          transactionId: transactionId,
          cardLast4: last4,
          cardType: cardType,
          evoTransactionRef: evoRef,
        );
        if (!mounted) return;
        navigateToPaymentDeclined(
          context,
          amount: widget.totalAmount,
          declineReason: parseDeclineReason(result),
          popWithResult: widget.completeWithPopResult,
        );
      }
    } on PaymentServiceException catch (e) {
      if (!mounted) return;
      setState(() {
        _isProcessing = false;
        _errorMessage = e.message;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isProcessing = false;
        _errorMessage = 'Payment could not be processed';
      });
    }
  }

  void _onPaymentCancelled() {
    if (widget.completeWithPopResult) {
      Navigator.of(context).pop(false);
      return;
    }
    setState(() {
      _isProcessing = false;
      _errorMessage = 'Payment cancelled';
    });
  }

  void _onGoBack() {
    if (_isProcessing) return;
    if (widget.completeWithPopResult) {
      Navigator.of(context).pop(false);
    } else {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return TeyaScreenScaffold(
      appBar: TeyaTopBar(onGoBack: _isProcessing ? null : _onGoBack),
      body: Stack(
        children: [
          if (_errorMessage != null)
            ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              children: [
                if (widget.splitLabel != null) ...[
                  Text(
                    widget.splitLabel!,
                    style: PaxTextStyles.caption.copyWith(
                      color: TeyaColors.textGrey,
                    ),
                  ),
                  const SizedBox(height: 4),
                ],
                Text(
                  TeyaUi.formatAmount(widget.totalAmount),
                  textAlign: TextAlign.center,
                  style: PaxTextStyles.amount.copyWith(color: TeyaColors.textDark),
                ),
                const SizedBox(height: 24),
                Text(
                  _errorMessage!,
                  textAlign: TextAlign.center,
                  style: PaxTextStyles.bodyMedium.copyWith(
                    color: TeyaColors.textGrey,
                  ),
                ),
                const SizedBox(height: 24),
                TeyaPrimaryButton(
                  label: 'Try again',
                  onPressed: _startCardPayment,
                ),
              ],
            ),
          if (_isProcessing)
            ColoredBox(
              color: Colors.black.withValues(alpha: 0.35),
              child: Center(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 32),
                  padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
                  decoration: BoxDecoration(
                    color: TeyaColors.white,
                    borderRadius: TeyaUi.buttonRadius,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(
                        width: 32,
                        height: 32,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: TeyaColors.accent,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Launching payment...',
                        style: PaxTextStyles.bodySemiBold.copyWith(
                          color: TeyaColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Complete payment on the terminal',
                        textAlign: TextAlign.center,
                        style: PaxTextStyles.caption.copyWith(
                          color: TeyaColors.textGrey,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
