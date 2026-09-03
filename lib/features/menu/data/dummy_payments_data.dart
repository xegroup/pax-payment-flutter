import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/payment_transaction.dart';
import '../../transaction/data/transaction_time_utils.dart';

/// Period filter for payments list.
enum PaymentsPeriodFilter { today, week, month }

/// Status filter for payments list.
enum PaymentsStatusFilter { all, success, failed }

/// Shared local transaction ledger backing list + analytics screens.
///
/// The name is kept to avoid touching many imports.
class DummyPaymentsData {
  DummyPaymentsData._();

  static const _storageKey = 'payment_transactions';
  static final List<PaymentTransaction> all = <PaymentTransaction>[];
  static bool _initialized = false;

  static Future<void> initialize() async {
    if (_initialized) return;
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw != null && raw.isNotEmpty) {
      final decoded = jsonDecode(raw);
      if (decoded is List) {
        all
          ..clear()
          ..addAll(
            decoded
                .whereType<Map>()
                .map((e) => PaymentTransaction.fromJson(
                      e.map((k, v) => MapEntry(k.toString(), v)),
                    )),
          );
      }
    }
    all.sort((a, b) => _parsedTime(b.time).compareTo(_parsedTime(a.time)));
    _initialized = true;
  }

  static Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(
      all.map((e) => e.toJson()).toList(growable: false),
    );
    await prefs.setString(_storageKey, encoded);
  }

  /// Adds a new transaction and keeps list sorted by newest first.
  static Future<void> addTransaction(PaymentTransaction transaction) async {
    if (!_initialized) {
      await initialize();
    }
    all.add(transaction);
    all.sort((a, b) => _parsedTime(b.time).compareTo(_parsedTime(a.time)));
    await _persist();
  }

  static PaymentTransaction? findById(String id) {
    for (final t in all) {
      if (t.id == id) return t;
    }
    return null;
  }

  /// Marks the original sale as refunded after a successful refund row is added.
  static Future<void> markTransactionRefunded(String originalId) async {
    if (!_initialized) await initialize();
    final index = all.indexWhere((t) => t.id == originalId);
    if (index < 0) return;
    all[index] = all[index].copyWith(
      status: PaymentStatus.refunded,
      isRefunded: true,
      refundSupported: false,
    );
    await _persist();
  }

  static Future<void> updateTransaction(PaymentTransaction updated) async {
    if (!_initialized) await initialize();
    final index = all.indexWhere((t) => t.id == updated.id);
    if (index < 0) return;
    all[index] = updated;
    await _persist();
  }

  static Future<void> clearAll() async {
    if (!_initialized) {
      await initialize();
    }
    all.clear();
    await _persist();
  }

  /// Payments visible for list filters.
  static List<PaymentTransaction> filtered({
    required PaymentsPeriodFilter period,
    required PaymentsStatusFilter status,
  }) {
    return filterList(
      all,
      period: period,
      status: status,
    );
  }

  static List<PaymentTransaction> filterList(
    List<PaymentTransaction> source, {
    required PaymentsPeriodFilter period,
    required PaymentsStatusFilter status,
  }) {
    var list = source.where((e) => _matchesPeriod(e, period)).toList();
    switch (status) {
      case PaymentsStatusFilter.all:
        break;
      case PaymentsStatusFilter.success:
        list = list
            .where(
              (e) =>
                  e.status == PaymentStatus.success ||
                  e.status == PaymentStatus.refunded,
            )
            .toList();
      case PaymentsStatusFilter.failed:
        list = list.where((e) => e.status == PaymentStatus.failed).toList();
    }
    return list;
  }

  static bool _matchesPeriod(
    PaymentTransaction transaction,
    PaymentsPeriodFilter period,
  ) {
    final txDate = _calendarDate(transaction.time);
    final today = TransactionTimeUtils.todayForOffset(
      _timeOffset(transaction.time),
    );

    switch (period) {
      case PaymentsPeriodFilter.today:
        return txDate.year == today.year &&
            txDate.month == today.month &&
            txDate.day == today.day;
      case PaymentsPeriodFilter.week:
        final start = today.subtract(const Duration(days: 7));
        return !txDate.isBefore(start);
      case PaymentsPeriodFilter.month:
        final start = today.subtract(const Duration(days: 30));
        return !txDate.isBefore(start);
    }
  }

  /// Inclusive chart range [start, end] by calendar days.
  static List<PaymentTransaction> inRange(
    DateTime start,
    DateTime end, {
    String? storeFilter,
    List<PaymentTransaction>? source,
  }) {
    final data = source ?? all;
    final startDay = DateTime(start.year, start.month, start.day);
    final endDay = DateTime(end.year, end.month, end.day);
    var list = data.where((e) {
      final txDate = _calendarDate(e.time);
      return !txDate.isBefore(startDay) && !txDate.isAfter(endDay);
    }).toList();
    if (storeFilter != null && storeFilter.isNotEmpty) {
      list = list.where((e) => _storeMatches(e, storeFilter)).toList();
    }
    return list;
  }

  static const String defaultStoreTag = '2Burger Bar';

  static bool _storeMatches(PaymentTransaction e, String storeFilter) {
    final tag = e.storeTag.isEmpty ? defaultStoreTag : e.storeTag;
    return tag == storeFilter;
  }

  /// Net volume grouped by calendar day (newest first).
  static List<({DateTime day, double net, int txnCount})> dailyNetByDay({
    int maxDays = 30,
  }) {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day)
        .subtract(Duration(days: maxDays - 1));
    final map = <DateTime, ({double net, int count})>{};
    for (final t in all) {
      final d = _calendarDate(t.time);
      if (d.isBefore(start)) continue;
      final cur = map[d] ?? (net: 0.0, count: 0);
      map[d] = (net: cur.net + t.amount, count: cur.count + 1);
    }
    final out = map.entries
        .map((e) => (day: e.key, net: e.value.net, txnCount: e.value.count))
        .toList();
    out.sort((a, b) => b.day.compareTo(a.day));
    return out;
  }

  /// Every calendar day in [rangeStart, rangeEnd] with gross volume (0 if none).
  static List<(DateTime day, double amount)> dailyBars(
    DateTime rangeStart,
    DateTime rangeEnd, {
    String? storeFilter,
    List<PaymentTransaction>? source,
  }) {
    final totals = dailyTotals(
      rangeStart,
      rangeEnd,
      storeFilter: storeFilter,
      source: source,
    );
    final start = DateTime(rangeStart.year, rangeStart.month, rangeStart.day);
    final end = DateTime(rangeEnd.year, rangeEnd.month, rangeEnd.day);
    final out = <(DateTime, double)>[];
    for (var d = start; !d.isAfter(end); d = d.add(const Duration(days: 1))) {
      final key = DateTime(d.year, d.month, d.day);
      out.add((key, totals[key] ?? 0));
    }
    return out;
  }

  /// Cumulative sales trend over each day in range (gross volume).
  static List<(DateTime day, double cumulative)> cumulativeSeries(
    DateTime rangeStart,
    DateTime rangeEnd, {
    String? storeFilter,
    List<PaymentTransaction>? source,
  }) {
    final bars = dailyBars(
      rangeStart,
      rangeEnd,
      storeFilter: storeFilter,
      source: source,
    );
    var run = 0.0;
    return bars.map((e) {
      run += e.$2;
      return (e.$1, run);
    }).toList();
  }

  /// Daily totals for bar chart (success + failed gross).
  static Map<DateTime, double> dailyTotals(
    DateTime rangeStart,
    DateTime rangeEnd, {
    String? storeFilter,
    List<PaymentTransaction>? source,
  }) {
    final txs = inRange(
      rangeStart,
      rangeEnd,
      storeFilter: storeFilter,
      source: source,
    );
    final map = <DateTime, double>{};
    for (final t in txs) {
      final d = _calendarDate(t.time);
      map[d] = (map[d] ?? 0) + t.amount;
    }
    return map;
  }

  static ({double total, int count, double avg}) summary(
    DateTime rangeStart,
    DateTime rangeEnd, {
    String? storeFilter,
    List<PaymentTransaction>? source,
  }) {
    final txs = inRange(
      rangeStart,
      rangeEnd,
      storeFilter: storeFilter,
      source: source,
    ).where((e) => e.status == PaymentStatus.success);
    final list = txs.toList();
    final total = list.fold<double>(0, (s, e) => s + e.amount);
    final count = list.length;
    final avg = count == 0 ? 0.0 : total / count;
    return (total: total, count: count, avg: avg);
  }

  static DateTime _parsedTime(String time) {
    final parsed = DateTime.tryParse(time.trim());
    if (parsed != null) return parsed.toLocal();
    return DateTime.fromMillisecondsSinceEpoch(0);
  }

  static DateTime _calendarDate(String time) {
    final trimmed = time.trim();
    if (trimmed.length >= 10 && trimmed[4] == '-' && trimmed[7] == '-') {
      final year = int.tryParse(trimmed.substring(0, 4));
      final month = int.tryParse(trimmed.substring(5, 7));
      final day = int.tryParse(trimmed.substring(8, 10));
      if (year != null && month != null && day != null) {
        return DateTime(year, month, day);
      }
    }
    final parsed = _parsedTime(trimmed);
    return DateTime(parsed.year, parsed.month, parsed.day);
  }

  static Duration _timeOffset(String time) {
    return TransactionTimeUtils.parseIsoOffset(time) ??
        DateTime.now().timeZoneOffset;
  }
}
