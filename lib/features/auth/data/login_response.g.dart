// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'login_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LoginResponse _$LoginResponseFromJson(Map<String, dynamic> json) =>
    LoginResponse(
      user: json['user'] == null
          ? null
          : UserDataModel.fromJson(json['user'] as Map<String, dynamic>),
      message: json['message'] as String? ?? '',
      errors: json['errors'] as String? ?? '',
      token: json['token'] as String? ?? '',
      tokenType: json['token_type'] as String? ?? '',
    );

Map<String, dynamic> _$LoginResponseToJson(LoginResponse instance) =>
    <String, dynamic>{
      'user': instance.user,
      'message': instance.message,
      'errors': instance.errors,
      'token': instance.token,
      'token_type': instance.tokenType,
    };
