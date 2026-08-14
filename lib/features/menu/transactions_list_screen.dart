import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/network/MyApiClient.dart';
import '../../shared/responsive/responsive.dart';
import '../../shared/theme/paxpayment_colors.dart';
import '../../shared/theme/paxpayment_spacing.dart';
import 'data/dummy_payments_data.dart';
import 'models/payment_transaction.dart';
import 'transaction_detail_screen.dart';
import 'widgets/payment_status_badge.dart';

/// Payments list loaded from the transactions API.
class TransactionsListScreen extends StatefulWidget {
  const TransactionsListScreen({super.key});

  @override
  State<TransactionsListScreen> createState() => _TransactionsListScreenState();
}

class _TransactionsListScreenState extends State<TransactionsListScreen> {
  PaymentsPeriodFilter _period = PaymentsPeriodFilter.today;
  PaymentsStatusFilter _status = PaymentsStatusFilter.all;
  final _searchCtrl = TextEditingController();

  List<PaymentTransaction> _transactions = [];
  bool _isLoading = true;
  String? _errorMessage;

  static final _money = NumberFormat.currency(locale: 'en_GB', symbol: '£');
  static final _time = DateFormat('HH:mm');
  static final _date = DateFormat('d MMM');

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadTransactions() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await MyApiClient.getAllTransactions();
      if (!mounted) return;
      setState(() {
        _transactions = response.data.map((r) => r.toPaymentTransaction()).toList()
          ..sort((a, b) => b.time.compareTo(a.time));
        _isLoading = false;
      });
    } on DioException catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = 'Unable to load payments. Please try again.';
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = 'Unable to load payments. Please try again.';
      });
    }
  }

  List<PaymentTransaction> get _items {
    var list = DummyPaymentsData.filterList(
      _transactions,
      period: _period,
      status: _status,
    );
    final q = _searchCtrl.text.trim().toLowerCase();
    if (q.isEmpty) return list;
    return list.where((t) => _matchesSearch(t, q)).toList();
  }

  bool _matchesSearch(PaymentTransaction t, String q) {
    if (t.id.toLowerCase().contains(q)) return true;
    final last4 = t.cardLast4?.trim() ?? '';
    if (last4.length >= 4 && last4.toLowerCase().contains(q)) return true;
    final amountStr = t.amount.abs().toStringAsFixed(2);
    if (amountStr.contains(q) || amountStr.replaceAll('.', '').contains(q)) {
      return true;
    }
    final formatted = _money.format(t.amount.abs()).toLowerCase();
    if (formatted.contains(q)) return true;
    return false;
  }

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
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: _isLoading ? null : _loadTransactions,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
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
                TextField(
                  controller: _searchCtrl,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: 'Search ref, last 4, or amount',
                    prefixIcon: const Icon(Icons.search_rounded),
                    suffixIcon: _searchCtrl.text.isEmpty
                        ? null
                        : IconButton(
                            icon: const Icon(Icons.clear_rounded),
                            onPressed: () {
                              _searchCtrl.clear();
                              setState(() {});
                            },
                          ),
                    filled: true,
                    fillColor: PaxPaymentColors.adminBackground,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: PaxPaymentSpacing.sp10),
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
            child: _buildBody(
              context,
              items: items,
              pad: pad,
              bottomInset: bottomInset,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(
    BuildContext context, {
    required List<PaymentTransaction> items,
    required double pad,
    required double bottomInset,
  }) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(pad),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: PaxPaymentColors.mediumGray,
                    ),
              ),
              const SizedBox(height: PaxPaymentSpacing.sp16),
              FilledButton(
                onPressed: _loadTransactions,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (items.isEmpty) {
      return Center(
        child: Text(
          'No payments in this range.',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: PaxPaymentColors.mediumGray,
              ),
        ),
      );
    }

    final contentPadding = EdgeInsets.fromLTRB(
      pad,
      PaxPaymentSpacing.sp16,
      pad,
      pad + bottomInset + 72,
    );

    return RefreshIndicator(
      onRefresh: _loadTransactions,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: contentPadding,
        itemCount: items.length,
        separatorBuilder: (context, index) =>
            const SizedBox(height: PaxPaymentSpacing.sp10),
        itemBuilder: (context, i) {
          final tx = items[i];
          return _PaymentGridTile(
            tx: tx,
            money: _money,
            dateFmt: _date,
            timeFmt: _time,
            onTap: () => _openTransactionDetail(context, tx),
          );
        },
      ),
    );
  }

  void _openTransactionDetail(BuildContext context, PaymentTransaction tx) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => TransactionDetailScreen(transaction: tx),
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

class _PaymentGridTile extends StatelessWidget {
  final PaymentTransaction tx;
  final NumberFormat money;
  final DateFormat dateFmt;
  final DateFormat timeFmt;
  final VoidCallback onTap;

  const _PaymentGridTile({
    required this.tx,
    required this.money,
    required this.dateFmt,
    required this.timeFmt,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(PaxPaymentSpacing.radiusLg);
    return Material(
      color: PaxPaymentColors.white,
      borderRadius: radius,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: Container(
          padding: const EdgeInsets.all(PaxPaymentSpacing.sp12),
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
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: PaxPaymentColors.darkGrayText,
                          ),
                    ),
                  ),
                  PaymentStatusBadge(
                    status: tx.status,
                    compact: true,
                    isRefund: tx.isRefund,
                    isRefunded: tx.isRefunded,
                  ),
                ],
              ),
              const SizedBox(height: PaxPaymentSpacing.sp10),
              Text(
                tx.customerName,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
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
