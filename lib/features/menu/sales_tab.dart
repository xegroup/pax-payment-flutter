import 'dart:async';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/di/injection.dart';
import '../../core/database/local_storage.dart';
import '../../shared/responsive/responsive.dart';
import '../../shared/theme/paxpayment_colors.dart';
import '../../shared/theme/paxpayment_spacing.dart';
import 'checkout_payment_screen.dart';
import 'data/dummy_payments_data.dart';
import 'settlements_screen.dart';
import 'settings_screen.dart';
import 'transactions_list_screen.dart';

class SalesTab extends StatefulWidget {
  const SalesTab({super.key});

  @override
  State<SalesTab> createState() => _SalesTabState();
}

class _SalesTabState extends State<SalesTab> {
  PaymentsPeriodFilter _period = PaymentsPeriodFilter.today;
  String _store = '2Burger Bar';
  String _allStores = 'All stores';

  final _stores = const ['2Burger Bar', 'City Diner', 'Pax Cafe'];
  final _storeFilters = const ['All stores', 'London', 'Birmingham', 'Manchester'];

  Timer? _timer;

  double _salesAmount = 0;
  int _transactionCount = 0;
  double _changeVsYesterday = 0;

  static final _money = NumberFormat.currency(locale: 'en_GB', symbol: '£');
  static final _axisDay = DateFormat('d MMM');

