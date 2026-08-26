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
  });

  factory TransactionRequest.fromJson(Map<String, dynamic> json) =>
      _$TransactionRequestFromJson(json);

  Map<String, dynamic> toJson() => _$TransactionRequestToJson(this);

  factory TransactionRequest.forCardPayment({
    required double amount,
    required String status,
    required String transactionId,
    String? cardType,
    String? time,
    String? customerName,
    String? storeTag,
    bool refundSupported = false,
    bool isRefund = false,
    bool isRefunded = false,
  }) {
    final id = transactionId.trim().isNotEmpty
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
      status: status,
      time: resolvedTime,
      customerName: customerName ?? 'Walk-in Customer',
      cardType: cardType ?? 'Card',
      refundSupported: refundSupported,
      isRefund: isRefund,
      isRefunded: isRefunded,
      storeTag: resolvedStore,
    );
  }
}
