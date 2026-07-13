import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';

/// True when executed under `flutter test`.
bool get isRunningTests {
  if (kIsWeb) return false;
  try {
    return Platform.environment['FLUTTER_TEST'] == 'true';
  } catch (_) {
    return false;
  }
}

bool get isMobilePlatform => !kIsWeb;
