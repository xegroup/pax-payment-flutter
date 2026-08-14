import 'dart:math';

import 'package:flutter/material.dart';

import '../core/di/injection.dart';
import '../core/database/local_storage.dart';
import '../core/services/payment_service.dart';
import '../features/menu/data/dummy_payments_data.dart';
import '../features/menu/models/payment_transaction.dart';
import 'payment_navigation.dart';

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

Future<void> startCardPaymentFlow(
  BuildContext context, {
  required double amount,
  bool popWithResult = false,
  Future<void> Function(PaymentTransaction transaction)? onTransactionSaved,
}) async {
  final paymentService = PaymentService();

  try {
    final result = await paymentService.startPayment(
      amount: (amount * 100).round(),
      title: 'Payment',
      paymentMethod: 'card',
    );

    if (!context.mounted) return;

    final status = parsePaymentStatus(result);
    if (status == null) {
      navigateToPaymentDeclined(
        context,
        amount: amount,
        declineReason: 'Payment cancelled',
        popWithResult: popWithResult,
      );
      return;
    }

    final nativeId = result['transactionId']?.toString().trim();
    final transactionId = (nativeId != null && nativeId.isNotEmpty)
        ? nativeId
        : generateTransactionId();
    final last4 = extractCardLast4(result['cardNumber']);
    final cardType = parseCardType(result);
    final evoRef = nativeId?.isNotEmpty == true ? nativeId : null;

    if (status == PaymentStatus.success) {
      final tx = await saveCardTransaction(
        amount: amount,
        status: PaymentStatus.success,
        transactionId: transactionId,
        cardLast4: last4,
        cardType: cardType,
        evoTransactionRef: evoRef,
      );
      await onTransactionSaved?.call(tx);
      if (!context.mounted) return;
      navigateToPaymentSuccess(
        context,
        amount: amount,
        cardLast4: last4,
        cardType: cardType,
        transactionId: transactionId,
        popWithResult: popWithResult,
      );
    } else {
      final tx = await saveCardTransaction(
        amount: amount,
        status: PaymentStatus.failed,
        transactionId: transactionId,
        cardLast4: last4,
        cardType: cardType,
        evoTransactionRef: evoRef,
      );
      await onTransactionSaved?.call(tx);
      if (!context.mounted) return;
      navigateToPaymentDeclined(
        context,
        amount: amount,
        declineReason: parseDeclineReason(result),
        popWithResult: popWithResult,
      );
    }
  } on PaymentServiceException catch (e) {
    if (!context.mounted) return;
    navigateToPaymentDeclined(
      context,
      amount: amount,
      declineReason: e.message,
      popWithResult: popWithResult,
    );
  } catch (_) {
    if (!context.mounted) return;
    navigateToPaymentDeclined(
      context,
      amount: amount,
      declineReason: 'Payment could not be processed',
      popWithResult: popWithResult,
    );
  }
}
