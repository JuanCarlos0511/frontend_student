/// State management for communities.
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart' as dio;
import 'package:uni_social_student/features/communities/data/models/community_models.dart';
import 'package:uni_social_student/features/communities/data/repositories/community_repository.dart';
import 'package:uni_social_student/core/network/network_client.dart';

class CommunityProvider extends ChangeNotifier {
  final CommunityRepository _repository;

  CommunityProvider({CommunityRepository? repository})
      : _repository = repository ?? CommunityRepository();

  List<CommunityModel> _communities = [];
  CommunityModel? _activeCommunity;
  List<CommunityPostModel> _posts = [];
  bool _isLoading = false;
  bool _isLoadingPosts = false;
  bool _isCreating = false;
  String _errorMessage = '';
  String? _selectedCategory;
  String _searchQuery = '';
  int? _currentStudentId;

  List<CommunityModel> get communities => _communities;
  CommunityModel? get activeCommunity => _activeCommunity;
  List<CommunityPostModel> get posts => _posts;
  bool get isLoading => _isLoading;
  bool get isLoadingPosts => _isLoadingPosts;
  bool get isCreating => _isCreating;
  String get errorMessage => _errorMessage;
  String? get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;
  int? get currentStudentId => _currentStudentId;

  static const List<String> categories = [
    'Todas',
    'Académicas',
    'Deportes',
    'Arte y Cultura',
    'Tecnología',
    'General',
  ];

  Future<void> _ensureStudentId() async {
    if (_currentStudentId == null) {
      final prefs = await SharedPreferences.getInstance();
      _currentStudentId = prefs.getInt('student_id');
    }
  }

  /// Load communities with optional category filter.
  Future<void> loadCommunities({String query = ''}) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    await _ensureStudentId();

    if (query.isNotEmpty || _searchQuery.isNotEmpty) {
      if (query.isNotEmpty) _searchQuery = query;
    }

    final response = await _repository.fetchAll(
      category: _selectedCategory, 
      search: _searchQuery.isNotEmpty ? _searchQuery : null
    );

