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
  final cardType =
      cardTypeOverride ??
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
    customerName:
        customerName ??
        (isRefund && originalTransactionId != null
            ? 'Refund for $originalTransactionId'
            : null),
    storeTag: resolvedStore,
    refundSupported: !isRefund && paymentStatus == PaymentStatus.success,
    isRefund: isRefund,
    isRefunded: false,

    slipNumber: 0,
    terminalId: 0,
    transactionCurrency: '',
    result: -1,
    authorizationMessage: '',
    merchantId: '',
    AC: '',
    AID: '',
    ATC: '',
    TSI: '',
    TVR: '',
    date: '',
    maskedCardNumber: '',
    transactionTitle: '',
    cardSource: '',
    cardBrandName: '',
    cardsetName: '',
    serverMessage: '',
    transactionAmount: 0,
  );

  return saveCardTransaction(request);
}

Future<TransactionResponse?> saveCardTransaction(
  TransactionRequest request,
) async {
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
  required double slipNumber,
  required double terminalId,
  required String transactionCurrency,
  required int result,
  required String authorizationMessage,
  required String merchantId,
  required String AC,
  required String AID,
  required String ATC,
  required String TSI,
  required String TVR,
  required String date,
  required String maskedCardNumber,
  required String transactionTitle,
  required String cardSource,
  required String cardBrandName,
  required String cardsetName,
  required String serverMessage,
  required double transactionAmount
}) async {
  return saveCardTransaction(
    TransactionRequest.forCardPayment(
      amount: amount,
      status: 'succeeded',
      transactionId: transactionId,
      cardType: 'Cash',
      storeTag: sl<LocalStorage>().currentStore,
      refundSupported: true,
      slipNumber: slipNumber,
      terminalId: terminalId,
      transactionCurrency: transactionCurrency,
      result: result,
      authorizationMessage: authorizationMessage,
      merchantId: merchantId,
      AC: AC,
      AID: AID,
      ATC: ATC,
      TSI: TSI,
      TVR: TVR,
      date: date,
      maskedCardNumber: maskedCardNumber,
      transactionTitle: transactionTitle,
      cardSource: cardSource,
      cardBrandName: cardBrandName,
      cardsetName: cardsetName,
      serverMessage: serverMessage,
      transactionAmount: transactionAmount,
      time: '',
      customerName: ''
    ),
  );
}

Future<TransactionResponse?> saveFailedCardTransaction({
  required double amount,
  required String? transactionId,
  required double slipNumber,
  required double terminalId,
  required String transactionCurrency,
  required int result,
  required String authorizationMessage,
  required String merchantId,
  required String AC,
  required String AID,
  required String ATC,
  required String TSI,
  required String TVR,
  required String date,
  required String maskedCardNumber,
  required String transactionTitle,
  required String cardSource,
  required String cardBrandName,
  required String cardsetName,
  required String serverMessage,
  required double transactionAmount
}) {
  return saveCardTransaction(
    TransactionRequest.forCardPayment(
      amount: amount,
      status: 'failed',
      transactionId: transactionId ?? _generateTransactionId(),
      storeTag: sl<LocalStorage>().currentStore,
      slipNumber: slipNumber,
      terminalId: terminalId,
      transactionCurrency: transactionCurrency,
      result: result,
      authorizationMessage: authorizationMessage,
      merchantId: merchantId,
      AC: AC,
      AID: AID,
      ATC: ATC,
      TSI: TSI,
      TVR: TVR,
      date: date,
      maskedCardNumber: maskedCardNumber,
      transactionTitle: transactionTitle,
      cardSource: cardSource,
      cardBrandName: cardBrandName,
      cardsetName: cardsetName,
      serverMessage: serverMessage,
      transactionAmount: transactionAmount,
      cardType: '',
      time: '',
      customerName: ''
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
