/// Data source for community API calls.
import 'package:dio/dio.dart';
import 'package:uni_social_student/core/network/api_constants.dart';
import 'package:uni_social_student/core/network/network_client.dart';
import 'package:uni_social_student/features/auth_login/data/models/api_response.dart';

class CommunityRepository {
  final Dio _dio;

  CommunityRepository({Dio? dio}) : _dio = dio ?? NetworkClient.instance;

  Future<ApiResponse> fetchAll({String? category, String? search}) async {
    try {
      final params = <String, dynamic>{};
      if (category != null && category.isNotEmpty && category != 'Todas') {
        params['category'] = category;
      }
      if (search != null && search.isNotEmpty) {
        params['search'] = search;
      }
      final response = await _dio.get(ApiConstants.communities, queryParameters: params);
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

  Future<ApiResponse> getById(int id) async {
    try {
      final response = await _dio.get(ApiConstants.communityDetail(id));
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

  Future<ApiResponse> create({
    required String name,
    required String category,
    String? description,
    String? coverImagePath,
    bool isCourse = false,
    List<String> courseModules = const [],
  }) async {
    try {
      final formData = FormData.fromMap({
        'name': name,
        'category': category,
        if (description != null && description.isNotEmpty) 'description': description,
        if (coverImagePath != null)
          'communityImage': await MultipartFile.fromFile(coverImagePath),
        'isCourse': isCourse.toString(),
        'courseModules': courseModules,
      });
      final response = await _dio.post(ApiConstants.communities, data: formData);
      return ApiResponse.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.response != null && e.response!.data is Map) {
        return ApiResponse.fromJson(e.response!.data as Map<String, dynamic>);
      }
      return ApiResponse(success: false, message: 'Error al crear comunidad.');
    } catch (e) {
      return ApiResponse(success: false, message: 'Error inesperado: $e');
    }
  }

  Future<ApiResponse> join(int communityId) async {
    try {
      final response = await _dio.post(ApiConstants.communityJoin(communityId));
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

  Future<ApiResponse> leave(int communityId) async {
    try {
      final response = await _dio.delete(ApiConstants.communityLeave(communityId));
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

  Future<ApiResponse> deleteCommunity(int communityId) async {
    try {
      final response = await _dio.delete(ApiConstants.communityDetail(communityId));
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

  
  Future<ApiResponse> fetchMembers(int communityId) async {
    try {
      final response = await _dio.get('/communities/$communityId/members');
      return ApiResponse.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      return ApiResponse(success: false, message: e.toString());
    }
  }

  Future<ApiResponse> fetchPosts(int communityId) async {
    try {
      final response = await _dio.get(ApiConstants.communityPosts(communityId));
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

  Future<ApiResponse> createPost({
    required int communityId,
    required String content,
    String? imagePath,
  }) async {
    try {
      final formData = FormData.fromMap({
        'content': content,
        if (imagePath != null)
          'communityImage': await MultipartFile.fromFile(imagePath),
      });
      final response = await _dio.post(
        ApiConstants.communityPosts(communityId),
        data: formData,
      );
      return ApiResponse.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.response != null && e.response!.data is Map) {
        return ApiResponse.fromJson(e.response!.data as Map<String, dynamic>);
      }
      return ApiResponse(success: false, message: 'Error al crear post.');
    } catch (e) {
      return ApiResponse(success: false, message: 'Error inesperado: $e');
    }
  }
}