  @override
  void initState() {
    super.initState();
    _store = sl<LocalStorage>().currentStore;
    if (!_stores.contains(_store)) {
      _store = _stores.first;
    }
    _recalculateStats();
    _timer = Timer.periodic(const Duration(seconds: 6), (_) {
      if (!mounted) return;
      setState(_recalculateStats);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _recalculateStats() {
    final now = DateTime.now();
    final start = switch (_period) {
      PaymentsPeriodFilter.today => DateTime(now.year, now.month, now.day),
      PaymentsPeriodFilter.week => now.subtract(const Duration(days: 7)),
      PaymentsPeriodFilter.month => now.subtract(const Duration(days: 30)),
    };
    final end = DateTime(now.year, now.month, now.day);

    final summary = DummyPaymentsData.summary(start, end, storeFilter: _store);
    _salesAmount = summary.total;
    _transactionCount =
        DummyPaymentsData.inRange(start, end, storeFilter: _store).length;

    final yStart = DateTime(now.year, now.month, now.day).subtract(
      const Duration(days: 1),
    );
    final ySummary = DummyPaymentsData.summary(yStart, yStart, storeFilter: _store);
    final base = ySummary.total <= 0 ? 1 : ySummary.total;
    _changeVsYesterday = ((_salesAmount - ySummary.total) / base) * 100;
  }

  @override
  Widget build(BuildContext context) {
    final r = Responsive.of(context);
    final pad = r.value(mobile: PaxPaymentSpacing.sp16, tablet: PaxPaymentSpacing.sp24);

    final chartData = _buildChartData();
    final maxY = chartData.isEmpty
        ? 1.0
        : chartData.map((e) => e.$2).reduce((a, b) => a > b ? a : b) * 1.15;

    return ColoredBox(
      color: PaxPaymentColors.adminBackground,
      child: ListView(
        padding: EdgeInsets.fromLTRB(
          pad,
          MediaQuery.paddingOf(context).top + pad,
          pad,
          pad + 18,
        ),
        children: [
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: PaxPaymentColors.white,
                    borderRadius: BorderRadius.circular(PaxPaymentSpacing.radiusLg),
                    border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _store,
                      isExpanded: true,
                      icon: const Icon(Icons.keyboard_arrow_down_rounded),
                      items: _stores
                          .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                          .toList(),
                      onChanged: (v) async {
                        if (v == null) return;
                        setState(() => _store = v);
                        await sl<LocalStorage>().setCurrentStore(v);
                        _recalculateStats();
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(width: PaxPaymentSpacing.sp10),
              IconButton.filledTonal(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(builder: (_) => const SettingsScreen()),
                  );
                },
                icon: const Icon(Icons.settings_outlined),
              ),
            ],
          ),
          const SizedBox(height: PaxPaymentSpacing.sp12),
          Row(
            children: [
              Expanded(
                child: _periodFilterRow(),
              ),
              const SizedBox(width: PaxPaymentSpacing.sp10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: PaxPaymentColors.white,
                  borderRadius: BorderRadius.circular(PaxPaymentSpacing.radiusLg),
                  border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _allStores,
                    icon: const Icon(Icons.keyboard_arrow_down_rounded),
                    items: _storeFilters
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (v) {
                      if (v == null) return;
                      setState(() => _allStores = v);
                    },
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: PaxPaymentSpacing.sp12),
          _statsCard(context),
          const SizedBox(height: PaxPaymentSpacing.sp12),
          Text(
            'Quick actions',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: PaxPaymentColors.darkGrayText,
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: PaxPaymentSpacing.sp8),
          _actionsRow(context),
          const SizedBox(height: PaxPaymentSpacing.sp14),
          _chartCard(context, chartData, maxY),
        ],
      ),
    );
  }

  Widget _periodFilterRow() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _chip('Today', _period == PaymentsPeriodFilter.today, () {
            setState(() {
              _period = PaymentsPeriodFilter.today;
              _recalculateStats();
            });
          }),
          const SizedBox(width: PaxPaymentSpacing.sp8),
          _chip('Week', _period == PaymentsPeriodFilter.week, () {
            setState(() {
              _period = PaymentsPeriodFilter.week;
              _recalculateStats();
            });
          }),
          const SizedBox(width: PaxPaymentSpacing.sp8),
          _chip('Month', _period == PaymentsPeriodFilter.month, () {
            setState(() {
              _period = PaymentsPeriodFilter.month;
              _recalculateStats();
            });
          }),
        ],
      ),
    );
  }

  Widget _chip(String label, bool selected, VoidCallback onTap) {
    return Material(
      color: selected
          ? PaxPaymentColors.primaryBlue.withValues(alpha: 0.12)
          : PaxPaymentColors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Text(
            label,
            style: TextStyle(
              color: selected
                  ? PaxPaymentColors.primaryBlue
                  : PaxPaymentColors.darkGrayText,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }

  Widget _statsCard(BuildContext context) {
    final isPositive = _changeVsYesterday >= 0;
    final changeColor =
        isPositive ? PaxPaymentColors.textGreen : PaxPaymentColors.errorRed;
    final changeSign = isPositive ? '+' : '';

    return Container(
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
            _money.format(_salesAmount),
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: PaxPaymentColors.darkGrayText,
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: PaxPaymentSpacing.sp6),
          Text(
            'Sales amount',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: PaxPaymentColors.mediumGray,
                ),
          ),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Transactions: $_transactionCount',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: PaxPaymentColors.darkGrayText,
                      fontWeight: FontWeight.w700,
                    ),
              ),
              Text(
                '$changeSign${_changeVsYesterday.toStringAsFixed(1)}% vs yesterday',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: changeColor,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _actionsRow(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _actionButton(
            context,
            title: 'Sell',
            icon: Icons.point_of_sale_outlined,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const CheckoutPaymentScreen(),
                ),
              );
            },
          ),
        ),
        const SizedBox(width: PaxPaymentSpacing.sp8),
        Expanded(
          child: _actionButton(
            context,
            title: 'Transactions',
            icon: Icons.receipt_long_outlined,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const TransactionsListScreen(),
                ),
              );
            },
          ),
        ),
        const SizedBox(width: PaxPaymentSpacing.sp8),
        Expanded(
          child: _actionButton(
            context,
            title: 'Settlements',
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
      ],
    );
  }

  Widget _actionButton(
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

  Widget _chartCard(
    BuildContext context,
    List<(String, double)> chartData,
    double maxY,
  ) {
    final groups = <BarChartGroupData>[
      for (var i = 0; i < chartData.length; i++)
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: chartData[i].$2,
              color: PaxPaymentColors.primaryBlue,
              width: chartData.length > 10 ? 8 : 12,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
            ),
          ],
        ),
    ];

    return Container(
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
            'Sales insights',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: PaxPaymentColors.darkGrayText,
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: PaxPaymentSpacing.sp4),
          Text(
            'Sales chart based on recorded terminal transactions',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: PaxPaymentColors.mediumGray,
                ),
          ),
          const SizedBox(height: PaxPaymentSpacing.sp12),
          SizedBox(
            height: 220,
            child: BarChart(
              BarChartData(
                maxY: maxY <= 0 ? 1 : maxY,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: (maxY <= 0 ? 1 : maxY) / 4,
                  getDrawingHorizontalLine: (v) => FlLine(
                    color: Colors.black.withValues(alpha: 0.06),
                    strokeWidth: 1,
                  ),
                ),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 44,
                      getTitlesWidget: (v, m) => Text(
                        '£${v.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 10,
                          color: PaxPaymentColors.mediumGray,
                        ),
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (v, m) {
                        final i = v.toInt();
                        if (i < 0 || i >= chartData.length) {
                          return const SizedBox.shrink();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            chartData[i].$1,
                            style: const TextStyle(
                              fontSize: 10,
                              color: PaxPaymentColors.mediumGray,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                barGroups: groups,
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<(String, double)> _buildChartData() {
    final now = DateTime.now();
    if (_period == PaymentsPeriodFilter.today) {
      final start = DateTime(now.year, now.month, now.day);
      final end = DateTime(now.year, now.month, now.day, 23, 59, 59);
      final tx = DummyPaymentsData.inRange(start, end, storeFilter: _store);
      final buckets = <int, double>{for (var h = 8; h <= 20; h++) h: 0};
      for (final t in tx) {
        if (buckets.containsKey(t.time.hour)) {
          buckets[t.time.hour] = (buckets[t.time.hour] ?? 0) + t.amount;
        }
      }
      return buckets.entries
          .map((e) => ('${e.key}', e.value))
          .toList(growable: false);
    }

    final start = _period == PaymentsPeriodFilter.week
        ? now.subtract(const Duration(days: 6))
        : now.subtract(const Duration(days: 29));
    final bars = DummyPaymentsData.dailyBars(start, now, storeFilter: _store);
    final step = _period == PaymentsPeriodFilter.week ? 1 : 4;
    return [
      for (var i = 0; i < bars.length; i += step)
        (_axisDay.format(bars[i].$1), bars[i].$2),
    ];
  }
}
