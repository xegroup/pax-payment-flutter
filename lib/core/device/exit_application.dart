import 'package:flutter/material.dart';

import 'pax_device_channel.dart';

/// Asks before closing Xe Pay, then exits without the system relaunching it.
Future<void> confirmExitApplication(BuildContext context) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Exit application'),
      content: const Text('Close Xe Pay?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: const Text('Exit'),
        ),
      ],
    ),
  );
  if (confirmed != true || !context.mounted) return;
  await PaxDeviceChannel.exitApp();
}
