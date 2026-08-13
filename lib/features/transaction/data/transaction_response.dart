import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';

import 'transaction_data_model.dart';

part 'transaction_response.g.dart';

@JsonSerializable()
class TransactionResponse {
  final TransactionDataModel? transaction;
  final String message;

  TransactionResponse({
    this.transaction,
    this.message = '',
  });

  factory TransactionResponse.fromJson(Map<String, dynamic> json) =>
      _$TransactionResponseFromJson(json);

  Map<String, dynamic> toJson() => _$TransactionResponseToJson(this);

  static TransactionResponse? tryParse(Object? data) {
    Map<String, dynamic>? json;
    if (data is Map<String, dynamic>) {
      json = data;
    } else if (data is Map) {
      json = Map<String, dynamic>.from(data);
    } else if (data is String && data.trim().isNotEmpty) {
      try {
        final decoded = jsonDecode(data);
        if (decoded is Map<String, dynamic>) {
          json = decoded;
        } else if (decoded is Map) {
          json = Map<String, dynamic>.from(decoded);
        }
      } catch (_) {
        return null;
      }
    }
    if (json == null) return null;
    try {
      return TransactionResponse.fromJson(json);
    } catch (_) {
      return null;
    }
  }
}
