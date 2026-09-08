// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SettingsModel _$SettingsModelFromJson(Map<String, dynamic> json) =>
    SettingsModel(
      tipEnabled: json['tipEnabled'] as bool,
      cashPaymentEnabled: json['cashPaymentEnabled'] as bool,
      managerPin: json['managerPin'] as String?,
      terminalName: json['terminalName'] as String?,
      profileImage: json['profileImage'] as String?,
      businessName: json['businessName'] as String?,
      businessNumber: json['businessNumber'] as String?,
      businessEmail: json['businessEmail'] as String?,
      businessAddress: json['businessAddress'] as String?,
      terminalId: json['terminalId'] as String?,
      merchantId: json['merchantId'] as String?,
    );

Map<String, dynamic> _$SettingsModelToJson(SettingsModel instance) =>
    <String, dynamic>{
      'tipEnabled': instance.tipEnabled,
      'cashPaymentEnabled': instance.cashPaymentEnabled,
      'managerPin': ?instance.managerPin,
      'terminalName': ?instance.terminalName,
      'profileImage': ?instance.profileImage,
      'businessName': ?instance.businessName,
      'businessNumber': ?instance.businessNumber,
      'businessEmail': ?instance.businessEmail,
      'businessAddress': ?instance.businessAddress,
      'terminalId': ?instance.terminalId,
      'merchantId': ?instance.merchantId,
    };
