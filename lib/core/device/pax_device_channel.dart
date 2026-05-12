import 'package:flutter/services.dart';

/// Android device actions (Wi‑Fi settings, etc.).
class PaxDeviceChannel {
  static const MethodChannel _channel = MethodChannel('pax_device_channel');

  static Future<void> openWifiSettings() async {
    await _channel.invokeMethod<void>('openWifiSettings');
  }
}
