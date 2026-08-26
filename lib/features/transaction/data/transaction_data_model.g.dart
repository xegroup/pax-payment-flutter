// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction_data_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TransactionDataModel _$TransactionDataModelFromJson(
  Map<String, dynamic> json,
) => TransactionDataModel(
  id: json['id'] as String,
  amount: (json['amount'] as num).toDouble(),
  status: json['status'] as String,
  time: json['time'] as String,
  customerName: json['customerName'] as String,
  cardType: json['cardType'] as String,
  refundSupported: json['refundSupported'] as bool,
  isRefund: json['isRefund'] as bool,
  isRefunded: json['isRefunded'] as bool,
  originalTransactionId: json['originalTransactionId'] as String?,
  cardLast4: json['cardLast4'] as String?,
  evoTransactionRef: json['evoTransactionRef'] as String?,
  storeTag: json['storeTag'] as String,
);

Map<String, dynamic> _$TransactionDataModelToJson(
  TransactionDataModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'amount': instance.amount,
  'status': instance.status,
  'time': instance.time,
  'customerName': instance.customerName,
  'cardType': instance.cardType,
  'refundSupported': instance.refundSupported,
  'isRefund': instance.isRefund,
  'isRefunded': instance.isRefunded,
  'originalTransactionId': instance.originalTransactionId,
  'cardLast4': instance.cardLast4,
  'evoTransactionRef': instance.evoTransactionRef,
  'storeTag': instance.storeTag,
};
