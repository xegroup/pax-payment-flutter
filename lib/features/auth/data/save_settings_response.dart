import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';
import 'package:pax_payment/features/auth/data/settings_model.dart';

part 'save_settings_response.g.dart';

@JsonSerializable()
class SaveSettingsResponse {
  final SettingsModel? settings;
  final String message;

  SaveSettingsResponse({
    this.message = '',
    this.settings,
  });

  factory SaveSettingsResponse.fromJson(Map<String, dynamic> json) =>
      _$SaveSettingsResponseFromJson(json);

  Map<String, dynamic> toJson() => _$SaveSettingsResponseToJson(this);

  static SaveSettingsResponse? tryParse(Object? data) {
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

    final normalized = _normalize(json);

    try {
      return SaveSettingsResponse.fromJson(normalized);
    } catch (_) {
      final message = normalized['message']?.toString() ?? '';
      SettingsModel? settings;
      final settingsJson = normalized['settings'];
      if (settingsJson is Map<String, dynamic>) {
        settings = _parseSettings(settingsJson);
      } else if (settingsJson is Map) {
        settings = _parseSettings(Map<String, dynamic>.from(settingsJson));
      }
      return SaveSettingsResponse(message: message, settings: settings);
    }
  }

  static Map<String, dynamic> _normalize(Map<String, dynamic> json) {
    if (json['settings'] is Map) {
      return json;
    }

    if (json['data'] is Map) {
      return {
        'message': json['message']?.toString() ?? '',
        'settings': Map<String, dynamic>.from(json['data'] as Map),
      };
    }

    const settingKeys = [
      'managerPin',
      'manager_pin',
      'tipEnabled',
      'cashPaymentEnabled',
      'terminalName',
      'terminalId',
      'merchantId',
    ];
    if (settingKeys.any(json.containsKey)) {
      final settings = Map<String, dynamic>.from(json);
      settings.remove('message');
      return {
        'message': json['message']?.toString() ?? '',
        'settings': settings,
      };
    }

    return json;
  }

  static SettingsModel? _parseSettings(Map<String, dynamic> json) {
    try {
      return SettingsModel.fromJson(json);
    } catch (_) {
      final managerPin = json['managerPin']?.toString() ??
          json['manager_pin']?.toString();
      if (managerPin == null) return null;
      return SettingsModel(managerPin: managerPin, tipEnabled: false, cashPaymentEnabled: false);
    }
  }
}