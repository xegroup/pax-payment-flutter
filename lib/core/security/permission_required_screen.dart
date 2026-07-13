import 'package:flutter/material.dart';

import 'manager_pin_gate.dart';

/// Full-screen gate when manager PIN is required for a sensitive action.
class PermissionRequiredScreen extends StatefulWidget {
  const PermissionRequiredScreen({
    super.key,
    required this.reason,
    required this.onGranted,
  });

  final String reason;
  final VoidCallback onGranted;

  @override
  State<PermissionRequiredScreen> createState() =>
      _PermissionRequiredScreenState();
}

class _PermissionRequiredScreenState extends State<PermissionRequiredScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _prompt());
  }

  Future<void> _prompt() async {
    final granted = await verifyManagerPin(context, reason: widget.reason);
    if (!mounted) return;
    if (granted) {
      widget.onGranted();
      Navigator.of(context).pop(true);
    } else {
      Navigator.of(context).pop(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
