import 'package:flutter/material.dart';

import '../core/di/injection.dart';
import '../core/database/local_storage.dart';
import '../shared/theme/pax_text_styles.dart';
import 'cash_payment_screen.dart';
import 'payment_flow_helpers.dart';
import 'teya_ui.dart';

enum PaymentMethodChoice { card, cash }

/// Card vs cash selection after tip. Card path calls EVO via [PaymentService] in-place.
class PaymentMethodScreen extends StatefulWidget {
  const PaymentMethodScreen({
    super.key,
    required this.totalAmount,
    this.splitLabel,
    this.completeWithPopResult = false,
  });

  final double totalAmount;
  final String? splitLabel;
  final bool completeWithPopResult;

  @override
  State<PaymentMethodScreen> createState() => _PaymentMethodScreenState();
}

class _PaymentMethodScreenState extends State<PaymentMethodScreen> {
  PaymentMethodChoice _choice = PaymentMethodChoice.card;
  bool _isProcessing = false;
  late final bool _cashEnabled = sl<LocalStorage>().cashEnabled;

  Future<void> _onContinue() async {
    if (_isProcessing) return;

    if (_choice == PaymentMethodChoice.cash) {
      final ok = await Navigator.of(context).push<bool>(
        MaterialPageRoute<bool>(
          builder: (_) => CashPaymentScreen(
            totalAmount: widget.totalAmount,
            completeWithPopResult: widget.completeWithPopResult,
          ),
        ),
      );
      if (!mounted) return;
      if (widget.completeWithPopResult) {
        Navigator.of(context).pop(ok == true);
      }
      return;
    }

    await _startCardPayment();
  }

  Future<void> _startCardPayment() async {
    setState(() => _isProcessing = true);
    try {
      await startCardPaymentFlow(
        context,
        amount: widget.totalAmount,
        popWithResult: widget.completeWithPopResult,
      );
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return TeyaScreenScaffold(
      appBar: TeyaTopBar(
        onGoBack: _isProcessing ? null : () => Navigator.of(context).pop(),
      ),
      body: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  children: [
                    if (widget.splitLabel != null) ...[
                      Text(
                        widget.splitLabel!,
                        style: PaxTextStyles.caption.copyWith(
                          color: TeyaColors.textGrey,
                        ),
                      ),
                      const SizedBox(height: 4),
                    ],
                    Text(
                      'Select payment method',
                      style: PaxTextStyles.h2.copyWith(color: TeyaColors.textDark),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Total ${TeyaUi.formatAmount(widget.totalAmount)}',
                      style: PaxTextStyles.bodyMedium.copyWith(
                        color: TeyaColors.textGrey,
                      ),
                    ),
                    const SizedBox(height: 24),
                    _MethodCard(
                      title: 'Card payment',
                      subtitle: 'Tap, insert, or swipe',
                      icon: Icons.credit_card_rounded,
                      selected: _choice == PaymentMethodChoice.card,
                      enabled: !_isProcessing,
                      onTap: () => setState(() => _choice = PaymentMethodChoice.card),
                    ),
                    if (_cashEnabled) ...[
                      const SizedBox(height: 12),
                      _MethodCard(
                        title: 'Cash',
                        subtitle: 'Record cash payment',
                        icon: Icons.payments_rounded,
                        selected: _choice == PaymentMethodChoice.cash,
                        enabled: !_isProcessing,
                        onTap: () =>
                            setState(() => _choice = PaymentMethodChoice.cash),
                      ),
                    ],
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                child: TeyaPrimaryButton(
                  label: 'Continue',
                  enabled: !_isProcessing,
                  onPressed: _onContinue,
                ),
              ),
            ],
          ),
          if (_isProcessing)
            ColoredBox(
              color: Colors.black.withValues(alpha: 0.35),
              child: Center(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 32),
                  padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
                  decoration: BoxDecoration(
                    color: TeyaColors.white,
                    borderRadius: TeyaUi.buttonRadius,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(
                        width: 32,
                        height: 32,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: TeyaColors.accent,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Launching payment...',
                        style: PaxTextStyles.bodySemiBold.copyWith(
                          color: TeyaColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Complete payment on the terminal',
                        textAlign: TextAlign.center,
                        style: PaxTextStyles.caption.copyWith(
                          color: TeyaColors.textGrey,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _MethodCard extends StatelessWidget {
  const _MethodCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.selected,
    required this.onTap,
    this.enabled = true,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1 : 0.5,
      child: Material(
        color: TeyaColors.white,
        shape: RoundedRectangleBorder(
          borderRadius: TeyaUi.buttonRadius,
          side: BorderSide(
            color: selected ? TeyaColors.accent : TeyaColors.borderGrey,
            width: selected ? 2 : 1,
          ),
        ),
        child: InkWell(
          borderRadius: TeyaUi.buttonRadius,
          onTap: enabled ? onTap : null,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Icon(icon, size: 36, color: TeyaColors.textDark),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: PaxTextStyles.h4.copyWith(color: TeyaColors.textDark),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: PaxTextStyles.bodyMedium.copyWith(
                          color: TeyaColors.textGrey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
