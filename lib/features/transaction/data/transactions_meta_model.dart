import 'package:json_annotation/json_annotation.dart';

part 'transactions_meta_model.g.dart';

@JsonSerializable()
class TransactionsMetaModel {
  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;

  TransactionsMetaModel({
    this.currentPage = 1,
    this.lastPage = 1,
    this.perPage = 25,
    this.total = 0,
  });

  factory TransactionsMetaModel.fromJson(Map<String, dynamic> json) =>
      _$TransactionsMetaModelFromJson(json);

  Map<String, dynamic> toJson() => _$TransactionsMetaModelToJson(this);
}
