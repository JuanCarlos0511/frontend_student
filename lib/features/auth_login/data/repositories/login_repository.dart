/// Data source for login API calls using Dio.
import 'package:dio/dio.dart';
import 'package:uni_social_student/core/network/api_constants.dart';
import 'package:uni_social_student/core/network/network_client.dart';
import 'package:uni_social_student/features/auth_login/data/models/api_response.dart';

class LoginRepository {
  final Dio _dio;

  LoginRepository({Dio? dio}) : _dio = dio ?? NetworkClient.instance;

  Future<ApiResponse> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        ApiConstants.login,
        data: {'email': email, 'password': password},
        options: Options(contentType: Headers.jsonContentType),
      );
      return ApiResponse.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.response != null && e.response!.data is Map) {
        return ApiResponse.fromJson(
            e.response!.data as Map<String, dynamic>);
      }
      return ApiResponse(
        success: false,
        message: 'No se pudo conectar al servidor. Verifica tu conexión.',
      );
    } catch (e) {
      return ApiResponse(
        success: false,
        message: 'Error inesperado: $e',
      );
    }
  }
}
