import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../shared/responsive/responsive.dart';
import '../../shared/theme/paxpayment_colors.dart';
import '../../shared/theme/paxpayment_spacing.dart';
import 'data/dummy_payments_data.dart';
import 'models/payment_transaction.dart';
import 'transaction_detail_screen.dart';
import 'widgets/payment_status_badge.dart';

/// Payments list with period + status filters (dummy data).
class TransactionsListScreen extends StatefulWidget {
  const TransactionsListScreen({super.key});

  @override
  State<TransactionsListScreen> createState() => _TransactionsListScreenState();
}

class _TransactionsListScreenState extends State<TransactionsListScreen> {
  PaymentsPeriodFilter _period = PaymentsPeriodFilter.week;
  PaymentsStatusFilter _status = PaymentsStatusFilter.all;

  static final _money = NumberFormat.currency(locale: 'en_GB', symbol: '£');
  static final _time = DateFormat('HH:mm');
  static final _date = DateFormat('d MMM');

  List<PaymentTransaction> get _items => DummyPaymentsData.filtered(
        period: _period,
        status: _status,
      );

  @override
  Widget build(BuildContext context) {
    final r = Responsive.of(context);
    final pad = r.layout(
      mobilePortrait: PaxPaymentSpacing.sp16,
      mobileLandscape: PaxPaymentSpacing.sp16,
      tabletPortrait: PaxPaymentSpacing.sp24,
      tabletLandscape: PaxPaymentSpacing.sp24,
    );
    final items = _items;
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Scaffold(
      backgroundColor: PaxPaymentColors.adminBackground,
      appBar: AppBar(
        title: const Text('Payments'),
        backgroundColor: PaxPaymentColors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        foregroundColor: PaxPaymentColors.darkGrayText,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            color: PaxPaymentColors.white,
            padding: EdgeInsets.fromLTRB(pad, 0, pad, PaxPaymentSpacing.sp12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Filters',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: PaxPaymentColors.mediumGray,
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: PaxPaymentSpacing.sp8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _PeriodChip(
                        label: 'Today',
                        selected: _period == PaymentsPeriodFilter.today,
                        onTap: () => setState(
                          () => _period = PaymentsPeriodFilter.today,
                        ),
                      ),
                      const SizedBox(width: PaxPaymentSpacing.sp8),
                      _PeriodChip(
                        label: 'Week',
                        selected: _period == PaymentsPeriodFilter.week,
                        onTap: () => setState(
                          () => _period = PaymentsPeriodFilter.week,
                        ),
                      ),
                      const SizedBox(width: PaxPaymentSpacing.sp8),
                      _PeriodChip(
                        label: 'Month',
                        selected: _period == PaymentsPeriodFilter.month,
                        onTap: () => setState(
                          () => _period = PaymentsPeriodFilter.month,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: PaxPaymentSpacing.sp10),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _StatusChip(
                        label: 'All',
                        selected: _status == PaymentsStatusFilter.all,
                        onTap: () => setState(
                          () => _status = PaymentsStatusFilter.all,
                        ),
                      ),
                      const SizedBox(width: PaxPaymentSpacing.sp8),
                      _StatusChip(
                        label: 'Success',
                        selected: _status == PaymentsStatusFilter.success,
                        onTap: () => setState(
                          () => _status = PaymentsStatusFilter.success,
                        ),
                      ),
                      const SizedBox(width: PaxPaymentSpacing.sp8),
                      _StatusChip(
                        label: 'Failed',
                        selected: _status == PaymentsStatusFilter.failed,
                        onTap: () => setState(
                          () => _status = PaymentsStatusFilter.failed,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: items.isEmpty
                ? Center(
                    child: Text(
                      'No payments in this range.',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: PaxPaymentColors.mediumGray,
                          ),
                    ),
                  )
                : ListView.separated(
                    padding: EdgeInsets.fromLTRB(
                      pad,
                      PaxPaymentSpacing.sp16,
                      pad,
                      pad + bottomInset + 72,
                    ),
                    itemCount: items.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: PaxPaymentSpacing.sp10),
                    itemBuilder: (context, i) {
                      final tx = items[i];
                      return _PaymentCard(
                        tx: tx,
                        money: _money,
                        timeFmt: _time,
                        dateFmt: _date,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) =>
                                  TransactionDetailScreen(transaction: tx),
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _PeriodChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _PeriodChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected
          ? PaxPaymentColors.primaryBlue.withValues(alpha: 0.12)
          : PaxPaymentColors.adminBackground,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: PaxPaymentSpacing.sp16,
            vertical: PaxPaymentSpacing.sp10,
          ),
          child: Text(
            label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: selected
                      ? PaxPaymentColors.primaryBlue
                      : PaxPaymentColors.darkGrayText,
                ),
          ),
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _StatusChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? PaxPaymentColors.darkGrayText : PaxPaymentColors.white,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: PaxPaymentSpacing.sp14,
            vertical: PaxPaymentSpacing.sp8,
          ),
          child: Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: selected ? Colors.white : PaxPaymentColors.darkGrayText,
                ),
          ),
        ),
      ),
    );
  }
}

class _PaymentCard extends StatelessWidget {
  final PaymentTransaction tx;
  final NumberFormat money;
  final DateFormat timeFmt;
  final DateFormat dateFmt;
  final VoidCallback onTap;

  const _PaymentCard({
    required this.tx,
    required this.money,
    required this.timeFmt,
    required this.dateFmt,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(PaxPaymentSpacing.radiusXl);
    return Material(
      color: PaxPaymentColors.white,
      borderRadius: radius,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: Container(
          padding: const EdgeInsets.all(PaxPaymentSpacing.sp16),
          decoration: BoxDecoration(
            borderRadius: radius,
            border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      money.format(tx.amount),
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: PaxPaymentColors.darkGrayText,
                          ),
                    ),
                  ),
                  PaymentStatusBadge(
                    status: tx.status,
                    compact: true,
                    isRefund: tx.isRefund,
                  ),
                ],
              ),
              const SizedBox(height: PaxPaymentSpacing.sp10),
              Text(
                tx.customerName,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: PaxPaymentColors.darkGrayText,
                    ),
              ),
              const SizedBox(height: PaxPaymentSpacing.sp4),
              Text(
                '${dateFmt.format(tx.time)} · ${timeFmt.format(tx.time)}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: PaxPaymentColors.mediumGray,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
