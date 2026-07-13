import 'package:flutter/material.dart';

import '../core/di/injection.dart';
import '../core/database/local_storage.dart';
import '../core/security/manager_pin_gate.dart';
import '../shared/theme/paxpayment_colors.dart';
import '../shared/theme/paxpayment_spacing.dart';

/// Tips, cash, receipt and print options for the terminal.
class PaymentSettingsScreen extends StatefulWidget {
  const PaymentSettingsScreen({super.key});

  @override
  State<PaymentSettingsScreen> createState() => _PaymentSettingsScreenState();
}

class _PaymentSettingsScreenState extends State<PaymentSettingsScreen> {
  late bool _tipsEnabled;
  late bool _cashEnabled;
  late bool _autoPrint;
  late String _receiptType;

  static const _receiptOptions = <({String value, String label})>[
    (value: 'print', label: 'Print'),
    (value: 'digital', label: 'Email'),
    (value: 'ask', label: 'Ask Customer'),
    (value: 'none', label: 'None'),
  ];

  @override
  void initState() {
    super.initState();
    final s = sl<LocalStorage>();
    _tipsEnabled = s.tipsEnabled;
    _cashEnabled = s.cashEnabled;
    _autoPrint = s.autoPrintReceipt;
    _receiptType = s.receiptType;
  }

  LocalStorage get _storage => sl<LocalStorage>();

  String get _receiptTypeLabel {
    for (final o in _receiptOptions) {
      if (o.value == _receiptType) return o.label;
    }
    return _receiptOptions.first.label;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PaxPaymentColors.adminBackground,
      appBar: AppBar(
        title: const Text('Payment settings'),
        backgroundColor: PaxPaymentColors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        foregroundColor: PaxPaymentColors.darkGrayText,
      ),
      body: ListView(
        padding: const EdgeInsets.all(PaxPaymentSpacing.sp16),
        children: [
          _SettingsCard(
            child: SwitchListTile(
              title: const Text('Enable tips'),
              subtitle: const Text('Show tip screen before payment'),
              value: _tipsEnabled,
              onChanged: (v) {
                setState(() => _tipsEnabled = v);
                _storage.setTipsEnabled(v);
              },
            ),
          ),
          const SizedBox(height: PaxPaymentSpacing.sp10),
          _SettingsCard(
            child: SwitchListTile(
              title: const Text('Enable cash payments'),
              subtitle: const Text('Allow cash as a payment method'),
              value: _cashEnabled,
              onChanged: (v) {
                setState(() => _cashEnabled = v);
                _storage.setCashEnabled(v);
              },
            ),
          ),
          const SizedBox(height: PaxPaymentSpacing.sp10),
          _SettingsCard(
            child: SwitchListTile(
              title: const Text('Auto print receipt'),
              subtitle: const Text('Print automatically after successful payment'),
              value: _autoPrint,
              onChanged: (v) {
                setState(() => _autoPrint = v);
                _storage.setAutoPrintReceipt(v);
              },
            ),
          ),
          const SizedBox(height: PaxPaymentSpacing.sp10),
          _SettingsCard(
            child: ListTile(
              title: const Text('Default receipt type'),
              subtitle: Text(_receiptTypeLabel),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: _pickReceiptType,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickReceiptType() async {
    final picked = await showDialog<String>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: const Text('Default receipt type'),
        children: [
          for (final o in _receiptOptions)
            SimpleDialogOption(
              onPressed: () => Navigator.pop(ctx, o.value),
              child: Text(o.label),
            ),
        ],
      ),
    );
    if (picked != null && mounted) {
      setState(() => _receiptType = picked);
      await _storage.setReceiptType(picked);
    }
  }
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(PaxPaymentSpacing.radiusXl);
    return Container(
      decoration: BoxDecoration(
        color: PaxPaymentColors.white,
        borderRadius: radius,
        border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
      ),
      child: child,
    );
  }
}

/// Opens payment settings after manager PIN verification.
Future<void> openPaymentSettings(BuildContext context) async {
  final ok = await verifyManagerPin(
    context,
    reason: 'Manager PIN is required to change payment settings.',
  );
  if (!ok || !context.mounted) return;

  await Navigator.of(context).push(
    MaterialPageRoute<void>(builder: (_) => const PaymentSettingsScreen()),
  );
}
