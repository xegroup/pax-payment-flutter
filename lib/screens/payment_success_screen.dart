import 'package:flutter/material.dart';
import 'package:pax_payment/features/transaction/data/evo_data_model.dart';

import '../core/di/injection.dart';
import '../core/database/local_storage.dart';
import '../features/menu/models/payment_transaction.dart';
import '../services/printer_service.dart';
import '../shared/theme/pax_text_styles.dart';
import 'payment_navigation.dart';
import 'teya_ui.dart';

/// Card payment approved.
class PaymentSuccessScreen extends StatefulWidget {
  const PaymentSuccessScreen({
    super.key,
    required this.amount,
    this.cardLast4,
    this.cardType,
    required this.transactionId,
    required this.timestamp,
    this.popWithResult = false,
    required this.evo
  });

  final double amount;
  final String? cardLast4;
  final String? cardType;
  final String transactionId;
  final String timestamp;
  final bool popWithResult;
  final EvoDataModel evo;

  @override
  State<PaymentSuccessScreen> createState() => _PaymentSuccessScreenState();
}

class _PaymentSuccessScreenState extends State<PaymentSuccessScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _maybeAutoPrint());
  }

  PaymentTransaction get _transaction =>
      PaymentTransaction(
          id: widget.transactionId,
          amount: widget.amount,
          status: PaymentStatus.success,
          time: widget.timestamp,
          customerName: 'Walk-in Customer',
          cardType: widget.cardType ?? 'Visa',
          refundSupported: true,
          cardLast4: widget.cardLast4,
          evoTransactionRef: widget.transactionId,
          evo: widget.evo
      );

  Future<void> _maybeAutoPrint() async {
    if (!sl<LocalStorage>().autoPrintReceipt) return;
    if (!mounted) return;
    await PrinterService.printReceipt(context, _transaction);
  }

  String get _cardLine {
    final type = widget.cardType
        ?.trim()
        .isNotEmpty == true
        ? widget.cardType!.trim()
        : 'Visa';
    final last4 = widget.cardLast4?.trim() ?? '';
    if (last4.length >= 4) {
      return '$type •••• ${last4.substring(last4.length - 4)}';
    }
    return type;
  }

  Future<void> _emailReceipt(BuildContext context) async {
    final ctrl = TextEditingController();
    final sent = await showDialog<bool>(
      context: context,
      builder: (ctx) =>
          AlertDialog(
            title: Text('Email receipt', style: PaxTextStyles.h4),
            content: TextField(
              controller: ctrl,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email address',
                hintText: 'customer@example.com',
              ),
              autofocus: true,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () {
                  if (ctrl.text
                      .trim()
                      .isEmpty) return;
                  Navigator.pop(ctx, true);
                },
                child: const Text('Send'),
              ),
            ],
          ),
    );
    if (sent == true && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Receipt sent'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _onDone(BuildContext context) {
    if (widget.popWithResult) {
      Navigator.of(context).pop(true);
      return;
    }
    navigateToCheckout(context);
  }

  @override
  Widget build(BuildContext context) {
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
            const Center(child: TeyaAnimatedResultIcon(success: true)),
            const SizedBox(height: 24),
            Text(
              'Payment successful',
              textAlign: TextAlign.center,
              style: PaxTextStyles.h2.copyWith(
                color: TeyaColors.textDark,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              TeyaUi.formatAmount(widget.amount),
              textAlign: TextAlign.center,
              style: PaxTextStyles.amount.copyWith(color: TeyaColors.textDark),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.credit_card_rounded,
                  color: TeyaColors.textGrey,
                  size: 22,
                ),
                const SizedBox(width: 8),
                Text(
                  _cardLine,
                  style: PaxTextStyles.bodyMedium.copyWith(
                    color: TeyaColors.textDark,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Ref: ${widget.transactionId}',
              textAlign: TextAlign.center,
              style: PaxTextStyles.caption.copyWith(color: TeyaColors.textGrey),
            ),
            Text(
              widget.timestamp,
              textAlign: TextAlign.center,
              style: PaxTextStyles.caption.copyWith(color: TeyaColors.textGrey),
            ),
            const TeyaDivider(),
            TeyaPrimaryButton(
              label: 'Print receipt',
              onPressed: () =>
                  PrinterService.printReceipt(context, _transaction),
            ),
            const SizedBox(height: 12),
            TeyaSecondaryButton(
              label: 'Email receipt',
              onPressed: () => _emailReceipt(context),
            ),
            const SizedBox(height: 12),
            TeyaSecondaryButton(
              label: widget.popWithResult ? 'Continue' : 'New payment',
              onPressed: () => _onDone(context),
            ),
          ],
        ),
      ),
    );
  }
}
