import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../core/di/injection.dart';
import '../../core/database/local_storage.dart';
import '../../core/network/MyApiClient.dart';
import '../../features/auth/data/settings_model.dart';
import '../../core/security/manager_pin_gate.dart';
import '../../screens/payment_settings_screen.dart';
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
            title: 'Change manager PIN',
            subtitle: 'PIN used for sensitive terminal actions.',
            icon: Icons.pin_outlined,
            onTap: () => _changeManagerPin(context),
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

  static void _goToPaymentScreen(BuildContext context) {
    Navigator.of(context).push(
      CheckoutPaymentScreen.materialRoute(),
    );
  }

  static Future<void> _changeManagerPin(BuildContext context) async {
    final currentPin = await promptManagerPinKeypad(
      context,
      title: 'Change manager PIN',
      reason: 'Enter your current manager PIN.',
      confirmLabel: 'Continue',
    );
    if (currentPin == null || !context.mounted) return;

    try {
      final settings = await MyApiClient.getSettings();
      final storedPin = settings.settings?.managerPin?.trim() ?? '';
      if (storedPin.isEmpty || storedPin != currentPin) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Current PIN incorrect')),
          );
        }
        return;
      }

      final newPin = await promptManagerPinKeypad(
        context,
        title: 'New manager PIN',
        reason: 'Enter a new PIN (4–6 digits).',
        confirmLabel: 'Save',
      );
      if (newPin == null || !context.mounted) return;

      if (newPin.length < managerPinMinLength ||
          newPin.length > managerPinMaxLength) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('PIN must be 4–6 digits')),
        );
        return;
      }

      await MyApiClient.saveSettings(
        SettingsModel(
          tipEnabled: settings.settings?.tipEnabled ?? false,
          cashPaymentEnabled: settings.settings?.cashPaymentEnabled ?? false,
          managerPin: newPin,
        ),
      );
      await sl<LocalStorage>().setManagerPin(newPin);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Manager PIN updated')),
      );
    } on DioException catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.message?.trim().isNotEmpty == true
                ? e.message!.trim()
                : 'Failed to save manager PIN',
          ),
        ),
      );
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to save manager PIN')),
      );
    }
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