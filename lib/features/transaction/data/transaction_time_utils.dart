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

  /// Calendar date encoded in the API ISO string (`YYYY-MM-DD` segment).
  static DateTime calendarDateFromIso(String iso) {
    final trimmed = iso.trim();
    if (trimmed.length >= 10 &&
        trimmed[4] == '-' &&
        trimmed[7] == '-') {
      final year = int.tryParse(trimmed.substring(0, 4));
      final month = int.tryParse(trimmed.substring(5, 7));
      final day = int.tryParse(trimmed.substring(8, 10));
      if (year != null && month != null && day != null) {
        return DateTime(year, month, day);
      }
    }

    final parsed = DateTime.tryParse(trimmed);
    if (parsed == null) {
      return _localCalendarDate(DateTime.now());
    }

    final offset = parsed.timeZoneOffset;
    final zoned = parsed.toUtc().add(offset);
    return DateTime(zoned.year, zoned.month, zoned.day);
  }

  static DateTime todayForOffset(Duration offset) {
    final now = DateTime.now().toUtc().add(offset);
    return DateTime(now.year, now.month, now.day);
  }

  static DateTime calendarDateForTransaction(PaymentTransaction tx) {
    final raw = tx.isoTime?.trim();
    if (raw != null && raw.isNotEmpty) {
      return calendarDateFromIso(raw);
    }
    return _localCalendarDate(tx.time);
  }

  static Duration offsetForTransaction(PaymentTransaction tx) {
    final raw = tx.isoTime?.trim();
    if (raw != null && raw.isNotEmpty) {
      return parseIsoOffset(raw) ?? DateTime.now().timeZoneOffset;
    }
    return DateTime.now().timeZoneOffset;
  }

  static DateTime _localCalendarDate(DateTime time) {
    final local = time.toLocal();
    return DateTime(local.year, local.month, local.day);
  }
}
