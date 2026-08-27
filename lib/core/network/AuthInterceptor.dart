import 'package:dio/dio.dart';

import '../auth/auth_session.dart';

typedef UnauthorizedHandler = Future<void> Function({String? message});

class AuthInterceptor extends Interceptor {
  String? _authToken;
  final UnauthorizedHandler? onUnauthorized;

  AuthInterceptor({
    String? authToken,
    this.onUnauthorized,
  }) : _authToken = authToken;

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
  void onResponse(
    Response response,
    ResponseInterceptorHandler handler,
  ) {
    if (AuthSession.shouldForceLogin(
      statusCode: response.statusCode,
      path: response.requestOptions.path,
    )) {
      onUnauthorized?.call(
        message: 'Your session has expired. Please sign in again.',
      );
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (AuthSession.shouldForceLogin(
      statusCode: err.response?.statusCode,
      path: err.requestOptions.path,
    )) {
      onUnauthorized?.call(
        message: 'Your session has expired. Please sign in again.',
      );
    }
    return handler.next(err);
  }
}
