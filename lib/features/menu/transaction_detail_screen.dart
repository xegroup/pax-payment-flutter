import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../shared/theme/paxpayment_colors.dart';
import '../../shared/theme/paxpayment_spacing.dart';
import 'models/payment_transaction.dart';

/// Full payment detail + practical actions.
class TransactionDetailScreen extends StatelessWidget {
  final PaymentTransaction transaction;

  const TransactionDetailScreen({
    super.key,
    required this.transaction,
  });

  static final _money = NumberFormat.currency(locale: 'en_GB', symbol: '£');
  static final _full = DateFormat('dd/MM/yyyy HH:mm', 'en_GB');

  static String _formatTransactionTime(String time) {
    final parsed = DateTime.tryParse(time.trim());
    if (parsed != null) {
      return _full.format(parsed.toLocal());
    }
    return time;
  }

  @override
  Widget build(BuildContext context) {
    final t = transaction;
    final amountText = _money.format(t.amount.abs());

    return Scaffold(
      backgroundColor: PaxPaymentColors.adminBackground,
      appBar: AppBar(
        title: const Text('Transaction details'),
        backgroundColor: PaxPaymentColors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        foregroundColor: PaxPaymentColors.darkGrayText,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(PaxPaymentSpacing.sp20),
              children: [
                Text(
                  amountText,
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        color: PaxPaymentColors.darkGrayText,
                        fontWeight: FontWeight.w500,
                        decoration: t.isRefund || t.amount < 0
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                      ),
                ),
                const SizedBox(height: PaxPaymentSpacing.sp24),
                Text(
                  'TRANSACTION DETAILS',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: PaxPaymentColors.mediumGray,
                        letterSpacing: 2,
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: PaxPaymentSpacing.sp12),
                _DetailRow(label: 'Date', value: _formatTransactionTime(t.time)),
                _DetailRow(
                  label: 'Card',
                  value: '${t.cardType} ${t.maskedLast4Display}',
                ),
                _DetailRow(
                  label: 'Approval code',
                  value: t.id.length <= 6 ? t.id : t.id.substring(0, 6),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              PaxPaymentSpacing.sp20,
              PaxPaymentSpacing.sp8,
              PaxPaymentSpacing.sp20,
              PaxPaymentSpacing.sp20,
            ),
            child: FilledButton(
              onPressed: () => Navigator.of(context).pop(),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
                backgroundColor: PaxPaymentColors.primaryBlue,
                foregroundColor: PaxPaymentColors.white,
              ),
              child: const Text('OK'),
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: PaxPaymentSpacing.sp12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: PaxPaymentColors.darkGrayText,
                  ),
            ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: PaxPaymentColors.darkGrayText,
                ),
          ),
        ],
      ),
    );
  }
}
