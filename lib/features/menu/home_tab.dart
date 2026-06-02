import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../app/app_route_observer.dart';
import '../../shared/responsive/responsive.dart';
import '../../shared/theme/paxpayment_colors.dart';
import '../../shared/theme/paxpayment_spacing.dart';
import 'checkout_payment_screen.dart';
import 'data/dummy_payments_data.dart';
import 'reports_analytics_screen.dart';
import 'settings_screen.dart';
import 'transactions_list_screen.dart';

/// Home dashboard: today’s sales, quick stats, actions.
class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> with RouteAware {
  static final _currency = NumberFormat.currency(locale: 'en_GB', symbol: '£');
  static final _compact = NumberFormat('#,###');

  double _todaySales = 0;
  int _transactionCount = 0;
  double _revenueToday = 0;
  DateTime _lastUpdated = DateTime.now();

  @override
  void initState() {
    super.initState();
    _refreshStats();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route is PageRoute<dynamic>) {
      appRouteObserver.subscribe(this, route);
    }
  }

  @override
  void dispose() {
    appRouteObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() {
    _refreshStats();
    setState(() {});
  }

  void _refreshStats() {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);
    final end = DateTime(now.year, now.month, now.day, 23, 59, 59);
    final summary = DummyPaymentsData.summary(start, end);
    final txs = DummyPaymentsData.inRange(start, end);
    _todaySales = summary.total;
    _revenueToday = summary.total;
    _transactionCount = txs.length;
    _lastUpdated = DateTime.now();
  }

  void _onAction(BuildContext context, String label) {
    if (label == 'Take Payment') {
      Navigator.of(context).push(CheckoutPaymentScreen.materialRoute());
      return;
    }
    if (label == 'View Transactions') {
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => const TransactionsListScreen(),
        ),
      );
      return;
    }
    if (label == 'Reports') {
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => const ReportsAnalyticsScreen(),
        ),
      );
      return;
    }
    if (label == 'Send Payment Link') {
      Navigator.of(context).push(
        CheckoutPaymentScreen.materialRoute(
          initialMethod: CheckoutPaymentMethod.paymentLink,
        ),
      );
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label — coming soon'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final r = Responsive.of(context);
    final pad = r.layout(
      mobilePortrait: PaxPaymentSpacing.sp20,
      mobileLandscape: PaxPaymentSpacing.sp16,
      tabletPortrait: PaxPaymentSpacing.sp28,
      tabletLandscape: PaxPaymentSpacing.sp24,
    );

    final cardRadius = BorderRadius.circular(PaxPaymentSpacing.radiusXl);
    final titleStyle = Theme.of(context).textTheme.titleMedium?.copyWith(
          color: PaxPaymentColors.darkGrayText,
          fontWeight: FontWeight.w600,
        );
    final muted = Theme.of(context).textTheme.bodySmall?.copyWith(
          color: PaxPaymentColors.mediumGray,
        );

    final salesFont = r.layout(
      mobilePortrait: 36.0,
      mobileLandscape: 30.0,
      tabletPortrait: 42.0,
      tabletLandscape: 38.0,
    );

    return ColoredBox(
      color: PaxPaymentColors.adminBackground,
      child: RefreshIndicator(
        color: PaxPaymentColors.primaryBlue,
        onRefresh: () async {
          await DummyPaymentsData.initialize();
          if (!mounted) return;
          setState(_refreshStats);
        },
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.fromLTRB(
            pad,
            pad + MediaQuery.paddingOf(context).top,
            pad,
            pad + PaxPaymentSpacing.sp24,
          ),
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Overview',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: PaxPaymentColors.darkGrayText,
                          letterSpacing: -0.3,
                        ),
                  ),
                ),
                IconButton(
                  tooltip: 'Settings',
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const SettingsScreen(),
                      ),
                    );
                  },
                  icon: const Icon(
                    Icons.settings_outlined,
                    color: PaxPaymentColors.darkGrayText,
                  ),
                ),
              ],
            ),
            const SizedBox(height: PaxPaymentSpacing.sp4),
            Text(
              'Updated ${_timeAgo(_lastUpdated)}',
              style: muted,
            ),
            SizedBox(height: r.value(mobile: PaxPaymentSpacing.sp20, tablet: PaxPaymentSpacing.sp24)),
            _DashboardCard(
              radius: cardRadius,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.payments_outlined,
                        size: 20,
                        color: PaxPaymentColors.adminTitle,
                      ),
                      const SizedBox(width: PaxPaymentSpacing.sp8),
                      Text("Today's sales", style: titleStyle),
                    ],
                  ),
                  const SizedBox(height: PaxPaymentSpacing.sp16),
                  Text(
                    _currency.format(_todaySales),
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: PaxPaymentColors.darkGrayText,
                          fontSize: salesFont,
                          height: 1.05,
                          letterSpacing: -1,
                        ),
                  ),
                  const SizedBox(height: PaxPaymentSpacing.sp8),
                  Text(
                    'Gross volume today',
                    style: muted,
                  ),
                ],
              ),
            ),
            SizedBox(height: r.value(mobile: PaxPaymentSpacing.sp14, tablet: PaxPaymentSpacing.sp16)),
            _DashboardCard(
              radius: cardRadius,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.insights_outlined,
                        size: 20,
                        color: PaxPaymentColors.adminTitle,
                      ),
                      const SizedBox(width: PaxPaymentSpacing.sp8),
                      Text('Quick stats', style: titleStyle),
                    ],
                  ),
                  const SizedBox(height: PaxPaymentSpacing.sp16),
                  LayoutBuilder(
                    builder: (context, c) {
                      final narrow = c.maxWidth < 340;
                      final statTiles = [
                        _StatTile(
                          label: 'Transactions',
                          value: _compact.format(_transactionCount),
                          icon: Icons.receipt_long_outlined,
                        ),
                        _StatTile(
                          label: 'Revenue',
                          value: _currency.format(_revenueToday),
                          icon: Icons.trending_up_rounded,
                        ),
                      ];
                      if (narrow) {
                        return Column(
                          children: [
                            statTiles[0],
                            const SizedBox(height: PaxPaymentSpacing.sp12),
                            statTiles[1],
                          ],
                        );
                      }
                      return Row(
                        children: [
                          Expanded(child: statTiles[0]),
                          const SizedBox(width: PaxPaymentSpacing.sp12),
                          Expanded(child: statTiles[1]),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
            SizedBox(height: r.value(mobile: PaxPaymentSpacing.sp14, tablet: PaxPaymentSpacing.sp16)),
            Text(
              'Actions',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: PaxPaymentColors.darkGrayText,
                  ),
            ),
            const SizedBox(height: PaxPaymentSpacing.sp12),
            _ActionTile(
              icon: Icons.point_of_sale_outlined,
              title: 'Take Payment',
              subtitle: 'Start checkout with amount and method',
              onTap: () => _onAction(context, 'Take Payment'),
            ),
            const SizedBox(height: PaxPaymentSpacing.sp10),
            _ActionTile(
              icon: Icons.list_alt_rounded,
              title: 'View Transactions',
              subtitle: 'Review recent activity',
              onTap: () => _onAction(context, 'View Transactions'),
            ),
            const SizedBox(height: PaxPaymentSpacing.sp10),
            _ActionTile(
              icon: Icons.link_rounded,
              title: 'Send Payment Link',
              subtitle: 'Share a pay-by-link request',
              onTap: () => _onAction(context, 'Send Payment Link'),
            ),
            const SizedBox(height: PaxPaymentSpacing.sp10),
            _ActionTile(
              icon: Icons.assessment_outlined,
              title: 'Reports',
              subtitle: 'Summaries and exports',
              onTap: () => _onAction(context, 'Reports'),
            ),
          ],
        ),
      ),
    );
  }

  static String _timeAgo(DateTime t) {
    final s = DateTime.now().difference(t).inSeconds;
    if (s < 5) return 'just now';
    if (s < 60) return '${s}s ago';
    final m = s ~/ 60;
    if (m < 60) return '${m}m ago';
    return '${m ~/ 60}h ago';
  }
}

