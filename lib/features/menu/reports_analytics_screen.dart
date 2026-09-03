import 'package:dio/dio.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/network/MyApiClient.dart';
import '../../shared/responsive/responsive.dart';
import '../../shared/theme/paxpayment_colors.dart';
import '../../shared/theme/paxpayment_spacing.dart';
import 'models/payment_transaction.dart';
import 'transaction_detail_screen.dart';
import 'widgets/payment_status_badge.dart';

enum _ReportRangePreset { last7, last30, thisMonth }

/// Reports & analytics with charts.
class ReportsAnalyticsScreen extends StatefulWidget {
  const ReportsAnalyticsScreen({super.key});

  @override
  State<ReportsAnalyticsScreen> createState() => _ReportsAnalyticsScreenState();
}

class _ReportsAnalyticsScreenState extends State<ReportsAnalyticsScreen> {
  _ReportRangePreset _preset = _ReportRangePreset.last7;

  List<PaymentTransaction> _transactions = [];
  bool _isLoading = true;
  String? _errorMessage;

  static final _money = NumberFormat.currency(locale: 'en_GB', symbol: '£');
  static final _compact = NumberFormat('#,##0.00');
  static final _axisDay = DateFormat('d MMM');
  static final _dateTime = DateFormat('dd/MM/yyyy HH:mm', 'en_GB');

  static String _formatTransactionTime(String time) {
    final parsed = DateTime.tryParse(time.trim());
    if (parsed != null) {
      return _dateTime.format(parsed.toLocal());
    }
    return time;
  }

