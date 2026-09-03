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
import 'transaction_time_utils.dart';

/// Saves a card transaction from EVO extras ([MainActivity] → method channel).
Future<TransactionResponse?> saveTransactionFromEvoResult(
  Map<String, dynamic>? result, {
  required double amountMajor,
  String? customerName,
  String? storeTag,
  bool isRefund = false,
  String? originalTransactionId,
  String? cardTypeOverride,
  double? slipNumber,
  double? terminalId,
  String? transactionCurrency,
  int? evoResult,
  String? authorizationMessage,
  String? merchantId,
  String? AC,
  String? AID,
  String? ATC,
  String? TSI,
  String? TVR,
  String? date,
  String? maskedCardNumber,
  String? transactionTitle,
  String? cardSource,
  String? cardBrandName,
  String? cardsetName,
  String? serverMessage,
  double? transactionAmount,
}) async {
  if (result == null) return null;

  final statusValue = (result['status'] ?? '').toString().toLowerCase();
  if (statusValue == 'cancelled' || statusValue == 'canceled') {
    return null;
  }

  final amountPence = _resolveAmountPence(
    result,
    amountMajor,
    transactionAmount,
  );
  final paymentStatus = _parsePaymentStatus(result);
  final resolvedStore = storeTag?.trim().isNotEmpty == true
      ? storeTag!.trim()
      : sl<LocalStorage>().currentStore;

  final request = TransactionRequest.forCardPayment(
    amount: amountPence / 100.0,
    status: _apiStatus(paymentStatus),
    transactionId: _resolveTransactionId(result),
    cardType: cardTypeOverride ??
        _readString(result['cardBrandName']) ??
        _readString(result['cardsetName']) ??
        _readString(result['cardType']) ??
        'Card',
    time: _resolveApiTime(result, date),
    customerName: customerName ??
        _readString(transactionTitle) ??
        _readString(result['transactionTitle']) ??
        (isRefund && originalTransactionId != null
            ? 'Refund for $originalTransactionId'
            : null),
    storeTag: resolvedStore,
    refundSupported: !isRefund && paymentStatus == PaymentStatus.success,
    isRefund: isRefund,
    isRefunded: false,
    slipNumber: slipNumber ?? _readDouble(result['slipNumber']) ?? 0,
    terminalId: terminalId ?? _readDouble(result['terminalId']) ?? 0,
    transactionCurrency:
        transactionCurrency ?? _readString(result['transactionCurrency']) ?? '',
    result: evoResult ?? _readInt(result['result']) ?? -1,
    authorizationMessage: authorizationMessage ??
        _readString(result['authorizationMessage']) ??
        '',
    merchantId: merchantId ?? _readString(result['merchantId']) ?? '',
    AC: AC ?? _readString(result['AC']) ?? '',
    AID: AID ?? _readString(result['AID']) ?? '',
    ATC: ATC ?? _readString(result['ATC']) ?? '',
    TSI: TSI ?? _readString(result['TSI']) ?? '',
    TVR: TVR ?? _readString(result['TVR']) ?? '',
    date: date ?? _readString(result['date']) ?? '',
    maskedCardNumber: maskedCardNumber ??
        _readString(result['maskedCardNumber']) ??
        _readString(result['additional']) ??
        _readString(result['cardNumber']) ??
        '',
    transactionTitle:
        transactionTitle ?? _readString(result['transactionTitle']) ?? '',
    cardSource: cardSource ?? _readString(result['cardSource']) ?? '',
    cardBrandName: cardBrandName ?? _readString(result['cardBrandName']) ?? '',
    cardsetName: cardsetName ?? _readString(result['cardsetName']) ?? '',
    serverMessage: serverMessage ??
        _readString(result['serverMessage']) ??
        _readString(result['declineReason']) ??
        '',
    transactionAmount: transactionAmount ?? amountPence.toDouble(),
  );

  return saveCardTransaction(request);
}

