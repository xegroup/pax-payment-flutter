import 'package:dio/dio.dart';

import '../../features/auth/data/login_response.dart';
import '../../features/transaction/data/transaction_response.dart';
import '../../features/transaction/data/transactions_list_response.dart';
import '../di/injection.dart';
import '../security/secure_storage_service.dart';
import '../services/api_service.dart';
import 'AuthInterceptor.dart';

class MyApiClient {
  static ApiService? _apiService;
  static String? _currentBaseUrl;
  static AuthInterceptor? _authInterceptor;
  static Dio? _dio;

  static ApiService get instance {
    if (_apiService == null) {
      throw Exception('ApiService not initialized! Call init(baseUrl) first.');
    }
    return _apiService!;
  }

  static void init(String baseUrl, {String? initialAuthToken}) {
    if (_apiService != null && _currentBaseUrl == baseUrl) {
      if (initialAuthToken != null && initialAuthToken.isNotEmpty) {
        setAuthToken(initialAuthToken);
      }
      return;
    }

    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 30),
        validateStatus: (status) => status != null && status < 500,
      ),
    );

    _authInterceptor = AuthInterceptor(authToken: initialAuthToken);
    _dio!.interceptors.add(_authInterceptor!);
    _dio!.interceptors.add(
      LogInterceptor(
        request: true,
        requestBody: true,
        responseBody: true,
        error: true,
        logPrint: (object) => print('📡 API: $object'),
      ),
    );

    _apiService = ApiService(_dio!, baseUrl: baseUrl);
    _currentBaseUrl = baseUrl;
  }

  static void setAuthToken(String token) {
    _authInterceptor?.setAuthToken(token);
  }

  static Future<void> persistAuthToken(String token) async {
    final trimmed = token.trim();
    setAuthToken(trimmed);
    await sl<SecureStorageService>().setAuthToken(trimmed);
  }

  static Future<void> loadPersistedAuthToken() async {
    final token = await sl<SecureStorageService>().getAuthToken();
    if (token != null && token.isNotEmpty) {
      setAuthToken(token);
    }
  }

  static Future<void> clearAuthToken() async {
    _authInterceptor?.clearAuthToken();
    await sl<SecureStorageService>().clearAuthToken();
  }

  static void reset() {
    _apiService = null;
    _currentBaseUrl = null;
    _dio = null;
    _authInterceptor?.clearAuthToken();
    _authInterceptor = null;
  }

  static Future<LoginResponse> login(Map<String, dynamic> body) {
    return instance.login(body);
  }

  static Future<LoginResponse> signup(Map<String, dynamic> body) {
    return instance.signup(body);
  }

  static Future<TransactionResponse> saveTransaction(Map<String, dynamic> body) {
    return instance.saveTransaction(body);
  }

  static Future<TransactionsListResponse> getAllTransactions() async {
    await loadPersistedAuthToken();
    return instance.getAllTransactions();
  }
}