  int get _apiDays => 30;

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await MyApiClient.getAllTransactions(
        _apiDays,
        '',
        100,
        '',
      );
      if (!mounted) return;
      setState(() {
        _transactions = response.data
            .map((r) => r.toPaymentTransaction())
            .toList()
          ..sort((a, b) => b.time.compareTo(a.time));
        _isLoading = false;
      });
    } on DioException catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = 'Unable to load sales data. Please try again.';
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = 'Unable to load sales data. Please try again.';
      });
    }
  }

  (DateTime, DateTime) get _range {
    final now = DateTime.now();
    final end = DateTime(now.year, now.month, now.day);
    switch (_preset) {
      case _ReportRangePreset.last7:
        return (end.subtract(const Duration(days: 6)), end);
      case _ReportRangePreset.last30:
        return (end.subtract(const Duration(days: 29)), end);
      case _ReportRangePreset.thisMonth:
        return (DateTime(now.year, now.month, 1), end);
    }
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

    return Scaffold(
      backgroundColor: PaxPaymentColors.adminBackground,
      appBar: AppBar(
        title: const Text('Reports & analytics'),
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
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
                )
              : _buildContent(context, r, pad),
    );
  }

  Widget _buildContent(BuildContext context, Responsive r, double pad) {
    final (start, end) = _range;
    final rangeTransactions = _transactionsInRange(_transactions, start, end);
    final s = _salesSummary(rangeTransactions);
    final daily = _dailyBars(rangeTransactions, start, end);
    final cumulative = _cumulativeSeries(daily);

    final lineSpots = <FlSpot>[
      for (var i = 0; i < cumulative.length; i++)
        FlSpot(i.toDouble(), cumulative[i].$2),
    ];
    // When every day is £0, peak Y is 0 — fl_chart requires horizontalInterval != 0.
    final peakLineY = lineSpots.isEmpty
        ? 0.0
        : lineSpots.map((e) => e.y).reduce((a, b) => a > b ? a : b);
    final maxLineY = peakLineY <= 0 ? 1.0 : peakLineY * 1.08;

    final maxBarRaw = daily.isEmpty
        ? 0.0
        : daily.map((e) => e.$2).reduce((a, b) => a > b ? a : b);
    final maxBarY = maxBarRaw <= 0 ? 1.0 : maxBarRaw * 1.15;
    final barGroups = <BarChartGroupData>[
      for (var i = 0; i < daily.length; i++)
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: daily[i].$2,
              color: PaxPaymentColors.primaryBlue,
              width: daily.length > 14 ? 6 : 10,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(6),
              ),
            ),
          ],
        ),
    ];

    return RefreshIndicator(
      onRefresh: _loadTransactions,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(
          pad,
          PaxPaymentSpacing.sp16,
          pad,
          pad + MediaQuery.paddingOf(context).bottom + 24,
        ),
        children: [
          Text(
            'Date range',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: PaxPaymentColors.mediumGray,
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: PaxPaymentSpacing.sp8),
          Wrap(
            spacing: PaxPaymentSpacing.sp8,
            runSpacing: PaxPaymentSpacing.sp8,
            children: [
              _RangeChip(
                label: 'Last 7 days',
                selected: _preset == _ReportRangePreset.last7,
                onTap: () => setState(() => _preset = _ReportRangePreset.last7),
              ),
              _RangeChip(
                label: 'Last 30 days',
                selected: _preset == _ReportRangePreset.last30,
                onTap: () => setState(() => _preset = _ReportRangePreset.last30),
              ),
              _RangeChip(
                label: 'This month',
                selected: _preset == _ReportRangePreset.thisMonth,
                onTap: () => setState(() => _preset = _ReportRangePreset.thisMonth),
              ),
            ],
          ),
          const SizedBox(height: PaxPaymentSpacing.sp8),
          Text(
            '${_axisDay.format(start)} – ${_axisDay.format(end)}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: PaxPaymentColors.mediumGray,
                ),
          ),
          SizedBox(height: r.value(mobile: PaxPaymentSpacing.sp20, tablet: PaxPaymentSpacing.sp24)),
          Row(
            children: [
              Expanded(
                child: _SummaryCard(
                  label: 'Total sales',
                  value: _money.format(s.total),
                  sub: '${s.count} successful txns',
                ),
              ),
              const SizedBox(width: PaxPaymentSpacing.sp12),
              Expanded(
                child: _SummaryCard(
                  label: 'Avg transaction',
                  value: _money.format(s.avg),
                  sub: 'Per successful payment',
                ),
              ),
            ],
          ),
          SizedBox(height: r.value(mobile: PaxPaymentSpacing.sp20, tablet: PaxPaymentSpacing.sp24)),
          Text(
            'Sales',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: PaxPaymentColors.darkGrayText,
                ),
          ),
          const SizedBox(height: PaxPaymentSpacing.sp4),
          Text(
            rangeTransactions.isEmpty
                ? 'No sales in this range'
                : '${rangeTransactions.length} transaction${rangeTransactions.length == 1 ? '' : 's'}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: PaxPaymentColors.mediumGray,
                ),
          ),
          const SizedBox(height: PaxPaymentSpacing.sp12),
          if (rangeTransactions.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(PaxPaymentSpacing.sp24),
              decoration: BoxDecoration(
                color: PaxPaymentColors.white,
                borderRadius: BorderRadius.circular(PaxPaymentSpacing.radiusXl),
                border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
              ),
              child: Text(
                _transactions.isEmpty
                    ? 'No sales data loaded yet.'
                    : 'No sales in this date range.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: PaxPaymentColors.mediumGray,
                    ),
              ),
            )
          else
            ...[
              for (final tx in rangeTransactions) ...[
                _ReportTransactionTile(
                  tx: tx,
                  money: _money,
                  formattedTime: _formatTransactionTime(tx.time),
                  onTap: () => _openTransactionDetail(context, tx),
                ),
                const SizedBox(height: PaxPaymentSpacing.sp10),
              ],
            ],
          SizedBox(height: r.value(mobile: PaxPaymentSpacing.sp20, tablet: PaxPaymentSpacing.sp24)),
          _ChartCard(
            title: 'Sales trend',
            subtitle: 'Cumulative net volume',
            child: lineSpots.length < 2
                ? SizedBox(
                    height: 200,
                    child: Center(
                      child: Text(
                        'Not enough data in this range.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: PaxPaymentColors.mediumGray,
                            ),
                      ),
                    ),
                  )
                : SizedBox(
                    height: 220,
                    child: LineChart(
                      LineChartData(
                        minX: 0,
                        maxX: (lineSpots.length - 1).toDouble(),
                        minY: 0,
                        maxY: maxLineY,
                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: false,
                          horizontalInterval: (maxLineY / 4).clamp(0.25, double.infinity),
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
                              interval: (maxLineY / 4).clamp(0.25, double.infinity),
                              getTitlesWidget: (v, m) => Text(
                                '£${_compact.format(v)}',
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
                              interval: lineSpots.length > 8 ? 2 : 1,
                              getTitlesWidget: (v, m) {
                                final i = v.round();
                                if (i < 0 || i >= cumulative.length) {
                                  return const SizedBox.shrink();
                                }
                                return Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Text(
                                    _axisDay.format(cumulative[i].$1),
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
                        lineBarsData: [
                          LineChartBarData(
                            spots: lineSpots,
                            isCurved: true,
                            color: PaxPaymentColors.primaryBlue,
                            barWidth: 3,
                            dotData: const FlDotData(show: false),
                            belowBarData: BarAreaData(
                              show: true,
                              color: PaxPaymentColors.primaryBlue
                                  .withValues(alpha: 0.12),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
          ),
          const SizedBox(height: PaxPaymentSpacing.sp16),
          _ChartCard(
            title: 'Daily revenue',
            subtitle: 'Net volume per day',
            child: barGroups.isEmpty
                ? SizedBox(
                    height: 200,
                    child: Center(
                      child: Text(
                        'No data.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: PaxPaymentColors.mediumGray,
                            ),
                      ),
                    ),
                  )
                : SizedBox(
                    height: 240,
                    child: BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        maxY: maxBarY,
                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: false,
                          horizontalInterval: (maxBarY / 4).clamp(0.25, double.infinity),
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
                              interval: (maxBarY / 4).clamp(0.25, double.infinity),
                              getTitlesWidget: (v, m) => Text(
                                '£${_compact.format(v)}',
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
                              interval: daily.length > 12 ? 3 : 1,
                              getTitlesWidget: (v, m) {
                                final i = v.toInt();
                                if (i < 0 || i >= daily.length) {
                                  return const SizedBox.shrink();
                                }
                                return Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Text(
                                    _axisDay.format(daily[i].$1),
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
                        barGroups: barGroups,
                      ),
                    ),
                  ),
          ),
        ],
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

List<PaymentTransaction> _transactionsInRange(
  List<PaymentTransaction> source,
  DateTime start,
  DateTime end,
) {
  final startDay = DateTime(start.year, start.month, start.day);
  final endDay = DateTime(end.year, end.month, end.day);
  return source.where((transaction) {
    final txDate = _calendarDate(transaction.time);
    return !txDate.isBefore(startDay) && !txDate.isAfter(endDay);
  }).toList();
}

DateTime _calendarDate(String time) {
  final trimmed = time.trim();
  if (trimmed.length >= 10 && trimmed[4] == '-' && trimmed[7] == '-') {
    final year = int.tryParse(trimmed.substring(0, 4));
    final month = int.tryParse(trimmed.substring(5, 7));
    final day = int.tryParse(trimmed.substring(8, 10));
    if (year != null && month != null && day != null) {
      return DateTime(year, month, day);
    }
  }
  final parsed = DateTime.tryParse(trimmed);
  if (parsed != null) {
    final local = parsed.toLocal();
    return DateTime(local.year, local.month, local.day);
  }
  return DateTime.fromMillisecondsSinceEpoch(0);
}

({double total, int count, double avg}) _salesSummary(
  List<PaymentTransaction> transactions,
) {
  final successful = transactions
      .where((transaction) => transaction.status == PaymentStatus.success)
      .toList();
  final total = successful.fold<double>(0, (sum, tx) => sum + tx.amount);
  final count = successful.length;
  final avg = count == 0 ? 0.0 : total / count;
  return (total: total, count: count, avg: avg);
}

List<(DateTime day, double amount)> _dailyBars(
  List<PaymentTransaction> transactions,
  DateTime rangeStart,
  DateTime rangeEnd,
) {
  final totals = <DateTime, double>{};
  for (final transaction in transactions) {
    final day = _calendarDate(transaction.time);
    totals[day] = (totals[day] ?? 0) + transaction.amount;
  }

  final start = DateTime(rangeStart.year, rangeStart.month, rangeStart.day);
  final end = DateTime(rangeEnd.year, rangeEnd.month, rangeEnd.day);
  final bars = <(DateTime, double)>[];
  for (var day = start; !day.isAfter(end); day = day.add(const Duration(days: 1))) {
    final key = DateTime(day.year, day.month, day.day);
    bars.add((key, totals[key] ?? 0));
  }
  return bars;
}

List<(DateTime day, double cumulative)> _cumulativeSeries(
  List<(DateTime day, double amount)> daily,
) {
  var runningTotal = 0.0;
  return daily.map((entry) {
    runningTotal += entry.$2;
    return (entry.$1, runningTotal);
  }).toList();
}

class _ReportTransactionTile extends StatelessWidget {
  final PaymentTransaction tx;
  final NumberFormat money;
  final String formattedTime;
  final VoidCallback onTap;

  const _ReportTransactionTile({
    required this.tx,
    required this.money,
    required this.formattedTime,
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
                formattedTime,
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

class _RangeChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _RangeChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected
          ? PaxPaymentColors.primaryBlue.withValues(alpha: 0.12)
          : PaxPaymentColors.white,
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

class _SummaryCard extends StatelessWidget {
  final String label;
  final String value;
  final String sub;

  const _SummaryCard({
    required this.label,
    required this.value,
    required this.sub,
  });

  @override
  Widget build(BuildContext context) {
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
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: PaxPaymentColors.mediumGray,
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: PaxPaymentSpacing.sp8),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: PaxPaymentColors.darkGrayText,
                ),
          ),
          const SizedBox(height: PaxPaymentSpacing.sp4),
          Text(
            sub,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: PaxPaymentColors.mediumGray,
                  height: 1.3,
                ),
          ),
        ],
      ),
    );
  }
}

class _ChartCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;

  const _ChartCard({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
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
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: PaxPaymentColors.darkGrayText,
                ),
          ),
          const SizedBox(height: PaxPaymentSpacing.sp4),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: PaxPaymentColors.mediumGray,
                ),
          ),
          const SizedBox(height: PaxPaymentSpacing.sp12),
          child,
        ],
      ),
    );
  }
}
