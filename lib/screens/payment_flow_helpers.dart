import 'dart:math';

import 'package:flutter/material.dart';
import 'package:pax_payment/features/transaction/data/evo_data_model.dart';

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

  String? nativeId="";
  String? transactionId="";
  String? last4="";
  String? cardType="";

  try {
    final result = await paymentService.startPayment(
      amount: (amount * 100).round(),
      title: 'Payment',
      paymentMethod: 'card',
    );

    if (!context.mounted) return;

    nativeId = result['transactionId']?.toString().trim();
    transactionId = (nativeId != null && nativeId.isNotEmpty)
        ? nativeId
        : generateTransactionId();
    last4 = parseCardNumber(result);
    cardType = parseCardType(result);
    if (!context.mounted) return;

    final status = parsePaymentStatus(result);
    if (status == null) {
      navigateToPaymentDeclined(
        context,
        amount: amount,
        declineReason: 'Payment cancelled',
        popWithResult: popWithResult,
        evo: EvoDataModel(
          slipNumber: 0,
          terminalId: 0,
          transactionCurrency: "GBP",
          result: 1,
          authorizationMessage: "",
          merchantId: "",
          AC: "",
          AID: "",
          ATC: "",
          TSI: "",
          TVR: "",
          date: "",
          maskedCardNumber: last4.toString(),
          transactionTitle: "",
          cardSource: "",
          cardBrandName: cardType,
          cardsetName: "",
          serverMessage: "",
          transactionAmount: amount,
        ),
      );
      return;
    }



    if (status == PaymentStatus.success) {
      navigateToPaymentSuccess(
        context,
        amount: amount,
        cardLast4: last4,
        cardType: cardType,
        transactionId: transactionId,
        popWithResult: popWithResult,
        evo: EvoDataModel(
          slipNumber: 0,
          terminalId: 0,
          transactionCurrency: "GBP",
          result: 1,
          authorizationMessage: "",
          merchantId: "",
          AC: "",
          AID: "",
          ATC: "",
          TSI: "",
          TVR: "",
          date: "",
          maskedCardNumber: last4.toString(),
          transactionTitle: "",
          cardSource: "",
          cardBrandName: cardType,
          cardsetName: "",
          serverMessage: "",
          transactionAmount: amount,
        ),
      );
    } else {
      await saveFailedCardTransaction(amount: amount,transactionId: '',slipNumber: 0,
          terminalId: 0,
          transactionCurrency: "GBP",
          result: 1,
          authorizationMessage: "",
          merchantId: "",
          AC: "",
          AID: "",
          ATC: "",
          TSI: "",
          TVR: "",
          date: "",
          maskedCardNumber: last4.toString(),
          transactionTitle: "",
          cardSource: "",
          cardBrandName: cardType.toString(),
          cardsetName: "",
          serverMessage: "",
          transactionAmount: amount);
      navigateToPaymentDeclined(
        context,
        amount: amount,
        declineReason: parseDeclineReason(result),
        popWithResult: popWithResult,
        evo: EvoDataModel(
          slipNumber: 0,
          terminalId: 0,
          transactionCurrency: "GBP",
          result: 1,
          authorizationMessage: "",
          merchantId: "",
          AC: "",
          AID: "",
          ATC: "",
          TSI: "",
          TVR: "",
          date: "",
          maskedCardNumber: last4.toString(),
          transactionTitle: "",
          cardSource: "",
          cardBrandName: cardType,
          cardsetName: "",
          serverMessage: "",
          transactionAmount: amount,
        ),
      );
    }
  } on PaymentServiceException catch (e) {
    await saveFailedCardTransaction(amount: amount,transactionId: '',slipNumber: 0,
      terminalId: 0,
      transactionCurrency: "GBP",
      result: 1,
      authorizationMessage: "",
      merchantId: "",
      AC: "",
      AID: "",
      ATC: "",
      TSI: "",
      TVR: "",
      date: "",
      maskedCardNumber: last4.toString(),
      transactionTitle: "",
      cardSource: "",
      cardBrandName: cardType.toString(),
      cardsetName: "",
      serverMessage: "",
      transactionAmount: amount);
    if (!context.mounted) return;
    navigateToPaymentDeclined(
      context,
      amount: amount,
      declineReason: e.message,
      popWithResult: popWithResult,
      evo: EvoDataModel(
        slipNumber: 0,
        terminalId: 0,
        transactionCurrency: "GBP",
        result: 1,
        authorizationMessage: "",
        merchantId: "",
        AC: "",
        AID: "",
        ATC: "",
        TSI: "",
        TVR: "",
        date: "",
        maskedCardNumber: last4.toString(),
        transactionTitle: "",
        cardSource: "",
        cardBrandName: cardType.toString(),
        cardsetName: "",
        serverMessage: "",
        transactionAmount: amount
      ),
    );
  } catch (_) {
    if (!context.mounted) return;
    await saveFailedCardTransaction(amount: amount,transactionId: '',slipNumber: 0,
        terminalId: 0,
        transactionCurrency: "GBP",
        result: 1,
        authorizationMessage: "",
        merchantId: "",
        AC: "",
        AID: "",
        ATC: "",
        TSI: "",
        TVR: "",
        date: "",
        maskedCardNumber: last4.toString(),
        transactionTitle: "",
        cardSource: "",
        cardBrandName: cardType.toString(),
        cardsetName: "",
        serverMessage: "",
        transactionAmount: amount);
    navigateToPaymentDeclined(
      context,
      amount: amount,
      declineReason: 'Payment could not be processed',
      popWithResult: popWithResult,
      evo: EvoDataModel(
        slipNumber: 0,
        terminalId: 0,
        transactionCurrency: "GBP",
        result: 1,
        authorizationMessage: "",
        merchantId: "",
        AC: "",
        AID: "",
        ATC: "",
        TSI: "",
        TVR: "",
        date: "",
        maskedCardNumber: last4.toString(),
        transactionTitle: "",
        cardSource: "",
        cardBrandName: cardType.toString(),
        cardsetName: "",
        serverMessage: "",
        transactionAmount: amount
      ),
    );
  }
}
