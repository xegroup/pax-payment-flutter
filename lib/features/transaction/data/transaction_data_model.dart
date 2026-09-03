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

  /// Parses one API row, skipping malformed nested [evo] payloads.
  static TransactionDataModel? tryParse(Object? raw) {
    if (raw is! Map) return null;
    final json = _normalizeJson(Map<String, dynamic>.from(raw));
    try {
      return TransactionDataModel.fromJson(json);
    } catch (_) {
      try {
        final withoutEvo = Map<String, dynamic>.from(json)..remove('evo');
        return TransactionDataModel.fromJson(withoutEvo);
      } catch (_) {
        return null;
      }
    }
  }

  static Map<String, dynamic> _normalizeJson(Map<String, dynamic> json) {
    bool asBool(Object? value) {
      if (value is bool) return value;
      if (value is num) return value != 0;
      final normalized = value?.toString().trim().toLowerCase();
      return normalized == 'true' || normalized == '1';
    }

    return {
      ...json,
      'id': (json['id'] ?? '').toString(),
      'amount': (json['amount'] as num?)?.toDouble() ?? 0,
      'status': (json['status'] ?? '').toString(),
      'time': (json['time'] ?? '').toString(),
      'customerName': (json['customerName'] ?? '').toString(),
      'cardType': (json['cardType'] ?? 'Card').toString(),
      'refundSupported': asBool(json['refundSupported']),
      'isRefund': asBool(json['isRefund']),
      'isRefunded': asBool(json['isRefunded']),
      'storeTag': (json['storeTag'] ?? '').toString(),
    };
  }

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
