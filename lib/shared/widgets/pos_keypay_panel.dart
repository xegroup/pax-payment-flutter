import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/paxpayment_colors.dart';
import '../theme/paxpayment_spacing.dart';

/// Handheld-style keypay: 3×3 digits, bottom row, and a vertical operator column.
class PosKeypayPanel extends StatelessWidget {
  const PosKeypayPanel({
    super.key,
    required this.onDigit,
    required this.onDelete,
    required this.onClear,
    this.onOperatorTap,
  });

  final ValueChanged<String> onDigit;
  final VoidCallback onDelete;
  final VoidCallback onClear;
  final ValueChanged<String>? onOperatorTap;

  @override
  Widget build(BuildContext context) {
    final bg = PaxPaymentColors.lightGray;
    final opBg = PaxColors.grey150;

    return ClipRRect(
      borderRadius: BorderRadius.circular(PaxPaymentSpacing.radiusLg),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            color: bg,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      PaxPaymentSpacing.sp10,
                      PaxPaymentSpacing.sp10,
                      PaxPaymentSpacing.sp6,
                      PaxPaymentSpacing.sp10,
                    ),
                    child: Column(
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Expanded(child: _NumKey(label: '1', onTap: () => onDigit('1'))),
                              const SizedBox(width: PaxPaymentSpacing.sp8),
                              Expanded(child: _NumKey(label: '2', onTap: () => onDigit('2'))),
                              const SizedBox(width: PaxPaymentSpacing.sp8),
                              Expanded(child: _NumKey(label: '3', onTap: () => onDigit('3'))),
                            ],
                          ),
                        ),
                        const SizedBox(height: PaxPaymentSpacing.sp8),
                        Expanded(
                          child: Row(
                            children: [
                              Expanded(child: _NumKey(label: '4', onTap: () => onDigit('4'))),
                              const SizedBox(width: PaxPaymentSpacing.sp8),
                              Expanded(child: _NumKey(label: '5', onTap: () => onDigit('5'))),
                              const SizedBox(width: PaxPaymentSpacing.sp8),
                              Expanded(child: _NumKey(label: '6', onTap: () => onDigit('6'))),
                            ],
                          ),
                        ),
                        const SizedBox(height: PaxPaymentSpacing.sp8),
                        Expanded(
                          child: Row(
                            children: [
                              Expanded(child: _NumKey(label: '7', onTap: () => onDigit('7'))),
                              const SizedBox(width: PaxPaymentSpacing.sp8),
                              Expanded(child: _NumKey(label: '8', onTap: () => onDigit('8'))),
                              const SizedBox(width: PaxPaymentSpacing.sp8),
                              Expanded(child: _NumKey(label: '9', onTap: () => onDigit('9'))),
                            ],
                          ),
                        ),
                        const SizedBox(height: PaxPaymentSpacing.sp8),
                        Expanded(
                          child: Row(
                            children: [
                              const Expanded(child: SizedBox.shrink()),
                              const SizedBox(width: PaxPaymentSpacing.sp8),
                              Expanded(
                                child: _NumKey(
                                  label: '0',
                                  onTap: () => onDigit('0'),
                                ),
                              ),
                              const SizedBox(width: PaxPaymentSpacing.sp8),
                              Expanded(
                                child: _NumKey(
                                  label: '⌫',
                                  isAction: true,
                                  onTap: () {
                                    HapticFeedback.selectionClick();
                                    onDelete();
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  width: 52,
                  color: opBg,
                  padding: const EdgeInsets.symmetric(vertical: PaxPaymentSpacing.sp8),
                  child: Column(
                    children: [
                      Expanded(
                        child: _OpKey(
                          label: 'C',
                          onTap: () {
                            HapticFeedback.mediumImpact();
                            onClear();
                          },
                        ),
                      ),
                      Expanded(
                        child: _OpKey(
                          label: '÷',
                          onTap: () {
                            HapticFeedback.selectionClick();
                            onOperatorTap?.call('÷');
                          },
                        ),
                      ),
                      Expanded(
                        child: _OpKey(
                          label: '×',
                          onTap: () {
                            HapticFeedback.selectionClick();
                            onOperatorTap?.call('×');
                          },
                        ),
                      ),
                      Expanded(
                        child: _OpKey(
                          label: '−',
                          onTap: () {
                            HapticFeedback.selectionClick();
                            onOperatorTap?.call('−');
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 3,
                  color: PaxPaymentColors.posKeypayAccent,
                ),
              ],
            ),
          ),
          Positioned(
            right: -2,
            top: 0,
            bottom: 0,
            child: Center(
              child: Container(
                width: 10,
                height: 28,
                decoration: const BoxDecoration(
                  color: PaxPaymentColors.white,
                  borderRadius: BorderRadius.horizontal(
                    right: Radius.circular(PaxPaymentSpacing.radiusRound),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x14000000),
                      blurRadius: 4,
                      offset: Offset(1, 0),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.chevron_left_rounded,
                  size: 16,
                  color: PaxPaymentColors.mediumGray,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NumKey extends StatelessWidget {
  const _NumKey({
    required this.label,
    required this.onTap,
    this.isAction = false,
  });

  final String label;
  final VoidCallback onTap;
  final bool isAction;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isAction ? PaxColors.grey200.withValues(alpha: 0.65) : PaxPaymentColors.white,
      borderRadius: BorderRadius.circular(PaxPaymentSpacing.radiusMd),
      elevation: 0,
      shadowColor: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(PaxPaymentSpacing.radiusMd),
        onTap: onTap,
        child: Center(
          child: Text(
            label,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: PaxPaymentColors.darkGrayText,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
      ),
    );
  }
}

class _OpKey extends StatelessWidget {
  const _OpKey({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Center(
        child: Text(
          label,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: PaxPaymentColors.darkGrayText,
                fontWeight: FontWeight.w500,
                height: 1.0,
              ),
        ),
      ),
    );
  }
}
