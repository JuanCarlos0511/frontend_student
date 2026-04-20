/// Data source for bus location API calls.
import 'package:dio/dio.dart';
import 'package:uni_social_student/core/network/api_constants.dart';
import 'package:uni_social_student/core/network/network_client.dart';
import 'package:uni_social_student/features/auth_login/data/models/api_response.dart';

class BusRepository {
  final Dio _dio;

  BusRepository({Dio? dio}) : _dio = dio ?? NetworkClient.instance;

  /// Reports bus arrival at given coordinates.
  Future<ApiResponse> reportBus(double latitude, double longitude) async {
    try {
      final response = await _dio.post(ApiConstants.busReport, data: {
        'latitude': latitude,
        'longitude': longitude,
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

  /// Cancels the user's active bus report.
  Future<ApiResponse> cancelReport() async {
    try {
      final response = await _dio.delete(ApiConstants.busReport);
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

  /// Gets all active bus reports (< 10 min old).
  Future<ApiResponse> getActiveReports() async {
    try {
      final response = await _dio.get(ApiConstants.busActive);
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
