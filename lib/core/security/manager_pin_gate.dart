import 'package:flutter/material.dart';

import '../di/injection.dart';
import '../database/local_storage.dart';

/// Shows manager PIN dialog; returns true when PIN matches.
Future<bool> verifyManagerPin(BuildContext context, {String? reason}) async {
  final ok = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => _ManagerPinDialog(reason: reason),
  );
  return ok == true;
}

class _ManagerPinDialog extends StatefulWidget {
  const _ManagerPinDialog({this.reason});

  final String? reason;

  @override
  State<_ManagerPinDialog> createState() => _ManagerPinDialogState();
}

class _ManagerPinDialogState extends State<_ManagerPinDialog> {
  late final TextEditingController _pinCtrl;

  @override
  void initState() {
    super.initState();
    _pinCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _pinCtrl.dispose();
    super.dispose();
  }

  Future<void> _confirm() async {
    final valid = await sl<LocalStorage>().verifyManagerPin(
      _pinCtrl.text.trim(),
    );
    if (!valid) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Incorrect manager PIN')),
        );
      }
      return;
    }
    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Manager PIN required'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.reason != null) ...[
            Text(widget.reason!),
            const SizedBox(height: 12),
          ],
          TextField(
            controller: _pinCtrl,
            keyboardType: TextInputType.number,
            obscureText: true,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'Manager PIN',
              hintText: '4 digits',
            ),
            onSubmitted: (_) => _confirm(),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _confirm,
          child: const Text('Confirm'),
        ),
      ],
    );
  }
}
