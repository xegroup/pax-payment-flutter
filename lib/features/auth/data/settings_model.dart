import 'package:json_annotation/json_annotation.dart';

part 'settings_model.g.dart';

@JsonSerializable(includeIfNull: false)
class SettingsModel {
  final bool tipEnabled;
  final bool cashPaymentEnabled;
  final String? managerPin;
  final String? terminalName;
  final String? profileImage;
  final String? businessName;
  final String? businessNumber;
  final String? businessEmail;
  final String? businessAddress;
  final String? terminalId;
  final String? merchantId;

  SettingsModel({
    required this.tipEnabled,
    required this.cashPaymentEnabled,
    this.managerPin,
    this.terminalName,
    this.profileImage,
    this.businessName,
    this.businessNumber,
    this.businessEmail,
    this.businessAddress,
    this.terminalId,
    this.merchantId,
  });

  // From JSON to Dart object
  factory SettingsModel.fromJson(Map<String, dynamic> json) =>
      _$SettingsModelFromJson(json);

  // From Dart object to JSON
  Map<String, dynamic> toJson() => _$SettingsModelToJson(this);
}
