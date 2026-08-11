import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';

import 'user_data_model.dart';

part 'login_response.g.dart';

@JsonSerializable()
class LoginResponse {
  final UserDataModel? user;
  final String message;
  final String errors;
  final String token;
  @JsonKey(name: 'token_type')
  final String tokenType;

  LoginResponse({
    this.user,
    this.message = '',
    this.errors = '',
    this.token = '',
    this.tokenType = '',
  });

  bool get isSuccess => token.trim().isNotEmpty;

  String get failureMessage {
    if (errors.trim().isNotEmpty) return errors.trim();
    if (message.trim().isNotEmpty) return message.trim();
    return 'Invalid username or password';
  }

  factory LoginResponse.fromJson(Map<String, dynamic> json) =>
      _$LoginResponseFromJson(json);

  Map<String, dynamic> toJson() => _$LoginResponseToJson(this);

  static LoginResponse? tryParse(Object? data) {
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
      return LoginResponse.fromJson(json);
    } catch (_) {
      return null;
    }
  }
}
