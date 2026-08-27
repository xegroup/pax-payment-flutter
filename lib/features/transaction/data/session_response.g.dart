// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'session_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SessionResponse _$SessionResponseFromJson(Map<String, dynamic> json) =>
    SessionResponse(
      valid: json['valid'] as bool,
      userId: (json['userId'] as num?)?.toInt() ?? 0,
      status: json['status'] as String? ?? '',
      expiresAt: json['expiresAt'] as String? ?? '',
      expiresIn: (json['expiresIn'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$SessionResponseToJson(SessionResponse instance) =>
    <String, dynamic>{
      'valid': instance.valid,
      'userId': instance.userId,
      'status': instance.status,
      'expiresAt': instance.expiresAt,
      'expiresIn': instance.expiresIn,
    };
