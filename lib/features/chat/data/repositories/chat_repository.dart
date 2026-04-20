/// Data source for chat API calls.
import 'package:dio/dio.dart';
import 'package:uni_social_student/core/network/api_constants.dart';
import 'package:uni_social_student/core/network/network_client.dart';
import 'package:uni_social_student/features/auth_login/data/models/api_response.dart';

class ChatRepository {
  final Dio _dio;

  ChatRepository({Dio? dio}) : _dio = dio ?? NetworkClient.instance;

  /// Find or create a chat room with seller for a product.
  Future<ApiResponse> findOrCreateRoom({
    required int sellerId,
    required int productId,
    String? productName,
  }) async {
    try {
      final response = await _dio.post(ApiConstants.chatRoom, data: {
        'sellerId': sellerId,
        'productId': productId,
        if (productName != null) 'productName': productName,
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

  /// Get all chat rooms for the current user.
  Future<ApiResponse> getRooms() async {
    try {
      final response = await _dio.get(ApiConstants.chatRooms);
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

  /// Get messages for a specific room.
  Future<ApiResponse> getMessages(int roomId, {int limit = 50, int offset = 0}) async {
    try {
      final response = await _dio.get(
        ApiConstants.chatMessages(roomId),
        queryParameters: {'limit': limit, 'offset': offset},
      );
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

  /// Send a message in a room.
  Future<ApiResponse> sendMessage(int roomId, String message, {int? referencedProductId}) async {
    try {
      final response = await _dio.post(
        ApiConstants.chatMessages(roomId),
        data: {
          'message': message,
          if (referencedProductId != null) 'referencedProductId': referencedProductId,
        },
      );
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
