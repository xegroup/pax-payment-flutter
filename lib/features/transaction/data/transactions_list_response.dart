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
}
