// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'evo_data_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EvoDataModel _$EvoDataModelFromJson(Map<String, dynamic> json) => EvoDataModel(
  slipNumber: (json['slipNumber'] as num).toDouble(),
  terminalId: (json['terminalId'] as num).toDouble(),
  transactionCurrency: json['transactionCurrency'] as String,
  result: (json['result'] as num).toInt(),
  authorizationMessage: json['authorizationMessage'] as String,
  merchantId: json['merchantId'] as String,
  AC: json['AC'] as String,
  AID: json['AID'] as String,
  ATC: json['ATC'] as String,
  TSI: json['TSI'] as String,
  TVR: json['TVR'] as String,
  date: json['date'] as String,
  maskedCardNumber: json['maskedCardNumber'] as String,
  transactionTitle: json['transactionTitle'] as String,
  cardSource: json['cardSource'] as String,
  cardBrandName: json['cardBrandName'] as String,
  cardsetName: json['cardsetName'] as String,
  serverMessage: json['serverMessage'] as String,
  transactionAmount: (json['transactionAmount'] as num).toDouble(),
);

Map<String, dynamic> _$EvoDataModelToJson(EvoDataModel instance) =>
    <String, dynamic>{
      'slipNumber': instance.slipNumber,
      'terminalId': instance.terminalId,
      'transactionCurrency': instance.transactionCurrency,
      'result': instance.result,
      'authorizationMessage': instance.authorizationMessage,
      'merchantId': instance.merchantId,
      'AC': instance.AC,
      'AID': instance.AID,
      'ATC': instance.ATC,
      'TSI': instance.TSI,
      'TVR': instance.TVR,
      'date': instance.date,
      'maskedCardNumber': instance.maskedCardNumber,
      'transactionTitle': instance.transactionTitle,
      'cardSource': instance.cardSource,
      'cardBrandName': instance.cardBrandName,
      'cardsetName': instance.cardsetName,
      'serverMessage': instance.serverMessage,
      'transactionAmount': instance.transactionAmount,
    };