Future<TransactionResponse?> saveCardTransaction(
  TransactionRequest request,
) async {
  try {
    developer.log(
      'POST api/app/transactions body=${jsonEncode(request.toJson())}',
      name: 'TransactionSave',
    );
    final response = await MyApiClient.saveTransaction(request);
    developer.log(
      'POST api/app/transactions OK: ${jsonEncode(response.toJson())}',
      name: 'TransactionSave',
    );
    return response;
  } on DioException catch (e) {
    developer.log(
      'POST api/app/transactions FAILED (${e.response?.statusCode}): '
      '${e.response?.data ?? e.message}',
      name: 'TransactionSave',
      error: e,
    );
    final parsed = TransactionResponse.tryParse(e.response?.data);
    if (parsed != null) {
      developer.log(
        'Parsed error response: ${parsed.message}',
        name: 'TransactionSave',
      );
    }
  } catch (e, stack) {
    developer.log(
      'POST api/app/transactions error: $e',
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
}) {
  return saveCardTransaction(
    TransactionRequest.forCardPayment(
      amount: amount,
      status: 'succeeded',
      transactionId: transactionId,
      cardType: 'Cash',
      storeTag: sl<LocalStorage>().currentStore,
      refundSupported: true,
      slipNumber: 0,
      terminalId: 0,
      transactionCurrency: '',
      result: 0,
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
      transactionAmount: amount * 100,
      time: '',
      customerName: '',
    ),
  );
}

int _resolveAmountPence(
  Map<String, dynamic> result,
  double amountMajor,
  double? transactionAmount,
) {
  if (transactionAmount != null && transactionAmount > 0) {
    // Values >= 100 are pence from EVO; smaller values are major units.
    return transactionAmount >= 100
        ? transactionAmount.round()
        : (transactionAmount * 100).round();
  }

  final fromEvo = _readInt(result['transactionAmount']);
  if (fromEvo != null && fromEvo > 0) return fromEvo;

  final fromChannel = _readInt(result['amountCents']);
  if (fromChannel != null && fromChannel > 0) return fromChannel;

  return (amountMajor * 100).round();
}

String _resolveTransactionId(Map<String, dynamic> result) {
  final nativeId = _readString(result['transactionId']);
  if (nativeId != null) return nativeId;

  final slip = _readString(result['slipNumber']);
  if (slip != null) return 'EVO-$slip';

  final auth = _readString(result['authorizationMessage']);
  if (auth != null) return 'EVO-$auth';

  return _generateTransactionId();
}

String _resolveApiTime(Map<String, dynamic> result, String? dateOverride) {
  final date = dateOverride ?? _readString(result['date']);
  final time = _readString(result['time']);
  if (date != null && time != null) {
    final normalizedDate = date.replaceAll('.', '-');
    final normalizedTime = time.length == 5 ? '$time:00' : time;
    return '${normalizedDate}T$normalizedTime';
  }
  if (date != null) {
    return date.replaceAll('.', '-');
  }
  return TransactionTimeUtils.formatApiDateTime(DateTime.now());
}

String _generateTransactionId() {
  const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
  final r = Random.secure();
  return 'TXN-${List.generate(8, (_) => chars[r.nextInt(chars.length)]).join()}';
}

PaymentStatus _parsePaymentStatus(Map<String, dynamic> result) {
  final statusValue = (result['status'] ?? '').toString().toLowerCase();
  return switch (statusValue) {
    'success' ||
    'approved' ||
    'ok' ||
    'completed' ||
    'true' ||
    'succeeded' => PaymentStatus.success,
    'cancelled' || 'canceled' => PaymentStatus.failed,
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

String? _readString(Object? value) {
  final text = value?.toString().trim() ?? '';
  return text.isEmpty ? null : text;
}

double? _readDouble(Object? value) {
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '');
}

int? _readInt(Object? value) {
  if (value is int) return value;
  if (value is num) return value.round();
  return int.tryParse(value?.toString() ?? '');
}

PaymentStatus? parsePaymentStatus(Map<String, dynamic> result) {
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

/// Saves EVO card/refund result to `POST api/app/transactions`.
Future<TransactionResponse?> saveEvoPaymentResult(
  Map<String, dynamic> result, {
  required int amountCents,
  bool isRefund = false,
  String? originalTransactionId,
}) {
  final status = (result['status'] ?? '').toString().toLowerCase();
  if (status == 'cancelled' || status == 'canceled') {
    return Future.value(null);
  }

  final amountPence =
      _readInt(result['transactionAmount']) ??
      _readInt(result['amountCents']) ??
      amountCents;

  return saveTransactionFromEvoResult(
    result,
    amountMajor: amountPence / 100.0,
    isRefund: isRefund,
    originalTransactionId: originalTransactionId,
    slipNumber: _readDouble(result['slipNumber']) ?? 0,
    terminalId: _readDouble(result['terminalId']) ?? 0,
    transactionCurrency: _readString(result['transactionCurrency']) ?? '',
    authorizationMessage: _readString(result['authorizationMessage']) ?? '',
    merchantId: _readString(result['merchantId']) ?? '',
    AC: _readString(result['AC']) ?? '',
    AID: _readString(result['AID']) ?? '',
    ATC: _readString(result['ATC']) ?? '',
    TSI: _readString(result['TSI']) ?? '',
    TVR: _readString(result['TVR']) ?? '',
    date: _readString(result['date']) ?? '',
    maskedCardNumber: _readString(result['maskedCardNumber']) ??
        _readString(result['additional']) ??
        _readString(result['cardNumber']) ??
        '',
    transactionTitle: _readString(result['transactionTitle']) ?? '',
    cardSource: _readString(result['cardSource']) ?? '',
    cardBrandName: _readString(result['cardBrandName']) ?? '',
    cardsetName: _readString(result['cardsetName']) ?? '',
    serverMessage: _readString(result['serverMessage']) ??
        _readString(result['declineReason']) ??
        '',
    transactionAmount: amountPence.toDouble(),
    evoResult: _readInt(result['result']) ?? -1,
  );
}
