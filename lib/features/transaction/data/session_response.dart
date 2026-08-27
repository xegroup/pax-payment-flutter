import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';

part 'session_response.g.dart';

@JsonSerializable()
class SessionResponse {
  final bool valid;
  final int userId;
  final String status;
  final String expiresAt;
  final int expiresIn;

  SessionResponse({
    required this.valid,
    this.userId = 0,
    this.status = '',
    this.expiresAt = '',
    this.expiresIn = 0,
  });

  factory SessionResponse.fromJson(Map<String, dynamic> json) =>
      _$SessionResponseFromJson(json);

  Map<String, dynamic> toJson() => _$SessionResponseToJson(this);

  static SessionResponse? tryParse(Object? data) {
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
      return SessionResponse.fromJson(json);
    } catch (_) {
      return null;
    }
  }
}
