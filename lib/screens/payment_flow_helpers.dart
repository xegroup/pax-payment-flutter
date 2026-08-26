import 'dart:math';

import 'package:flutter/material.dart';

import '../core/services/payment_service.dart';
import '../features/menu/models/payment_transaction.dart';
import '../features/transaction/data/transaction_save_service.dart';
import 'payment_navigation.dart';

export '../features/transaction/data/transaction_save_service.dart';

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
  final scheme =
      (result['cardType'] ?? result['cardScheme'] ?? result['brand'] ?? '')
          .toString()
          .trim();
  if (scheme.isNotEmpty) return scheme;
  return 'Visa';
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

String parseDeclineReason(Map<String, dynamic> result) {
  final msg =
      (result['message'] ?? result['declineReason'] ?? result['error'] ?? '')
          .toString()
          .trim();
  if (msg.isNotEmpty) return msg;
  return 'Payment could not be processed';
}

String? parseCardNumber(Map<String, dynamic> result) {
  final cardNumber = result['cardNumber']?.toString().trim();
  if (cardNumber != null && cardNumber.isNotEmpty) return cardNumber;
  return null;
}
String? parseTerminalTime(Map<String, dynamic> result) {
  final date = result['date']?.toString().trim();
  if (date != null && date.isNotEmpty) return date;
  return null;
}

double roundMoney(double v) => double.parse(v.toStringAsFixed(2));

Future<void> startCardPaymentFlow(
  BuildContext context, {
  required double amount,
  bool popWithResult = false,
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
    final last4 = parseCardNumber(result);
    final cardType = parseCardType(result);
    if (!context.mounted) return;

    if (status == PaymentStatus.success) {
      navigateToPaymentSuccess(
        context,
        amount: amount,
        cardLast4: last4,
        cardType: cardType,
        transactionId: transactionId,
        popWithResult: popWithResult,
      );
    } else {
      navigateToPaymentDeclined(
        context,
        amount: amount,
        declineReason: parseDeclineReason(result),
        popWithResult: popWithResult,
      );
    }
  } on PaymentServiceException catch (e) {
    await saveFailedCardTransaction(amount: amount);
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
