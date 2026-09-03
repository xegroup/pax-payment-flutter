import 'dart:core';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:pax_payment/features/transaction/data/evo_data_model.dart';

import '../core/services/payment_service.dart';
import '../features/menu/models/payment_transaction.dart';
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
  final msg = (result['serverMessage'] ??
          result['declineReason'] ??
          result['message'] ??
          result['error'] ??
          '')
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

double? parseTerminalId(Map<String, dynamic> result) {
  final terminalId = result['terminalId']?.trim();
  if (terminalId != null && terminalId.isNotEmpty) return terminalId;
  return null;
}

double? parseSlipNumber(Map<String, dynamic> result) {
  final slipNumber = result['slipNumber']?.trim();
  if (slipNumber != null && slipNumber.isNotEmpty) return slipNumber;
  return null;
}

String? parseTransactionCurrency(Map<String, dynamic> result) {
  final transactionCurrency = result['transactionCurrency']?.toString().trim();
  if (transactionCurrency != null && transactionCurrency.isNotEmpty)
    return transactionCurrency;
  return null;
}

int? parseResult(Map<String, dynamic> result) {
  final resultParsed = result['result']?.trim();
  if (resultParsed != null && resultParsed.isNotEmpty) return resultParsed;
  return null;
}

String? parseAuthorizationMessage(Map<String, dynamic> result) {
  final authorizationMessage = result['authorizationMessage']?.trim();
  if (authorizationMessage != null && authorizationMessage.isNotEmpty)
    return authorizationMessage;
  return null;
}

String? parseMerchantId(Map<String, dynamic> result) {
  final merchantId = result['merchantId']?.toString().trim();
  if (merchantId != null && merchantId.isNotEmpty) return merchantId;
  return null;
}

String? parseAC(Map<String, dynamic> result) {
  final ac = result['AC']?.toString().trim();
  if (ac != null && ac.isNotEmpty) return ac;
  return null;
}

String? parseAID(Map<String, dynamic> result) {
  final aid = result['AID']?.toString().trim();
  if (aid != null && aid.isNotEmpty) return aid;
  return null;
}

String? parseATC(Map<String, dynamic> result) {
  final atc = result['ATC']?.toString().trim();
  if (atc != null && atc.isNotEmpty) return atc;
  return null;
}

String? parseTSI(Map<String, dynamic> result) {
  final tsi = result['TSI']?.toString().trim();
  if (tsi != null && tsi.isNotEmpty) return tsi;
  return null;
}

String? parseTVR(Map<String, dynamic> result) {
  final tvr = result['TVR']?.toString().trim();
  if (tvr != null && tvr.isNotEmpty) return tvr;
  return null;
}

String? parseDate(Map<String, dynamic> result) {
  final date = result['date']?.toString().trim();
  if (date != null && date.isNotEmpty) return date;
  return null;
}

String? parseTime(Map<String, dynamic> result) {
  final time = result['time']?.toString().trim();
  if (time != null && time.isNotEmpty) return time;
  return null;
}

String? parseType(Map<String, dynamic> result) {
  final type = result['type']?.toString().trim();
  if (type != null && type.isNotEmpty) return type;
  return null;
}

String? parseTerminalTime(Map<String, dynamic> result) {
  final date = result['date']?.toString().trim();
  if (date != null && date.isNotEmpty) return date;
  return null;
}

String? parseMaskedCardNumber(Map<String, dynamic> result) {
  final maskedCardNumber = result['maskedCardNumber']?.toString().trim();
  if (maskedCardNumber != null && maskedCardNumber.isNotEmpty)
    return maskedCardNumber;
  return null;
}

String? parseTransactionTitle(Map<String, dynamic> result) {
  final transactionTitle = result['transactionTitle']?.toString().trim();
  if (transactionTitle != null && transactionTitle.isNotEmpty)
    return transactionTitle;
  return null;
}

String? parseCardSource(Map<String, dynamic> result) {
  final cardSource = result['cardSource']?.toString().trim();
  if (cardSource != null && cardSource.isNotEmpty) return cardSource;
  return null;
}

String? parseCardBrandName(Map<String, dynamic> result) {
  final cardBrandName = result['cardBrandName']?.toString().trim();
  if (cardBrandName != null && cardBrandName.isNotEmpty) return cardBrandName;
  return null;
}

