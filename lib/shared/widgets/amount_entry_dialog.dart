import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../resources/paxpayment_strings.dart';
import '../theme/pax_colors.dart';
import '../theme/pax_spacing.dart';
import '../theme/pax_text_styles.dart';
import 'paxpayment_button.dart';

Future<double?> showAmountEntryDialog(
  BuildContext context, {
  double initialAmount = 0.0,
  String title = 'Enter Amount',
}) {
  return AmountEntryDialog.show(
    context,
    currencySymbol: XeposStrings.currencySymbol,
    initialAmount: initialAmount > 0 ? initialAmount : null,
    title: title,
  );
}

class AmountEntryDialog extends StatefulWidget {
  const AmountEntryDialog({
    super.key,
    this.currencySymbol = '£',
    this.initialAmount,
    this.title = 'Enter Amount',
    this.confirmLabel = 'Continue',
    this.maxAmount,
  });

  final String currencySymbol;
  final double? initialAmount;
  final String title;
  final String confirmLabel;
  final double? maxAmount;

  static Future<double?> show(
    BuildContext context, {
    String currencySymbol = '£',
    double? initialAmount,
    String title = 'Enter Amount',
    String confirmLabel = 'Continue',
    double? maxAmount,
  }) {
    return showModalBottomSheet<double>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => AmountEntryDialog(
        currencySymbol: currencySymbol,
        initialAmount: initialAmount,
        title: title,
        confirmLabel: confirmLabel,
        maxAmount: maxAmount,
      ),
    );
  }

  @override
  State<AmountEntryDialog> createState() => _AmountEntryDialogState();
}

class _AmountEntryDialogState extends State<AmountEntryDialog> {
  late String _raw;
  String? _error;

  @override
  void initState() {
    super.initState();
    if (widget.initialAmount != null && widget.initialAmount! > 0) {
      _raw = (widget.initialAmount! * 100).round().toString();
    } else {
      _raw = '';
    }
  }

  double get _amount => _raw.isEmpty ? 0 : int.parse(_raw) / 100;

  String get _displayAmount {
    if (_raw.isEmpty) return '0.00';
    final padded = _raw.padLeft(3, '0');
    final cents = padded.substring(padded.length - 2);
    final dollars = padded.substring(0, padded.length - 2);
    return '$dollars.$cents';
  }

  void _tap(String digit) {
    HapticFeedback.selectionClick();
    if (_raw.length >= 8) return;
    setState(() {
      _raw += digit;
      _error = null;
    });
  }

  void _delete() {
    HapticFeedback.selectionClick();
    if (_raw.isEmpty) return;
    setState(() {
      _raw = _raw.substring(0, _raw.length - 1);
      _error = null;
    });
  }

  void _clear() {
    HapticFeedback.mediumImpact();
    setState(() {
      _raw = '';
      _error = null;
    });
  }

  void _confirm() {
    if (_amount <= 0) {
      setState(() => _error = 'Please enter an amount');
      return;
    }
    if (widget.maxAmount != null && _amount > widget.maxAmount!) {
      setState(() => _error =
          'Amount exceeds maximum of ${widget.currencySymbol}${widget.maxAmount!.toStringAsFixed(2)}');
      return;
    }
    Navigator.of(context).pop(_amount);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cs = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? PaxColors.grey850 : PaxColors.white,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(PaxSpacing.radiusXxl),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            PaxSpacing.lg,
            PaxSpacing.sm,
            PaxSpacing.lg,
            PaxSpacing.lg,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: PaxSpacing.md),
                decoration: BoxDecoration(
                  color: isDark ? PaxColors.grey700 : PaxColors.grey300,
                  borderRadius: PaxSpacing.brPill,
                ),
              ),
              Text(
                widget.title,
                style: PaxTextStyles.h4.copyWith(color: cs.onSurface),
              ),
              const SizedBox(height: PaxSpacing.xl),
              AnimatedSwitcher(
                duration: PaxSpacing.durationFast,
                child: Text(
                  '${widget.currencySymbol}$_displayAmount',
                  key: ValueKey(_displayAmount),
                  style: PaxTextStyles.amount.copyWith(
                    color: _amount > 0 ? cs.onSurface : cs.onSurfaceVariant,
                  ),
                ),
              ),
              AnimatedCrossFade(
                duration: PaxSpacing.durationFast,
                crossFadeState: _error != null
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,
                firstChild: const SizedBox(height: PaxSpacing.sm),
                secondChild: Padding(
                  padding: const EdgeInsets.only(
                    top: PaxSpacing.xs,
                    bottom: PaxSpacing.xs,
                  ),
                  child: Text(
                    _error ?? '',
                    style:
                        PaxTextStyles.caption.copyWith(color: PaxColors.error),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              const SizedBox(height: PaxSpacing.md),
              _Keypad(
                onDigit: _tap,
                onDelete: _delete,
                onClear: _raw.isNotEmpty ? _clear : null,
              ),
              const SizedBox(height: PaxSpacing.md),
              PaxButton.primary(
                label: _amount > 0
                    ? '${widget.confirmLabel} — ${widget.currencySymbol}$_displayAmount'
                    : widget.confirmLabel,
                onPressed: _confirm,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Keypad extends StatelessWidget {
  const _Keypad({
    required this.onDigit,
    required this.onDelete,
    this.onClear,
  });

  final ValueChanged<String> onDigit;
  final VoidCallback onDelete;
  final VoidCallback? onClear;

  static const _keys = [
    ['1', '2', '3'],
    ['4', '5', '6'],
    ['7', '8', '9'],
    ['C', '0', '⌫'],
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: _keys.map((row) {
        return Padding(
          padding: const EdgeInsets.only(bottom: PaxSpacing.sm),
          child: Row(
            children: row.map((key) {
              final isAction = key == '⌫' || key == 'C';
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: PaxSpacing.xs),
                  child: _KeyButton(
                    label: key,
                    isAction: isAction,
                    onTap: switch (key) {
                      '⌫' => onDelete,
                      'C' => onClear ?? () {},
                      _ => () => onDigit(key),
                    },
                    isDisabled: key == 'C' && onClear == null,
                  ),
                ),
              );
            }).toList(),
          ),
        );
      }).toList(),
    );
  }
}

class _KeyButton extends StatelessWidget {
  const _KeyButton({
    required this.label,
    required this.isAction,
    required this.onTap,
    this.isDisabled = false,
  });

  final String label;
  final bool isAction;
  final VoidCallback onTap;
  final bool isDisabled;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cs = Theme.of(context).colorScheme;

    final bgColor = isAction
        ? (isDark ? PaxColors.grey800 : PaxColors.grey100)
        : (isDark ? PaxColors.grey900 : PaxColors.white);

    final textColor =
        isAction ? cs.onSurfaceVariant : cs.onSurface;

    return SizedBox(
      height: 60,
      child: Material(
        color: bgColor,
        borderRadius: PaxSpacing.brMd,
        child: InkWell(
          borderRadius: PaxSpacing.brMd,
          onTap: isDisabled ? null : onTap,
          child: Center(
            child: Text(
              label,
              style: PaxTextStyles.h3.copyWith(
                color: isDisabled
                    ? cs.onSurfaceVariant.withValues(alpha: 0.3)
                    : textColor,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
