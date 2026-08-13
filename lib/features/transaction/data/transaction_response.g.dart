// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TransactionResponse _$TransactionResponseFromJson(Map<String, dynamic> json) =>
    TransactionResponse(
      transaction: json['transaction'] == null
          ? null
          : TransactionDataModel.fromJson(
              json['transaction'] as Map<String, dynamic>,
            ),
      message: json['message'] as String? ?? '',
    );

Map<String, dynamic> _$TransactionResponseToJson(
  TransactionResponse instance,
) => <String, dynamic>{
  'transaction': instance.transaction,
  'message': instance.message,
};
