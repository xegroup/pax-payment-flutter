import 'package:flutter/material.dart';

import '../../core/di/injection.dart';
import '../../core/database/local_storage.dart';
import '../../core/security/manager_pin_gate.dart';
import '../../features/admin/admin_screen.dart';
import '../../screens/payment_settings_screen.dart';
import '../../main.dart';
import 'data/dummy_payments_data.dart';
import '../../shared/theme/paxpayment_colors.dart';
import '../../shared/theme/paxpayment_spacing.dart';
import 'checkout_payment_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PaxPaymentColors.adminBackground,
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: PaxPaymentColors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        foregroundColor: PaxPaymentColors.darkGrayText,
      ),
      body: ListView(
        padding: const EdgeInsets.all(PaxPaymentSpacing.sp16),
        children: [
          _SectionCard(
            title: 'Language',
            subtitle: 'App display language (${appLocalizationService.currentLocale})',
            icon: Icons.language_outlined,
            onTap: () => _pickLanguage(context),
          ),
          const SizedBox(height: PaxPaymentSpacing.sp10),
          _SectionCard(
            title: 'Change password',
            subtitle: 'Update login password for this device.',
            icon: Icons.password_outlined,
            onTap: () => _changePassword(context),
          ),
          const SizedBox(height: PaxPaymentSpacing.sp10),
          _SectionCard(
            title: 'Change manager PIN',
            subtitle: 'PIN used for sensitive terminal actions.',
            icon: Icons.pin_outlined,
            onTap: () => _changeManagerPin(context),
          ),
          const SizedBox(height: PaxPaymentSpacing.sp10),
          _SectionCard(
            title: 'Admin',
            subtitle: 'Merchant administration tools.',
            icon: Icons.admin_panel_settings_outlined,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => const AdminScreen()),
              );
            },
          ),
          const SizedBox(height: PaxPaymentSpacing.sp10),
          _SectionCard(
            title: 'Profile',
            subtitle: 'Name, email, and account preferences.',
            icon: Icons.person_outline_rounded,
            onTap: () => _showComingSoon(context, 'Profile'),
          ),
          const SizedBox(height: PaxPaymentSpacing.sp10),
          _SectionCard(
            title: 'Business info',
            subtitle: 'Store details, VAT, and merchant profile.',
            icon: Icons.storefront_outlined,
            onTap: () => _showComingSoon(context, 'Business info'),
          ),
          const SizedBox(height: PaxPaymentSpacing.sp10),
          _SectionCard(
            title: 'Payment settings',
            subtitle: 'Tips, cash, receipts, and auto-print.',
            icon: Icons.tune_rounded,
            onTap: () => openPaymentSettings(context),
          ),
          const SizedBox(height: PaxPaymentSpacing.sp10),
          _SectionCard(
            title: 'Reset transactions',
            subtitle: 'Clears saved payment records from this device.',
            icon: Icons.delete_outline_rounded,
            onTap: () => _resetTransactions(context),
          ),
          const SizedBox(height: PaxPaymentSpacing.sp16),
          FilledButton.tonalIcon(
            onPressed: () => _goToPaymentScreen(context),
            style: FilledButton.styleFrom(
              backgroundColor: PaxPaymentColors.primaryBlue.withValues(alpha: 0.10),
              foregroundColor: PaxPaymentColors.primaryBlue,
              minimumSize: const Size.fromHeight(48),
            ),
            icon: const Icon(Icons.point_of_sale_outlined),
            label: const Text('Take payment'),
          ),
        ],
      ),
    );
  }

  static void _showComingSoon(BuildContext context, String label) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label — coming soon'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  static void _goToPaymentScreen(BuildContext context) {
    Navigator.of(context).push(
      CheckoutPaymentScreen.materialRoute(),
    );
  }

  static Future<void> _changePassword(BuildContext context) async {
    final storage = sl<LocalStorage>();
    final currentCtrl = TextEditingController();
    final nextCtrl = TextEditingController();
    final confirmCtrl = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Change password'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: currentCtrl,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Current password'),
              ),
              TextField(
                controller: nextCtrl,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'New password'),
              ),
              TextField(
                controller: confirmCtrl,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Confirm new password'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(
            onPressed: () async {
              final valid = await storage.verifyLoginPassword(
                currentCtrl.text.trim(),
              );
              if (!valid) {
                if (ctx.mounted) {
                  ScaffoldMessenger.of(ctx).showSnackBar(
                    const SnackBar(content: Text('Current password incorrect')),
                  );
                }
                return;
              }
              if (nextCtrl.text.isEmpty || nextCtrl.text != confirmCtrl.text) {
                if (ctx.mounted) {
                  ScaffoldMessenger.of(ctx).showSnackBar(
                    const SnackBar(content: Text('New passwords do not match')),
                  );
                }
                return;
              }
              if (ctx.mounted) Navigator.pop(ctx, true);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (ok == true) {
      final newPass = nextCtrl.text.trim();
      await storage.setLoginPassword(newPass);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password updated')),
        );
      }
    }
    currentCtrl.dispose();
    nextCtrl.dispose();
    confirmCtrl.dispose();
  }

  static Future<void> _changeManagerPin(BuildContext context) async {
    final storage = sl<LocalStorage>();
    final currentCtrl = TextEditingController();
    final nextCtrl = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Change manager PIN'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: currentCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Current PIN'),
            ),
            TextField(
              controller: nextCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'New PIN (4 digits)'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(
            onPressed: () async {
              final valid = await storage.verifyManagerPin(
                currentCtrl.text.trim(),
              );
              if (!valid) {
                if (ctx.mounted) {
                  ScaffoldMessenger.of(ctx).showSnackBar(
                    const SnackBar(content: Text('Current PIN incorrect')),
                  );
                }
                return;
              }
              if (nextCtrl.text.trim().length < 4) {
                if (ctx.mounted) {
                  ScaffoldMessenger.of(ctx).showSnackBar(
                    const SnackBar(
                      content: Text('PIN must be at least 4 digits'),
                    ),
                  );
                }
                return;
              }
              if (ctx.mounted) Navigator.pop(ctx, true);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (ok == true) {
      final newPin = nextCtrl.text.trim();
      await storage.setManagerPin(newPin);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Manager PIN updated')),
        );
      }
    }
    currentCtrl.dispose();
    nextCtrl.dispose();
  }

  static Future<void> _resetTransactions(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reset transactions'),
        content: const Text(
          'This will delete all saved payment records on this device. '
          'Only do this if you want to remove demo or old test data.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Reset'),
          ),
        ],
      ),
    );

    if (ok != true || !context.mounted) return;

    final pinOk = await verifyManagerPin(
      context,
      reason: 'Manager PIN is required to reset transactions.',
    );
    if (!pinOk || !context.mounted) return;

    await DummyPaymentsData.clearAll();
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Transactions cleared'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  static Future<void> _pickLanguage(BuildContext context) async {
    final picked = await showDialog<Locale>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: const Text('Language'),
        children: [
          for (final l in appLocalizationService.supportedLocales)
            SimpleDialogOption(
              onPressed: () => Navigator.pop(ctx, l),
              child: Text('${l.languageCode}_${l.countryCode}'),
            ),
        ],
      ),
    );
    if (picked != null) {
      appLocalizationService.setLocale(picked);
    }
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const _SectionCard({
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