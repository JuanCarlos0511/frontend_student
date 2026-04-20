/// Data source for market API calls using Dio.
import 'package:dio/dio.dart';
import 'package:uni_social_student/core/network/api_constants.dart';
import 'package:uni_social_student/core/network/network_client.dart';
import 'package:uni_social_student/features/auth_login/data/models/api_response.dart';

class MarketRepository {
  final Dio _dio;

  MarketRepository({Dio? dio}) : _dio = dio ?? NetworkClient.instance;

  /// Obtiene todos los productos del marketplace.
  Future<ApiResponse> fetchProducts({String? category, int limit = 50, int offset = 0}) async {
    try {
      final params = <String, dynamic>{
        'limit': limit,
        'offset': offset,
      };
      if (category != null && category.isNotEmpty) {
        params['category'] = category;
      }

      final response = await _dio.get(
        ApiConstants.market,
        queryParameters: params,
      );
      return ApiResponse.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.response != null && e.response!.data is Map) {
        return ApiResponse.fromJson(e.response!.data as Map<String, dynamic>);
      }
      return ApiResponse(success: false, message: 'No se pudo conectar al servidor.');
    } catch (e) {
      return ApiResponse(success: false, message: 'Error inesperado: $e');
    }
  }

  /// Crea un nuevo producto en el marketplace.
  Future<ApiResponse> createProduct({
    required String title,
    required String description,
    required double price,
    required String category,
    String? location,
    String? schedule,
    String? imagePath,
  }) async {
    try {
      final formData = FormData.fromMap({
        'title': title,
        'description': description,
        'price': price,
        'category': category,
        if (location != null && location.isNotEmpty) 'location': location,
        if (schedule != null && schedule.isNotEmpty) 'schedule': schedule,
        if (imagePath != null)
          'marketImage': await MultipartFile.fromFile(imagePath),
      });

      final response = await _dio.post(
        ApiConstants.market,
        data: formData,
      );
      return ApiResponse.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.response != null && e.response!.data is Map) {
        return ApiResponse.fromJson(e.response!.data as Map<String, dynamic>);
      }
      return ApiResponse(success: false, message: 'No se pudo crear el producto.');
    } catch (e) {
      return ApiResponse(success: false, message: 'Error inesperado: $e');
    }
  }

  /// Actualiza un producto existente en el marketplace.
  Future<ApiResponse> updateProduct({
    required int productId,
    required String title,
    required String description,
    required double price,
    required String category,
    String? location,
    String? schedule,
    String? imagePath,
  }) async {
    try {
      final formData = FormData.fromMap({
        'title': title,
        'description': description,
        'price': price,
        'category': category,
        if (location != null && location.isNotEmpty) 'location': location,
        if (schedule != null && schedule.isNotEmpty) 'schedule': schedule,
        if (imagePath != null && !imagePath.startsWith('http'))
          'marketImage': await MultipartFile.fromFile(imagePath),
      });

      final response = await _dio.put(
        '${ApiConstants.market}/$productId',
        data: formData,
      );
      return ApiResponse.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.response != null && e.response!.data is Map) {
        return ApiResponse.fromJson(e.response!.data as Map<String, dynamic>);
      }
      return ApiResponse(success: false, message: 'No se pudo actualizar el producto.');
    } catch (e) {
      return ApiResponse(success: false, message: 'Error inesperado: $e');
    }
  }

  /// Elimina un producto.
  Future<ApiResponse> deleteProduct(int productId) async {
    try {
      final response = await _dio.delete('${ApiConstants.market}/$productId');
      return ApiResponse.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.response != null && e.response!.data is Map) {
        return ApiResponse.fromJson(e.response!.data as Map<String, dynamic>);
      }
      return ApiResponse(success: false, message: 'No se pudo eliminar el producto.');
    } catch (e) {
      return ApiResponse(success: false, message: 'Error inesperado: $e');
    }
  }
}
