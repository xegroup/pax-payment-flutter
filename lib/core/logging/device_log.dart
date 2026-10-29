import 'dart:convert';

import 'package:flutter/services.dart';

/// Appends text to `evo_payment_log.txt` on device storage.
class DeviceLog {
  DeviceLog._();

  static const MethodChannel _channel = MethodChannel('pax_device_channel');
  static const int _maxChars = 64000;
  static Future<void> _tail = Future<void>.value();

  /// Queues writes so a request is stored before its response.
  static Future<void> write(String body) {
    final text = body.trim();
    if (text.isEmpty) return Future<void>.value();
    final pending = _tail.then((_) => _append(text));
    _tail = pending.catchError((Object error, StackTrace _) {
      // ignore: avoid_print
      print('DeviceLog write failed: $error');
    });
    return pending;
  }

  static Future<void> _append(String text) async {
    try {
      await _channel.invokeMethod<void>('appendDeviceLog', {'text': text});
    } on PlatformException catch (e) {
      // ignore: avoid_print
      print('DeviceLog write failed: ${e.code} ${e.message}');
    } on MissingPluginException {
      // ignore: avoid_print
      print('DeviceLog channel is not available on this platform.');
    }
  }

  /// Redacts secrets and full card numbers before they are written to disk.
  static String describe(dynamic value) {
    try {
      final encoded = jsonEncode(_redact(value));
      final pretty = const JsonEncoder.withIndent('  ').convert(jsonDecode(encoded));
      return _truncate(pretty);
    } catch (_) {
      return _truncate(_maskPan(value?.toString() ?? '(empty)'));
    }
  }

  static dynamic _redact(dynamic value, {String? key}) {
    if (key != null && _isSensitiveKey(key)) return '***';
    if (value is Map) {
      return value.map(
        (k, v) => MapEntry(k.toString(), _redact(v, key: k.toString())),
      );
    }
    if (value is List) {
      return value.map((item) => _redact(item)).toList();
    }
    if (value is String) return _maskPan(value);
    return value;
  }

  static bool _isSensitiveKey(String key) {
    final normalized = key.toLowerCase().replaceAll('_', '');
    const needles = [
      'password',
      'pin',
      'token',
      'secret',
      'authorization',
      'cvv',
      'cvc',
      'track',
    ];
    return needles.any(normalized.contains);
  }

  static final RegExp _pan = RegExp(r'\b\d{13,19}\b');

  static String _maskPan(String raw) {
    return raw.replaceAllMapped(_pan, (match) {
      final digits = match.group(0)!;
      return '${'*' * (digits.length - 4)}${digits.substring(digits.length - 4)}';
    });
  }

  static String _truncate(String text) {
    if (text.length <= _maxChars) return text;
    return '${text.substring(0, _maxChars)}\n...[truncated]';
  }
}
