// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'save_settings_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SaveSettingsResponse _$SaveSettingsResponseFromJson(
  Map<String, dynamic> json,
) => SaveSettingsResponse(
  message: json['message'] as String? ?? '',
  settings: json['settings'] == null
      ? null
      : SettingsModel.fromJson(json['settings'] as Map<String, dynamic>),
);

Map<String, dynamic> _$SaveSettingsResponseToJson(
  SaveSettingsResponse instance,
) => <String, dynamic>{
  'settings': instance.settings,
  'message': instance.message,
};
