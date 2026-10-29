import 'package:dio/dio.dart';

import 'device_log.dart';

/// Writes each API call's request and response into the device log file.
class ApiFileLogInterceptor extends Interceptor {
  static int _nextId = 1;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final id = _nextId++;
    options.extra['deviceLogId'] = id;
    DeviceLog.write(_formatRequest(id, options));
    handler.next(options);
  }

  @override
  void onResponse(Response<dynamic> response, ResponseInterceptorHandler handler) {
    final options = response.requestOptions;
    final id = options.extra['deviceLogId'];
    final buffer = StringBuffer()
      ..writeln('[API RESPONSE] #$id')
      ..writeln('${options.method} ${options.uri}')
      ..writeln('status: ${response.statusCode}')
      ..writeln('body:')
      ..write(DeviceLog.describe(response.data));
    DeviceLog.write(buffer.toString());
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final options = err.requestOptions;
    final id = options.extra['deviceLogId'];
    final buffer = StringBuffer()
      ..writeln('[API ERROR] #$id')
      ..writeln('${options.method} ${options.uri}')
      ..writeln('type: ${err.type.name}')
      ..writeln('message: ${err.message ?? ''}');
    final status = err.response?.statusCode;
    if (status != null) {
      buffer.writeln('status: $status');
    }
    if (err.response?.data != null) {
      buffer
        ..writeln('body:')
        ..write(DeviceLog.describe(err.response?.data));
    }
    DeviceLog.write(buffer.toString());
    handler.next(err);
  }

  String _formatRequest(int id, RequestOptions options) {
    final headers = Map<String, dynamic>.from(options.headers);
    final buffer = StringBuffer()
      ..writeln('[API REQUEST] #$id')
      ..writeln('${options.method} ${options.uri}')
      ..writeln('headers:')
      ..writeln(DeviceLog.describe(headers));
    if (options.queryParameters.isNotEmpty) {
      buffer
        ..writeln('query:')
        ..writeln(DeviceLog.describe(options.queryParameters));
    }
    buffer
      ..writeln('body:')
      ..write(_describeBody(options.data));
    return buffer.toString();
  }

  String _describeBody(dynamic data) {
    if (data == null) return '(empty)';
    if (data is FormData) {
      return DeviceLog.describe({
        'fields': {for (final field in data.fields) field.key: field.value},
        'files': data.files.map((file) => file.key).toList(),
      });
    }
    return DeviceLog.describe(data);
  }
}
