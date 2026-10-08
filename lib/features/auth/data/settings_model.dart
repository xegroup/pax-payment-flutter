import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';

part 'settings_model.g.dart';

@JsonSerializable(includeIfNull: false)
class SettingsModel {
  final bool tipEnabled;
  final bool cashPaymentEnabled;
  final String? managerPin;
  final String? terminalName;
  final String? profileImage;
  @JsonKey(readValue: _readPaymentScreenLogo)
  final String? paymentScreenLogo;
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
    this.paymentScreenLogo,
    this.businessName,
    this.businessNumber,
    this.businessEmail,
    this.businessAddress,
    this.terminalId,
    this.merchantId
  });

  static Object? _readPaymentScreenLogo(Map<dynamic, dynamic> json, String key) {
    return json['paymentScreenLogo'] ??
        json['payment_screen_logo'] ??
        json['logo'] ??
        json['logoUrl'] ??
        json['logo_url'];
  }

  // From JSON to Dart object
  factory SettingsModel.fromJson(Map<String, dynamic> json) =>
      _$SettingsModelFromJson(json);

  /// Accepts a flat settings object or `{ settings: ... }` / `{ data: ... }`.
  static SettingsModel? tryParse(Object? data) {
    final root = _asMap(data);
    if (root == null) return null;
    final settings = _unwrapSettings(root);
    if (settings == null) return null;

    return SettingsModel(
      tipEnabled: _asBool(settings['tipEnabled'] ?? settings['tip_enabled']),
      cashPaymentEnabled: _asBool(
        settings['cashPaymentEnabled'] ?? settings['cash_payment_enabled'],
      ),
      managerPin: _asString(settings['managerPin'] ?? settings['manager_pin']),
      terminalName: _asString(
        settings['terminalName'] ?? settings['terminal_name'],
      ),
      profileImage: _asString(
        settings['profileImage'] ?? settings['profile_image'],
      ),
      paymentScreenLogo: _logoFrom(settings) ?? _logoFrom(root),
      businessName: _asString(
        settings['businessName'] ?? settings['business_name'],
      ),
      businessNumber: _asString(
        settings['businessNumber'] ?? settings['business_number'],
      ),
      businessEmail: _asString(
        settings['businessEmail'] ?? settings['business_email'],
      ),
      businessAddress: _asString(
        settings['businessAddress'] ?? settings['business_address'],
      ),
      terminalId: _asString(settings['terminalId'] ?? settings['terminal_id']),
      merchantId: _asString(settings['merchantId'] ?? settings['merchant_id']),
    );
  }

  static Map<String, dynamic>? _asMap(Object? data) {
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);
    if (data is String && data.trim().isNotEmpty) {
      try {
        return _asMap(jsonDecode(data));
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  static Map<String, dynamic>? _unwrapSettings(Map<String, dynamic> json) {
    for (final key in const ['settings', 'data', 'result']) {
      final child = _asMap(json[key]);
      if (child == null) continue;
      final nested = _asMap(child['settings']);
      if (nested != null && (_looksLikeSettings(nested) || _logoFrom(nested) != null)) {
        return nested;
      }
      if (_looksLikeSettings(child) || _logoFrom(child) != null) return child;
    }
    if (_looksLikeSettings(json) || _logoFrom(json) != null) return json;
    return null;
  }

  static bool _looksLikeSettings(Map<String, dynamic> json) {
    const keys = [
      'tipEnabled',
      'tip_enabled',
      'cashPaymentEnabled',
      'cash_payment_enabled',
      'managerPin',
      'manager_pin',
      'terminalId',
      'terminal_id',
      'merchantId',
      'merchant_id',
      'paymentScreenLogo',
      'payment_screen_logo',
      'logo',
    ];
    return keys.any(json.containsKey);
  }

  static String? _logoFrom(Map<String, dynamic> json) {
    const keys = [
      'paymentScreenLogo',
      'payment_screen_logo',
      'logo',
      'logoUrl',
      'logo_url',
      'imageUrl',
      'image_url',
    ];
    for (final key in keys) {
      final value = json[key];
      if (value is Map) {
        final nested = _asString(
          value['url'] ?? value['image'] ?? value['src'] ?? value['path'],
        );
        if (nested != null) return nested;
      }
      final text = _asString(value);
      if (text != null) return text;
    }
    return null;
  }

  static bool _asBool(Object? value) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    final text = value?.toString().trim().toLowerCase() ?? '';
    return text == 'true' || text == '1' || text == 'yes';
  }

  static String? _asString(Object? value) {
    final text = value?.toString().trim() ?? '';
    if (text.isEmpty || text.toLowerCase() == 'null') return null;
    return text;
  }

  // From Dart object to JSON
  Map<String, dynamic> toJson() => _$SettingsModelToJson(this);
}
