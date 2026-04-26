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
      
  // --- Folders & Files ---
  Future<ApiResponse> fetchFolders(int communityId) async {
    try {
      final response = await _dio.get('/communities/$communityId/folders');
      return ApiResponse.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      return ApiResponse(success: false, message: e.toString());
    }
  }

  Future<ApiResponse> createFolder(int communityId, String name) async {
    try {
      final response = await _dio.post('/communities/$communityId/folders', data: {'name': name});
      return ApiResponse.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      return ApiResponse(success: false, message: e.toString());
    }
  }

  Future<ApiResponse> deleteFolder(int communityId, int folderId) async {
    try {
      final response = await _dio.delete('/communities/$communityId/folders/$folderId');
      return ApiResponse.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      return ApiResponse(success: false, message: e.toString());
    }
  }

  Future<ApiResponse> fetchFiles(int communityId, {int? folderId}) async {
    try {
      final uri = folderId != null ? '/communities/$communityId/files?folderId=$folderId' : '/communities/$communityId/files';
      final response = await _dio.get(uri);
      return ApiResponse.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      return ApiResponse(success: false, message: e.toString());
    }
  }

  Future<ApiResponse> uploadFile(int communityId, String filePath, {int? folderId}) async {
    try {
      final formData = FormData.fromMap({
        if (folderId != null) 'folderId': folderId,
        'communityFile': await MultipartFile.fromFile(filePath),
      });
      final response = await _dio.post('/communities/$communityId/files', data: formData);
      return ApiResponse.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      return ApiResponse(success: false, message: e.toString());
    }
  }

  Future<ApiResponse> deleteFile(int communityId, int fileId) async {
    try {
      final response = await _dio.delete('/communities/$communityId/files/$fileId');
      return ApiResponse.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      return ApiResponse(success: false, message: e.toString());
    }
  }
}
      if (search != null && search.isNotEmpty) {
        params['search'] = search;
      
  // --- Folders & Files ---
  Future<ApiResponse> fetchFolders(int communityId) async {
    try {
      final response = await _dio.get('/communities/$communityId/folders');
      return ApiResponse.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      return ApiResponse(success: false, message: e.toString());
    }
  }

  Future<ApiResponse> createFolder(int communityId, String name) async {
    try {
      final response = await _dio.post('/communities/$communityId/folders', data: {'name': name});
      return ApiResponse.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      return ApiResponse(success: false, message: e.toString());
    }
  }

  Future<ApiResponse> deleteFolder(int communityId, int folderId) async {
    try {
      final response = await _dio.delete('/communities/$communityId/folders/$folderId');
      return ApiResponse.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      return ApiResponse(success: false, message: e.toString());
    }
  }

  Future<ApiResponse> fetchFiles(int communityId, {int? folderId}) async {
    try {
      final uri = folderId != null ? '/communities/$communityId/files?folderId=$folderId' : '/communities/$communityId/files';
      final response = await _dio.get(uri);
      return ApiResponse.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      return ApiResponse(success: false, message: e.toString());
    }
  }

  Future<ApiResponse> uploadFile(int communityId, String filePath, {int? folderId}) async {
    try {
      final formData = FormData.fromMap({
        if (folderId != null) 'folderId': folderId,
        'communityFile': await MultipartFile.fromFile(filePath),
      });
      final response = await _dio.post('/communities/$communityId/files', data: formData);
      return ApiResponse.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      return ApiResponse(success: false, message: e.toString());
    }
  }

  Future<ApiResponse> deleteFile(int communityId, int fileId) async {
    try {
      final response = await _dio.delete('/communities/$communityId/files/$fileId');
      return ApiResponse.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      return ApiResponse(success: false, message: e.toString());
    }
  }
}
      final response = await _dio.get(ApiConstants.communities, queryParameters: params);
      return ApiResponse.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.response != null && e.response!.data is Map) {
        return ApiResponse.fromJson(e.response!.data as Map<String, dynamic>);
      
  // --- Folders & Files ---
  Future<ApiResponse> fetchFolders(int communityId) async {
    try {
      final response = await _dio.get('/communities/$communityId/folders');
      return ApiResponse.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      return ApiResponse(success: false, message: e.toString());
    }
  }

  Future<ApiResponse> createFolder(int communityId, String name) async {
    try {
      final response = await _dio.post('/communities/$communityId/folders', data: {'name': name});
      return ApiResponse.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      return ApiResponse(success: false, message: e.toString());
    }
  }

  Future<ApiResponse> deleteFolder(int communityId, int folderId) async {
    try {
      final response = await _dio.delete('/communities/$communityId/folders/$folderId');
      return ApiResponse.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      return ApiResponse(success: false, message: e.toString());
    }
  }

  Future<ApiResponse> fetchFiles(int communityId, {int? folderId}) async {
    try {
      final uri = folderId != null ? '/communities/$communityId/files?folderId=$folderId' : '/communities/$communityId/files';
      final response = await _dio.get(uri);
      return ApiResponse.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      return ApiResponse(success: false, message: e.toString());
    }
  }

  Future<ApiResponse> uploadFile(int communityId, String filePath, {int? folderId}) async {
    try {
      final formData = FormData.fromMap({
        if (folderId != null) 'folderId': folderId,
        'communityFile': await MultipartFile.fromFile(filePath),
      });
      final response = await _dio.post('/communities/$communityId/files', data: formData);
      return ApiResponse.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      return ApiResponse(success: false, message: e.toString());
    }
  }

  Future<ApiResponse> deleteFile(int communityId, int fileId) async {
    try {
      final response = await _dio.delete('/communities/$communityId/files/$fileId');
      return ApiResponse.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      return ApiResponse(success: false, message: e.toString());
    }
  }
}
      return ApiResponse(success: false, message: 'Error de conexión.');
    } catch (e) {
      return ApiResponse(success: false, message: 'Error inesperado: $e');
    
  // --- Folders & Files ---
  Future<ApiResponse> fetchFolders(int communityId) async {
    try {
      final response = await _dio.get('/communities/$communityId/folders');
      return ApiResponse.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      return ApiResponse(success: false, message: e.toString());
    }
  }

  Future<ApiResponse> createFolder(int communityId, String name) async {
    try {
      final response = await _dio.post('/communities/$communityId/folders', data: {'name': name});
      return ApiResponse.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      return ApiResponse(success: false, message: e.toString());
    }
  }

  Future<ApiResponse> deleteFolder(int communityId, int folderId) async {
    try {
      final response = await _dio.delete('/communities/$communityId/folders/$folderId');
      return ApiResponse.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      return ApiResponse(success: false, message: e.toString());
    }
  }

  Future<ApiResponse> fetchFiles(int communityId, {int? folderId}) async {
    try {
      final uri = folderId != null ? '/communities/$communityId/files?folderId=$folderId' : '/communities/$communityId/files';
      final response = await _dio.get(uri);
      return ApiResponse.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      return ApiResponse(success: false, message: e.toString());
    }
  }

  Future<ApiResponse> uploadFile(int communityId, String filePath, {int? folderId}) async {
    try {
      final formData = FormData.fromMap({
        if (folderId != null) 'folderId': folderId,
        'communityFile': await MultipartFile.fromFile(filePath),
      });
      final response = await _dio.post('/communities/$communityId/files', data: formData);
      return ApiResponse.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      return ApiResponse(success: false, message: e.toString());
    }
  }

  Future<ApiResponse> deleteFile(int communityId, int fileId) async {
    try {
      final response = await _dio.delete('/communities/$communityId/files/$fileId');
      return ApiResponse.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      return ApiResponse(success: false, message: e.toString());
    }
  }
}
  
  // --- Folders & Files ---
  Future<ApiResponse> fetchFolders(int communityId) async {
    try {
      final response = await _dio.get('/communities/$communityId/folders');
      return ApiResponse.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      return ApiResponse(success: false, message: e.toString());
    }
  }

  Future<ApiResponse> createFolder(int communityId, String name) async {
    try {
      final response = await _dio.post('/communities/$communityId/folders', data: {'name': name});
      return ApiResponse.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      return ApiResponse(success: false, message: e.toString());
    }
  }

  Future<ApiResponse> deleteFolder(int communityId, int folderId) async {
    try {
      final response = await _dio.delete('/communities/$communityId/folders/$folderId');
      return ApiResponse.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      return ApiResponse(success: false, message: e.toString());
    }
  }

  Future<ApiResponse> fetchFiles(int communityId, {int? folderId}) async {
    try {
      final uri = folderId != null ? '/communities/$communityId/files?folderId=$folderId' : '/communities/$communityId/files';
      final response = await _dio.get(uri);
      return ApiResponse.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      return ApiResponse(success: false, message: e.toString());
    }
  }

  Future<ApiResponse> uploadFile(int communityId, String filePath, {int? folderId}) async {
    try {
      final formData = FormData.fromMap({
        if (folderId != null) 'folderId': folderId,
        'communityFile': await MultipartFile.fromFile(filePath),
      });
      final response = await _dio.post('/communities/$communityId/files', data: formData);
      return ApiResponse.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      return ApiResponse(success: false, message: e.toString());
    }
  }

  Future<ApiResponse> deleteFile(int communityId, int fileId) async {
    try {
      final response = await _dio.delete('/communities/$communityId/files/$fileId');
      return ApiResponse.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      return ApiResponse(success: false, message: e.toString());
    }
  }
}

  Future<ApiResponse> getById(int id) async {
    try {
      final response = await _dio.get(ApiConstants.communityDetail(id));
      return ApiResponse.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.response != null && e.response!.data is Map) {
        return ApiResponse.fromJson(e.response!.data as Map<String, dynamic>);
      
  // --- Folders & Files ---
  Future<ApiResponse> fetchFolders(int communityId) async {
    try {
      final response = await _dio.get('/communities/$communityId/folders');
      return ApiResponse.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      return ApiResponse(success: false, message: e.toString());
    }
  }

  Future<ApiResponse> createFolder(int communityId, String name) async {
    try {
      final response = await _dio.post('/communities/$communityId/folders', data: {'name': name});
      return ApiResponse.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      return ApiResponse(success: false, message: e.toString());
    }
  }

  Future<ApiResponse> deleteFolder(int communityId, int folderId) async {
    try {
      final response = await _dio.delete('/communities/$communityId/folders/$folderId');
      return ApiResponse.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      return ApiResponse(success: false, message: e.toString());
    }
  }

  Future<ApiResponse> fetchFiles(int communityId, {int? folderId}) async {
    try {
      final uri = folderId != null ? '/communities/$communityId/files?folderId=$folderId' : '/communities/$communityId/files';
      final response = await _dio.get(uri);
      return ApiResponse.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      return ApiResponse(success: false, message: e.toString());
    }
  }

  Future<ApiResponse> uploadFile(int communityId, String filePath, {int? folderId}) async {
    try {
      final formData = FormData.fromMap({
        if (folderId != null) 'folderId': folderId,
        'communityFile': await MultipartFile.fromFile(filePath),
      });
      final response = await _dio.post('/communities/$communityId/files', data: formData);
      return ApiResponse.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      return ApiResponse(success: false, message: e.toString());
    }
  }

  Future<ApiResponse> deleteFile(int communityId, int fileId) async {
    try {
      final response = await _dio.delete('/communities/$communityId/files/$fileId');
      return ApiResponse.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      return ApiResponse(success: false, message: e.toString());
    }
  }
}
      return ApiResponse(success: false, message: 'Error de conexión.');
    } catch (e) {
      return ApiResponse(success: false, message: 'Error inesperado: $e');
    
  // --- Folders & Files ---
  Future<ApiResponse> fetchFolders(int communityId) async {
    try {
      final response = await _dio.get('/communities/$communityId/folders');
      return ApiResponse.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      return ApiResponse(success: false, message: e.toString());
    }
  }

  Future<ApiResponse> createFolder(int communityId, String name) async {
    try {
      final response = await _dio.post('/communities/$communityId/folders', data: {'name': name});
      return ApiResponse.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      return ApiResponse(success: false, message: e.toString());
    }
  }

  Future<ApiResponse> deleteFolder(int communityId, int folderId) async {
    try {
      final response = await _dio.delete('/communities/$communityId/folders/$folderId');
      return ApiResponse.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      return ApiResponse(success: false, message: e.toString());
    }
  }

  Future<ApiResponse> fetchFiles(int communityId, {int? folderId}) async {
    try {
      final uri = folderId != null ? '/communities/$communityId/files?folderId=$folderId' : '/communities/$communityId/files';
      final response = await _dio.get(uri);
      return ApiResponse.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      return ApiResponse(success: false, message: e.toString());
    }
  }

  Future<ApiResponse> uploadFile(int communityId, String filePath, {int? folderId}) async {
    try {
      final formData = FormData.fromMap({
        if (folderId != null) 'folderId': folderId,
        'communityFile': await MultipartFile.fromFile(filePath),
      });
      final response = await _dio.post('/communities/$communityId/files', data: formData);
      return ApiResponse.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      return ApiResponse(success: false, message: e.toString());
    }
  }

  Future<ApiResponse> deleteFile(int communityId, int fileId) async {
    try {
      final response = await _dio.delete('/communities/$communityId/files/$fileId');
      return ApiResponse.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      return ApiResponse(success: false, message: e.toString());
    }
  }
}
  
  // --- Folders & Files ---
  Future<ApiResponse> fetchFolders(int communityId) async {
    try {
      final response = await _dio.get('/communities/$communityId/folders');
      return ApiResponse.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      return ApiResponse(success: false, message: e.toString());
    }
  }

  Future<ApiResponse> createFolder(int communityId, String name) async {
    try {
      final response = await _dio.post('/communities/$communityId/folders', data: {'name': name});
      return ApiResponse.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      return ApiResponse(success: false, message: e.toString());
    }
  }

  Future<ApiResponse> deleteFolder(int communityId, int folderId) async {
    try {
      final response = await _dio.delete('/communities/$communityId/folders/$folderId');
      return ApiResponse.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      return ApiResponse(success: false, message: e.toString());
    }
  }

  Future<ApiResponse> fetchFiles(int communityId, {int? folderId}) async {
    try {
      final uri = folderId != null ? '/communities/$communityId/files?folderId=$folderId' : '/communities/$communityId/files';
      final response = await _dio.get(uri);
      return ApiResponse.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      return ApiResponse(success: false, message: e.toString());
    }
  }

  Future<ApiResponse> uploadFile(int communityId, String filePath, {int? folderId}) async {
    try {
      final formData = FormData.fromMap({
        if (folderId != null) 'folderId': folderId,
        'communityFile': await MultipartFile.fromFile(filePath),
      });
      final response = await _dio.post('/communities/$communityId/files', data: formData);
      return ApiResponse.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      return ApiResponse(success: false, message: e.toString());
    }
  }

  Future<ApiResponse> deleteFile(int communityId, int fileId) async {
    try {
      final response = await _dio.delete('/communities/$communityId/files/$fileId');
      return ApiResponse.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      return ApiResponse(success: false, message: e.toString());
    }
  }
}

  Future<ApiResponse> create({
    required String name,
    required String category,
    String? description,
    String? coverImagePath,
  }) async {
    try {
      final formData = FormData.fromMap({
        'name': name,
        'category': category,
        if (description != null && description.isNotEmpty) 'description': description,
        if (coverImagePath != null)
          'communityImage': await MultipartFile.fromFile(coverImagePath),
      });
      final response = await _dio.post(ApiConstants.communities, data: formData);
      return ApiResponse.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.response != null && e.response!.data is Map) {
        return ApiResponse.fromJson(e.response!.data as Map<String, dynamic>);
      
  // --- Folders & Files ---
  Future<ApiResponse> fetchFolders(int communityId) async {
    try {
      final response = await _dio.get('/communities/$communityId/folders');
      return ApiResponse.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      return ApiResponse(success: false, message: e.toString());
    }
  }

  Future<ApiResponse> createFolder(int communityId, String name) async {
    try {
      final response = await _dio.post('/communities/$communityId/folders', data: {'name': name});
      return ApiResponse.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      return ApiResponse(success: false, message: e.toString());
    }
  }

  Future<ApiResponse> deleteFolder(int communityId, int folderId) async {
    try {
      final response = await _dio.delete('/communities/$communityId/folders/$folderId');
      return ApiResponse.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      return ApiResponse(success: false, message: e.toString());
    }
  }

  Future<ApiResponse> fetchFiles(int communityId, {int? folderId}) async {
    try {
      final uri = folderId != null ? '/communities/$communityId/files?folderId=$folderId' : '/communities/$communityId/files';
      final response = await _dio.get(uri);
      return ApiResponse.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      return ApiResponse(success: false, message: e.toString());
    }
  }

  Future<ApiResponse> uploadFile(int communityId, String filePath, {int? folderId}) async {
    try {
      final formData = FormData.fromMap({
        if (folderId != null) 'folderId': folderId,
        'communityFile': await MultipartFile.fromFile(filePath),
      });
      final response = await _dio.post('/communities/$communityId/files', data: formData);
      return ApiResponse.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      return ApiResponse(success: false, message: e.toString());
    }
  }

  Future<ApiResponse> deleteFile(int communityId, int fileId) async {
    try {
      final response = await _dio.delete('/communities/$communityId/files/$fileId');
      return ApiResponse.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      return ApiResponse(success: false, message: e.toString());
    }
  }
}
      return ApiResponse(success: false, message: 'Error al crear comunidad.');
    } catch (e) {
      return ApiResponse(success: false, message: 'Error inesperado: $e');
    
  // --- Folders & Files ---
  Future<ApiResponse> fetchFolders(int communityId) async {
    try {
      final response = await _dio.get('/communities/$communityId/folders');
      return ApiResponse.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      return ApiResponse(success: false, message: e.toString());
    }
  }

  Future<ApiResponse> createFolder(int communityId, String name) async {
    try {
      final response = await _dio.post('/communities/$communityId/folders', data: {'name': name});
      return ApiResponse.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      return ApiResponse(success: false, message: e.toString());
    }
  }

  Future<ApiResponse> deleteFolder(int communityId, int folderId) async {
    try {
      final response = await _dio.delete('/communities/$communityId/folders/$folderId');
      return ApiResponse.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      return ApiResponse(success: false, message: e.toString());
    }
  }

  Future<ApiResponse> fetchFiles(int communityId, {int? folderId}) async {
    try {
      final uri = folderId != null ? '/communities/$communityId/files?folderId=$folderId' : '/communities/$communityId/files';
      final response = await _dio.get(uri);
      return ApiResponse.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      return ApiResponse(success: false, message: e.toString());
    }
  }

  Future<ApiResponse> uploadFile(int communityId, String filePath, {int? folderId}) async {
    try {
      final formData = FormData.fromMap({
        if (folderId != null) 'folderId': folderId,
        'communityFile': await MultipartFile.fromFile(filePath),
      });
      final response = await _dio.post('/communities/$communityId/files', data: formData);
      return ApiResponse.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      return ApiResponse(success: false, message: e.toString());
    }
  }

  Future<ApiResponse> deleteFile(int communityId, int fileId) async {
    try {
      final response = await _dio.delete('/communities/$communityId/files/$fileId');
      return ApiResponse.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      return ApiResponse(success: false, message: e.toString());
    }
  }
}
  
  // --- Folders & Files ---
  Future<ApiResponse> fetchFolders(int communityId) async {
    try {
      final response = await _dio.get('/communities/$communityId/folders');
      return ApiResponse.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      return ApiResponse(success: false, message: e.toString());
    }
  }

  Future<ApiResponse> createFolder(int communityId, String name) async {
    try {
      final response = await _dio.post('/communities/$communityId/folders', data: {'name': name});
      return ApiResponse.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      return ApiResponse(success: false, message: e.toString());
    }
  }

  Future<ApiResponse> deleteFolder(int communityId, int folderId) async {
    try {
      final response = await _dio.delete('/communities/$communityId/folders/$folderId');
      return ApiResponse.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      return ApiResponse(success: false, message: e.toString());
    }
  }

  Future<ApiResponse> fetchFiles(int communityId, {int? folderId}) async {
    try {
      final uri = folderId != null ? '/communities/$communityId/files?folderId=$folderId' : '/communities/$communityId/files';
      final response = await _dio.get(uri);
      return ApiResponse.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      return ApiResponse(success: false, message: e.toString());
    }
  }

  Future<ApiResponse> uploadFile(int communityId, String filePath, {int? folderId}) async {
    try {
      final formData = FormData.fromMap({
        if (folderId != null) 'folderId': folderId,
        'communityFile': await MultipartFile.fromFile(filePath),
      });
      final response = await _dio.post('/communities/$communityId/files', data: formData);
      return ApiResponse.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      return ApiResponse(success: false, message: e.toString());
    }
  }

  Future<ApiResponse> deleteFile(int communityId, int fileId) async {
    try {
      final response = await _dio.delete('/communities/$communityId/files/$fileId');
      return ApiResponse.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      return ApiResponse(success: false, message: e.toString());
    }
  }
}

  Future<ApiResponse> join(int communityId) async {
    try {
      final response = await _dio.post(ApiConstants.communityJoin(communityId));
      return ApiResponse.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.response != null && e.response!.data is Map) {
        return ApiResponse.fromJson(e.response!.data as Map<String, dynamic>);
      
  // --- Folders & Files ---
  Future<ApiResponse> fetchFolders(int communityId) async {
    try {
      final response = await _dio.get('/communities/$communityId/folders');
      return ApiResponse.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      return ApiResponse(success: false, message: e.toString());
    }
  }

  Future<ApiResponse> createFolder(int communityId, String name) async {
    try {
      final response = await _dio.post('/communities/$communityId/folders', data: {'name': name});
      return ApiResponse.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      return ApiResponse(success: false, message: e.toString());
    }
  }

  Future<ApiResponse> deleteFolder(int communityId, int folderId) async {
    try {
      final response = await _dio.delete('/communities/$communityId/folders/$folderId');
      return ApiResponse.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      return ApiResponse(success: false, message: e.toString());
    }
  }

  Future<ApiResponse> fetchFiles(int communityId, {int? folderId}) async {
    try {
      final uri = folderId != null ? '/communities/$communityId/files?folderId=$folderId' : '/communities/$communityId/files';
      final response = await _dio.get(uri);
      return ApiResponse.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      return ApiResponse(success: false, message: e.toString());
    }
  }

  Future<ApiResponse> uploadFile(int communityId, String filePath, {int? folderId}) async {
    try {
      final formData = FormData.fromMap({
        if (folderId != null) 'folderId': folderId,
        'communityFile': await MultipartFile.fromFile(filePath),
      });
      final response = await _dio.post('/communities/$communityId/files', data: formData);
      return ApiResponse.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      return ApiResponse(success: false, message: e.toString());
    }
  }

  Future<ApiResponse> deleteFile(int communityId, int fileId) async {
    try {
      final response = await _dio.delete('/communities/$communityId/files/$fileId');
      return ApiResponse.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      return ApiResponse(success: false, message: e.toString());
    }
  }
}
      return ApiResponse(success: false, message: 'Error de conexión.');
    } catch (e) {
      return ApiResponse(success: false, message: 'Error inesperado: $e');
    
  // --- Folders & Files ---
  Future<ApiResponse> fetchFolders(int communityId) async {
    try {
      final response = await _dio.get('/communities/$communityId/folders');
      return ApiResponse.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      return ApiResponse(success: false, message: e.toString());
    }
  }

  Future<ApiResponse> createFolder(int communityId, String name) async {
    try {
      final response = await _dio.post('/communities/$communityId/folders', data: {'name': name});
      return ApiResponse.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      return ApiResponse(success: false, message: e.toString());
    }
  }

  Future<ApiResponse> deleteFolder(int communityId, int folderId) async {
    try {
      final response = await _dio.delete('/communities/$communityId/folders/$folderId');
      return ApiResponse.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      return ApiResponse(success: false, message: e.toString());
    }
  }

  Future<ApiResponse> fetchFiles(int communityId, {int? folderId}) async {
    try {
      final uri = folderId != null ? '/communities/$communityId/files?folderId=$folderId' : '/communities/$communityId/files';
      final response = await _dio.get(uri);
      return ApiResponse.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      return ApiResponse(success: false, message: e.toString());
    }
  }

  Future<ApiResponse> uploadFile(int communityId, String filePath, {int? folderId}) async {
    try {
      final formData = FormData.fromMap({
        if (folderId != null) 'folderId': folderId,
        'communityFile': await MultipartFile.fromFile(filePath),
      });
      final response = await _dio.post('/communities/$communityId/files', data: formData);
      return ApiResponse.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      return ApiResponse(success: false, message: e.toString());
    }
  }

  Future<ApiResponse> deleteFile(int communityId, int fileId) async {
    try {
      final response = await _dio.delete('/communities/$communityId/files/$fileId');
      return ApiResponse.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      return ApiResponse(success: false, message: e.toString());
    }
  }
}
  
  // --- Folders & Files ---
  Future<ApiResponse> fetchFolders(int communityId) async {
    try {
      final response = await _dio.get('/communities/$communityId/folders');
      return ApiResponse.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      return ApiResponse(success: false, message: e.toString());
    }
  }

  Future<ApiResponse> createFolder(int communityId, String name) async {
    try {
      final response = await _dio.post('/communities/$communityId/folders', data: {'name': name});
      return ApiResponse.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      return ApiResponse(success: false, message: e.toString());
    }
  }

  Future<ApiResponse> deleteFolder(int communityId, int folderId) async {
    try {
      final response = await _dio.delete('/communities/$communityId/folders/$folderId');
      return ApiResponse.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      return ApiResponse(success: false, message: e.toString());
    }
  }

  Future<ApiResponse> fetchFiles(int communityId, {int? folderId}) async {
    try {
      final uri = folderId != null ? '/communities/$communityId/files?folderId=$folderId' : '/communities/$communityId/files';
      final response = await _dio.get(uri);
      return ApiResponse.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      return ApiResponse(success: false, message: e.toString());
    }
  }

  Future<ApiResponse> uploadFile(int communityId, String filePath, {int? folderId}) async {
    try {
      final formData = FormData.fromMap({
        if (folderId != null) 'folderId': folderId,
        'communityFile': await MultipartFile.fromFile(filePath),
      });
      final response = await _dio.post('/communities/$communityId/files', data: formData);
      return ApiResponse.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      return ApiResponse(success: false, message: e.toString());
    }
  }

  Future<ApiResponse> deleteFile(int communityId, int fileId) async {
    try {
      final response = await _dio.delete('/communities/$communityId/files/$fileId');
      return ApiResponse.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      return ApiResponse(success: false, message: e.toString());
    }
  }
}

  Future<ApiResponse> leave(int communityId) async {
    try {
      final response = await _dio.delete(ApiConstants.communityLeave(communityId));
      return ApiResponse.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.response != null && e.response!.data is Map) {
        return ApiResponse.fromJson(e.response!.data as Map<String, dynamic>);
      
  // --- Folders & Files ---
  Future<ApiResponse> fetchFolders(int communityId) async {
    try {
      final response = await _dio.get('/communities/$communityId/folders');
      return ApiResponse.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      return ApiResponse(success: false, message: e.toString());
    }
  }

  Future<ApiResponse> createFolder(int communityId, String name) async {
    try {
      final response = await _dio.post('/communities/$communityId/folders', data: {'name': name});
      return ApiResponse.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      return ApiResponse(success: false, message: e.toString());
    }
  }

  Future<ApiResponse> deleteFolder(int communityId, int folderId) async {
    try {
      final response = await _dio.delete('/communities/$communityId/folders/$folderId');
      return ApiResponse.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      return ApiResponse(success: false, message: e.toString());
    }
  }

  Future<ApiResponse> fetchFiles(int communityId, {int? folderId}) async {
    try {
      final uri = folderId != null ? '/communities/$communityId/files?folderId=$folderId' : '/communities/$communityId/files';
      final response = await _dio.get(uri);
      return ApiResponse.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      return ApiResponse(success: false, message: e.toString());
    }
  }

  Future<ApiResponse> uploadFile(int communityId, String filePath, {int? folderId}) async {
    try {
      final formData = FormData.fromMap({
        if (folderId != null) 'folderId': folderId,
        'communityFile': await MultipartFile.fromFile(filePath),
      });
      final response = await _dio.post('/communities/$communityId/files', data: formData);
      return ApiResponse.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      return ApiResponse(success: false, message: e.toString());
    }
  }

  Future<ApiResponse> deleteFile(int communityId, int fileId) async {
    try {
      final response = await _dio.delete('/communities/$communityId/files/$fileId');
      return ApiResponse.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      return ApiResponse(success: false, message: e.toString());
    }
  }
}
      return ApiResponse(success: false, message: 'Error de conexión.');
    } catch (e) {
      return ApiResponse(success: false, message: 'Error inesperado: $e');
    
  // --- Folders & Files ---
  Future<ApiResponse> fetchFolders(int communityId) async {
    try {
      final response = await _dio.get('/communities/$communityId/folders');
      return ApiResponse.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      return ApiResponse(success: false, message: e.toString());
    }
  }

  Future<ApiResponse> createFolder(int communityId, String name) async {
    try {
      final response = await _dio.post('/communities/$communityId/folders', data: {'name': name});
      return ApiResponse.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      return ApiResponse(success: false, message: e.toString());
    }
  }

  Future<ApiResponse> deleteFolder(int communityId, int folderId) async {
    try {
      final response = await _dio.delete('/communities/$communityId/folders/$folderId');
      return ApiResponse.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      return ApiResponse(success: false, message: e.toString());
    }
  }

  Future<ApiResponse> fetchFiles(int communityId, {int? folderId}) async {
    try {
      final uri = folderId != null ? '/communities/$communityId/files?folderId=$folderId' : '/communities/$communityId/files';
      final response = await _dio.get(uri);
      return ApiResponse.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      return ApiResponse(success: false, message: e.toString());
    }
  }

  Future<ApiResponse> uploadFile(int communityId, String filePath, {int? folderId}) async {
    try {
      final formData = FormData.fromMap({
        if (folderId != null) 'folderId': folderId,
        'communityFile': await MultipartFile.fromFile(filePath),
      });
      final response = await _dio.post('/communities/$communityId/files', data: formData);
      return ApiResponse.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      return ApiResponse(success: false, message: e.toString());
    }
  }

  Future<ApiResponse> deleteFile(int communityId, int fileId) async {
    try {
      final response = await _dio.delete('/communities/$communityId/files/$fileId');
      return ApiResponse.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      return ApiResponse(success: false, message: e.toString());
    }
  }
}
  
  // --- Folders & Files ---
  Future<ApiResponse> fetchFolders(int communityId) async {
    try {
      final response = await _dio.get('/communities/$communityId/folders');
      return ApiResponse.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      return ApiResponse(success: false, message: e.toString());
    }
  }

  Future<ApiResponse> createFolder(int communityId, String name) async {
    try {
      final response = await _dio.post('/communities/$communityId/folders', data: {'name': name});
      return ApiResponse.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      return ApiResponse(success: false, message: e.toString());
    }
  }

  Future<ApiResponse> deleteFolder(int communityId, int folderId) async {
    try {
      final response = await _dio.delete('/communities/$communityId/folders/$folderId');
      return ApiResponse.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      return ApiResponse(success: false, message: e.toString());
    }
  }

  Future<ApiResponse> fetchFiles(int communityId, {int? folderId}) async {
    try {
      final uri = folderId != null ? '/communities/$communityId/files?folderId=$folderId' : '/communities/$communityId/files';
      final response = await _dio.get(uri);
      return ApiResponse.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      return ApiResponse(success: false, message: e.toString());
    }
  }

  Future<ApiResponse> uploadFile(int communityId, String filePath, {int? folderId}) async {
    try {
      final formData = FormData.fromMap({
        if (folderId != null) 'folderId': folderId,
        'communityFile': await MultipartFile.fromFile(filePath),
      });
      final response = await _dio.post('/communities/$communityId/files', data: formData);
      return ApiResponse.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      return ApiResponse(success: false, message: e.toString());
    }
  }

  Future<ApiResponse> deleteFile(int communityId, int fileId) async {
    try {
      final response = await _dio.delete('/communities/$communityId/files/$fileId');
      return ApiResponse.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      return ApiResponse(success: false, message: e.toString());
    }
  }
}

  Future<ApiResponse> deleteCommunity(int communityId) async {
    try {
      final response = await _dio.delete(ApiConstants.communityDetail(communityId));
      return ApiResponse.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.response != null && e.response!.data is Map) {
        return ApiResponse.fromJson(e.response!.data as Map<String, dynamic>);
      
  // --- Folders & Files ---
  Future<ApiResponse> fetchFolders(int communityId) async {
    try {
      final response = await _dio.get('/communities/$communityId/folders');
      return ApiResponse.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      return ApiResponse(success: false, message: e.toString());
    }
  }

  Future<ApiResponse> createFolder(int communityId, String name) async {
    try {
      final response = await _dio.post('/communities/$communityId/folders', data: {'name': name});
      return ApiResponse.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      return ApiResponse(success: false, message: e.toString());
    }
  }

  Future<ApiResponse> deleteFolder(int communityId, int folderId) async {
    try {
      final response = await _dio.delete('/communities/$communityId/folders/$folderId');
      return ApiResponse.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      return ApiResponse(success: false, message: e.toString());
    }
  }

  Future<ApiResponse> fetchFiles(int communityId, {int? folderId}) async {
    try {
      final uri = folderId != null ? '/communities/$communityId/files?folderId=$folderId' : '/communities/$communityId/files';
      final response = await _dio.get(uri);
      return ApiResponse.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      return ApiResponse(success: false, message: e.toString());
    }
  }

  Future<ApiResponse> uploadFile(int communityId, String filePath, {int? folderId}) async {
    try {
      final formData = FormData.fromMap({
        if (folderId != null) 'folderId': folderId,
        'communityFile': await MultipartFile.fromFile(filePath),
      });
      final response = await _dio.post('/communities/$communityId/files', data: formData);
      return ApiResponse.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      return ApiResponse(success: false, message: e.toString());
    }
  }

  Future<ApiResponse> deleteFile(int communityId, int fileId) async {
    try {
      final response = await _dio.delete('/communities/$communityId/files/$fileId');
      return ApiResponse.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      return ApiResponse(success: false, message: e.toString());
    }
  }
}
      return ApiResponse(success: false, message: 'Error de conexión.');
    } catch (e) {
      return ApiResponse(success: false, message: 'Error inesperado: $e');
    
  // --- Folders & Files ---
  Future<ApiResponse> fetchFolders(int communityId) async {
    try {
      final response = await _dio.get('/communities/$communityId/folders');
      return ApiResponse.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      return ApiResponse(success: false, message: e.toString());
    }
  }

  Future<ApiResponse> createFolder(int communityId, String name) async {
    try {
      final response = await _dio.post('/communities/$communityId/folders', data: {'name': name});
      return ApiResponse.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      return ApiResponse(success: false, message: e.toString());
    }
  }

  Future<ApiResponse> deleteFolder(int communityId, int folderId) async {
    try {
      final response = await _dio.delete('/communities/$communityId/folders/$folderId');
      return ApiResponse.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      return ApiResponse(success: false, message: e.toString());
    }
  }

  Future<ApiResponse> fetchFiles(int communityId, {int? folderId}) async {
    try {
      final uri = folderId != null ? '/communities/$communityId/files?folderId=$folderId' : '/communities/$communityId/files';
      final response = await _dio.get(uri);
      return ApiResponse.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      return ApiResponse(success: false, message: e.toString());
    }
  }

  Future<ApiResponse> uploadFile(int communityId, String filePath, {int? folderId}) async {
    try {
      final formData = FormData.fromMap({
        if (folderId != null) 'folderId': folderId,
        'communityFile': await MultipartFile.fromFile(filePath),
      });
      final response = await _dio.post('/communities/$communityId/files', data: formData);
      return ApiResponse.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      return ApiResponse(success: false, message: e.toString());
    }
  }

  Future<ApiResponse> deleteFile(int communityId, int fileId) async {
    try {
      final response = await _dio.delete('/communities/$communityId/files/$fileId');
      return ApiResponse.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      return ApiResponse(success: false, message: e.toString());
    }
  }
}
  
  // --- Folders & Files ---
  Future<ApiResponse> fetchFolders(int communityId) async {
    try {
      final response = await _dio.get('/communities/$communityId/folders');
      return ApiResponse.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      return ApiResponse(success: false, message: e.toString());
    }
  }

  Future<ApiResponse> createFolder(int communityId, String name) async {
    try {
      final response = await _dio.post('/communities/$communityId/folders', data: {'name': name});
      return ApiResponse.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      return ApiResponse(success: false, message: e.toString());
    }
  }

  Future<ApiResponse> deleteFolder(int communityId, int folderId) async {
    try {
      final response = await _dio.delete('/communities/$communityId/folders/$folderId');
      return ApiResponse.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      return ApiResponse(success: false, message: e.toString());
    }
  }

  Future<ApiResponse> fetchFiles(int communityId, {int? folderId}) async {
    try {
      final uri = folderId != null ? '/communities/$communityId/files?folderId=$folderId' : '/communities/$communityId/files';
      final response = await _dio.get(uri);
      return ApiResponse.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      return ApiResponse(success: false, message: e.toString());
    }
  }

  Future<ApiResponse> uploadFile(int communityId, String filePath, {int? folderId}) async {
    try {
      final formData = FormData.fromMap({
        if (folderId != null) 'folderId': folderId,
        'communityFile': await MultipartFile.fromFile(filePath),
      });
      final response = await _dio.post('/communities/$communityId/files', data: formData);
      return ApiResponse.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      return ApiResponse(success: false, message: e.toString());
    }
  }

  Future<ApiResponse> deleteFile(int communityId, int fileId) async {
    try {
      final response = await _dio.delete('/communities/$communityId/files/$fileId');
      return ApiResponse.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      return ApiResponse(success: false, message: e.toString());
    }
  }
}

  
  Future<ApiResponse> fetchMembers(int communityId) async {
    try {
      final response = await _dio.get('/communities/$communityId/members');
      return ApiResponse.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      return ApiResponse(success: false, message: e.toString());
    
  // --- Folders & Files ---
  Future<ApiResponse> fetchFolders(int communityId) async {
    try {
      final response = await _dio.get('/communities/$communityId/folders');
      return ApiResponse.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      return ApiResponse(success: false, message: e.toString());
    }
  }

  Future<ApiResponse> createFolder(int communityId, String name) async {
    try {
      final response = await _dio.post('/communities/$communityId/folders', data: {'name': name});
      return ApiResponse.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      return ApiResponse(success: false, message: e.toString());
    }
  }

  Future<ApiResponse> deleteFolder(int communityId, int folderId) async {
    try {
      final response = await _dio.delete('/communities/$communityId/folders/$folderId');
      return ApiResponse.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      return ApiResponse(success: false, message: e.toString());
    }
  }

  Future<ApiResponse> fetchFiles(int communityId, {int? folderId}) async {
    try {
      final uri = folderId != null ? '/communities/$communityId/files?folderId=$folderId' : '/communities/$communityId/files';
      final response = await _dio.get(uri);
      return ApiResponse.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      return ApiResponse(success: false, message: e.toString());
    }
  }

  Future<ApiResponse> uploadFile(int communityId, String filePath, {int? folderId}) async {
    try {
      final formData = FormData.fromMap({
        if (folderId != null) 'folderId': folderId,
        'communityFile': await MultipartFile.fromFile(filePath),
      });
      final response = await _dio.post('/communities/$communityId/files', data: formData);
      return ApiResponse.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      return ApiResponse(success: false, message: e.toString());
    }
  }

  Future<ApiResponse> deleteFile(int communityId, int fileId) async {
    try {
      final response = await _dio.delete('/communities/$communityId/files/$fileId');
      return ApiResponse.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      return ApiResponse(success: false, message: e.toString());
    }
  }
}
  
  // --- Folders & Files ---
  Future<ApiResponse> fetchFolders(int communityId) async {
    try {
      final response = await _dio.get('/communities/$communityId/folders');
      return ApiResponse.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      return ApiResponse(success: false, message: e.toString());
    }
  }

  Future<ApiResponse> createFolder(int communityId, String name) async {
    try {
      final response = await _dio.post('/communities/$communityId/folders', data: {'name': name});
      return ApiResponse.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      return ApiResponse(success: false, message: e.toString());
    }
  }

  Future<ApiResponse> deleteFolder(int communityId, int folderId) async {
    try {
      final response = await _dio.delete('/communities/$communityId/folders/$folderId');
      return ApiResponse.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      return ApiResponse(success: false, message: e.toString());
    }
  }

  Future<ApiResponse> fetchFiles(int communityId, {int? folderId}) async {
    try {
      final uri = folderId != null ? '/communities/$communityId/files?folderId=$folderId' : '/communities/$communityId/files';
      final response = await _dio.get(uri);
      return ApiResponse.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      return ApiResponse(success: false, message: e.toString());
    }
  }

  Future<ApiResponse> uploadFile(int communityId, String filePath, {int? folderId}) async {
    try {
      final formData = FormData.fromMap({
        if (folderId != null) 'folderId': folderId,
        'communityFile': await MultipartFile.fromFile(filePath),
      });
      final response = await _dio.post('/communities/$communityId/files', data: formData);
      return ApiResponse.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      return ApiResponse(success: false, message: e.toString());
    }
  }

  Future<ApiResponse> deleteFile(int communityId, int fileId) async {
    try {
      final response = await _dio.delete('/communities/$communityId/files/$fileId');
      return ApiResponse.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      return ApiResponse(success: false, message: e.toString());
    }
  }
}

  Future<ApiResponse> fetchPosts(int communityId) async {
    try {
      final response = await _dio.get(ApiConstants.communityPosts(communityId));
      return ApiResponse.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.response != null && e.response!.data is Map) {
        return ApiResponse.fromJson(e.response!.data as Map<String, dynamic>);
      
  // --- Folders & Files ---
  Future<ApiResponse> fetchFolders(int communityId) async {
    try {
      final response = await _dio.get('/communities/$communityId/folders');
      return ApiResponse.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      return ApiResponse(success: false, message: e.toString());
    }
  }

  Future<ApiResponse> createFolder(int communityId, String name) async {
    try {
      final response = await _dio.post('/communities/$communityId/folders', data: {'name': name});
      return ApiResponse.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      return ApiResponse(success: false, message: e.toString());
    }
  }

  Future<ApiResponse> deleteFolder(int communityId, int folderId) async {
    try {
      final response = await _dio.delete('/communities/$communityId/folders/$folderId');
      return ApiResponse.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      return ApiResponse(success: false, message: e.toString());
    }
  }

  Future<ApiResponse> fetchFiles(int communityId, {int? folderId}) async {
    try {
      final uri = folderId != null ? '/communities/$communityId/files?folderId=$folderId' : '/communities/$communityId/files';
      final response = await _dio.get(uri);
      return ApiResponse.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      return ApiResponse(success: false, message: e.toString());
    }
  }

  Future<ApiResponse> uploadFile(int communityId, String filePath, {int? folderId}) async {
    try {
      final formData = FormData.fromMap({
        if (folderId != null) 'folderId': folderId,
        'communityFile': await MultipartFile.fromFile(filePath),
      });
      final response = await _dio.post('/communities/$communityId/files', data: formData);
      return ApiResponse.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      return ApiResponse(success: false, message: e.toString());
    }
  }

  Future<ApiResponse> deleteFile(int communityId, int fileId) async {
    try {
      final response = await _dio.delete('/communities/$communityId/files/$fileId');
      return ApiResponse.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      return ApiResponse(success: false, message: e.toString());
    }
  }
}
      return ApiResponse(success: false, message: 'Error de conexión.');
    } catch (e) {
      return ApiResponse(success: false, message: 'Error inesperado: $e');
    
  // --- Folders & Files ---
  Future<ApiResponse> fetchFolders(int communityId) async {
    try {
      final response = await _dio.get('/communities/$communityId/folders');
      return ApiResponse.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      return ApiResponse(success: false, message: e.toString());
    }
  }

  Future<ApiResponse> createFolder(int communityId, String name) async {
    try {
      final response = await _dio.post('/communities/$communityId/folders', data: {'name': name});
      return ApiResponse.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      return ApiResponse(success: false, message: e.toString());
    }
  }

  Future<ApiResponse> deleteFolder(int communityId, int folderId) async {
    try {
      final response = await _dio.delete('/communities/$communityId/folders/$folderId');
      return ApiResponse.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      return ApiResponse(success: false, message: e.toString());
    }
  }

  Future<ApiResponse> fetchFiles(int communityId, {int? folderId}) async {
    try {
      final uri = folderId != null ? '/communities/$communityId/files?folderId=$folderId' : '/communities/$communityId/files';
      final response = await _dio.get(uri);
      return ApiResponse.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      return ApiResponse(success: false, message: e.toString());
    }
  }

  Future<ApiResponse> uploadFile(int communityId, String filePath, {int? folderId}) async {
    try {
      final formData = FormData.fromMap({
        if (folderId != null) 'folderId': folderId,
        'communityFile': await MultipartFile.fromFile(filePath),
      });
      final response = await _dio.post('/communities/$communityId/files', data: formData);
      return ApiResponse.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      return ApiResponse(success: false, message: e.toString());
    }
  }

  Future<ApiResponse> deleteFile(int communityId, int fileId) async {
    try {
      final response = await _dio.delete('/communities/$communityId/files/$fileId');
      return ApiResponse.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      return ApiResponse(success: false, message: e.toString());
    }
  }
}
  
  // --- Folders & Files ---
  Future<ApiResponse> fetchFolders(int communityId) async {
    try {
      final response = await _dio.get('/communities/$communityId/folders');
      return ApiResponse.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      return ApiResponse(success: false, message: e.toString());
    }
  }

  Future<ApiResponse> createFolder(int communityId, String name) async {
    try {
      final response = await _dio.post('/communities/$communityId/folders', data: {'name': name});
      return ApiResponse.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      return ApiResponse(success: false, message: e.toString());
    }
  }

  Future<ApiResponse> deleteFolder(int communityId, int folderId) async {
    try {
      final response = await _dio.delete('/communities/$communityId/folders/$folderId');
      return ApiResponse.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      return ApiResponse(success: false, message: e.toString());
    }
  }

  Future<ApiResponse> fetchFiles(int communityId, {int? folderId}) async {
    try {
      final uri = folderId != null ? '/communities/$communityId/files?folderId=$folderId' : '/communities/$communityId/files';
      final response = await _dio.get(uri);
      return ApiResponse.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      return ApiResponse(success: false, message: e.toString());
    }
  }

  Future<ApiResponse> uploadFile(int communityId, String filePath, {int? folderId}) async {
    try {
      final formData = FormData.fromMap({
        if (folderId != null) 'folderId': folderId,
        'communityFile': await MultipartFile.fromFile(filePath),
      });
      final response = await _dio.post('/communities/$communityId/files', data: formData);
      return ApiResponse.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      return ApiResponse(success: false, message: e.toString());
    }
  }

  Future<ApiResponse> deleteFile(int communityId, int fileId) async {
    try {
      final response = await _dio.delete('/communities/$communityId/files/$fileId');
      return ApiResponse.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      return ApiResponse(success: false, message: e.toString());
    }
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
      
  // --- Folders & Files ---
  Future<ApiResponse> fetchFolders(int communityId) async {
    try {
      final response = await _dio.get('/communities/$communityId/folders');
      return ApiResponse.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      return ApiResponse(success: false, message: e.toString());
    }
  }

  Future<ApiResponse> createFolder(int communityId, String name) async {
    try {
      final response = await _dio.post('/communities/$communityId/folders', data: {'name': name});
      return ApiResponse.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      return ApiResponse(success: false, message: e.toString());
    }
  }

  Future<ApiResponse> deleteFolder(int communityId, int folderId) async {
    try {
      final response = await _dio.delete('/communities/$communityId/folders/$folderId');
      return ApiResponse.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      return ApiResponse(success: false, message: e.toString());
    }
  }

  Future<ApiResponse> fetchFiles(int communityId, {int? folderId}) async {
    try {
      final uri = folderId != null ? '/communities/$communityId/files?folderId=$folderId' : '/communities/$communityId/files';
      final response = await _dio.get(uri);
      return ApiResponse.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      return ApiResponse(success: false, message: e.toString());
    }
  }

  Future<ApiResponse> uploadFile(int communityId, String filePath, {int? folderId}) async {
    try {
      final formData = FormData.fromMap({
        if (folderId != null) 'folderId': folderId,
        'communityFile': await MultipartFile.fromFile(filePath),
      });
      final response = await _dio.post('/communities/$communityId/files', data: formData);
      return ApiResponse.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      return ApiResponse(success: false, message: e.toString());
    }
  }

  Future<ApiResponse> deleteFile(int communityId, int fileId) async {
    try {
      final response = await _dio.delete('/communities/$communityId/files/$fileId');
      return ApiResponse.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      return ApiResponse(success: false, message: e.toString());
    }
  }
}
      return ApiResponse(success: false, message: 'Error al crear post.');
    } catch (e) {
      return ApiResponse(success: false, message: 'Error inesperado: $e');
    
  // --- Folders & Files ---
  Future<ApiResponse> fetchFolders(int communityId) async {
    try {
      final response = await _dio.get('/communities/$communityId/folders');
      return ApiResponse.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      return ApiResponse(success: false, message: e.toString());
    }
  }

  Future<ApiResponse> createFolder(int communityId, String name) async {
    try {
      final response = await _dio.post('/communities/$communityId/folders', data: {'name': name});
      return ApiResponse.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      return ApiResponse(success: false, message: e.toString());
    }
  }

  Future<ApiResponse> deleteFolder(int communityId, int folderId) async {
    try {
      final response = await _dio.delete('/communities/$communityId/folders/$folderId');
      return ApiResponse.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      return ApiResponse(success: false, message: e.toString());
    }
  }

  Future<ApiResponse> fetchFiles(int communityId, {int? folderId}) async {
    try {
      final uri = folderId != null ? '/communities/$communityId/files?folderId=$folderId' : '/communities/$communityId/files';
      final response = await _dio.get(uri);
      return ApiResponse.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      return ApiResponse(success: false, message: e.toString());
    }
  }

  Future<ApiResponse> uploadFile(int communityId, String filePath, {int? folderId}) async {
    try {
      final formData = FormData.fromMap({
        if (folderId != null) 'folderId': folderId,
        'communityFile': await MultipartFile.fromFile(filePath),
      });
      final response = await _dio.post('/communities/$communityId/files', data: formData);
      return ApiResponse.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      return ApiResponse(success: false, message: e.toString());
    }
  }

  Future<ApiResponse> deleteFile(int communityId, int fileId) async {
    try {
      final response = await _dio.delete('/communities/$communityId/files/$fileId');
      return ApiResponse.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      return ApiResponse(success: false, message: e.toString());
    }
  }
}
  
  // --- Folders & Files ---
  Future<ApiResponse> fetchFolders(int communityId) async {
    try {
      final response = await _dio.get('/communities/$communityId/folders');
      return ApiResponse.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      return ApiResponse(success: false, message: e.toString());
    }
  }

  Future<ApiResponse> createFolder(int communityId, String name) async {
    try {
      final response = await _dio.post('/communities/$communityId/folders', data: {'name': name});
      return ApiResponse.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      return ApiResponse(success: false, message: e.toString());
    }
  }

  Future<ApiResponse> deleteFolder(int communityId, int folderId) async {
    try {
      final response = await _dio.delete('/communities/$communityId/folders/$folderId');
      return ApiResponse.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      return ApiResponse(success: false, message: e.toString());
    }
  }

  Future<ApiResponse> fetchFiles(int communityId, {int? folderId}) async {
    try {
      final uri = folderId != null ? '/communities/$communityId/files?folderId=$folderId' : '/communities/$communityId/files';
      final response = await _dio.get(uri);
      return ApiResponse.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      return ApiResponse(success: false, message: e.toString());
    }
  }

  Future<ApiResponse> uploadFile(int communityId, String filePath, {int? folderId}) async {
    try {
      final formData = FormData.fromMap({
        if (folderId != null) 'folderId': folderId,
        'communityFile': await MultipartFile.fromFile(filePath),
      });
      final response = await _dio.post('/communities/$communityId/files', data: formData);
      return ApiResponse.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      return ApiResponse(success: false, message: e.toString());
    }
  }

  Future<ApiResponse> deleteFile(int communityId, int fileId) async {
    try {
      final response = await _dio.delete('/communities/$communityId/files/$fileId');
      return ApiResponse.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      return ApiResponse(success: false, message: e.toString());
    }
  }
}

  // --- Folders & Files ---
  Future<ApiResponse> fetchFolders(int communityId) async {
    try {
      final response = await _dio.get('/communities/$communityId/folders');
      return ApiResponse.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      return ApiResponse(success: false, message: e.toString());
    }
  }

  Future<ApiResponse> createFolder(int communityId, String name) async {
    try {
      final response = await _dio.post('/communities/$communityId/folders', data: {'name': name});
      return ApiResponse.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      return ApiResponse(success: false, message: e.toString());
    }
  }

  Future<ApiResponse> deleteFolder(int communityId, int folderId) async {
    try {
      final response = await _dio.delete('/communities/$communityId/folders/$folderId');
      return ApiResponse.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      return ApiResponse(success: false, message: e.toString());
    }
  }

  Future<ApiResponse> fetchFiles(int communityId, {int? folderId}) async {
    try {
      final uri = folderId != null ? '/communities/$communityId/files?folderId=$folderId' : '/communities/$communityId/files';
      final response = await _dio.get(uri);
      return ApiResponse.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      return ApiResponse(success: false, message: e.toString());
    }
  }

  Future<ApiResponse> uploadFile(int communityId, String filePath, {int? folderId}) async {
    try {
      final formData = FormData.fromMap({
        if (folderId != null) 'folderId': folderId,
        'communityFile': await MultipartFile.fromFile(filePath),
      });
      final response = await _dio.post('/communities/$communityId/files', data: formData);
      return ApiResponse.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      return ApiResponse(success: false, message: e.toString());
    }
  }

  Future<ApiResponse> deleteFile(int communityId, int fileId) async {
    try {
      final response = await _dio.delete('/communities/$communityId/files/$fileId');
      return ApiResponse.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      return ApiResponse(success: false, message: e.toString());
    }
  }
}
