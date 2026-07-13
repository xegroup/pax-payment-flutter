import 'package:flutter/material.dart';

import '../core/di/injection.dart';
import '../core/database/local_storage.dart';
import 'payment_method_screen.dart';
import 'tip_screen.dart';

/// Runs each split amount through Tip → Payment Method → EVO in sequence.
class SplitPaymentFlowScreen extends StatefulWidget {
  const SplitPaymentFlowScreen({
    super.key,
    required this.amounts,
  });

  final List<double> amounts;

  @override
  State<SplitPaymentFlowScreen> createState() => _SplitPaymentFlowScreenState();
}

class _SplitPaymentFlowScreenState extends State<SplitPaymentFlowScreen> {
  int _index = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _runCurrent());
  }

  Future<void> _runCurrent() async {
    if (_index >= widget.amounts.length) {
      if (mounted) Navigator.of(context).pop(true);
      return;
    }

    final amount = widget.amounts[_index];
    final label = widget.amounts.length > 1
        ? 'Split ${_index + 1} of ${widget.amounts.length}'
        : null;
    final tipsOn = sl<LocalStorage>().tipsEnabled;

    final ok = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => tipsOn
            ? TipScreen(
                baseAmount: amount,
                splitLabel: label,
                completeWithPopResult: true,
              )
            : PaymentMethodScreen(
                totalAmount: amount,
                splitLabel: label,
                completeWithPopResult: true,
              ),
      ),
    );

    if (!mounted) return;
    if (ok != true) {
      Navigator.of(context).pop(false);
      return;
    }
    _index++;
    await _runCurrent();
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
