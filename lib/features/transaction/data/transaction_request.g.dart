// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TransactionRequest _$TransactionRequestFromJson(Map<String, dynamic> json) =>
    TransactionRequest(
      id: json['id'] as String,
      amount: (json['amount'] as num).toInt(),
      status: json['status'] as String,
      time: json['time'] as String,
      customerName: json['customerName'] as String,
      cardType: json['cardType'] as String,
      refundSupported: json['refundSupported'] as bool,
      isRefund: json['isRefund'] as bool,
      isRefunded: json['isRefunded'] as bool,
      storeTag: json['storeTag'] as String,
    );

Map<String, dynamic> _$TransactionRequestToJson(TransactionRequest instance) =>
    <String, dynamic>{
      'id': instance.id,
      'amount': instance.amount,
      'status': instance.status,
      'time': instance.time,
      'customerName': instance.customerName,
      'cardType': instance.cardType,
      'refundSupported': instance.refundSupported,
      'isRefund': instance.isRefund,
      'isRefunded': instance.isRefunded,
      'storeTag': instance.storeTag,
    };
