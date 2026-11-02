import 'package:flutter/services.dart';

/// Android device actions (Wi‑Fi settings, etc.).
class PaxDeviceChannel {
  static const MethodChannel _channel = MethodChannel('pax_device_channel');

  static Future<void> openWifiSettings() async {
    await _channel.invokeMethod<void>('openWifiSettings');
  }

  /// Sends plain text to the device printer when native support exists.
  static Future<void> printText(String text) async {
    await _channel.invokeMethod<void>('printText', <String, dynamic>{'text': text});
  }

  /// Closes Xe Pay without the system opening it again as the Home app.
  static Future<void> exitApp() async {
    await _channel.invokeMethod<void>('exitApp');
  }
}
