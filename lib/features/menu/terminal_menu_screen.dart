import 'package:flutter/material.dart';

import '../../core/database/local_storage.dart';
import '../../core/di/injection.dart';
import '../../shared/theme/paxpayment_colors.dart';
import '../../shared/theme/paxpayment_spacing.dart';
import '../../screens/device_settings_screen.dart';
import '../../screens/payment_settings_screen.dart';
import 'payment_links_screen.dart';
import 'reports_analytics_screen.dart';
import 'settings_screen.dart';
import 'transactions_list_screen.dart';

/// Terminal-style menu shown from the Checkout screen.
class TerminalMenuScreen extends StatelessWidget {
  const TerminalMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PaxPaymentColors.adminBackground,
      appBar: AppBar(
        title: const Text('Menu'),
        backgroundColor: PaxPaymentColors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        foregroundColor: PaxPaymentColors.darkGrayText,
      ),
      body: ListView(
        padding: const EdgeInsets.all(PaxPaymentSpacing.sp16),
        children: [
          _TerminalHeader(),
          const SizedBox(height: PaxPaymentSpacing.sp16),
          _MenuTile(
            title: 'Sales overview',
            subtitle: 'Today’s sales and performance.',
            icon: Icons.bar_chart_rounded,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const ReportsAnalyticsScreen(),
                ),
              );
            },
          ),
          const SizedBox(height: PaxPaymentSpacing.sp10),
          _MenuTile(
            title: 'Transactions & refunds',
            subtitle: 'View payments history and details.',
            icon: Icons.receipt_long_rounded,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const TransactionsListScreen(),
                ),
              );
            },
          ),
          const SizedBox(height: PaxPaymentSpacing.sp10),
          _MenuTile(
            title: 'POS integrations',
            subtitle: 'Payment links and integrations.',
            icon: Icons.qr_code_rounded,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const PaymentLinksScreen(),
                ),
              );
            },
          ),
          const SizedBox(height: PaxPaymentSpacing.sp10),
          _MenuTile(
            title: 'Payment settings',
            subtitle: 'Tips, cash, receipts, and auto-print.',
            icon: Icons.tune_rounded,
            onTap: () => openPaymentSettings(context),
          ),
          const SizedBox(height: PaxPaymentSpacing.sp10),
          _MenuTile(
            title: 'App settings',
            subtitle: 'Password, language, and account.',
            icon: Icons.settings_outlined,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const SettingsScreen(),
                ),
              );
            },
          ),
          const SizedBox(height: PaxPaymentSpacing.sp10),
          _MenuTile(
            title: 'Device settings',
            subtitle: 'Wi‑Fi, printer test, terminal IDs.',
            icon: Icons.settings_suggest_rounded,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const DeviceSettingsScreen(),
                ),
              );
            },
          ),
          const SizedBox(height: PaxPaymentSpacing.sp10),
          _MenuTile(
            title: 'Help',
            subtitle: 'Support details and FAQs.',
            icon: Icons.help_outline_rounded,
            onTap: () {
              showDialog<void>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Help'),
                  content: const Text(
                    'For support, please contact your payment provider or merchant helpdesk.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Close'),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: PaxPaymentSpacing.sp24),
          Center(
            child: Text(
              'POSLink Testing - XePOS',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: PaxPaymentColors.mediumGray,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TerminalHeader extends StatefulWidget {
  const _TerminalHeader();

  @override
  State<_TerminalHeader> createState() => _TerminalHeaderState();
}

class _TerminalHeaderState extends State<_TerminalHeader> {
  late String _terminalName;

  @override
  void initState() {
    super.initState();
    _terminalName = sl<LocalStorage>().terminalName;
  }

  Future<void> _showEditDialog() async {
    final saved = await showDialog<String>(
      context: context,
      builder: (ctx) => _TerminalNameDialog(initialName: _terminalName),
    );

    if (saved == null || !mounted) return;

    await sl<LocalStorage>().setTerminalName(saved);
    setState(() => _terminalName = saved);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Terminal name saved'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(PaxPaymentSpacing.radiusXl);
    return Container(
      padding: const EdgeInsets.all(PaxPaymentSpacing.sp14),
      decoration: BoxDecoration(
        color: PaxPaymentColors.white,
        borderRadius: radius,
        border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _terminalName,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: PaxPaymentColors.darkGrayText,
                      ),
                ),
                const SizedBox(height: PaxPaymentSpacing.sp2),
                Text(
                  'Update the name of your card machine.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: PaxPaymentColors.mediumGray,
                      ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: _showEditDialog,
            icon: const Icon(Icons.edit_outlined),
            color: PaxPaymentColors.primaryBlue,
          ),
        ],
      ),
    );
  }
}

class _TerminalNameDialog extends StatefulWidget {
  const _TerminalNameDialog({required this.initialName});

  final String initialName;

  @override
  State<_TerminalNameDialog> createState() => _TerminalNameDialogState();
}

class _TerminalNameDialogState extends State<_TerminalNameDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialName);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _save() {
    final name = _controller.text.trim();
    if (name.isEmpty) return;
    Navigator.pop(context, name);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Terminal name'),
      content: TextField(
        controller: _controller,
        autofocus: true,
        textCapitalization: TextCapitalization.words,
        decoration: const InputDecoration(
          labelText: 'Name',
          hintText: 'Enter terminal name',
        ),
        onSubmitted: (value) {
          if (value.trim().isNotEmpty) {
            Navigator.pop(context, value.trim());
          }
        },
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _save,
          child: const Text('Save'),
        ),
      ],
    );
  }
}

class _MenuTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const _MenuTile({
    required this.title,
    required this.subtitle,
    required this.icon,
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
                  borderRadius: BorderRadius.circular(PaxPaymentSpacing.radiusLg),
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
              const Icon(
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

