import 'package:json_annotation/json_annotation.dart';
part 'user_data_model.g.dart';
@JsonSerializable()
class UserDataModel {
  final int? id;
  final String? name;
  final String? username;
  final String? email;
  final String? phone;
  final String? status;
  final String? created_at;
  final String? updated_at;

  UserDataModel({
    this.id,
    this.name,
    this.username,
    this.email,
    this.phone,
    this.status,
    this.created_at,
    this.updated_at
  });

  // From JSON to Dart object
  factory UserDataModel.fromJson(Map<String, dynamic> json) =>
      _$UserDataModelFromJson(json);

  // From Dart object to JSON
  Map<String, dynamic> toJson() => _$UserDataModelToJson(this);
}