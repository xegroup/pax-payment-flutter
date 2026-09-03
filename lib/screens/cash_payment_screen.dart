import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../shared/theme/pax_text_styles.dart';
import '../shared/widgets/pos_keypay_panel.dart';
import 'cash_success_screen.dart';
import 'payment_flow_helpers.dart';
import 'teya_ui.dart';

/// Cash tender entry with keypad.
class CashPaymentScreen extends StatefulWidget {
  const CashPaymentScreen({
    super.key,
    required this.totalAmount,
    this.completeWithPopResult = false,
  });

  final double totalAmount;
  final bool completeWithPopResult;

  @override
  State<CashPaymentScreen> createState() => _CashPaymentScreenState();
}

class _CashPaymentScreenState extends State<CashPaymentScreen> {
  String _tenderedRaw = '';

  double get _tendered =>
      _tenderedRaw.isEmpty ? 0.0 : int.parse(_tenderedRaw) / 100;

  String get _displayTendered {
    if (_tenderedRaw.isEmpty) return '0.00';
    final padded = _tenderedRaw.padLeft(3, '0');
    final cents = padded.substring(padded.length - 2);
    final pounds = padded.substring(0, padded.length - 2);
    return '$pounds.$cents';
  }

  double get _change => roundMoney(_tendered - widget.totalAmount);

  bool get _sufficient => _tendered >= widget.totalAmount - 0.009;

  void _onDigit(String d) {
    final addLen = d.length;
    if (_tenderedRaw.length + addLen > 8) return;
    HapticFeedback.selectionClick();
    setState(() => _tenderedRaw += d);
  }

  void _onDelete() {
    if (_tenderedRaw.isEmpty) return;
    setState(() {
      _tenderedRaw = _tenderedRaw.substring(0, _tenderedRaw.length - 1);
    });
  }

  void _onClear() => setState(() => _tenderedRaw = '');

  Future<void> _confirm() async {
    if (!_sufficient) return;
    final change = _change;
    final txnId = generateTransactionId();
    await saveCashTransaction(
      amount: widget.totalAmount,
      transactionId: txnId,
    );
    if (!mounted) return;
    final route = MaterialPageRoute<bool>(
      builder: (_) => CashSuccessScreen(
        amount: widget.totalAmount,
        cashGiven: _tendered,
        changeGiven: change,
        transactionId: txnId,
        popWithResult: widget.completeWithPopResult,
      ),
    );
    if (widget.completeWithPopResult) {
      final ok = await Navigator.of(context).push<bool>(route);
      if (!mounted) return;
      Navigator.of(context).pop(ok == true);
    } else {
      await Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (_) => CashSuccessScreen(
            amount: widget.totalAmount,
            cashGiven: _tendered,
            changeGiven: change,
            transactionId: txnId,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final changeColor = _sufficient
        ? TeyaColors.successGreen
        : TeyaColors.errorRed;
    final changeLabel = _sufficient ? 'Change due' : 'Insufficient amount';

    return TeyaScreenScaffold(
      appBar: TeyaTopBar(onGoBack: () => Navigator.of(context).pop()),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Cash payment',
                  style: PaxTextStyles.h2.copyWith(color: TeyaColors.textDark),
                ),
                const SizedBox(height: 16),
                Text(
                  'Amount due',
                  style: PaxTextStyles.bodyMedium.copyWith(
                    color: TeyaColors.textGrey,
                  ),
                ),
                Text(
                  TeyaUi.formatAmount(widget.totalAmount),
                  style: PaxTextStyles.amount.copyWith(
                    color: TeyaColors.textDark,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Cash tendered',
                  style: PaxTextStyles.bodyMedium.copyWith(
                    color: TeyaColors.textGrey,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '£$_displayTendered',
                  style: PaxTextStyles.h2.copyWith(
                    color: TeyaColors.textDark,
                    decoration: TextDecoration.underline,
                    decorationColor: TeyaColors.accent,
                    decorationThickness: 3,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  changeLabel,
                  style: PaxTextStyles.bodyMedium.copyWith(
                    color: TeyaColors.textGrey,
                  ),
                ),
                Text(
                  _sufficient
                      ? TeyaUi.formatAmount(_change)
                      : 'Short by ${TeyaUi.formatAmount(roundMoney(widget.totalAmount - _tendered))}',
                  style: PaxTextStyles.h3.copyWith(
                    color: changeColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: PosKeypayPanel(
                onDigit: _onDigit,
                onDelete: _onDelete,
                onClear: _onClear,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
            child: TeyaPrimaryButton(
              label: 'Confirm cash payment',
              enabled: _sufficient,
              onPressed: _confirm,
            ),
          ),
        ],
      ),
    );
  }
}
