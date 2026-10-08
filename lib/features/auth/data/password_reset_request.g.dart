// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'password_reset_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PasswordResetRequest _$PasswordResetRequestFromJson(
  Map<String, dynamic> json,
) => PasswordResetRequest(
  email: json['email'] as String,
  token: json['token'] as String,
  password: json['password'] as String,
  passwordConfirmation: json['password_confirmation'] as String,
);

Map<String, dynamic> _$PasswordResetRequestToJson(
  PasswordResetRequest instance,
) => <String, dynamic>{
  'email': instance.email,
  'token': instance.token,
  'password': instance.password,
  'password_confirmation': instance.passwordConfirmation,
};
