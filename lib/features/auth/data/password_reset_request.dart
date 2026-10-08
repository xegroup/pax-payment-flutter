

import 'package:json_annotation/json_annotation.dart';


part 'password_reset_request.g.dart';
@JsonSerializable()
class PasswordResetRequest {

  final String email;
  final String token;
  final String password;
  @JsonKey(name: 'password_confirmation')
  final String passwordConfirmation;
  // Constructor
  PasswordResetRequest({
    required this.email,
    required this.token,
    required this.password,
    required this.passwordConfirmation
  });

  // A method to convert JSON data to a LoginResponse object
  factory PasswordResetRequest.fromJson(Map<String, dynamic> json) =>
      _$PasswordResetRequestFromJson(json);

  // A method to convert a LoginResponse object to JSON
  Map<String, dynamic> toJson() => _$PasswordResetRequestToJson(this);
}