class _DashboardCard extends StatelessWidget {
  final BorderRadius radius;
  final Widget child;

  const _DashboardCard({required this.radius, required this.child});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: PaxPaymentColors.white,
      elevation: 0,
      shadowColor: Colors.black12,
      borderRadius: radius,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(PaxPaymentSpacing.sp20),
        decoration: BoxDecoration(
          borderRadius: radius,
          border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
        ),
        child: child,
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _StatTile({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(PaxPaymentSpacing.sp16),
      decoration: BoxDecoration(
        color: PaxPaymentColors.adminBackground,
        borderRadius: BorderRadius.circular(PaxPaymentSpacing.radiusLg),
        border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
      ),
      child: Row(
        children: [
          Icon(icon, color: PaxPaymentColors.primaryBlue, size: 22),
          const SizedBox(width: PaxPaymentSpacing.sp12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: PaxPaymentColors.mediumGray,
                        fontWeight: FontWeight.w500,
                      ),
                ),
                const SizedBox(height: PaxPaymentSpacing.sp4),
                Text(
                  value,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: PaxPaymentColors.darkGrayText,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
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
          padding: const EdgeInsets.symmetric(
            horizontal: PaxPaymentSpacing.sp16,
            vertical: PaxPaymentSpacing.sp14,
          ),
          decoration: BoxDecoration(
            borderRadius: radius,
            border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(PaxPaymentSpacing.sp10),
                decoration: BoxDecoration(
                  color: PaxPaymentColors.lightGray,
                  borderRadius:
                      BorderRadius.circular(PaxPaymentSpacing.radiusLg),
                ),
                child: Icon(icon, color: PaxPaymentColors.darkGrayText),
              ),
              const SizedBox(width: PaxPaymentSpacing.sp14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: PaxPaymentColors.darkGrayText,
                          ),
                    ),
                    const SizedBox(height: PaxPaymentSpacing.sp2),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: PaxPaymentColors.mediumGray,
                          ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: PaxPaymentColors.mediumGray,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
