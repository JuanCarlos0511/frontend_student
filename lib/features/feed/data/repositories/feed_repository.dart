/// Data source for posts API calls using Dio.
import 'package:dio/dio.dart';
import 'package:uni_social_student/core/network/api_constants.dart';
import 'package:uni_social_student/core/network/network_client.dart';
import 'package:uni_social_student/features/auth_login/data/models/api_response.dart';

class FeedRepository {
  final Dio _dio;

  FeedRepository({Dio? dio}) : _dio = dio ?? NetworkClient.instance;

  /// Obtiene todas las publicaciones del feed.
  Future<ApiResponse> fetchPosts({int limit = 50, int offset = 0}) async {
    try {
      final response = await _dio.get(
        ApiConstants.posts,
        queryParameters: {'limit': limit, 'offset': offset},
      );
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

  /// Crea una nueva publicación (con imagen opcional).
  Future<ApiResponse> createPost({
    required String content,
    String? imagePath,
  }) async {
    try {
      final formData = FormData.fromMap({
        'content': content,
        if (imagePath != null)
          'postImage': await MultipartFile.fromFile(imagePath),
      });

      final response = await _dio.post(
        ApiConstants.posts,
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
        message: 'No se pudo crear la publicación.',
      );
    } catch (e) {
      return ApiResponse(success: false, message: 'Error inesperado: $e');
    }
  }

  /// Actualiza una publicación existente.
  Future<ApiResponse> updatePost({
    required int postId,
    required String content,
    String? imagePath,
  }) async {
    try {
      final formData = FormData.fromMap({
        'content': content,
        if (imagePath != null)
          'postImage': await MultipartFile.fromFile(imagePath),
      });

      final response = await _dio.put(
        '${ApiConstants.posts}/$postId',
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
        message: 'No se pudo actualizar la publicación.',
      );
    } catch (e) {
      return ApiResponse(success: false, message: 'Error inesperado: $e');
    }
  }

  /// Elimina una publicación.
  Future<ApiResponse> deletePost(int postId) async {
    try {
      final response = await _dio.delete('${ApiConstants.posts}/$postId');
      return ApiResponse.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.response != null && e.response!.data is Map) {
        return ApiResponse.fromJson(
            e.response!.data as Map<String, dynamic>);
      }
      return ApiResponse(
        success: false,
        message: 'No se pudo eliminar la publicación.',
      );
    } catch (e) {
      return ApiResponse(success: false, message: 'Error inesperado: $e');
    }
  }

  // ── Replies ──────────────────────────────────────────────────

  /// Obtiene todas las respuestas de un post.
  Future<ApiResponse> fetchReplies(int postId, {int limit = 100, int offset = 0}) async {
    try {
      final response = await _dio.get(
        ApiConstants.postReplies(postId),
        queryParameters: {'limit': limit, 'offset': offset},
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

  /// Crea una nueva respuesta en un post.
  Future<ApiResponse> createReply({
    required int postId,
    required String content,
  }) async {
    try {
      final response = await _dio.post(
        ApiConstants.postReplies(postId),
        data: {'content': content},
      );
      return ApiResponse.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.response != null && e.response!.data is Map) {
        return ApiResponse.fromJson(e.response!.data as Map<String, dynamic>);
      }
      return ApiResponse(success: false, message: 'No se pudo enviar la respuesta.');
    } catch (e) {
      return ApiResponse(success: false, message: 'Error inesperado: $e');
    }
  }

  /// Actualiza una respuesta existente.
  Future<ApiResponse> updateReply({
    required int postId,
    required int replyId,
    required String content,
  }) async {
    try {
      final response = await _dio.put(
        '${ApiConstants.postReplies(postId)}/$replyId',
        data: {'content': content},
      );
      return ApiResponse.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.response != null && e.response!.data is Map) {
        return ApiResponse.fromJson(e.response!.data as Map<String, dynamic>);
      }
      return ApiResponse(success: false, message: 'No se pudo actualizar la respuesta.');
    } catch (e) {
      return ApiResponse(success: false, message: 'Error inesperado: $e');
    }
  }

  /// Elimina una respuesta.
  Future<ApiResponse> deleteReply(int postId, int replyId) async {
    try {
      final response = await _dio.delete('${ApiConstants.postReplies(postId)}/$replyId');
      return ApiResponse.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.response != null && e.response!.data is Map) {
        return ApiResponse.fromJson(e.response!.data as Map<String, dynamic>);
      }
      return ApiResponse(success: false, message: 'No se pudo eliminar la respuesta.');
    } catch (e) {
      return ApiResponse(success: false, message: 'Error inesperado: $e');
    }
  }
}
