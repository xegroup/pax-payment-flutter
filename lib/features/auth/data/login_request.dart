

import 'package:json_annotation/json_annotation.dart';


part 'login_request.g.dart';
@JsonSerializable()
class LoginRequest {

  final String email;
  final String password;

  // Constructor
  LoginRequest({
    required this.email,
    required this.password,
  });

  // A method to convert JSON data to a LoginResponse object
  factory LoginRequest.fromJson(Map<String, dynamic> json) =>
      _$LoginRequestFromJson(json);

  // A method to convert a LoginResponse object to JSON
  Map<String, dynamic> toJson() => _$LoginRequestToJson(this);
}