    if (response.success && response.data != null) {
      final list = response.data as List;
      _communities = list
          .map((json) =>
              CommunityModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } else {
      _errorMessage = response.message;
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Set search query and reload.
  void setSearchQuery(String query) {
    _searchQuery = query;
    loadCommunities();
  }

  /// Set category filter and reload.
  void setCategory(String? category) {
    _selectedCategory = category;
    loadCommunities();
  }

  /// Load a specific community's detail.
  Future<void> loadCommunityDetail(int id) async {
    _isLoading = true;
    notifyListeners();

    final response = await _repository.getById(id);

    if (response.success && response.data != null) {
      _activeCommunity =
          CommunityModel.fromJson(response.data as Map<String, dynamic>);
    } else {
      _errorMessage = response.message;
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Create a new community.
  Future<bool> createCommunity({
    required String name,
    required String category,
    String? description,
    String? coverImagePath,
    bool isCourse = false,
    List<String> courseModules = const [],
  }) async {
    _isCreating = true;
    notifyListeners();

    final response = await _repository.create(
      name: name,
      category: category,
      description: description,
      coverImagePath: coverImagePath,
      isCourse: isCourse,
      courseModules: courseModules,
    );

    _isCreating = false;

    if (response.success) {
      await loadCommunities();
      return true;
    } else {
      _errorMessage = response.message;
      notifyListeners();
      return false;
    }
  }

  /// Join a community.
  Future<bool> joinCommunity(int communityId) async {
    final response = await _repository.join(communityId);
    if (response.success) {
      await loadCommunities();
      return true;
    }
    _errorMessage = response.message;
    notifyListeners();
    return false;
  }

  /// Leave a community.
  Future<bool> leaveCommunity(int communityId) async {
    final response = await _repository.leave(communityId);
    if (response.success) {
      await loadCommunities();
      return true;
    }
    _errorMessage = response.message;
    notifyListeners();
    return false;
  }

  /// Delete a community (creator only).
  Future<bool> deleteCommunity(int communityId) async {
    final response = await _repository.deleteCommunity(communityId);
    if (response.success) {
      _activeCommunity = null;
      await loadCommunities();
      return true;
    }
    _errorMessage = response.message;
    notifyListeners();
    return false;
  }

  /// Load posts for a community.
  
  List<CommunityMemberModel> _members = [];
  bool _isLoadingMembers = false;
  List<CommunityMemberModel> get members => _members;
  bool get isLoadingMembers => _isLoadingMembers;

  Future<void> loadMembers(int communityId) async {
    _isLoadingMembers = true;
    _members = [];
    notifyListeners();

    final response = await _repository.fetchMembers(communityId);
    if (response.success && response.data != null) {
      final list = response.data as List;
      _members = list.map((m) => CommunityMemberModel.fromJson(m as Map<String, dynamic>)).toList();
    } else {
      _errorMessage = response.message;
    }
    _isLoadingMembers = false;
    notifyListeners();
  }

  Future<void> loadPosts(int communityId) async {
    _isLoadingPosts = true;
    _posts = [];
    notifyListeners();

    final response = await _repository.fetchPosts(communityId);

    if (response.success && response.data != null) {
      final list = response.data as List;
      _posts = list
          .map((json) =>
              CommunityPostModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } else {
      _errorMessage = response.message;
    }

    _isLoadingPosts = false;
    notifyListeners();
  }

  /// Create a post in a community.
  Future<bool> createPost({
    required int communityId,
    required String content,
    String? imagePath,
  }) async {
    _isCreating = true;
    notifyListeners();

    final response = await _repository.createPost(
      communityId: communityId,
      content: content,
      imagePath: imagePath,
    );

    _isCreating = false;

    if (response.success) {
      await loadPosts(communityId);
      return true;
    } else {
      _errorMessage = response.message;
      notifyListeners();
      return false;
    }
  }

  // --- Requests & Privacy ---
  Future<Map<String, dynamic>> updateSettings(int id, String privacyMode, List<String> questions) async {
    try {
      final res = await NetworkClient.instance.put('/communities/$id/settings', data: {
        'privacyMode': privacyMode,
        'questions': questions
      });
      return res.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getSettings(int id) async {
    try {
      final res = await NetworkClient.instance.get('/communities/$id/settings');
      return res.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<dynamic>> getRequests(int id) async {
    try {
      final res = await NetworkClient.instance.get('/communities/$id/requests');
      return res.data['data'] ?? [];
    } catch (e) {
      rethrow;
    }
  }

  Future<void> respondRequest(int id, int requestId, String action) async {
    try {
      await NetworkClient.instance.post('/communities/$id/requests/$requestId/respond', data: {'action': action});
    } catch (e) {
      rethrow;
    }
  }


  // --- POSTS INTERACTIONS ---
  Future<Map<String, dynamic>> getPostDetails(int communityId, int postId) async {
    try {
      final res = await NetworkClient.instance.get('/communities/$communityId/posts/$postId/details');
      return res.data['data'] ?? {};
    } catch(e) { return {'likesCount': 0, 'commentsCount': 0, 'isLikedByMe': false}; }
  }

  Future<bool> toggleLike(int communityId, int postId) async {
    try {
      final res = await NetworkClient.instance.post('/communities/$communityId/posts/$postId/like');
      return res.data['isLiked'] ?? false;
    } catch(e) { return false; }
  }

  Future<List<dynamic>> getComments(int communityId, int postId) async {
    try {
      final res = await NetworkClient.instance.get('/communities/$communityId/posts/$postId/comments');
      return res.data['data'] ?? [];
    } catch(e) { return []; }
  }

  Future<bool> addComment(int communityId, int postId, String content) async {
    try {
      await NetworkClient.instance.post('/communities/$communityId/posts/$postId/comments', data: {'content': content});
      return true;
    } catch(e) { return false; }
  }

  Future<bool> editPost(int communityId, int postId, String content) async {
    try {
      await NetworkClient.instance.put('/communities/$communityId/posts/$postId', data: {'content': content});
      int idx = _posts.indexWhere((p) => p.id == postId);
      if(idx != -1) {
        // Can't mutate final model directly, so we reload posts
        await loadPosts(communityId);
      }
      return true;
    } catch(e) { return false; }
  }

  Future<bool> deletePost(int communityId, int postId) async {
    try {
      await NetworkClient.instance.delete('/communities/$communityId/posts/$postId');
      _posts.removeWhere((p) => p.id == postId);
      notifyListeners();
      return true;
    } catch(e) { return false; }
  }


  

  // --- RECURSOS (Folders & Files) ---
  
  
  Future<bool> advanceCourseTopic(int communityId) async {
    try {
      final res = await NetworkClient.instance.post('/communities/$communityId/next-topic');
      if (res.data['success'] == true) {
        if (_activeCommunity != null && _activeCommunity!.id == communityId) {
          final updated = res.data['data'];
          _activeCommunity = CommunityModel.fromJson(updated);
          notifyListeners();
        }
        await loadCommunities();
        return true;
      }
      return false;
    } catch(e) {
      return false;
    }
  }

  Future<List<dynamic>> getFolders(int communityId) async {
    try {
      final res = await NetworkClient.instance.get('/communities/$communityId/folders');
      if (res.data['success'] == true) {
        return res.data['data'] as List<dynamic>;
      }
      return [];
    } catch(e) { return []; }
  }

  Future<bool> createFolder(int communityId, String name) async {
    try {
      final res = await NetworkClient.instance.post('/communities/$communityId/folders', data: {'name': name});
      return res.data['success'] == true;
    } catch(e) { return false; }
  }

  Future<bool> updateFolder(int communityId, int folderId, String name) async {
    try {
      final res = await NetworkClient.instance.put('/communities/$communityId/folders/$folderId', data: {'name': name});
      return res.data['success'] == true;
    } catch(e) { return false; }
  }

  Future<bool> deleteFolder(int communityId, int folderId) async {
    try {
      final res = await NetworkClient.instance.delete('/communities/$communityId/folders/$folderId');
      return res.data['success'] == true;
    } catch(e) { return false; }
  }

  Future<List<dynamic>> getFiles(int communityId, {int? folderId}) async {
    try {
      final url = folderId != null 
        ? '/communities/$communityId/files?folderId=$folderId'
        : '/communities/$communityId/files';
      final res = await NetworkClient.instance.get(url);
      if (res.data['success'] == true) {
        return res.data['data'] as List<dynamic>;
      }
      return [];
    } catch(e) { return []; }
  }

  Future<bool> uploadFile(int communityId, int? folderId, String filePath) async {
    try {
      final formData = dio.FormData.fromMap({
        if (folderId != null) 'folderId': folderId.toString(),
        'file': await dio.MultipartFile.fromFile(filePath),
      });
      final res = await NetworkClient.instance.post(
        '/communities/$communityId/files',
        data: formData
      );
      return res.data['success'] == true;
    } catch(e) { return false; }
  }

  Future<bool> updateFile(int communityId, int fileId, String name) async {
    try {
      final res = await NetworkClient.instance.put('/communities/$communityId/files/$fileId', data: {'name': name});
      return res.data['success'] == true;
    } catch(e) { return false; }
  }

  Future<bool> deleteFile(int communityId, int fileId) async {
    try {
      final res = await NetworkClient.instance.delete('/communities/$communityId/files/$fileId');
      return res.data['success'] == true;
    } catch(e) { return false; }
  }
  
  // --- Asignacion de moderadores ---
  
  Future<List<dynamic>> getModerators(int communityId) async {
    try {
      final res = await NetworkClient.instance.get('/communities/$communityId/moderators');
      if (res.data['success'] == true) {
        return res.data['data'] as List<dynamic>;
      }
      return [];
    } catch(e) { return []; }
  }

  Future<bool> addModerator(int communityId, int studentId) async {
    try {
      final res = await NetworkClient.instance.post('/communities/$communityId/moderators', data: {'studentId': studentId});
      return res.data['success'] == true;
    } catch(e) { return false; }
  }

  Future<bool> removeModerator(int communityId, int studentId) async {
    try {
      final res = await NetworkClient.instance.delete('/communities/$communityId/moderators/$studentId');
      return res.data['success'] == true;
    } catch(e) { return false; }
  }


  Future<List<dynamic>> getQuestions(int id) async {
    try {
      final res = await NetworkClient.instance.get('/communities/$id/questions');
      return res.data['data'] ?? [];
    } catch (e) {
      rethrow;
    }
  }

  Future<void> joinRequest(int id, Map<String, dynamic> answers) async {
    try {
      await NetworkClient.instance.post('/communities/$id/join-request', data: {'answers': answers});
      await fetchMyCommunities(); // Refresh
      await loadCommunities();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> fetchMyCommunities() async {
    // Basic alias to refresh
    await loadCommunities();
  }
}

