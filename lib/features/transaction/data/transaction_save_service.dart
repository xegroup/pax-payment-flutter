import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:math';

import 'package:dio/dio.dart';

import '../../../core/database/local_storage.dart';
import '../../../core/di/injection.dart';
import '../../../core/network/MyApiClient.dart';
import '../../menu/models/payment_transaction.dart';
import 'transaction_request.dart';
import 'transaction_response.dart';

/// Persists a transaction from the native EVO result payload
/// ([MainActivity.onEvoActivityResult] → method channel map).
Future<TransactionResponse?> saveTransactionFromEvoResult(
  Map<String, dynamic> result, {
  required double amountMajor,
  String? customerName,
  String? storeTag,
  bool isRefund = false,
  String? originalTransactionId,
  String? cardTypeOverride,
}) async {
  final statusValue = (result['status'] ?? '').toString().toLowerCase();
  if (statusValue == 'cancelled' || statusValue == 'canceled') {
    return null;
  }
  final paymentStatus = _parsePaymentStatus(result) ?? PaymentStatus.failed;
  final nativeId = result['transactionId']?.toString().trim();
  final transactionId = (nativeId != null && nativeId.isNotEmpty)
      ? nativeId
      : _generateTransactionId();
  final terminalTime = _parseTerminalTime(result);
  final cardType = cardTypeOverride ??
      (result['paymentMethod']?.toString().toLowerCase() == 'cash'
          ? 'Cash'
          : _parseCardType(result));
  final resolvedStore = storeTag?.trim().isNotEmpty == true
      ? storeTag!.trim()
      : sl<LocalStorage>().currentStore;

  final request = TransactionRequest.forCardPayment(
    amount: amountMajor.abs(),
    status: _apiStatus(paymentStatus),
    transactionId: transactionId,
    cardType: cardType,
    time: terminalTime,
    customerName: customerName ??
        (isRefund && originalTransactionId != null
            ? 'Refund for $originalTransactionId'
            : null),
    storeTag: resolvedStore,
    refundSupported: !isRefund && paymentStatus == PaymentStatus.success,
    isRefund: isRefund,
    isRefunded: false,
  );

  return saveCardTransaction(request);
}

Future<TransactionResponse?> saveCardTransaction(TransactionRequest request) async {
  try {
    final response = await MyApiClient.saveTransaction(request);
    developer.log(
      'saveTransaction response: ${jsonEncode(response.toJson())}',
      name: 'TransactionSave',
    );
    return response;
  } on DioException catch (e) {
    final parsed = TransactionResponse.tryParse(e.response?.data);
    developer.log(
      'saveTransaction failed (${e.response?.statusCode}): '
      '${parsed?.message ?? e.response?.data ?? e.message}',
      name: 'TransactionSave',
      error: e,
    );
  } catch (e, stack) {
    developer.log(
      'saveTransaction failed: $e',
      name: 'TransactionSave',
      error: e,
      stackTrace: stack,
    );
  }
  return null;
}

Future<TransactionResponse?> saveCashTransaction({
  required double amount,
  required String transactionId,
}) async {
  return saveCardTransaction(
    TransactionRequest.forCardPayment(
      amount: amount,
      status: 'succeeded',
      transactionId: transactionId,
      cardType: 'Cash',
      storeTag: sl<LocalStorage>().currentStore,
      refundSupported: true,
    ),
  );
}

Future<TransactionResponse?> saveFailedCardTransaction({
  required double amount,
  String? transactionId,
}) {
  return saveCardTransaction(
    TransactionRequest.forCardPayment(
      amount: amount,
      status: 'failed',
      transactionId: transactionId ?? _generateTransactionId(),
      storeTag: sl<LocalStorage>().currentStore,
    ),
  );
}

String _generateTransactionId() {
  const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
  final r = Random.secure();
  return 'TXN-${List.generate(8, (_) => chars[r.nextInt(chars.length)]).join()}';
}

PaymentStatus? _parsePaymentStatus(Map<String, dynamic> result) {
  final statusValue = (result['status'] ?? '').toString().toLowerCase();
  return switch (statusValue) {
    'success' ||
    'approved' ||
    'ok' ||
    'completed' ||
    'true' => PaymentStatus.success,
    'cancelled' || 'canceled' => null,
    _ => PaymentStatus.failed,
  };
}

String _apiStatus(PaymentStatus status) {
  return switch (status) {
    PaymentStatus.success => 'succeeded',
    PaymentStatus.refunded => 'refunded',
    PaymentStatus.failed => 'failed',
  };
}

String _parseCardType(Map<String, dynamic> result) {
  final scheme =
      (result['cardType'] ?? result['cardScheme'] ?? result['brand'] ?? '')
          .toString()
          .trim();
  if (scheme.isNotEmpty) return scheme;
  return 'Card';
}

String? _parseTerminalTime(Map<String, dynamic> result) {
  final date = result['date']?.toString().trim();
  if (date != null && date.isNotEmpty) return date;
  return null;
}
