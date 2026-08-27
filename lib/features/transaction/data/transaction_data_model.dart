import 'package:json_annotation/json_annotation.dart';
import 'package:pax_payment/features/transaction/data/evo_data_model.dart';

import '../../menu/models/payment_transaction.dart';

part 'transaction_data_model.g.dart';

@JsonSerializable()
class TransactionDataModel {
  final String id;
  final double amount;
  final String status;
  final String time;
  final String customerName;
  final String cardType;
  final bool refundSupported;
  final bool isRefund;
  final bool isRefunded;
  final String? originalTransactionId;
  final String? cardLast4;
  final String? evoTransactionRef;
  final String storeTag;
  final EvoDataModel? evo;


  TransactionDataModel({
    required this.id,
    required this.amount,
    required this.status,
    required this.time,
    required this.customerName,
    required this.cardType,
    required this.refundSupported,
    required this.isRefund,
    required this.isRefunded,
    this.originalTransactionId,
    this.cardLast4,
    this.evoTransactionRef,
    required this.storeTag,
    required this.evo
  });

  factory TransactionDataModel.fromJson(Map<String, dynamic> json) =>
      _$TransactionDataModelFromJson(json);

  Map<String, dynamic> toJson() => _$TransactionDataModelToJson(this);

  PaymentStatus paymentStatusFromApi() {
    return switch (status.toLowerCase()) {
      'success' || 'succeeded' || 'approved' || 'completed' =>
        PaymentStatus.success,
      'refunded' => PaymentStatus.refunded,
      _ => PaymentStatus.failed,
    };
  }

  double get amountMajor => amount / 100;

  PaymentTransaction toPaymentTransaction() {
    return PaymentTransaction(
      id: id,
      amount: amountMajor,
      status: paymentStatusFromApi(),
      time: time,
      customerName: customerName,
      cardType: cardType,
      refundSupported: refundSupported,
      isRefund: isRefund,
      isRefunded: isRefunded,
      originalTransactionId: _nullableString(originalTransactionId),
      cardLast4: _nullableString(cardLast4),
      evoTransactionRef: _nullableString(evoTransactionRef),
      storeTag: storeTag,
      evo: evo

    );
  }

  static String? _nullableString(String? value) {
    final trimmed = value?.trim() ?? '';
    return trimmed.isEmpty ? null : trimmed;
  }
}
