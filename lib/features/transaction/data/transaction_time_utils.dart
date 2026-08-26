import '../../menu/models/payment_transaction.dart';

/// Parses API timestamps such as `2026-08-14T17:24:07+01:00`.
class TransactionTimeUtils {
  TransactionTimeUtils._();

  static final _offsetPattern = RegExp(r'([+-])(\d{2}):(\d{2})$');

  static Duration? parseIsoOffset(String iso) {
    final match = _offsetPattern.firstMatch(iso.trim());
    if (match != null) {
      final sign = match.group(1) == '-' ? -1 : 1;
      final hours = int.parse(match.group(2)!);
      final minutes = int.parse(match.group(3)!);
      return Duration(minutes: sign * (hours * 60 + minutes));
    }
    if (iso.trim().endsWith('Z')) {
      return Duration.zero;
    }
    return null;
  }

  static DateTime todayForOffset(Duration offset) {
    final now = DateTime.now().toUtc().add(offset);
    return DateTime(now.year, now.month, now.day);
  }




  /// Formats timestamps for the API, e.g. `2026-08-14T17:24:07+01:00`.
  static String formatApiDateTime(
    DateTime time, {
    Duration offset = const Duration(hours: 1),
  }) {
    final zoned = time.toUtc().add(offset);
    String two(int v) => v.toString().padLeft(2, '0');
    final sign = offset.isNegative ? '-' : '+';
    final totalMinutes = offset.inMinutes.abs();
    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;
    return '${zoned.year}-${two(zoned.month)}-${two(zoned.day)}T'
        '${two(zoned.hour)}:${two(zoned.minute)}:${two(zoned.second)}'
        '$sign${two(hours)}:${two(minutes)}';
  }
}
