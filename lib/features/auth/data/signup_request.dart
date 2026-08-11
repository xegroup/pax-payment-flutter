

import 'package:json_annotation/json_annotation.dart';

part 'signup_request.g.dart';
@JsonSerializable()
class SignupRequest {

  final String name;
  final String username;
  final String email;
  final String phone;
  final String password;
  final String status;

  // Constructor
  SignupRequest({
    required this.name,
    required this.username,
    required this.email,
    required this.phone,
    required this.password,
    required this.status
  });

  // A method to convert JSON data to a LoginResponse object
  factory SignupRequest.fromJson(Map<String, dynamic> json) =>
      _$SignupRequestFromJson(json);

  // A method to convert a LoginResponse object to JSON
  Map<String, dynamic> toJson() => _$SignupRequestToJson(this);
}