import 'package:dio/dio.dart';
import '../../features/auth/data/login_response.dart';
import '../services/api_service.dart';
import 'AuthInterceptor.dart';

class MyApiClient {
  static ApiService? _apiService;
  static String? _currentBaseUrl;
  static late AuthInterceptor _authInterceptor;
  static late Dio _dio;

  static ApiService get instance {
    if (_apiService == null) {
      throw Exception('ApiService not initialized! Call init(baseUrl) first.');
    }
    return _apiService!;
  }

  static void init(String baseUrl, {String? initialAuthToken}) {
    if (_apiService != null && _currentBaseUrl == baseUrl) {
      print("ℹ️ ApiService already initialized with same URL: $baseUrl");
      return;
    }

    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 30),
      validateStatus: (status) => status != null && status < 500,
    ));

    // Initialize Auth Interceptor
    _authInterceptor = AuthInterceptor(authToken: initialAuthToken);
    _dio.interceptors.add(_authInterceptor);


    // Add Logging Interceptor
    _dio.interceptors.add(LogInterceptor(
      request: true,
      requestBody: true,
      responseBody: true,
      error: true,
      logPrint: (object) => print("📡 API: $object"),
    ));

    // Initialize API Service
    _apiService = ApiService(_dio, baseUrl: baseUrl);
    _currentBaseUrl = baseUrl;

    print("✅ ApiService initialized with baseUrl: $baseUrl");
  }

  static void setAuthToken(String token) {
    _authInterceptor.setAuthToken(token);
    print("🔑 Auth token updated");
  }

  static void clearAuthToken() {
    _authInterceptor.clearAuthToken();
    print("🔑 Auth token cleared");
  }

  static void reset() {
    _apiService = null;
    _currentBaseUrl = null;
    _authInterceptor.clearAuthToken();
    print("🔄 ApiService has been reset.");
  }


  static Future<LoginResponse> login(Map<String, dynamic> body) {
    return instance.login(body);
  }

  static Future<LoginResponse> signup(Map<String, dynamic> body) {
    return instance.signup(body);
  }
}
