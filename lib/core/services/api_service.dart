import 'package:dio/dio.dart';
import 'package:retrofit/dio.dart';
import 'package:retrofit/error_logger.dart';
import 'package:retrofit/http.dart';

import '../../features/auth/data/login_response.dart';

part 'api_service.g.dart';

@RestApi()
abstract class ApiService {
  factory ApiService(Dio dio, {String baseUrl}) = _ApiService;

  @POST("api/app/auth/login")
  @DioResponseType(ResponseType.plain)
  Future<LoginResponse> login(@Body() Map<String, dynamic> body);

  @POST("api/app/auth/register")
  @DioResponseType(ResponseType.plain)
  Future<LoginResponse> signup(@Body() Map<String, dynamic> body);

// @GET("api/dashboard/stats")
  // Future<GetStatsResponse> getStats(@Header("Authorization") String? authorization);




}
