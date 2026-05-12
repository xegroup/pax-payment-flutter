import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../shared/theme/paxpayment_colors.dart';
import '../../shared/theme/paxpayment_spacing.dart';
import 'data/dummy_payments_data.dart';

class SettlementsScreen extends StatelessWidget {
  const SettlementsScreen({super.key});

  static final _money = NumberFormat.currency(locale: 'en_GB', symbol: '£');
  static final _date = DateFormat('dd/MM/yyyy', 'en_GB');

  @override
  Widget build(BuildContext context) {
    final rows = DummyPaymentsData.dailyNetByDay(maxDays: 30);
    final totalNet = rows.fold<double>(0, (s, e) => s + e.net);

    return Scaffold(
      backgroundColor: PaxPaymentColors.adminBackground,
      appBar: AppBar(
        title: const Text('Settlements'),
        backgroundColor: PaxPaymentColors.white,
        foregroundColor: PaxPaymentColors.darkGrayText,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _requestPayout(context),
        icon: const Icon(Icons.payments_outlined),
        label: const Text('Request payout'),
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
                  'Net ledger (last 30 days)',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: PaxPaymentColors.mediumGray,
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: PaxPaymentSpacing.sp8),
                Text(
                  _money.format(double.parse(totalNet.toStringAsFixed(2))),
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: PaxPaymentColors.darkGrayText,
                        fontWeight: FontWeight.w800,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(height: PaxPaymentSpacing.sp12),
          Text(
            'By day',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: PaxPaymentSpacing.sp8),
          if (rows.isEmpty)
            Text(
              'No transactions yet.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: PaxPaymentColors.mediumGray,
                  ),
            )
          else
            ...rows.map(
              (p) => Padding(
                padding: const EdgeInsets.only(bottom: PaxPaymentSpacing.sp10),
                child: Container(
                  padding: const EdgeInsets.all(PaxPaymentSpacing.sp14),
                  decoration: BoxDecoration(
                    color: PaxPaymentColors.white,
                    borderRadius: BorderRadius.circular(PaxPaymentSpacing.radiusLg),
                    border:
                        Border.all(color: Colors.black.withValues(alpha: 0.06)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _date.format(p.day),
                              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                            Text(
                              '${p.txnCount} transactions',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: PaxPaymentColors.mediumGray,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        _money.format(double.parse(p.net.toStringAsFixed(2))),
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: p.net >= 0
                                  ? PaxPaymentColors.textGreen
                                  : PaxPaymentColors.errorRed,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          const SizedBox(height: 88),
        ],
      ),
    );
  }

  static Future<void> _requestPayout(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Request payout'),
        content: const Text(
          'Confirm you want to request a payout for the available balance? '
          '(No funds will be moved in this demo.)',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Confirm')),
        ],
      ),
    );
    if (ok == true && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Payout request recorded (demo).')),
      );
    }
  }
}
