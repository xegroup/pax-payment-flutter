import 'package:flutter/material.dart';

import '../core/di/injection.dart';
import '../core/database/local_storage.dart';
import '../features/menu/models/payment_transaction.dart';
import '../services/printer_service.dart';
import '../shared/theme/pax_text_styles.dart';
import 'payment_navigation.dart';
import 'teya_ui.dart';

/// Cash payment completed.
class CashSuccessScreen extends StatefulWidget {
  const CashSuccessScreen({
    super.key,
    required this.amount,
    required this.cashGiven,
    required this.changeGiven,
    required this.transactionId,
    this.popWithResult = false,
  });

  final double amount;
  final double cashGiven;
  final double changeGiven;
  final String transactionId;
  final bool popWithResult;

  @override
  State<CashSuccessScreen> createState() => _CashSuccessScreenState();
}

class _CashSuccessScreenState extends State<CashSuccessScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _maybeAutoPrint());
  }

  PaymentTransaction get _transaction => PaymentTransaction(
        id: widget.transactionId,
        amount: widget.amount,
        status: PaymentStatus.success,
        time: DateTime.now().toString(),
        customerName: 'Walk-in Customer',
        cardType: 'Cash',
        refundSupported: false,
      );

  Future<void> _maybeAutoPrint() async {
    if (!sl<LocalStorage>().autoPrintReceipt) return;
    if (!mounted) return;
    await PrinterService.printReceipt(context, _transaction);
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
              'Cash payment recorded',
              textAlign: TextAlign.center,
              style: PaxTextStyles.h2.copyWith(
                color: TeyaColors.textDark,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 16),
            _row('Amount paid', TeyaUi.formatAmount(widget.amount)),
            _row('Cash given', TeyaUi.formatAmount(widget.cashGiven)),
            _row('Change given', TeyaUi.formatAmount(widget.changeGiven)),
            const SizedBox(height: 12),
            Text(
              'Ref: ${widget.transactionId}',
              textAlign: TextAlign.center,
              style: PaxTextStyles.caption.copyWith(color: TeyaColors.textGrey),
            ),
            Text(
              TeyaUi.ukDateTime.format(DateTime.now()),
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
              label: widget.popWithResult ? 'Continue' : 'New payment',
              onPressed: () => _onDone(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: PaxTextStyles.bodyMedium.copyWith(color: TeyaColors.textGrey),
          ),
          Text(
            value,
            style: PaxTextStyles.bodySemiBold.copyWith(
              color: TeyaColors.textDark,
            ),
          ),
        ],
      ),
    );
  }
}
