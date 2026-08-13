// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transactions_list_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TransactionsListResponse _$TransactionsListResponseFromJson(
  Map<String, dynamic> json,
) => TransactionsListResponse(
  data:
      (json['data'] as List<dynamic>?)
          ?.map((e) => TransactionDataModel.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  meta: json['meta'] == null
      ? null
      : TransactionsMetaModel.fromJson(json['meta'] as Map<String, dynamic>),
);

Map<String, dynamic> _$TransactionsListResponseToJson(
  TransactionsListResponse instance,
) => <String, dynamic>{'data': instance.data, 'meta': instance.meta};
