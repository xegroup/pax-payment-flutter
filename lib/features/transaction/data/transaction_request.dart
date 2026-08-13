import 'package:json_annotation/json_annotation.dart';

part 'transaction_request.g.dart';
@JsonSerializable()
class TransactionRequest {

  final String id;
  final int amount;
  final String status;
  final String time;
  final String customerName;
  final String cardType;
  final String refundSupported;
  final bool isRefund;
  final bool isRefunded;
  final String storeTag;

  // Constructor
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
    required this.storeTag
  });

  // A method to convert JSON data to a LoginResponse object
  factory TransactionRequest.fromJson(Map<String, dynamic> json) =>
      _$TransactionRequestFromJson(json);

  // A method to convert a LoginResponse object to JSON
  Map<String, dynamic> toJson() => _$TransactionRequestToJson(this);
}