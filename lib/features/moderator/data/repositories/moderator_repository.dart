/// Data source for moderator application API calls.
import 'package:dio/dio.dart';
import 'package:uni_social_student/core/network/api_constants.dart';
import 'package:uni_social_student/core/network/network_client.dart';
import 'package:uni_social_student/features/auth_login/data/models/api_response.dart';

class ModeratorRepository {
  final Dio _dio;

  ModeratorRepository({Dio? dio}) : _dio = dio ?? NetworkClient.instance;

  /// Submit a moderator application.
  Future<ApiResponse> apply(String arguments) async {
    try {
      final response = await _dio.post(ApiConstants.moderatorApply, data: {
        'arguments': arguments,
      });
      return ApiResponse.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.response != null && e.response!.data is Map) {
        return ApiResponse.fromJson(e.response!.data as Map<String, dynamic>);
      }
      return ApiResponse(success: false, message: 'Error de conexión.');
    } catch (e) {
      return ApiResponse(success: false, message: 'Error inesperado: $e');
    }
  }
}
