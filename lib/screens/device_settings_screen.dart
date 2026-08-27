import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:uuid/uuid.dart';

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

  Future<String> generateTerminalId() async {
    const uuid = Uuid();
    return uuid.v4();
  }

  Future<void> _load() async {
    final info = await PackageInfo.fromPlatform();
    final storage = sl<LocalStorage>();
    if(storage.terminalID.isEmpty) {
      storage.setTerminalId(await generateTerminalId());
    }

    if (!mounted) return;
    setState(() {
      _appVersion = '${info.version} (${info.buildNumber})';
      _tid = storage.terminalID.isEmpty ? 'Not set' : storage.terminalID;
      _mid = storage.mid.isEmpty ? '...' : storage.mid;
    });
  }

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
          _InfoTile(
            title: 'Terminal ID',
            value: _tid,
            icon: Icons.point_of_sale_outlined,
          ),
          const SizedBox(height: PaxPaymentSpacing.sp10),
          _InfoTile(
            title: 'Merchant ID',
            value: _mid,
            icon: Icons.store_outlined,
          ),
        ],
      ),
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
