import 'package:dio/dio.dart';

/// Placeholder HTTP client for future backend integration.
class ApiClient {
  ApiClient({Dio? dio}) : _dio = dio ?? Dio(BaseOptions(connectTimeout: const Duration(seconds: 15)));

  final Dio _dio;

  Dio get client => _dio;

  /// Reserved for authenticated REST calls.
  // ignore: unused_element
  Future<Response<dynamic>> _get(String path) => _dio.get(path);
}
