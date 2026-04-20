/// Data source for profile API calls using Dio.
import 'package:dio/dio.dart';
import 'package:uni_social_student/core/network/api_constants.dart';
import 'package:uni_social_student/core/network/network_client.dart';
import 'package:uni_social_student/features/auth_login/data/models/api_response.dart';

class ProfileRepository {
  final Dio _dio;

  ProfileRepository({Dio? dio}) : _dio = dio ?? NetworkClient.instance;

  /// Obtiene el perfil del estudiante autenticado.
  Future<ApiResponse> getProfile() async {
    try {
      final response = await _dio.get(ApiConstants.myProfile);
      return ApiResponse.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.response != null && e.response!.data is Map) {
        return ApiResponse.fromJson(
            e.response!.data as Map<String, dynamic>);
      }
      return ApiResponse(
        success: false,
        message: 'No se pudo conectar al servidor.',
      );
    } catch (e) {
      return ApiResponse(success: false, message: 'Error inesperado: $e');
    }
  }

  /// Actualiza la foto de perfil.
  Future<ApiResponse> updateProfilePhoto(String filePath) async {
    try {
      final formData = FormData.fromMap({
        'profilePhoto': await MultipartFile.fromFile(filePath),
      });
      final response = await _dio.patch(
        ApiConstants.myProfilePhoto,
        data: formData,
      );
      return ApiResponse.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.response != null && e.response!.data is Map) {
        return ApiResponse.fromJson(
            e.response!.data as Map<String, dynamic>);
      }
      return ApiResponse(
        success: false,
        message: 'No se pudo actualizar la foto de perfil.',
      );
    } catch (e) {
      return ApiResponse(success: false, message: 'Error inesperado: $e');
    }
  }
}
