import 'package:json_annotation/json_annotation.dart';

import '../../menu/data/dummy_payments_data.dart';
import 'transaction_time_utils.dart';

part 'transaction_request.g.dart';

@JsonSerializable()
class TransactionRequest {
  final String id;
  final int amount;
  final String status;
  final String time;
  final String customerName;
  final String cardType;
  final bool refundSupported;
  final bool isRefund;
  final bool isRefunded;
  final String storeTag;

  // evo data
  final double slipNumber;
  final double terminalId;
  final String transactionCurrency;
  final int result;
  final String authorizationMessage;
  final String merchantId;
  final String AC;
  final String AID;
  final String ATC;
  final String TSI;
  final String TVR;
  final String date;
  final String maskedCardNumber;
  final String transactionTitle;
  final String cardSource;
  final String cardBrandName;
  final String cardsetName;
  final String serverMessage;
  final double transactionAmount;

  TransactionRequest({
    required this.id,
    required this.amount,
    required this.status,
    required this.time,
    required this.customerName,
    required this.cardType,
    required this.refundSupported,
    required this.isRefund,
    required this.isRefunded,
    required this.storeTag,
    // evo data
    required this.slipNumber,
    required this.terminalId,
    required this.transactionCurrency,
    required this.result,
    required this.authorizationMessage,
    required this.merchantId,
    required this.AC,
    required this.AID,
    required this.ATC,
    required this.TSI,
    required this.TVR,
    required this.date,
    required this.maskedCardNumber,
    required this.transactionTitle,
    required this.cardSource,
    required this.cardBrandName,
    required this.cardsetName,
    required this.serverMessage,
    required this.transactionAmount,
  });

  factory TransactionRequest.fromJson(Map<String, dynamic> json) =>
      _$TransactionRequestFromJson(json);

  Map<String, dynamic> toJson() => _$TransactionRequestToJson(this);

  factory TransactionRequest.forCardPayment({
    required double amount,
    String? status,
    required String? transactionId,
    required String? cardType,
    required String? time,
    required String? customerName,
    required String? storeTag,
    bool refundSupported = true,
    bool isRefund = false,
    bool isRefunded = false,
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
    required double transactionAmount,
  }) {
    final id = transactionId!.trim().isNotEmpty
        ? transactionId.trim()
        : 'TXN-${DateTime.now().millisecondsSinceEpoch}';
    final resolvedTime = time?.trim().isNotEmpty == true
        ? time!.trim()
        : TransactionTimeUtils.formatApiDateTime(DateTime.now());
    final resolvedStore = storeTag?.trim().isNotEmpty == true
        ? storeTag!.trim()
        : DummyPaymentsData.defaultStoreTag;

    return TransactionRequest(
      id: id,
      amount: (amount * 100).round(),
      status: status ?? "NA",
      time: resolvedTime,
      customerName: customerName ?? 'Walk-in Customer',
      cardType: cardType ?? 'Card',
      refundSupported: refundSupported,
      isRefund: isRefund,
      isRefunded: isRefunded,
      storeTag: resolvedStore,
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
    );
  }
}
