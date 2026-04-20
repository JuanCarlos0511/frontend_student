/// State management for communities.
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uni_social_student/features/communities/data/models/community_models.dart';
import 'package:uni_social_student/features/communities/data/repositories/community_repository.dart';

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
  int? _currentStudentId;

  List<CommunityModel> get communities => _communities;
  CommunityModel? get activeCommunity => _activeCommunity;
  List<CommunityPostModel> get posts => _posts;
  bool get isLoading => _isLoading;
  bool get isLoadingPosts => _isLoadingPosts;
  bool get isCreating => _isCreating;
  String get errorMessage => _errorMessage;
  String? get selectedCategory => _selectedCategory;
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
  Future<void> loadCommunities() async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    await _ensureStudentId();

    final response = await _repository.fetchAll(category: _selectedCategory);

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
  }) async {
    _isCreating = true;
    notifyListeners();

    final response = await _repository.create(
      name: name,
      category: category,
      description: description,
      coverImagePath: coverImagePath,
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
}