String? parseCardsetName(Map<String, dynamic> result) {
  final cardsetName = result['cardsetName']?.toString().trim();
  if (cardsetName != null && cardsetName.isNotEmpty) return cardsetName;
  return null;
}

String? parseServerMessage(Map<String, dynamic> result) {
  final serverMessage = result['serverMessage']?.toString().trim();
  if (serverMessage != null && serverMessage.isNotEmpty) return serverMessage;
  return null;
}

double roundMoney(double v) => double.parse(v.toStringAsFixed(2));

Future<void> startCardPaymentFlow(
  BuildContext context, {
  required double amount,
  bool popWithResult = false,
}) async {
  final paymentService = PaymentService();

  String? nativeId = "";
  String? transactionId = "";
  String? last4 = "";
  String? cardType = "";
  String? terminalTime = "";
  double? slipNumber;
  double? terminalId;
  String? transactionCurrency;
  int? evoResult;
  String? authorizationMessage;
  String? merchantId;
  String? AC;
  String? AID;
  String? ATC;
  String? TSI;
  String? TVR;
  String? date;
  String? maskedCardNumber;
  String? transactionTitle;
  String? cardSource;
  String? cardBrandName;
  String? cardsetName;
  String? serverMessage;
  double? transactionAmount;
   Map<String, dynamic>? result;

  try {
    result = await paymentService.startPayment(
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
    terminalTime = parseTerminalTime(result);
    terminalId = parseTerminalId(result);
    slipNumber = parseSlipNumber(result);
    terminalId = parseTerminalId(result);
    transactionCurrency = parseTransactionCurrency(result);
    evoResult = parseResult(result);
    authorizationMessage = parseAuthorizationMessage(result);
    merchantId = parseMerchantId(result);
    AC = parseAC(result);
    AID = parseAID(result);
    ATC = parseATC(result);
    TSI = parseTSI(result);
    TVR = parseTVR(result);
    date = parseDate(result);
    maskedCardNumber = parseCardNumber(result);
    transactionTitle = parseTransactionTitle(result);
    cardSource = parseCardSource(result);
    cardBrandName = parseCardBrandName(result);
    cardsetName = parseCardsetName(result);
    serverMessage = parseServerMessage(result);
    if (!context.mounted) return;

    final status = parsePaymentStatus(result);
    if (status == null) {
      navigateToPaymentDeclined(
        context,
        amount: amount,
        declineReason: 'Payment cancelled',
        popWithResult: popWithResult,
        evo: EvoDataModel(
          slipNumber: slipNumber ?? 0,
          terminalId: terminalId ?? 0,
          transactionCurrency: transactionCurrency ?? "",
          result: evoResult ?? -1,
          authorizationMessage: authorizationMessage ?? "",
          merchantId: merchantId ?? "",
          AC: AC ?? "",
          AID: AID ?? "",
          ATC: ATC ?? "",
          TSI: TSI ?? "",
          TVR: TVR ?? "",
          date: date ?? "",
          maskedCardNumber: maskedCardNumber ?? last4.toString(),
          transactionTitle: transactionTitle ?? "",
          cardSource: cardSource ?? "",
          cardBrandName: cardBrandName ?? "",
          cardsetName: cardsetName ?? "",
          serverMessage: serverMessage ?? "",
          transactionAmount: transactionAmount??0.0
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
          slipNumber: slipNumber ?? 0,
          terminalId: terminalId ?? 0,
          transactionCurrency: transactionCurrency ?? "",
          result: evoResult ?? -1,
          authorizationMessage: authorizationMessage ?? "",
          merchantId: merchantId ?? "",
          AC: AC ?? "",
          AID: AID ?? "",
          ATC: ATC ?? "",
          TSI: TSI ?? "",
          TVR: TVR ?? "",
          date: date ?? "",
          maskedCardNumber: maskedCardNumber ?? last4.toString(),
          transactionTitle: transactionTitle ?? "",
          cardSource: cardSource ?? "",
          cardBrandName: cardBrandName ?? "",
          cardsetName: cardsetName ?? "",
          serverMessage: serverMessage ?? "",
            transactionAmount: transactionAmount??0.0
        ),
      );
    } else {
      navigateToPaymentDeclined(
        context,
        amount: amount,
        declineReason: parseDeclineReason(result),
        popWithResult: popWithResult,
        evo: EvoDataModel(
          slipNumber: slipNumber ?? 0,
          terminalId: terminalId ?? 0,
          transactionCurrency: transactionCurrency ?? "",
          result: evoResult ?? -1,
          authorizationMessage: authorizationMessage ?? "",
          merchantId: merchantId ?? "",
          AC: AC ?? "",
          AID: AID ?? "",
          ATC: ATC ?? "",
          TSI: TSI ?? "",
          TVR: TVR ?? "",
          date: date ?? "",
          maskedCardNumber: maskedCardNumber ?? last4.toString(),
          transactionTitle: transactionTitle ?? "",
          cardSource: cardSource ?? "",
          cardBrandName: cardBrandName ?? "",
          cardsetName: cardsetName ?? "",
          serverMessage: serverMessage ?? "",
            transactionAmount: transactionAmount??0.0
        ),
      );
    }
  } on PaymentServiceException catch (e) {
    if (!context.mounted) return;

    navigateToPaymentDeclined(
      context,
      amount: amount,
      declineReason: e.message,
      popWithResult: popWithResult,
      evo: EvoDataModel(
        slipNumber: slipNumber ?? 0,
        terminalId: terminalId ?? 0,
        transactionCurrency: transactionCurrency ?? "",
        result: evoResult ?? -1,
        authorizationMessage: authorizationMessage ?? "",
        merchantId: merchantId ?? "",
        AC: AC ?? "",
        AID: AID ?? "",
        ATC: ATC ?? "",
        TSI: TSI ?? "",
        TVR: TVR ?? "",
        date: date ?? "",
        maskedCardNumber: maskedCardNumber ?? last4.toString(),
        transactionTitle: transactionTitle ?? "",
        cardSource: cardSource ?? "",
        cardBrandName: cardBrandName ?? "",
        cardsetName: cardsetName ?? "",
        serverMessage: serverMessage ?? "",
        transactionAmount: amount,
      ),
    );
  } catch (_) { // catch 2
    if (!context.mounted) return;

    // await saveFailedCardTransaction(
    //   amount: amount,
    //   transactionId: transactionId,
    //   slipNumber: slipNumber ?? 0,
    //   terminalId: terminalId ?? 0,
    //   transactionCurrency: transactionCurrency ?? "",
    //   result: evoResult ?? -1,
    //   authorizationMessage: authorizationMessage ?? "",
    //   merchantId: merchantId ?? "",
    //   AC: AC ?? "",
    //   AID: AID ?? "",
    //   ATC: ATC ?? "",
    //   TSI: TSI ?? "",
    //   TVR: TVR ?? "",
    //   date: date ?? "",
    //   maskedCardNumber: maskedCardNumber ?? last4.toString(),
    //   transactionTitle: transactionTitle ?? "",
    //   cardSource: cardSource ?? "",
    //   cardBrandName: cardBrandName ?? "",
    //   cardsetName: cardsetName ?? "",
    //   serverMessage: serverMessage ?? "",
    //   transactionAmount: amount,
    // );
    navigateToPaymentDeclined(
      context,
      amount: amount,
      declineReason: 'Payment could not be processed',
      popWithResult: popWithResult,
      evo: EvoDataModel(
        slipNumber: slipNumber ?? 0,
        terminalId: terminalId ?? 0,
        transactionCurrency: transactionCurrency ?? "",
        result: evoResult ?? -1,
        authorizationMessage: authorizationMessage ?? "",
        merchantId: merchantId ?? "",
        AC: AC ?? "",
        AID: AID ?? "",
        ATC: ATC ?? "",
        TSI: TSI ?? "",
        TVR: TVR ?? "",
        date: date ?? "",
        maskedCardNumber: maskedCardNumber ?? last4.toString(),
        transactionTitle: transactionTitle ?? "",
        cardSource: cardSource ?? "",
        cardBrandName: cardBrandName ?? "",
        cardsetName: cardsetName ?? "",
        serverMessage: serverMessage ?? "",
        transactionAmount: transactionAmount??0.0,
      ),
    );
  }
}
