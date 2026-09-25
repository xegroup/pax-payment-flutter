import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../shared/theme/paxpayment_colors.dart';
import '../../shared/theme/paxpayment_spacing.dart';
import '../../shared/widgets/pos_keypay_panel.dart';
import '../di/injection.dart';
import '../database/local_storage.dart';

const int managerPinMinLength = 4;
const int managerPinMaxLength = 6;

/// Shows manager PIN dialog; returns true when PIN matches.
Future<bool> verifyManagerPin(BuildContext context, {String? reason}) async {
  final ok = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => _ManagerPinKeypadDialog(
      title: 'Manager PIN required',
      reason: reason,
      confirmLabel: 'Confirm',
      verifyBeforeClose: true,
    ),
  );
  return ok == true;
}

/// Keypad PIN entry; returns entered PIN or null if cancelled.
Future<String?> promptManagerPinKeypad(
  BuildContext context, {
  required String title,
  String? reason,
  String confirmLabel = 'Confirm',
}) {
  return showDialog<String>(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => _ManagerPinKeypadDialog(
      title: title,
      reason: reason,
      confirmLabel: confirmLabel,
      verifyBeforeClose: false,
    ),
  );
}

class _ManagerPinKeypadDialog extends StatefulWidget {
  const _ManagerPinKeypadDialog({
    required this.title,
    required this.confirmLabel,
    required this.verifyBeforeClose,
    this.reason,
  });

  final String title;
  final String? reason;
  final String confirmLabel;
  final bool verifyBeforeClose;

  @override
  State<_ManagerPinKeypadDialog> createState() =>
      _ManagerPinKeypadDialogState();
}

class _ManagerPinKeypadDialogState extends State<_ManagerPinKeypadDialog> {
  String _pinRaw = '';
  bool _isVerifying = false;

  bool get _canConfirm =>
      _pinRaw.length >= managerPinMinLength &&
      _pinRaw.length <= managerPinMaxLength &&
      !_isVerifying;

  void _onDigit(String d) {
    if (_pinRaw.length + d.length > managerPinMaxLength) return;
    HapticFeedback.selectionClick();
    setState(() => _pinRaw += d);
  }

  void _onDelete() {
    if (_pinRaw.isEmpty) return;
    setState(
      () => _pinRaw = _pinRaw.substring(0, _pinRaw.length - 1),
    );
  }

  void _onClear() {
    setState(() => _pinRaw = '');
  }

  Future<void> _onConfirm() async {
    if (!_canConfirm) return;

    if (!widget.verifyBeforeClose) {
      Navigator.pop(context, _pinRaw);
      return;
    }

    setState(() => _isVerifying = true);
    final valid = await sl<LocalStorage>().verifyManagerPin(_pinRaw);
    if (!mounted) return;

    if (valid) {
      Navigator.pop(context, true);
      return;
    }

    setState(() => _isVerifying = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Incorrect manager PIN')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pinDisplay = _pinRaw.isEmpty
        ? '••••••'
        : List.filled(_pinRaw.length, '•').join();

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            PaxPaymentSpacing.sp16,
            PaxPaymentSpacing.sp16,
            PaxPaymentSpacing.sp16,
            PaxPaymentSpacing.sp12,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                widget.title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              if (widget.reason != null) ...[
                const SizedBox(height: PaxPaymentSpacing.sp8),
                Text(
                  widget.reason!,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: PaxPaymentColors.mediumGray,
                      ),
                ),
              ],
              const SizedBox(height: PaxPaymentSpacing.sp16),
              Center(
                child: Text(
                  pinDisplay,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        letterSpacing: 6,
                        color: _pinRaw.isEmpty
                            ? PaxPaymentColors.mediumGray.withValues(alpha: 0.45)
                            : PaxPaymentColors.darkGrayText,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
              const SizedBox(height: PaxPaymentSpacing.sp12),
              SizedBox(
                height: 300,
                child: PosKeypayPanel(
                  showOperatorColumn: false,
                  bottomLeftClear: true,
                  onDigit: _onDigit,
                  onDelete: _onDelete,
                  onClear: _onClear,
                  footer: Material(
                    color: _canConfirm
                        ? PaxPaymentColors.posKeypayAccent
                        : PaxPaymentColors.posKeypayAccent
                            .withValues(alpha: 0.4),
                    child: InkWell(
                      onTap: _canConfirm ? _onConfirm : null,
                      child: SizedBox(
                        height: 52,
                        child: Center(
                          child: _isVerifying
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: PaxPaymentColors.onPosKeypayAccent,
                                  ),
                                )
                              : Text(
                                  widget.confirmLabel,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(
                                        color: _canConfirm
                                            ? PaxPaymentColors.onPosKeypayAccent
                                            : PaxPaymentColors.onPosKeypayAccent
                                                .withValues(alpha: 0.65),
                                        fontWeight: FontWeight.w700,
                                      ),
                                ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: PaxPaymentSpacing.sp8),
              TextButton(
                onPressed: _isVerifying
                    ? null
                    : () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
