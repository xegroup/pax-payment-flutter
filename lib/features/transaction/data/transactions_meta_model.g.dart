// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transactions_meta_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TransactionsMetaModel _$TransactionsMetaModelFromJson(
  Map<String, dynamic> json,
) => TransactionsMetaModel(
  currentPage: (json['currentPage'] as num?)?.toInt() ?? 1,
  lastPage: (json['lastPage'] as num?)?.toInt() ?? 1,
  perPage: (json['perPage'] as num?)?.toInt() ?? 25,
  total: (json['total'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$TransactionsMetaModelToJson(
  TransactionsMetaModel instance,
) => <String, dynamic>{
  'currentPage': instance.currentPage,
  'lastPage': instance.lastPage,
  'perPage': instance.perPage,
  'total': instance.total,
};
