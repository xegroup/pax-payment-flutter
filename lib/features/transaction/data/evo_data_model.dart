import 'package:json_annotation/json_annotation.dart';

import '../../menu/models/payment_transaction.dart';

part 'evo_data_model.g.dart';

@JsonSerializable()
class EvoDataModel {
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

  EvoDataModel({
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
    required this.transactionAmount
  });

  factory EvoDataModel.fromJson(Map<String, dynamic> json) =>
      _$EvoDataModelFromJson(json);

  Map<String, dynamic> toJson() => _$EvoDataModelToJson(this);


}
