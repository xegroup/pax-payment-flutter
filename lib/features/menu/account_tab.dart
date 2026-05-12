import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../shared/theme/paxpayment_colors.dart';
import '../../shared/theme/paxpayment_spacing.dart';
import 'data/dummy_payments_data.dart';
import 'models/payment_transaction.dart';
import 'settlements_screen.dart';

class AccountTab extends StatelessWidget {
  const AccountTab({super.key});

  static final _money = NumberFormat.currency(locale: 'en_GB', symbol: '£');
  static final _time = DateFormat('dd/MM/yyyy HH:mm', 'en_GB');

  @override
  Widget build(BuildContext context) {
    final recent = DummyPaymentsData.all.take(12).toList();

    final successVolume = recent
        .where((t) => t.status == PaymentStatus.success && !t.isRefund && t.amount > 0)
        .fold<double>(0, (s, t) => s + t.amount);
    final refundVolume = recent
        .where((t) => t.isRefund || t.amount < 0)
        .fold<double>(0, (s, t) => s + t.amount.abs());
    final available = successVolume - refundVolume;

    return ColoredBox(
      color: PaxPaymentColors.adminBackground,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 22, 16, 20),
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
                  'Available balance (recent activity)',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: PaxPaymentColors.mediumGray,
                      ),
                ),
                const SizedBox(height: PaxPaymentSpacing.sp6),
                Text(
                  _money.format(double.parse(available.toStringAsFixed(2))),
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: PaxPaymentColors.darkGrayText,
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: PaxPaymentSpacing.sp4),
                Text(
                  'Currency: GBP (£)',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: PaxPaymentColors.mediumGray,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(height: PaxPaymentSpacing.sp12),
          Text(
            'Quick actions',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: PaxPaymentColors.darkGrayText,
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: PaxPaymentSpacing.sp8),
          Row(
            children: [
              Expanded(
                child: _quickAction(
                  context,
                  title: 'Transfer',
                  icon: Icons.swap_horiz_rounded,
                  onTap: () => _snack(context, 'Transfer flow coming soon'),
                ),
              ),
              const SizedBox(width: PaxPaymentSpacing.sp8),
              Expanded(
                child: _quickAction(
                  context,
                  title: 'Settlement Info',
                  icon: Icons.account_balance_wallet_outlined,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const SettlementsScreen(),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: PaxPaymentSpacing.sp8),
              Expanded(
                child: _quickAction(
                  context,
                  title: 'Bank Details',
                  icon: Icons.account_balance_outlined,
                  onTap: () => _snack(context, 'Bank details coming soon'),
                ),
              ),
            ],
          ),
          const SizedBox(height: PaxPaymentSpacing.sp14),
          Text(
            'Recent transactions',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: PaxPaymentColors.darkGrayText,
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: PaxPaymentSpacing.sp8),
          if (recent.isEmpty)
            Text(
              'No transactions yet.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: PaxPaymentColors.mediumGray,
                  ),
            )
          else
            ...recent.map((t) => _txTile(context, t)),
        ],
      ),
    );
  }

  Widget _txTile(BuildContext context, PaymentTransaction t) {
    final amt = _money.format(t.amount.abs());
    final isCredit =
        !t.isRefund && t.status == PaymentStatus.success && t.amount >= 0;
    final signed = isCredit ? '+$amt' : '-$amt';
    return Container(
      margin: const EdgeInsets.only(bottom: PaxPaymentSpacing.sp10),
      padding: const EdgeInsets.all(PaxPaymentSpacing.sp14),
      decoration: BoxDecoration(
        color: PaxPaymentColors.white,
        borderRadius: BorderRadius.circular(PaxPaymentSpacing.radiusLg),
        border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(PaxPaymentSpacing.sp8),
            decoration: BoxDecoration(
              color: PaxPaymentColors.lightGray,
              borderRadius: BorderRadius.circular(PaxPaymentSpacing.radiusMd),
            ),
            child: Icon(
              t.isRefund ? Icons.replay_rounded : Icons.receipt_long_outlined,
              color: PaxPaymentColors.darkGrayText,
            ),
          ),
          const SizedBox(width: PaxPaymentSpacing.sp12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t.isRefund ? 'Refund' : (t.isCash ? 'Cash sale' : 'Card sale'),
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: PaxPaymentColors.darkGrayText,
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: PaxPaymentSpacing.sp2),
                Text(
                  _time.format(t.time),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: PaxPaymentColors.mediumGray,
                      ),
                ),
              ],
            ),
          ),
          Text(
            signed,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: isCredit ? PaxPaymentColors.textGreen : PaxPaymentColors.errorRed,
                  fontWeight: FontWeight.w800,
                ),
          ),
        ],
      ),
    );
  }

  Widget _quickAction(
    BuildContext context, {
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: PaxPaymentColors.white,
      borderRadius: BorderRadius.circular(PaxPaymentSpacing.radiusLg),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(PaxPaymentSpacing.radiusLg),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          child: Column(
            children: [
              Icon(icon, color: PaxPaymentColors.primaryBlue, size: 20),
              const SizedBox(height: PaxPaymentSpacing.sp6),
              Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: PaxPaymentColors.darkGrayText,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _snack(BuildContext context, String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text), behavior: SnackBarBehavior.floating),
    );
  }
}
