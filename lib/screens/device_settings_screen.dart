import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../core/di/injection.dart';
import '../core/database/local_storage.dart';
import '../shared/theme/paxpayment_colors.dart';
import '../shared/theme/paxpayment_spacing.dart';

/// Device-level settings: version and terminal IDs.
class DeviceSettingsScreen extends StatefulWidget {
  const DeviceSettingsScreen({super.key});

  @override
  State<DeviceSettingsScreen> createState() => _DeviceSettingsScreenState();
}

class _DeviceSettingsScreenState extends State<DeviceSettingsScreen> {
  String _appVersion = '…';
  String _tid = '';
  String _mid = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final info = await PackageInfo.fromPlatform();
    final storage = sl<LocalStorage>();

    if (!mounted) return;
    setState(() {
      _appVersion = '${info.version} (${info.buildNumber})';
      _tid = storage.terminalID;
      _mid = storage.mid;
    });
  }

  Future<void> _editTerminalId() => _editStoredValue(
        currentValue: _tid,
        title: 'Terminal ID',
        hintText: 'Enter terminal ID',
        saveLabel: 'Terminal ID saved',
        onSaved: (value) async {
          await sl<LocalStorage>().setTerminalId(value);
          setState(() => _tid = value);
        },
      );

  Future<void> _editMerchantId() => _editStoredValue(
        currentValue: _mid,
        title: 'Merchant ID',
        hintText: 'Enter merchant ID',
        saveLabel: 'Merchant ID saved',
        onSaved: (value) async {
          await sl<LocalStorage>().setMid(value);
          setState(() => _mid = value);
        },
      );

  Future<void> _editStoredValue({
    required String currentValue,
    required String title,
    required String hintText,
    required String saveLabel,
    required Future<void> Function(String value) onSaved,
  }) async {
    final saved = await showDialog<String>(
      context: context,
      builder: (ctx) => _EditValueDialog(
        title: title,
        hintText: hintText,
        initialValue: currentValue,
      ),
    );

    if (saved == null || !mounted) return;

    await onSaved(saved);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(saveLabel),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  String _displayValue(String value) => value.isEmpty ? 'Not set' : value;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PaxPaymentColors.adminBackground,
      appBar: AppBar(
        title: const Text('Device settings'),
        backgroundColor: PaxPaymentColors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        foregroundColor: PaxPaymentColors.darkGrayText,
      ),
      body: ListView(
        padding: const EdgeInsets.all(PaxPaymentSpacing.sp16),
        children: [
          _InfoTile(
            title: 'App version',
            value: _appVersion,
            icon: Icons.info_outline_rounded,
          ),
          const SizedBox(height: PaxPaymentSpacing.sp10),
          _EditableInfoTile(
            title: 'Terminal ID',
            value: _displayValue(_tid),
            icon: Icons.point_of_sale_outlined,
            editTooltip: 'Edit terminal ID',
            onEdit: _editTerminalId,
          ),
          const SizedBox(height: PaxPaymentSpacing.sp10),
          _EditableInfoTile(
            title: 'Merchant ID',
            value: _displayValue(_mid),
            icon: Icons.store_outlined,
            editTooltip: 'Edit merchant ID',
            onEdit: _editMerchantId,
          ),
        ],
      ),
    );
  }
}

class _EditValueDialog extends StatefulWidget {
  const _EditValueDialog({
    required this.title,
    required this.hintText,
    required this.initialValue,
  });

  final String title;
  final String hintText;
  final String initialValue;

  @override
  State<_EditValueDialog> createState() => _EditValueDialogState();
}

class _EditValueDialogState extends State<_EditValueDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _save() {
    final value = _controller.text.trim();
    if (value.isEmpty) return;
    Navigator.pop(context, value);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: TextField(
        controller: _controller,
        autofocus: true,
        decoration: InputDecoration(
          hintText: widget.hintText,
          border: const OutlineInputBorder(),
        ),
        textInputAction: TextInputAction.done,
        onSubmitted: (_) => _save(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _save,
          child: const Text('Save'),
        ),
      ],
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.title,
    required this.value,
    required this.icon,
  });

  final String title;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) => _DeviceCard(
        child: ListTile(
          leading: Icon(icon, color: PaxPaymentColors.darkGrayText),
          title: Text(title),
          subtitle: Text(
            value,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
      );
}

class _EditableInfoTile extends StatelessWidget {
  const _EditableInfoTile({
    required this.title,
    required this.value,
    required this.icon,
    required this.onEdit,
    required this.editTooltip,
  });

  final String title;
  final String value;
  final IconData icon;
  final VoidCallback onEdit;
  final String editTooltip;

  @override
  Widget build(BuildContext context) {
    return _DeviceCard(
      child: ListTile(
        leading: Icon(icon, color: PaxPaymentColors.darkGrayText),
        title: Text(title),
        subtitle: Text(
          value,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        trailing: IconButton(
          onPressed: onEdit,
          icon: const Icon(Icons.edit_outlined),
          color: PaxPaymentColors.primaryBlue,
          tooltip: editTooltip,
        ),
        onTap: onEdit,
      ),
    );
  }
}

class _DeviceCard extends StatelessWidget {
  const _DeviceCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(PaxPaymentSpacing.radiusXl);
    return Material(
      color: PaxPaymentColors.white,
      borderRadius: radius,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: radius,
          border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
        ),
        child: child,
      ),
    );
  }
}
