import 'package:dio/dio.dart';

class AuthInterceptor extends Interceptor {
  String? _authToken;

  AuthInterceptor({String? authToken}) : _authToken = authToken;

  void setAuthToken(String token) {
    _authToken = token;
  }

  void clearAuthToken() {
    _authToken = null;
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (_authToken != null && _authToken!.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $_authToken';
    }
    return handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // Handle 401 Unauthorized - token expired
    if (err.response?.statusCode == 401) {
      print("🔐 Token expired - implement refresh logic here");
      // TODO: Implement token refresh logic
    }
    return handler.next(err);
  }
}