import 'dart:math';

import '../core/di/injection.dart';
import '../core/database/local_storage.dart';
import '../features/menu/data/dummy_payments_data.dart';
import '../features/menu/models/payment_transaction.dart';

/// TXN- + 8 random uppercase alphanumeric characters.
String generateTransactionId() {
  const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
  final r = Random.secure();
  return 'TXN-${List.generate(8, (_) => chars[r.nextInt(chars.length)]).join()}';
}

String? extractCardLast4(Object? raw) {
  final digits = raw?.toString().replaceAll(RegExp(r'\D'), '') ?? '';
  if (digits.length >= 4) {
    return digits.substring(digits.length - 4);
  }
  return null;
}

String parseCardType(Map<String, dynamic> result) {
  final scheme = (result['cardType'] ??
          result['cardScheme'] ??
          result['brand'] ??
          '')
      .toString()
      .trim();
  if (scheme.isNotEmpty) return scheme;
  return 'Visa';
}

PaymentStatus? parsePaymentStatus(Map<String, dynamic> result) {
  final statusValue = (result['status'] ?? '').toString().toLowerCase();
  return switch (statusValue) {
    'success' || 'approved' || 'ok' || 'completed' || 'true' =>
      PaymentStatus.success,
    'cancelled' || 'canceled' => null,
    _ => PaymentStatus.failed,
  };
}

String parseDeclineReason(Map<String, dynamic> result) {
  final msg = (result['message'] ??
          result['declineReason'] ??
          result['error'] ??
          '')
      .toString()
      .trim();
  if (msg.isNotEmpty) return msg;
  return 'Payment could not be processed';
}

Future<PaymentTransaction> saveCardTransaction({
  required double amount,
  required PaymentStatus status,
  required String transactionId,
  String? cardLast4,
  String? cardType,
  String? evoTransactionRef,
}) async {
  final storeTag = sl<LocalStorage>().currentStore;
  final tx = PaymentTransaction(
    id: transactionId,
    amount: amount,
    status: status,
    time: DateTime.now(),
    customerName: 'Walk-in Customer',
    cardType: cardType ?? 'Card',
    refundSupported: status == PaymentStatus.success,
    cardLast4: cardLast4,
    evoTransactionRef: evoTransactionRef,
    storeTag: storeTag,
  );
  await DummyPaymentsData.addTransaction(tx);
  return tx;
}

Future<PaymentTransaction> saveCashTransaction({
  required double amount,
  required String transactionId,
}) async {
  return saveCardTransaction(
    amount: amount,
    status: PaymentStatus.success,
    transactionId: transactionId,
    cardType: 'Cash',
    cardLast4: null,
    evoTransactionRef: null,
  );
}

double roundMoney(double v) => double.parse(v.toStringAsFixed(2));
