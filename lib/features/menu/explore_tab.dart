import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../core/network/MyApiClient.dart';
import '../../features/auth/login_screen.dart';
import '../../shared/theme/paxpayment_colors.dart';
import '../../shared/theme/paxpayment_spacing.dart';
import 'account_details_screen.dart';
import 'payment_links_screen.dart';
import 'reports_analytics_screen.dart';
import 'settings_screen.dart';
import 'settlements_screen.dart';
import 'transactions_list_screen.dart';

class ExploreTab extends StatelessWidget {
  const ExploreTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: PaxPaymentColors.adminBackground,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 22, 16, 20),
        children: [
          _sectionTitle(context, 'Sales'),
          _tile(
            context,
            icon: Icons.insights_outlined,
            title: 'Sales Insights',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const ReportsAnalyticsScreen(),
              ),
            ),
          ),
          _tile(
            context,
            icon: Icons.receipt_long_outlined,
            title: 'Transactions',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const TransactionsListScreen(),
              ),
            ),
          ),
          _tile(
            context,
            icon: Icons.link_rounded,
            title: 'Payment Links',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const PaymentLinksScreen(),
              ),
            ),
          ),
          const SizedBox(height: PaxPaymentSpacing.sp14),
          _sectionTitle(context, 'Account & Settlements'),
          _tile(
            context,
            icon: Icons.person_outline_rounded,
            title: 'Account Details',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const AccountDetailsScreen(),
              ),
            ),
          ),
          _tile(
            context,
            icon: Icons.account_balance_wallet_outlined,
            title: 'Settlements',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const SettlementsScreen(),
              ),
            ),
          ),
          _tile(
            context,
            icon: Icons.assessment_outlined,
            title: 'Reports',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const ReportsAnalyticsScreen(),
              ),
            ),
          ),
          const SizedBox(height: PaxPaymentSpacing.sp14),
          _sectionTitle(context, 'Settings'),
          _tile(
            context,
            icon: Icons.badge_outlined,
            title: 'Profile',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const SettingsScreen(),
              ),
            ),
          ),
          _tile(
            context,
            icon: Icons.info_outline_rounded,
            title: 'Device info',
            onTap: () => _showDeviceInfo(context),
          ),
          _tile(
            context,
            icon: Icons.logout_rounded,
            title: 'Logout',
            onTap: () => _logout(context),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: PaxPaymentSpacing.sp8),
      child: Text(
        text,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: PaxPaymentColors.darkGrayText,
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }

  Widget _tile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    final radius = BorderRadius.circular(PaxPaymentSpacing.radiusLg);
    return Padding(
      padding: const EdgeInsets.only(bottom: PaxPaymentSpacing.sp10),
      child: Material(
        color: PaxPaymentColors.white,
        borderRadius: radius,
        child: InkWell(
          onTap: onTap,
          borderRadius: radius,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: PaxPaymentSpacing.sp14,
              vertical: PaxPaymentSpacing.sp12,
            ),
            decoration: BoxDecoration(
              borderRadius: radius,
              border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
            ),
            child: Row(
              children: [
                Icon(icon, color: PaxPaymentColors.primaryBlue),
                const SizedBox(width: PaxPaymentSpacing.sp12),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: PaxPaymentColors.darkGrayText,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: PaxPaymentColors.mediumGray,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showDeviceInfo(BuildContext context) async {
    final platform = defaultTargetPlatform.name.toUpperCase();
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Device info'),
        content: Text('Platform: $platform\nMode: Demo'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<void> _logout(BuildContext context) async {
    final yes = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Log out'),
        content: const Text('Return to the login screen?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Log out'),
          ),
        ],
      ),
    );
    if (yes == true && context.mounted) {
      await MyApiClient.clearAuthToken();
      if (!context.mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute<void>(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }
}
