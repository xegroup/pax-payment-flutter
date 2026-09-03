import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';

import 'transaction_data_model.dart';
import 'transactions_meta_model.dart';

part 'transactions_list_response.g.dart';

@JsonSerializable()
class TransactionsListResponse {
  final List<TransactionDataModel> data;
  final TransactionsMetaModel meta;

  TransactionsListResponse({
    this.data = const [],
    TransactionsMetaModel? meta,
  }) : meta = meta ?? TransactionsMetaModel();

  factory TransactionsListResponse.fromJson(Map<String, dynamic> json) =>
      _$TransactionsListResponseFromJson(json);

  Map<String, dynamic> toJson() => _$TransactionsListResponseToJson(this);

  static TransactionsListResponse? tryParse(Object? data) {
    if (data is List) {
      final rows = data
          .map(TransactionDataModel.tryParse)
          .whereType<TransactionDataModel>()
          .toList();
      return TransactionsListResponse(data: rows);
    }

    Map<String, dynamic>? json;
    if (data is Map<String, dynamic>) {
      json = data;
    } else if (data is Map) {
      json = Map<String, dynamic>.from(data);
    } else if (data is String && data.trim().isNotEmpty) {
      try {
        final decoded = jsonDecode(data);
        if (decoded is List) {
          return tryParse(decoded);
        }
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
      return TransactionsListResponse.fromJson(json);
    } catch (_) {
      final rows = (json['data'] as List<dynamic>? ?? const [])
          .map(TransactionDataModel.tryParse)
          .whereType<TransactionDataModel>()
          .toList();
      if (rows.isEmpty) return null;
      final metaRaw = json['meta'];
      final meta = metaRaw is Map<String, dynamic>
          ? TransactionsMetaModel.fromJson(metaRaw)
          : metaRaw is Map
              ? TransactionsMetaModel.fromJson(
                  Map<String, dynamic>.from(metaRaw),
                )
              : null;
      return TransactionsListResponse(data: rows, meta: meta);
    }
  }
}
