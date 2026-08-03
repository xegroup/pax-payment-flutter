import 'package:flutter/material.dart';

import '../shared/theme/pax_text_styles.dart';
import 'payment_flow_helpers.dart';
import 'card_payment_screen.dart';
import 'teya_ui.dart';

/// Tip selection after amount entry, before payment method.
class TipScreen extends StatefulWidget {
  const TipScreen({
    super.key,
    required this.baseAmount,
    this.splitLabel,
    this.completeWithPopResult = false,
  });

  final double baseAmount;
  final String? splitLabel;
  final bool completeWithPopResult;

  @override
  State<TipScreen> createState() => _TipScreenState();
}

class _TipScreenState extends State<TipScreen> {
  static const _presets = <({String label, double? pct})>[
    (label: 'No tip', pct: null),
    (label: '10%', pct: 0.10),
    (label: '15%', pct: 0.15),
    (label: '20%', pct: 0.20),
  ];

  int _selectedIndex = 0;
  double _customTip = 0;
  bool _usingCustom = false;

  double get _tipAmount {
    if (_usingCustom) return _customTip;
    final pct = _presets[_selectedIndex].pct;
    if (pct == null) return 0;
    return roundMoney(widget.baseAmount * pct);
  }

  double get _totalAmount => roundMoney(widget.baseAmount + _tipAmount);

  Future<void> _openCustomTip() async {
    final ctrl = TextEditingController(
      text: _usingCustom && _customTip > 0 ? _customTip.toStringAsFixed(2) : '',
    );
    final value = await showDialog<double>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Custom tip', style: PaxTextStyles.h4),
        content: TextField(
          controller: ctrl,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(
            prefixText: '£ ',
            hintText: '0.00',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              final tip = double.tryParse(ctrl.text.trim());
              if (tip == null || tip < 0) return;
              Navigator.pop(ctx, roundMoney(tip));
            },
            child: const Text('Apply'),
          ),
        ],
      ),
    );
    if (value != null && mounted) {
      setState(() {
        _usingCustom = true;
        _customTip = value;
      });
    }
  }

  Future<void> _onContinue() async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => CardPaymentScreen(
          totalAmount: _totalAmount,
          splitLabel: widget.splitLabel,
          completeWithPopResult: widget.completeWithPopResult,
        ),
      ),
    );
    if (!mounted) return;
    if (widget.completeWithPopResult) {
      Navigator.of(context).pop(result == true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return TeyaScreenScaffold(
      appBar: TeyaTopBar(onGoBack: () => Navigator.of(context).pop()),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              children: [
                if (widget.splitLabel != null) ...[
                  Text(
                    widget.splitLabel!,
                    textAlign: TextAlign.center,
                    style: PaxTextStyles.caption.copyWith(color: TeyaColors.textGrey),
                  ),
                  const SizedBox(height: 8),
                ],
                Text(
                  TeyaUi.formatAmount(widget.baseAmount),
                  textAlign: TextAlign.center,
                  style: PaxTextStyles.amount.copyWith(color: TeyaColors.textDark),
                ),
                const SizedBox(height: 28),
                Text(
                  'Add a tip?',
                  style: PaxTextStyles.h3.copyWith(color: TeyaColors.textDark),
                ),
                const SizedBox(height: 16),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.55,
                  children: List.generate(_presets.length, (i) {
                    final p = _presets[i];
                    final tip = p.pct == null
                        ? 0.0
                        : roundMoney(widget.baseAmount * p.pct!);
                    final selected = !_usingCustom && _selectedIndex == i;
                    return _TipOptionCard(
                      title: p.label,
                      subtitle: p.pct == null
                          ? null
                          : TeyaUi.formatAmount(tip),
                      selected: selected,
                      onTap: () => setState(() {
                        _usingCustom = false;
                        _selectedIndex = i;
                      }),
                    );
                  }),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: _openCustomTip,
                  child: Text(
                    'Custom amount',
                    style: PaxTextStyles.bodySemiBold.copyWith(
                      color: TeyaColors.textDark,
                      decoration: TextDecoration.underline,
                      decorationColor: TeyaColors.accent,
                    ),
                  ),
                ),
                if (_usingCustom && _customTip > 0)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      'Custom tip: ${TeyaUi.formatAmount(_customTip)}',
                      textAlign: TextAlign.center,
                      style: PaxTextStyles.bodyMedium.copyWith(
                        color: TeyaColors.textGrey,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
            child: TeyaPrimaryButton(label: 'Continue', onPressed: _onContinue),
          ),
        ],
      ),
    );
  }
}

class _TipOptionCard extends StatelessWidget {
  const _TipOptionCard({
    required this.title,
    this.subtitle,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final String? subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
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
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                style: PaxTextStyles.bodySemiBold.copyWith(
                  color: TeyaColors.textDark,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 4),
                Text(
                  subtitle!,
                  style: PaxTextStyles.caption.copyWith(color: TeyaColors.textGrey),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
