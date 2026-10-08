import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../core/di/injection.dart';
import '../../core/database/local_storage.dart';
import '../../core/network/MyApiClient.dart';
import '../../features/auth/data/login_response.dart';
import '../../features/auth/data/password_reset_request.dart';
import '../../shared/resources/paxpayment_strings.dart';
import '../../features/auth/data/settings_model.dart';
import '../../core/security/manager_pin_gate.dart';
import '../../screens/payment_settings_screen.dart';
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
            title: 'Reset password',
            subtitle: 'Choose a new password for your account.',
            icon: Icons.lock_reset_rounded,
            onTap: () => _resetPassword(context),
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

  static Future<void> _resetPassword(BuildContext context) async {
    final storedLogin = sl<LocalStorage>().loginUsername.trim();
    final initialEmail =
        storedLogin.contains('@') ? storedLogin : '';
    await showDialog<void>(
      context: context,
      builder: (ctx) => _ResetPasswordDialog(initialEmail: initialEmail),
    );
  }
}

class _ResetPasswordDialog extends StatefulWidget {
  const _ResetPasswordDialog({this.initialEmail = ''});

  final String initialEmail;

  @override
  State<_ResetPasswordDialog> createState() => _ResetPasswordDialogState();
}

class _ResetPasswordDialogState extends State<_ResetPasswordDialog> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _emailController.text = widget.initialEmail;
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  InputDecoration _fieldDecoration({
    required String label,
    required String hint,
    Widget? suffixIcon,
    IconData prefixIcon = Icons.lock_outline_rounded,
  }) {
    final borderRadius = BorderRadius.circular(PaxPaymentSpacing.radiusLg);
    return InputDecoration(
      labelText: label,
      hintText: hint,
      filled: true,
      fillColor: PaxPaymentColors.white,
      border: OutlineInputBorder(borderRadius: borderRadius),
      enabledBorder: OutlineInputBorder(
        borderRadius: borderRadius,
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: borderRadius,
        borderSide: const BorderSide(
          color: PaxPaymentColors.primaryBlue,
          width: 2,
        ),
      ),
      prefixIcon: Icon(prefixIcon, color: PaxPaymentColors.adminTitle),
      suffixIcon: suffixIcon,
    );
  }

  Future<void> _onSubmit() async {
    FocusScope.of(context).unfocus();
    if (_isSubmitting) return;
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isSubmitting = true);

    final request = PasswordResetRequest(
      email: _emailController.text.trim(),
      token: '',
      password: _passwordController.text,
      passwordConfirmation: _confirmPasswordController.text,
    );

    try {
      final response = await MyApiClient.resetPassword(request);
      if (!mounted) return;

      if (response.errors.trim().isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response.failureMessage)),
        );
        return;
      }

      await sl<LocalStorage>().setLoginPassword(request.password);
      if (!mounted) return;

      final message = response.message.trim().isNotEmpty
          ? response.message.trim()
          : 'Password updated';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
      Navigator.of(context).pop();
    } on DioException catch (e) {
      if (!mounted) return;
      final parsed = LoginResponse.tryParse(e.response?.data);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            parsed?.failureMessage ??
                'Unable to reset password. Please try again.',
          ),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to reset password. Please try again.')),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        'Reset password',
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: PaxPaymentColors.darkGrayText,
            ),
      ),
      content: SingleChildScrollView(
        child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.email],
              enabled: !_isSubmitting,
              style: const TextStyle(fontSize: 13),
              decoration: _fieldDecoration(
                label: PaxPaymentStrings.email,
                hint: PaxPaymentStrings.enterEmail,
                prefixIcon: Icons.email_outlined,
              ).copyWith(
                labelStyle: const TextStyle(fontSize: 12),
                hintStyle: const TextStyle(fontSize: 12),
                floatingLabelStyle: const TextStyle(fontSize: 12),
              ),
              validator: (value) {
                final email = value?.trim() ?? '';
                if (email.isEmpty) return 'Enter your email';
                if (!email.contains('@') || !email.contains('.')) {
                  return 'Enter a valid email address';
                }
                return null;
              },
            ),
            const SizedBox(height: PaxPaymentSpacing.sp12),
            TextFormField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              textInputAction: TextInputAction.next,
              enabled: !_isSubmitting,
              decoration: _fieldDecoration(
                label: 'New password',
                hint: 'Enter new password',
                suffixIcon: IconButton(
                  tooltip: _obscurePassword ? 'Show' : 'Hide',
                  onPressed: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: PaxPaymentColors.mediumGray,
                  ),
                ),
              ),
              validator: (value) {
                final s = value ?? '';
                if (s.isEmpty) return 'Enter a password';
                if (s.length < 6) return 'Password must be at least 6 characters';
                return null;
              },
            ),
            const SizedBox(height: PaxPaymentSpacing.sp12),
            TextFormField(
              controller: _confirmPasswordController,
              obscureText: _obscureConfirm,
              textInputAction: TextInputAction.done,
              enabled: !_isSubmitting,
              onFieldSubmitted: (_) => _onSubmit(),
              decoration: _fieldDecoration(
                label: 'Confirm password',
                hint: 'Re-enter new password',
                suffixIcon: IconButton(
                  tooltip: _obscureConfirm ? 'Show' : 'Hide',
                  onPressed: () =>
                      setState(() => _obscureConfirm = !_obscureConfirm),
                  icon: Icon(
                    _obscureConfirm
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: PaxPaymentColors.mediumGray,
                  ),
                ),
              ),
              validator: (value) {
                final s = value ?? '';
                if (s.isEmpty) return 'Confirm your password';
                if (s != _passwordController.text) {
                  return 'Passwords do not match';
                }
                return null;
              },
            ),
          ],
        ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _isSubmitting ? null : _onSubmit,
          child: _isSubmitting
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text(
                  'Reset password',
                  style: TextStyle(fontSize: 13),
                ),
        ),
      ],
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