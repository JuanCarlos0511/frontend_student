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
  String _searchQuery = '';
  int? _currentStudentId;

  List<CommunityModel> get communities => _communities;
  CommunityModel? get activeCommunity => _activeCommunity;

  List<CommunityFolderModel> _folders = [];
  List<CommunityFileModel> _files = [];
  bool _isLoadingFiles = false;
  int? _currentFolderId;

  List<CommunityFolderModel> get folders => _folders;
  List<CommunityFileModel> get files => _files;
  bool get isLoadingFiles => _isLoadingFiles;
  int? get currentFolderId => _currentFolderId;

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
    
  // --- Folders & Files Methods ---
  void enterFolder(int? folderId) {
    _currentFolderId = folderId;
    if (_activeCommunity != null) {
      loadFilesAndFolders(_activeCommunity!.id);
    }
  }

  Future<void> loadFilesAndFolders(int communityId) async {
    _isLoadingFiles = true;
    notifyListeners();

    if (_currentFolderId == null) {
      final resF = await _repository.fetchFolders(communityId);
      if (resF.success && resF.data != null) {
        _folders = (resF.data as List).map((e) => CommunityFolderModel.fromJson(e)).toList();
      }
    } else {
      _folders = []; // No nested folders natively supported in this iteration
    }

    final resFiles = await _repository.fetchFiles(communityId, folderId: _currentFolderId);
    if (resFiles.success && resFiles.data != null) {
      _files = (resFiles.data as List).map((e) => CommunityFileModel.fromJson(e)).toList();
    }

    _isLoadingFiles = false;
    notifyListeners();
  }

  Future<bool> createFolder(int communityId, String name) async {
    final res = await _repository.createFolder(communityId, name);
    if (res.success) {
      loadFilesAndFolders(communityId);
      return true;
    }
    _errorMessage = res.message;
    notifyListeners();
    return false;
  }

  Future<bool> deleteFolder(int communityId, int folderId) async {
    final res = await _repository.deleteFolder(communityId, folderId);
    if (res.success) {
      loadFilesAndFolders(communityId);
      return true;
    }
    _errorMessage = res.message;
    notifyListeners();
    return false;
  }

  Future<bool> uploadCommunityFile(int communityId, String path) async {
    _isLoadingFiles = true;
    notifyListeners();
    final res = await _repository.uploadFile(communityId, path, folderId: _currentFolderId);
    if (res.success) {
      loadFilesAndFolders(communityId);
      return true;
    }
    _isLoadingFiles = false;
    _errorMessage = res.message;
    notifyListeners();
    return false;
  }

  Future<bool> deleteFile(int communityId, int fileId) async {
    final res = await _repository.deleteFile(communityId, fileId);
    if (res.success) {
      loadFilesAndFolders(communityId);
      return true;
    }
    _errorMessage = res.message;
    notifyListeners();
    return false;
  }
}
  
  // --- Folders & Files Methods ---
  void enterFolder(int? folderId) {
    _currentFolderId = folderId;
    if (_activeCommunity != null) {
      loadFilesAndFolders(_activeCommunity!.id);
    }
  }

  Future<void> loadFilesAndFolders(int communityId) async {
    _isLoadingFiles = true;
    notifyListeners();

    if (_currentFolderId == null) {
      final resF = await _repository.fetchFolders(communityId);
      if (resF.success && resF.data != null) {
        _folders = (resF.data as List).map((e) => CommunityFolderModel.fromJson(e)).toList();
      }
    } else {
      _folders = []; // No nested folders natively supported in this iteration
    }

    final resFiles = await _repository.fetchFiles(communityId, folderId: _currentFolderId);
    if (resFiles.success && resFiles.data != null) {
      _files = (resFiles.data as List).map((e) => CommunityFileModel.fromJson(e)).toList();
    }

    _isLoadingFiles = false;
    notifyListeners();
  }

  Future<bool> createFolder(int communityId, String name) async {
    final res = await _repository.createFolder(communityId, name);
    if (res.success) {
      loadFilesAndFolders(communityId);
      return true;
    }
    _errorMessage = res.message;
    notifyListeners();
    return false;
  }

  Future<bool> deleteFolder(int communityId, int folderId) async {
    final res = await _repository.deleteFolder(communityId, folderId);
    if (res.success) {
      loadFilesAndFolders(communityId);
      return true;
    }
    _errorMessage = res.message;
    notifyListeners();
    return false;
  }

  Future<bool> uploadCommunityFile(int communityId, String path) async {
    _isLoadingFiles = true;
    notifyListeners();
    final res = await _repository.uploadFile(communityId, path, folderId: _currentFolderId);
    if (res.success) {
      loadFilesAndFolders(communityId);
      return true;
    }
    _isLoadingFiles = false;
    _errorMessage = res.message;
    notifyListeners();
    return false;
  }

  Future<bool> deleteFile(int communityId, int fileId) async {
    final res = await _repository.deleteFile(communityId, fileId);
    if (res.success) {
      loadFilesAndFolders(communityId);
      return true;
    }
    _errorMessage = res.message;
    notifyListeners();
    return false;
  }
}

  /// Load communities with optional category filter.
  Future<void> loadCommunities({String query = ''}) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    await _ensureStudentId();

    if (query.isNotEmpty) {
      _searchQuery = query;
    
  // --- Folders & Files Methods ---
  void enterFolder(int? folderId) {
    _currentFolderId = folderId;
    if (_activeCommunity != null) {
      loadFilesAndFolders(_activeCommunity!.id);
    }
  }

  Future<void> loadFilesAndFolders(int communityId) async {
    _isLoadingFiles = true;
    notifyListeners();

    if (_currentFolderId == null) {
      final resF = await _repository.fetchFolders(communityId);
      if (resF.success && resF.data != null) {
        _folders = (resF.data as List).map((e) => CommunityFolderModel.fromJson(e)).toList();
      }
    } else {
      _folders = []; // No nested folders natively supported in this iteration
    }

    final resFiles = await _repository.fetchFiles(communityId, folderId: _currentFolderId);
    if (resFiles.success && resFiles.data != null) {
      _files = (resFiles.data as List).map((e) => CommunityFileModel.fromJson(e)).toList();
    }

    _isLoadingFiles = false;
    notifyListeners();
  }

  Future<bool> createFolder(int communityId, String name) async {
    final res = await _repository.createFolder(communityId, name);
    if (res.success) {
      loadFilesAndFolders(communityId);
      return true;
    }
    _errorMessage = res.message;
    notifyListeners();
    return false;
  }

  Future<bool> deleteFolder(int communityId, int folderId) async {
    final res = await _repository.deleteFolder(communityId, folderId);
    if (res.success) {
      loadFilesAndFolders(communityId);
      return true;
    }
    _errorMessage = res.message;
    notifyListeners();
    return false;
  }

  Future<bool> uploadCommunityFile(int communityId, String path) async {
    _isLoadingFiles = true;
    notifyListeners();
    final res = await _repository.uploadFile(communityId, path, folderId: _currentFolderId);
    if (res.success) {
      loadFilesAndFolders(communityId);
      return true;
    }
    _isLoadingFiles = false;
    _errorMessage = res.message;
    notifyListeners();
    return false;
  }

  Future<bool> deleteFile(int communityId, int fileId) async {
    final res = await _repository.deleteFile(communityId, fileId);
    if (res.success) {
      loadFilesAndFolders(communityId);
      return true;
    }
    _errorMessage = res.message;
    notifyListeners();
    return false;
  }
}
    final response = await _repository.fetchAll(category: _selectedCategory, search: _searchQuery);

    if (response.success && response.data != null) {
      _currentFolderId = null;
      loadFilesAndFolders(id);
      final list = response.data as List;
      _communities = list
          .map((json) =>
              CommunityModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } else {
      _errorMessage = response.message;
    
  // --- Folders & Files Methods ---
  void enterFolder(int? folderId) {
    _currentFolderId = folderId;
    if (_activeCommunity != null) {
      loadFilesAndFolders(_activeCommunity!.id);
    }
  }

  Future<void> loadFilesAndFolders(int communityId) async {
    _isLoadingFiles = true;
    notifyListeners();

    if (_currentFolderId == null) {
      final resF = await _repository.fetchFolders(communityId);
      if (resF.success && resF.data != null) {
        _folders = (resF.data as List).map((e) => CommunityFolderModel.fromJson(e)).toList();
      }
    } else {
      _folders = []; // No nested folders natively supported in this iteration
    }

    final resFiles = await _repository.fetchFiles(communityId, folderId: _currentFolderId);
    if (resFiles.success && resFiles.data != null) {
      _files = (resFiles.data as List).map((e) => CommunityFileModel.fromJson(e)).toList();
    }

    _isLoadingFiles = false;
    notifyListeners();
  }

  Future<bool> createFolder(int communityId, String name) async {
    final res = await _repository.createFolder(communityId, name);
    if (res.success) {
      loadFilesAndFolders(communityId);
      return true;
    }
    _errorMessage = res.message;
    notifyListeners();
    return false;
  }

  Future<bool> deleteFolder(int communityId, int folderId) async {
    final res = await _repository.deleteFolder(communityId, folderId);
    if (res.success) {
      loadFilesAndFolders(communityId);
      return true;
    }
    _errorMessage = res.message;
    notifyListeners();
    return false;
  }

  Future<bool> uploadCommunityFile(int communityId, String path) async {
    _isLoadingFiles = true;
    notifyListeners();
    final res = await _repository.uploadFile(communityId, path, folderId: _currentFolderId);
    if (res.success) {
      loadFilesAndFolders(communityId);
      return true;
    }
    _isLoadingFiles = false;
    _errorMessage = res.message;
    notifyListeners();
    return false;
  }

  Future<bool> deleteFile(int communityId, int fileId) async {
    final res = await _repository.deleteFile(communityId, fileId);
    if (res.success) {
      loadFilesAndFolders(communityId);
      return true;
    }
    _errorMessage = res.message;
    notifyListeners();
    return false;
  }
}

    _isLoading = false;
    notifyListeners();
  
  // --- Folders & Files Methods ---
  void enterFolder(int? folderId) {
    _currentFolderId = folderId;
    if (_activeCommunity != null) {
      loadFilesAndFolders(_activeCommunity!.id);
    }
  }

  Future<void> loadFilesAndFolders(int communityId) async {
    _isLoadingFiles = true;
    notifyListeners();

    if (_currentFolderId == null) {
      final resF = await _repository.fetchFolders(communityId);
      if (resF.success && resF.data != null) {
        _folders = (resF.data as List).map((e) => CommunityFolderModel.fromJson(e)).toList();
      }
    } else {
      _folders = []; // No nested folders natively supported in this iteration
    }

    final resFiles = await _repository.fetchFiles(communityId, folderId: _currentFolderId);
    if (resFiles.success && resFiles.data != null) {
      _files = (resFiles.data as List).map((e) => CommunityFileModel.fromJson(e)).toList();
    }

    _isLoadingFiles = false;
    notifyListeners();
  }

  Future<bool> createFolder(int communityId, String name) async {
    final res = await _repository.createFolder(communityId, name);
    if (res.success) {
      loadFilesAndFolders(communityId);
      return true;
    }
    _errorMessage = res.message;
    notifyListeners();
    return false;
  }

  Future<bool> deleteFolder(int communityId, int folderId) async {
    final res = await _repository.deleteFolder(communityId, folderId);
    if (res.success) {
      loadFilesAndFolders(communityId);
      return true;
    }
    _errorMessage = res.message;
    notifyListeners();
    return false;
  }

  Future<bool> uploadCommunityFile(int communityId, String path) async {
    _isLoadingFiles = true;
    notifyListeners();
    final res = await _repository.uploadFile(communityId, path, folderId: _currentFolderId);
    if (res.success) {
      loadFilesAndFolders(communityId);
      return true;
    }
    _isLoadingFiles = false;
    _errorMessage = res.message;
    notifyListeners();
    return false;
  }

  Future<bool> deleteFile(int communityId, int fileId) async {
    final res = await _repository.deleteFile(communityId, fileId);
    if (res.success) {
      loadFilesAndFolders(communityId);
      return true;
    }
    _errorMessage = res.message;
    notifyListeners();
    return false;
  }
}

  /// Set category filter and reload.
  void setSearchQuery(String query) {
    _searchQuery = query;
    loadCommunities();
  
  // --- Folders & Files Methods ---
  void enterFolder(int? folderId) {
    _currentFolderId = folderId;
    if (_activeCommunity != null) {
      loadFilesAndFolders(_activeCommunity!.id);
    }
  }

  Future<void> loadFilesAndFolders(int communityId) async {
    _isLoadingFiles = true;
    notifyListeners();

    if (_currentFolderId == null) {
      final resF = await _repository.fetchFolders(communityId);
      if (resF.success && resF.data != null) {
        _folders = (resF.data as List).map((e) => CommunityFolderModel.fromJson(e)).toList();
      }
    } else {
      _folders = []; // No nested folders natively supported in this iteration
    }

    final resFiles = await _repository.fetchFiles(communityId, folderId: _currentFolderId);
    if (resFiles.success && resFiles.data != null) {
      _files = (resFiles.data as List).map((e) => CommunityFileModel.fromJson(e)).toList();
    }

    _isLoadingFiles = false;
    notifyListeners();
  }

  Future<bool> createFolder(int communityId, String name) async {
    final res = await _repository.createFolder(communityId, name);
    if (res.success) {
      loadFilesAndFolders(communityId);
      return true;
    }
    _errorMessage = res.message;
    notifyListeners();
    return false;
  }

  Future<bool> deleteFolder(int communityId, int folderId) async {
    final res = await _repository.deleteFolder(communityId, folderId);
    if (res.success) {
      loadFilesAndFolders(communityId);
      return true;
    }
    _errorMessage = res.message;
    notifyListeners();
    return false;
  }

  Future<bool> uploadCommunityFile(int communityId, String path) async {
    _isLoadingFiles = true;
    notifyListeners();
    final res = await _repository.uploadFile(communityId, path, folderId: _currentFolderId);
    if (res.success) {
      loadFilesAndFolders(communityId);
      return true;
    }
    _isLoadingFiles = false;
    _errorMessage = res.message;
    notifyListeners();
    return false;
  }

  Future<bool> deleteFile(int communityId, int fileId) async {
    final res = await _repository.deleteFile(communityId, fileId);
    if (res.success) {
      loadFilesAndFolders(communityId);
      return true;
    }
    _errorMessage = res.message;
    notifyListeners();
    return false;
  }
}

  void setCategory(String? category) {
    _selectedCategory = category;
    loadCommunities();
  
  // --- Folders & Files Methods ---
  void enterFolder(int? folderId) {
    _currentFolderId = folderId;
    if (_activeCommunity != null) {
      loadFilesAndFolders(_activeCommunity!.id);
    }
  }

  Future<void> loadFilesAndFolders(int communityId) async {
    _isLoadingFiles = true;
    notifyListeners();

    if (_currentFolderId == null) {
      final resF = await _repository.fetchFolders(communityId);
      if (resF.success && resF.data != null) {
        _folders = (resF.data as List).map((e) => CommunityFolderModel.fromJson(e)).toList();
      }
    } else {
      _folders = []; // No nested folders natively supported in this iteration
    }

    final resFiles = await _repository.fetchFiles(communityId, folderId: _currentFolderId);
    if (resFiles.success && resFiles.data != null) {
      _files = (resFiles.data as List).map((e) => CommunityFileModel.fromJson(e)).toList();
    }

    _isLoadingFiles = false;
    notifyListeners();
  }

  Future<bool> createFolder(int communityId, String name) async {
    final res = await _repository.createFolder(communityId, name);
    if (res.success) {
      loadFilesAndFolders(communityId);
      return true;
    }
    _errorMessage = res.message;
    notifyListeners();
    return false;
  }

  Future<bool> deleteFolder(int communityId, int folderId) async {
    final res = await _repository.deleteFolder(communityId, folderId);
    if (res.success) {
      loadFilesAndFolders(communityId);
      return true;
    }
    _errorMessage = res.message;
    notifyListeners();
    return false;
  }

  Future<bool> uploadCommunityFile(int communityId, String path) async {
    _isLoadingFiles = true;
    notifyListeners();
    final res = await _repository.uploadFile(communityId, path, folderId: _currentFolderId);
    if (res.success) {
      loadFilesAndFolders(communityId);
      return true;
    }
    _isLoadingFiles = false;
    _errorMessage = res.message;
    notifyListeners();
    return false;
  }

  Future<bool> deleteFile(int communityId, int fileId) async {
    final res = await _repository.deleteFile(communityId, fileId);
    if (res.success) {
      loadFilesAndFolders(communityId);
      return true;
    }
    _errorMessage = res.message;
    notifyListeners();
    return false;
  }
}

  /// Load a specific community's detail.
  Future<void> loadCommunityDetail(int id) async {
    _isLoading = true;
    notifyListeners();

    final response = await _repository.getById(id);

    if (response.success && response.data != null) {
      _currentFolderId = null;
      loadFilesAndFolders(id);
      _activeCommunity =
          CommunityModel.fromJson(response.data as Map<String, dynamic>);
    } else {
      _errorMessage = response.message;
    
  // --- Folders & Files Methods ---
  void enterFolder(int? folderId) {
    _currentFolderId = folderId;
    if (_activeCommunity != null) {
      loadFilesAndFolders(_activeCommunity!.id);
    }
  }

  Future<void> loadFilesAndFolders(int communityId) async {
    _isLoadingFiles = true;
    notifyListeners();

    if (_currentFolderId == null) {
      final resF = await _repository.fetchFolders(communityId);
      if (resF.success && resF.data != null) {
        _folders = (resF.data as List).map((e) => CommunityFolderModel.fromJson(e)).toList();
      }
    } else {
      _folders = []; // No nested folders natively supported in this iteration
    }

    final resFiles = await _repository.fetchFiles(communityId, folderId: _currentFolderId);
    if (resFiles.success && resFiles.data != null) {
      _files = (resFiles.data as List).map((e) => CommunityFileModel.fromJson(e)).toList();
    }

    _isLoadingFiles = false;
    notifyListeners();
  }

  Future<bool> createFolder(int communityId, String name) async {
    final res = await _repository.createFolder(communityId, name);
    if (res.success) {
      loadFilesAndFolders(communityId);
      return true;
    }
    _errorMessage = res.message;
    notifyListeners();
    return false;
  }

  Future<bool> deleteFolder(int communityId, int folderId) async {
    final res = await _repository.deleteFolder(communityId, folderId);
    if (res.success) {
      loadFilesAndFolders(communityId);
      return true;
    }
    _errorMessage = res.message;
    notifyListeners();
    return false;
  }

  Future<bool> uploadCommunityFile(int communityId, String path) async {
    _isLoadingFiles = true;
    notifyListeners();
    final res = await _repository.uploadFile(communityId, path, folderId: _currentFolderId);
    if (res.success) {
      loadFilesAndFolders(communityId);
      return true;
    }
    _isLoadingFiles = false;
    _errorMessage = res.message;
    notifyListeners();
    return false;
  }

  Future<bool> deleteFile(int communityId, int fileId) async {
    final res = await _repository.deleteFile(communityId, fileId);
    if (res.success) {
      loadFilesAndFolders(communityId);
      return true;
    }
    _errorMessage = res.message;
    notifyListeners();
    return false;
  }
}

    _isLoading = false;
    notifyListeners();
  
  // --- Folders & Files Methods ---
  void enterFolder(int? folderId) {
    _currentFolderId = folderId;
    if (_activeCommunity != null) {
      loadFilesAndFolders(_activeCommunity!.id);
    }
  }

  Future<void> loadFilesAndFolders(int communityId) async {
    _isLoadingFiles = true;
    notifyListeners();

    if (_currentFolderId == null) {
      final resF = await _repository.fetchFolders(communityId);
      if (resF.success && resF.data != null) {
        _folders = (resF.data as List).map((e) => CommunityFolderModel.fromJson(e)).toList();
      }
    } else {
      _folders = []; // No nested folders natively supported in this iteration
    }

    final resFiles = await _repository.fetchFiles(communityId, folderId: _currentFolderId);
    if (resFiles.success && resFiles.data != null) {
      _files = (resFiles.data as List).map((e) => CommunityFileModel.fromJson(e)).toList();
    }

    _isLoadingFiles = false;
    notifyListeners();
  }

  Future<bool> createFolder(int communityId, String name) async {
    final res = await _repository.createFolder(communityId, name);
    if (res.success) {
      loadFilesAndFolders(communityId);
      return true;
    }
    _errorMessage = res.message;
    notifyListeners();
    return false;
  }

  Future<bool> deleteFolder(int communityId, int folderId) async {
    final res = await _repository.deleteFolder(communityId, folderId);
    if (res.success) {
      loadFilesAndFolders(communityId);
      return true;
    }
    _errorMessage = res.message;
    notifyListeners();
    return false;
  }

  Future<bool> uploadCommunityFile(int communityId, String path) async {
    _isLoadingFiles = true;
    notifyListeners();
    final res = await _repository.uploadFile(communityId, path, folderId: _currentFolderId);
    if (res.success) {
      loadFilesAndFolders(communityId);
      return true;
    }
    _isLoadingFiles = false;
    _errorMessage = res.message;
    notifyListeners();
    return false;
  }

  Future<bool> deleteFile(int communityId, int fileId) async {
    final res = await _repository.deleteFile(communityId, fileId);
    if (res.success) {
      loadFilesAndFolders(communityId);
      return true;
    }
    _errorMessage = res.message;
    notifyListeners();
    return false;
  }
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
    
  // --- Folders & Files Methods ---
  void enterFolder(int? folderId) {
    _currentFolderId = folderId;
    if (_activeCommunity != null) {
      loadFilesAndFolders(_activeCommunity!.id);
    }
  }

  Future<void> loadFilesAndFolders(int communityId) async {
    _isLoadingFiles = true;
    notifyListeners();

    if (_currentFolderId == null) {
      final resF = await _repository.fetchFolders(communityId);
      if (resF.success && resF.data != null) {
        _folders = (resF.data as List).map((e) => CommunityFolderModel.fromJson(e)).toList();
      }
    } else {
      _folders = []; // No nested folders natively supported in this iteration
    }

    final resFiles = await _repository.fetchFiles(communityId, folderId: _currentFolderId);
    if (resFiles.success && resFiles.data != null) {
      _files = (resFiles.data as List).map((e) => CommunityFileModel.fromJson(e)).toList();
    }

    _isLoadingFiles = false;
    notifyListeners();
  }

  Future<bool> createFolder(int communityId, String name) async {
    final res = await _repository.createFolder(communityId, name);
    if (res.success) {
      loadFilesAndFolders(communityId);
      return true;
    }
    _errorMessage = res.message;
    notifyListeners();
    return false;
  }

  Future<bool> deleteFolder(int communityId, int folderId) async {
    final res = await _repository.deleteFolder(communityId, folderId);
    if (res.success) {
      loadFilesAndFolders(communityId);
      return true;
    }
    _errorMessage = res.message;
    notifyListeners();
    return false;
  }

  Future<bool> uploadCommunityFile(int communityId, String path) async {
    _isLoadingFiles = true;
    notifyListeners();
    final res = await _repository.uploadFile(communityId, path, folderId: _currentFolderId);
    if (res.success) {
      loadFilesAndFolders(communityId);
      return true;
    }
    _isLoadingFiles = false;
    _errorMessage = res.message;
    notifyListeners();
    return false;
  }

  Future<bool> deleteFile(int communityId, int fileId) async {
    final res = await _repository.deleteFile(communityId, fileId);
    if (res.success) {
      loadFilesAndFolders(communityId);
      return true;
    }
    _errorMessage = res.message;
    notifyListeners();
    return false;
  }
}
  
  // --- Folders & Files Methods ---
  void enterFolder(int? folderId) {
    _currentFolderId = folderId;
    if (_activeCommunity != null) {
      loadFilesAndFolders(_activeCommunity!.id);
    }
  }

  Future<void> loadFilesAndFolders(int communityId) async {
    _isLoadingFiles = true;
    notifyListeners();

    if (_currentFolderId == null) {
      final resF = await _repository.fetchFolders(communityId);
      if (resF.success && resF.data != null) {
        _folders = (resF.data as List).map((e) => CommunityFolderModel.fromJson(e)).toList();
      }
    } else {
      _folders = []; // No nested folders natively supported in this iteration
    }

    final resFiles = await _repository.fetchFiles(communityId, folderId: _currentFolderId);
    if (resFiles.success && resFiles.data != null) {
      _files = (resFiles.data as List).map((e) => CommunityFileModel.fromJson(e)).toList();
    }

    _isLoadingFiles = false;
    notifyListeners();
  }

  Future<bool> createFolder(int communityId, String name) async {
    final res = await _repository.createFolder(communityId, name);
    if (res.success) {
      loadFilesAndFolders(communityId);
      return true;
    }
    _errorMessage = res.message;
    notifyListeners();
    return false;
  }

  Future<bool> deleteFolder(int communityId, int folderId) async {
    final res = await _repository.deleteFolder(communityId, folderId);
    if (res.success) {
      loadFilesAndFolders(communityId);
      return true;
    }
    _errorMessage = res.message;
    notifyListeners();
    return false;
  }

  Future<bool> uploadCommunityFile(int communityId, String path) async {
    _isLoadingFiles = true;
    notifyListeners();
    final res = await _repository.uploadFile(communityId, path, folderId: _currentFolderId);
    if (res.success) {
      loadFilesAndFolders(communityId);
      return true;
    }
    _isLoadingFiles = false;
    _errorMessage = res.message;
    notifyListeners();
    return false;
  }

  Future<bool> deleteFile(int communityId, int fileId) async {
    final res = await _repository.deleteFile(communityId, fileId);
    if (res.success) {
      loadFilesAndFolders(communityId);
      return true;
    }
    _errorMessage = res.message;
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
    
  // --- Folders & Files Methods ---
  void enterFolder(int? folderId) {
    _currentFolderId = folderId;
    if (_activeCommunity != null) {
      loadFilesAndFolders(_activeCommunity!.id);
    }
  }

  Future<void> loadFilesAndFolders(int communityId) async {
    _isLoadingFiles = true;
    notifyListeners();

    if (_currentFolderId == null) {
      final resF = await _repository.fetchFolders(communityId);
      if (resF.success && resF.data != null) {
        _folders = (resF.data as List).map((e) => CommunityFolderModel.fromJson(e)).toList();
      }
    } else {
      _folders = []; // No nested folders natively supported in this iteration
    }

    final resFiles = await _repository.fetchFiles(communityId, folderId: _currentFolderId);
    if (resFiles.success && resFiles.data != null) {
      _files = (resFiles.data as List).map((e) => CommunityFileModel.fromJson(e)).toList();
    }

    _isLoadingFiles = false;
    notifyListeners();
  }

  Future<bool> createFolder(int communityId, String name) async {
    final res = await _repository.createFolder(communityId, name);
    if (res.success) {
      loadFilesAndFolders(communityId);
      return true;
    }
    _errorMessage = res.message;
    notifyListeners();
    return false;
  }

  Future<bool> deleteFolder(int communityId, int folderId) async {
    final res = await _repository.deleteFolder(communityId, folderId);
    if (res.success) {
      loadFilesAndFolders(communityId);
      return true;
    }
    _errorMessage = res.message;
    notifyListeners();
    return false;
  }

  Future<bool> uploadCommunityFile(int communityId, String path) async {
    _isLoadingFiles = true;
    notifyListeners();
    final res = await _repository.uploadFile(communityId, path, folderId: _currentFolderId);
    if (res.success) {
      loadFilesAndFolders(communityId);
      return true;
    }
    _isLoadingFiles = false;
    _errorMessage = res.message;
    notifyListeners();
    return false;
  }

  Future<bool> deleteFile(int communityId, int fileId) async {
    final res = await _repository.deleteFile(communityId, fileId);
    if (res.success) {
      loadFilesAndFolders(communityId);
      return true;
    }
    _errorMessage = res.message;
    notifyListeners();
    return false;
  }
}
    _errorMessage = response.message;
    notifyListeners();
    return false;
  
  // --- Folders & Files Methods ---
  void enterFolder(int? folderId) {
    _currentFolderId = folderId;
    if (_activeCommunity != null) {
      loadFilesAndFolders(_activeCommunity!.id);
    }
  }

  Future<void> loadFilesAndFolders(int communityId) async {
    _isLoadingFiles = true;
    notifyListeners();

    if (_currentFolderId == null) {
      final resF = await _repository.fetchFolders(communityId);
      if (resF.success && resF.data != null) {
        _folders = (resF.data as List).map((e) => CommunityFolderModel.fromJson(e)).toList();
      }
    } else {
      _folders = []; // No nested folders natively supported in this iteration
    }

    final resFiles = await _repository.fetchFiles(communityId, folderId: _currentFolderId);
    if (resFiles.success && resFiles.data != null) {
      _files = (resFiles.data as List).map((e) => CommunityFileModel.fromJson(e)).toList();
    }

    _isLoadingFiles = false;
    notifyListeners();
  }

  Future<bool> createFolder(int communityId, String name) async {
    final res = await _repository.createFolder(communityId, name);
    if (res.success) {
      loadFilesAndFolders(communityId);
      return true;
    }
    _errorMessage = res.message;
    notifyListeners();
    return false;
  }

  Future<bool> deleteFolder(int communityId, int folderId) async {
    final res = await _repository.deleteFolder(communityId, folderId);
    if (res.success) {
      loadFilesAndFolders(communityId);
      return true;
    }
    _errorMessage = res.message;
    notifyListeners();
    return false;
  }

  Future<bool> uploadCommunityFile(int communityId, String path) async {
    _isLoadingFiles = true;
    notifyListeners();
    final res = await _repository.uploadFile(communityId, path, folderId: _currentFolderId);
    if (res.success) {
      loadFilesAndFolders(communityId);
      return true;
    }
    _isLoadingFiles = false;
    _errorMessage = res.message;
    notifyListeners();
    return false;
  }

  Future<bool> deleteFile(int communityId, int fileId) async {
    final res = await _repository.deleteFile(communityId, fileId);
    if (res.success) {
      loadFilesAndFolders(communityId);
      return true;
    }
    _errorMessage = res.message;
    notifyListeners();
    return false;
  }
}

  /// Leave a community.
  Future<bool> leaveCommunity(int communityId) async {
    final response = await _repository.leave(communityId);
    if (response.success) {
      await loadCommunities();
      return true;
    
  // --- Folders & Files Methods ---
  void enterFolder(int? folderId) {
    _currentFolderId = folderId;
    if (_activeCommunity != null) {
      loadFilesAndFolders(_activeCommunity!.id);
    }
  }

  Future<void> loadFilesAndFolders(int communityId) async {
    _isLoadingFiles = true;
    notifyListeners();

    if (_currentFolderId == null) {
      final resF = await _repository.fetchFolders(communityId);
      if (resF.success && resF.data != null) {
        _folders = (resF.data as List).map((e) => CommunityFolderModel.fromJson(e)).toList();
      }
    } else {
      _folders = []; // No nested folders natively supported in this iteration
    }

    final resFiles = await _repository.fetchFiles(communityId, folderId: _currentFolderId);
    if (resFiles.success && resFiles.data != null) {
      _files = (resFiles.data as List).map((e) => CommunityFileModel.fromJson(e)).toList();
    }

    _isLoadingFiles = false;
    notifyListeners();
  }

  Future<bool> createFolder(int communityId, String name) async {
    final res = await _repository.createFolder(communityId, name);
    if (res.success) {
      loadFilesAndFolders(communityId);
      return true;
    }
    _errorMessage = res.message;
    notifyListeners();
    return false;
  }

  Future<bool> deleteFolder(int communityId, int folderId) async {
    final res = await _repository.deleteFolder(communityId, folderId);
    if (res.success) {
      loadFilesAndFolders(communityId);
      return true;
    }
    _errorMessage = res.message;
    notifyListeners();
    return false;
  }

  Future<bool> uploadCommunityFile(int communityId, String path) async {
    _isLoadingFiles = true;
    notifyListeners();
    final res = await _repository.uploadFile(communityId, path, folderId: _currentFolderId);
    if (res.success) {
      loadFilesAndFolders(communityId);
      return true;
    }
    _isLoadingFiles = false;
    _errorMessage = res.message;
    notifyListeners();
    return false;
  }

  Future<bool> deleteFile(int communityId, int fileId) async {
    final res = await _repository.deleteFile(communityId, fileId);
    if (res.success) {
      loadFilesAndFolders(communityId);
      return true;
    }
    _errorMessage = res.message;
    notifyListeners();
    return false;
  }
}
    _errorMessage = response.message;
    notifyListeners();
    return false;
  
  // --- Folders & Files Methods ---
  void enterFolder(int? folderId) {
    _currentFolderId = folderId;
    if (_activeCommunity != null) {
      loadFilesAndFolders(_activeCommunity!.id);
    }
  }

  Future<void> loadFilesAndFolders(int communityId) async {
    _isLoadingFiles = true;
    notifyListeners();

    if (_currentFolderId == null) {
      final resF = await _repository.fetchFolders(communityId);
      if (resF.success && resF.data != null) {
        _folders = (resF.data as List).map((e) => CommunityFolderModel.fromJson(e)).toList();
      }
    } else {
      _folders = []; // No nested folders natively supported in this iteration
    }

    final resFiles = await _repository.fetchFiles(communityId, folderId: _currentFolderId);
    if (resFiles.success && resFiles.data != null) {
      _files = (resFiles.data as List).map((e) => CommunityFileModel.fromJson(e)).toList();
    }

    _isLoadingFiles = false;
    notifyListeners();
  }

  Future<bool> createFolder(int communityId, String name) async {
    final res = await _repository.createFolder(communityId, name);
    if (res.success) {
      loadFilesAndFolders(communityId);
      return true;
    }
    _errorMessage = res.message;
    notifyListeners();
    return false;
  }

  Future<bool> deleteFolder(int communityId, int folderId) async {
    final res = await _repository.deleteFolder(communityId, folderId);
    if (res.success) {
      loadFilesAndFolders(communityId);
      return true;
    }
    _errorMessage = res.message;
    notifyListeners();
    return false;
  }

  Future<bool> uploadCommunityFile(int communityId, String path) async {
    _isLoadingFiles = true;
    notifyListeners();
    final res = await _repository.uploadFile(communityId, path, folderId: _currentFolderId);
    if (res.success) {
      loadFilesAndFolders(communityId);
      return true;
    }
    _isLoadingFiles = false;
    _errorMessage = res.message;
    notifyListeners();
    return false;
  }

  Future<bool> deleteFile(int communityId, int fileId) async {
    final res = await _repository.deleteFile(communityId, fileId);
    if (res.success) {
      loadFilesAndFolders(communityId);
      return true;
    }
    _errorMessage = res.message;
    notifyListeners();
    return false;
  }
}

  /// Delete a community (creator only).
  Future<bool> deleteCommunity(int communityId) async {
    final response = await _repository.deleteCommunity(communityId);
    if (response.success) {
      _activeCommunity = null;
      await loadCommunities();
      return true;
    
  // --- Folders & Files Methods ---
  void enterFolder(int? folderId) {
    _currentFolderId = folderId;
    if (_activeCommunity != null) {
      loadFilesAndFolders(_activeCommunity!.id);
    }
  }

  Future<void> loadFilesAndFolders(int communityId) async {
    _isLoadingFiles = true;
    notifyListeners();

    if (_currentFolderId == null) {
      final resF = await _repository.fetchFolders(communityId);
      if (resF.success && resF.data != null) {
        _folders = (resF.data as List).map((e) => CommunityFolderModel.fromJson(e)).toList();
      }
    } else {
      _folders = []; // No nested folders natively supported in this iteration
    }

    final resFiles = await _repository.fetchFiles(communityId, folderId: _currentFolderId);
    if (resFiles.success && resFiles.data != null) {
      _files = (resFiles.data as List).map((e) => CommunityFileModel.fromJson(e)).toList();
    }

    _isLoadingFiles = false;
    notifyListeners();
  }

  Future<bool> createFolder(int communityId, String name) async {
    final res = await _repository.createFolder(communityId, name);
    if (res.success) {
      loadFilesAndFolders(communityId);
      return true;
    }
    _errorMessage = res.message;
    notifyListeners();
    return false;
  }

  Future<bool> deleteFolder(int communityId, int folderId) async {
    final res = await _repository.deleteFolder(communityId, folderId);
    if (res.success) {
      loadFilesAndFolders(communityId);
      return true;
    }
    _errorMessage = res.message;
    notifyListeners();
    return false;
  }

  Future<bool> uploadCommunityFile(int communityId, String path) async {
    _isLoadingFiles = true;
    notifyListeners();
    final res = await _repository.uploadFile(communityId, path, folderId: _currentFolderId);
    if (res.success) {
      loadFilesAndFolders(communityId);
      return true;
    }
    _isLoadingFiles = false;
    _errorMessage = res.message;
    notifyListeners();
    return false;
  }

  Future<bool> deleteFile(int communityId, int fileId) async {
    final res = await _repository.deleteFile(communityId, fileId);
    if (res.success) {
      loadFilesAndFolders(communityId);
      return true;
    }
    _errorMessage = res.message;
    notifyListeners();
    return false;
  }
}
    _errorMessage = response.message;
    notifyListeners();
    return false;
  
  // --- Folders & Files Methods ---
  void enterFolder(int? folderId) {
    _currentFolderId = folderId;
    if (_activeCommunity != null) {
      loadFilesAndFolders(_activeCommunity!.id);
    }
  }

  Future<void> loadFilesAndFolders(int communityId) async {
    _isLoadingFiles = true;
    notifyListeners();

    if (_currentFolderId == null) {
      final resF = await _repository.fetchFolders(communityId);
      if (resF.success && resF.data != null) {
        _folders = (resF.data as List).map((e) => CommunityFolderModel.fromJson(e)).toList();
      }
    } else {
      _folders = []; // No nested folders natively supported in this iteration
    }

    final resFiles = await _repository.fetchFiles(communityId, folderId: _currentFolderId);
    if (resFiles.success && resFiles.data != null) {
      _files = (resFiles.data as List).map((e) => CommunityFileModel.fromJson(e)).toList();
    }

    _isLoadingFiles = false;
    notifyListeners();
  }

  Future<bool> createFolder(int communityId, String name) async {
    final res = await _repository.createFolder(communityId, name);
    if (res.success) {
      loadFilesAndFolders(communityId);
      return true;
    }
    _errorMessage = res.message;
    notifyListeners();
    return false;
  }

  Future<bool> deleteFolder(int communityId, int folderId) async {
    final res = await _repository.deleteFolder(communityId, folderId);
    if (res.success) {
      loadFilesAndFolders(communityId);
      return true;
    }
    _errorMessage = res.message;
    notifyListeners();
    return false;
  }

  Future<bool> uploadCommunityFile(int communityId, String path) async {
    _isLoadingFiles = true;
    notifyListeners();
    final res = await _repository.uploadFile(communityId, path, folderId: _currentFolderId);
    if (res.success) {
      loadFilesAndFolders(communityId);
      return true;
    }
    _isLoadingFiles = false;
    _errorMessage = res.message;
    notifyListeners();
    return false;
  }

  Future<bool> deleteFile(int communityId, int fileId) async {
    final res = await _repository.deleteFile(communityId, fileId);
    if (res.success) {
      loadFilesAndFolders(communityId);
      return true;
    }
    _errorMessage = res.message;
    notifyListeners();
    return false;
  }
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
      _currentFolderId = null;
      loadFilesAndFolders(id);
      final list = response.data as List;
      _members = list.map((m) => CommunityMemberModel.fromJson(m as Map<String, dynamic>)).toList();
    } else {
      _errorMessage = response.message;
    
  // --- Folders & Files Methods ---
  void enterFolder(int? folderId) {
    _currentFolderId = folderId;
    if (_activeCommunity != null) {
      loadFilesAndFolders(_activeCommunity!.id);
    }
  }

  Future<void> loadFilesAndFolders(int communityId) async {
    _isLoadingFiles = true;
    notifyListeners();

    if (_currentFolderId == null) {
      final resF = await _repository.fetchFolders(communityId);
      if (resF.success && resF.data != null) {
        _folders = (resF.data as List).map((e) => CommunityFolderModel.fromJson(e)).toList();
      }
    } else {
      _folders = []; // No nested folders natively supported in this iteration
    }

    final resFiles = await _repository.fetchFiles(communityId, folderId: _currentFolderId);
    if (resFiles.success && resFiles.data != null) {
      _files = (resFiles.data as List).map((e) => CommunityFileModel.fromJson(e)).toList();
    }

    _isLoadingFiles = false;
    notifyListeners();
  }

  Future<bool> createFolder(int communityId, String name) async {
    final res = await _repository.createFolder(communityId, name);
    if (res.success) {
      loadFilesAndFolders(communityId);
      return true;
    }
    _errorMessage = res.message;
    notifyListeners();
    return false;
  }

  Future<bool> deleteFolder(int communityId, int folderId) async {
    final res = await _repository.deleteFolder(communityId, folderId);
    if (res.success) {
      loadFilesAndFolders(communityId);
      return true;
    }
    _errorMessage = res.message;
    notifyListeners();
    return false;
  }

  Future<bool> uploadCommunityFile(int communityId, String path) async {
    _isLoadingFiles = true;
    notifyListeners();
    final res = await _repository.uploadFile(communityId, path, folderId: _currentFolderId);
    if (res.success) {
      loadFilesAndFolders(communityId);
      return true;
    }
    _isLoadingFiles = false;
    _errorMessage = res.message;
    notifyListeners();
    return false;
  }

  Future<bool> deleteFile(int communityId, int fileId) async {
    final res = await _repository.deleteFile(communityId, fileId);
    if (res.success) {
      loadFilesAndFolders(communityId);
      return true;
    }
    _errorMessage = res.message;
    notifyListeners();
    return false;
  }
}
    _isLoadingMembers = false;
    notifyListeners();
  
  // --- Folders & Files Methods ---
  void enterFolder(int? folderId) {
    _currentFolderId = folderId;
    if (_activeCommunity != null) {
      loadFilesAndFolders(_activeCommunity!.id);
    }
  }

  Future<void> loadFilesAndFolders(int communityId) async {
    _isLoadingFiles = true;
    notifyListeners();

    if (_currentFolderId == null) {
      final resF = await _repository.fetchFolders(communityId);
      if (resF.success && resF.data != null) {
        _folders = (resF.data as List).map((e) => CommunityFolderModel.fromJson(e)).toList();
      }
    } else {
      _folders = []; // No nested folders natively supported in this iteration
    }

    final resFiles = await _repository.fetchFiles(communityId, folderId: _currentFolderId);
    if (resFiles.success && resFiles.data != null) {
      _files = (resFiles.data as List).map((e) => CommunityFileModel.fromJson(e)).toList();
    }

    _isLoadingFiles = false;
    notifyListeners();
  }

  Future<bool> createFolder(int communityId, String name) async {
    final res = await _repository.createFolder(communityId, name);
    if (res.success) {
      loadFilesAndFolders(communityId);
      return true;
    }
    _errorMessage = res.message;
    notifyListeners();
    return false;
  }

  Future<bool> deleteFolder(int communityId, int folderId) async {
    final res = await _repository.deleteFolder(communityId, folderId);
    if (res.success) {
      loadFilesAndFolders(communityId);
      return true;
    }
    _errorMessage = res.message;
    notifyListeners();
    return false;
  }

  Future<bool> uploadCommunityFile(int communityId, String path) async {
    _isLoadingFiles = true;
    notifyListeners();
    final res = await _repository.uploadFile(communityId, path, folderId: _currentFolderId);
    if (res.success) {
      loadFilesAndFolders(communityId);
      return true;
    }
    _isLoadingFiles = false;
    _errorMessage = res.message;
    notifyListeners();
    return false;
  }

  Future<bool> deleteFile(int communityId, int fileId) async {
    final res = await _repository.deleteFile(communityId, fileId);
    if (res.success) {
      loadFilesAndFolders(communityId);
      return true;
    }
    _errorMessage = res.message;
    notifyListeners();
    return false;
  }
}

  Future<void> loadPosts(int communityId) async {
    _isLoadingPosts = true;
    _posts = [];
    notifyListeners();

    final response = await _repository.fetchPosts(communityId);

    if (response.success && response.data != null) {
      _currentFolderId = null;
      loadFilesAndFolders(id);
      final list = response.data as List;
      _posts = list
          .map((json) =>
              CommunityPostModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } else {
      _errorMessage = response.message;
    
  // --- Folders & Files Methods ---
  void enterFolder(int? folderId) {
    _currentFolderId = folderId;
    if (_activeCommunity != null) {
      loadFilesAndFolders(_activeCommunity!.id);
    }
  }

  Future<void> loadFilesAndFolders(int communityId) async {
    _isLoadingFiles = true;
    notifyListeners();

    if (_currentFolderId == null) {
      final resF = await _repository.fetchFolders(communityId);
      if (resF.success && resF.data != null) {
        _folders = (resF.data as List).map((e) => CommunityFolderModel.fromJson(e)).toList();
      }
    } else {
      _folders = []; // No nested folders natively supported in this iteration
    }

    final resFiles = await _repository.fetchFiles(communityId, folderId: _currentFolderId);
    if (resFiles.success && resFiles.data != null) {
      _files = (resFiles.data as List).map((e) => CommunityFileModel.fromJson(e)).toList();
    }

    _isLoadingFiles = false;
    notifyListeners();
  }

  Future<bool> createFolder(int communityId, String name) async {
    final res = await _repository.createFolder(communityId, name);
    if (res.success) {
      loadFilesAndFolders(communityId);
      return true;
    }
    _errorMessage = res.message;
    notifyListeners();
    return false;
  }

  Future<bool> deleteFolder(int communityId, int folderId) async {
    final res = await _repository.deleteFolder(communityId, folderId);
    if (res.success) {
      loadFilesAndFolders(communityId);
      return true;
    }
    _errorMessage = res.message;
    notifyListeners();
    return false;
  }

  Future<bool> uploadCommunityFile(int communityId, String path) async {
    _isLoadingFiles = true;
    notifyListeners();
    final res = await _repository.uploadFile(communityId, path, folderId: _currentFolderId);
    if (res.success) {
      loadFilesAndFolders(communityId);
      return true;
    }
    _isLoadingFiles = false;
    _errorMessage = res.message;
    notifyListeners();
    return false;
  }

  Future<bool> deleteFile(int communityId, int fileId) async {
    final res = await _repository.deleteFile(communityId, fileId);
    if (res.success) {
      loadFilesAndFolders(communityId);
      return true;
    }
    _errorMessage = res.message;
    notifyListeners();
    return false;
  }
}

    _isLoadingPosts = false;
    notifyListeners();
  
  // --- Folders & Files Methods ---
  void enterFolder(int? folderId) {
    _currentFolderId = folderId;
    if (_activeCommunity != null) {
      loadFilesAndFolders(_activeCommunity!.id);
    }
  }

  Future<void> loadFilesAndFolders(int communityId) async {
    _isLoadingFiles = true;
    notifyListeners();

    if (_currentFolderId == null) {
      final resF = await _repository.fetchFolders(communityId);
      if (resF.success && resF.data != null) {
        _folders = (resF.data as List).map((e) => CommunityFolderModel.fromJson(e)).toList();
      }
    } else {
      _folders = []; // No nested folders natively supported in this iteration
    }

    final resFiles = await _repository.fetchFiles(communityId, folderId: _currentFolderId);
    if (resFiles.success && resFiles.data != null) {
      _files = (resFiles.data as List).map((e) => CommunityFileModel.fromJson(e)).toList();
    }

    _isLoadingFiles = false;
    notifyListeners();
  }

  Future<bool> createFolder(int communityId, String name) async {
    final res = await _repository.createFolder(communityId, name);
    if (res.success) {
      loadFilesAndFolders(communityId);
      return true;
    }
    _errorMessage = res.message;
    notifyListeners();
    return false;
  }

  Future<bool> deleteFolder(int communityId, int folderId) async {
    final res = await _repository.deleteFolder(communityId, folderId);
    if (res.success) {
      loadFilesAndFolders(communityId);
      return true;
    }
    _errorMessage = res.message;
    notifyListeners();
    return false;
  }

  Future<bool> uploadCommunityFile(int communityId, String path) async {
    _isLoadingFiles = true;
    notifyListeners();
    final res = await _repository.uploadFile(communityId, path, folderId: _currentFolderId);
    if (res.success) {
      loadFilesAndFolders(communityId);
      return true;
    }
    _isLoadingFiles = false;
    _errorMessage = res.message;
    notifyListeners();
    return false;
  }

  Future<bool> deleteFile(int communityId, int fileId) async {
    final res = await _repository.deleteFile(communityId, fileId);
    if (res.success) {
      loadFilesAndFolders(communityId);
      return true;
    }
    _errorMessage = res.message;
    notifyListeners();
    return false;
  }
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
    
  // --- Folders & Files Methods ---
  void enterFolder(int? folderId) {
    _currentFolderId = folderId;
    if (_activeCommunity != null) {
      loadFilesAndFolders(_activeCommunity!.id);
    }
  }

  Future<void> loadFilesAndFolders(int communityId) async {
    _isLoadingFiles = true;
    notifyListeners();

    if (_currentFolderId == null) {
      final resF = await _repository.fetchFolders(communityId);
      if (resF.success && resF.data != null) {
        _folders = (resF.data as List).map((e) => CommunityFolderModel.fromJson(e)).toList();
      }
    } else {
      _folders = []; // No nested folders natively supported in this iteration
    }

    final resFiles = await _repository.fetchFiles(communityId, folderId: _currentFolderId);
    if (resFiles.success && resFiles.data != null) {
      _files = (resFiles.data as List).map((e) => CommunityFileModel.fromJson(e)).toList();
    }

    _isLoadingFiles = false;
    notifyListeners();
  }

  Future<bool> createFolder(int communityId, String name) async {
    final res = await _repository.createFolder(communityId, name);
    if (res.success) {
      loadFilesAndFolders(communityId);
      return true;
    }
    _errorMessage = res.message;
    notifyListeners();
    return false;
  }

  Future<bool> deleteFolder(int communityId, int folderId) async {
    final res = await _repository.deleteFolder(communityId, folderId);
    if (res.success) {
      loadFilesAndFolders(communityId);
      return true;
    }
    _errorMessage = res.message;
    notifyListeners();
    return false;
  }

  Future<bool> uploadCommunityFile(int communityId, String path) async {
    _isLoadingFiles = true;
    notifyListeners();
    final res = await _repository.uploadFile(communityId, path, folderId: _currentFolderId);
    if (res.success) {
      loadFilesAndFolders(communityId);
      return true;
    }
    _isLoadingFiles = false;
    _errorMessage = res.message;
    notifyListeners();
    return false;
  }

  Future<bool> deleteFile(int communityId, int fileId) async {
    final res = await _repository.deleteFile(communityId, fileId);
    if (res.success) {
      loadFilesAndFolders(communityId);
      return true;
    }
    _errorMessage = res.message;
    notifyListeners();
    return false;
  }
}
  
  // --- Folders & Files Methods ---
  void enterFolder(int? folderId) {
    _currentFolderId = folderId;
    if (_activeCommunity != null) {
      loadFilesAndFolders(_activeCommunity!.id);
    }
  }

  Future<void> loadFilesAndFolders(int communityId) async {
    _isLoadingFiles = true;
    notifyListeners();

    if (_currentFolderId == null) {
      final resF = await _repository.fetchFolders(communityId);
      if (resF.success && resF.data != null) {
        _folders = (resF.data as List).map((e) => CommunityFolderModel.fromJson(e)).toList();
      }
    } else {
      _folders = []; // No nested folders natively supported in this iteration
    }

    final resFiles = await _repository.fetchFiles(communityId, folderId: _currentFolderId);
    if (resFiles.success && resFiles.data != null) {
      _files = (resFiles.data as List).map((e) => CommunityFileModel.fromJson(e)).toList();
    }

    _isLoadingFiles = false;
    notifyListeners();
  }

  Future<bool> createFolder(int communityId, String name) async {
    final res = await _repository.createFolder(communityId, name);
    if (res.success) {
      loadFilesAndFolders(communityId);
      return true;
    }
    _errorMessage = res.message;
    notifyListeners();
    return false;
  }

  Future<bool> deleteFolder(int communityId, int folderId) async {
    final res = await _repository.deleteFolder(communityId, folderId);
    if (res.success) {
      loadFilesAndFolders(communityId);
      return true;
    }
    _errorMessage = res.message;
    notifyListeners();
    return false;
  }

  Future<bool> uploadCommunityFile(int communityId, String path) async {
    _isLoadingFiles = true;
    notifyListeners();
    final res = await _repository.uploadFile(communityId, path, folderId: _currentFolderId);
    if (res.success) {
      loadFilesAndFolders(communityId);
      return true;
    }
    _isLoadingFiles = false;
    _errorMessage = res.message;
    notifyListeners();
    return false;
  }

  Future<bool> deleteFile(int communityId, int fileId) async {
    final res = await _repository.deleteFile(communityId, fileId);
    if (res.success) {
      loadFilesAndFolders(communityId);
      return true;
    }
    _errorMessage = res.message;
    notifyListeners();
    return false;
  }
}

  // --- Folders & Files Methods ---
  void enterFolder(int? folderId) {
    _currentFolderId = folderId;
    if (_activeCommunity != null) {
      loadFilesAndFolders(_activeCommunity!.id);
    }
  }

  Future<void> loadFilesAndFolders(int communityId) async {
    _isLoadingFiles = true;
    notifyListeners();

    if (_currentFolderId == null) {
      final resF = await _repository.fetchFolders(communityId);
      if (resF.success && resF.data != null) {
        _folders = (resF.data as List).map((e) => CommunityFolderModel.fromJson(e)).toList();
      }
    } else {
      _folders = []; // No nested folders natively supported in this iteration
    }

    final resFiles = await _repository.fetchFiles(communityId, folderId: _currentFolderId);
    if (resFiles.success && resFiles.data != null) {
      _files = (resFiles.data as List).map((e) => CommunityFileModel.fromJson(e)).toList();
    }

    _isLoadingFiles = false;
    notifyListeners();
  }

  Future<bool> createFolder(int communityId, String name) async {
    final res = await _repository.createFolder(communityId, name);
    if (res.success) {
      loadFilesAndFolders(communityId);
      return true;
    }
    _errorMessage = res.message;
    notifyListeners();
    return false;
  }

  Future<bool> deleteFolder(int communityId, int folderId) async {
    final res = await _repository.deleteFolder(communityId, folderId);
    if (res.success) {
      loadFilesAndFolders(communityId);
      return true;
    }
    _errorMessage = res.message;
    notifyListeners();
    return false;
  }

  Future<bool> uploadCommunityFile(int communityId, String path) async {
    _isLoadingFiles = true;
    notifyListeners();
    final res = await _repository.uploadFile(communityId, path, folderId: _currentFolderId);
    if (res.success) {
      loadFilesAndFolders(communityId);
      return true;
    }
    _isLoadingFiles = false;
    _errorMessage = res.message;
    notifyListeners();
    return false;
  }

  Future<bool> deleteFile(int communityId, int fileId) async {
    final res = await _repository.deleteFile(communityId, fileId);
    if (res.success) {
      loadFilesAndFolders(communityId);
      return true;
    }
    _errorMessage = res.message;
    notifyListeners();
    return false;
  }
}
