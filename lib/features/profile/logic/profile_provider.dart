/// State management for profile screen.
import 'package:flutter/material.dart';
import 'package:uni_social_student/features/profile/data/repositories/profile_repository.dart';

class ProfileProvider extends ChangeNotifier {
  final ProfileRepository _repository;

  ProfileProvider({ProfileRepository? repository})
      : _repository = repository ?? ProfileRepository();

  bool _isLoading = false;
  String _errorMessage = '';
  Map<String, dynamic>? _profile;
  bool _isUpdatingPhoto = false;

  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  Map<String, dynamic>? get profile => _profile;
  bool get isUpdatingPhoto => _isUpdatingPhoto;

  String get fullName {
    if (_profile == null) return '';
    return '${_profile!['first_name'] ?? ''} ${_profile!['last_name'] ?? ''}'.trim();
  }

  String get email => _profile?['email'] ?? '';
  String? get profilePhotoUrl => _profile?['profile_photo_path'];

  /// Carga el perfil del estudiante autenticado.
  Future<void> loadProfile() async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    final response = await _repository.getProfile();

    if (response.success && response.data != null) {
      _profile = Map<String, dynamic>.from(response.data);
    } else {
      _errorMessage = response.message;
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Actualiza la foto de perfil.
  Future<bool> updateProfilePhoto(String filePath) async {
    _isUpdatingPhoto = true;
    notifyListeners();

    final response = await _repository.updateProfilePhoto(filePath);

    if (response.success && response.data != null) {
      // Actualizar el profile con la nueva foto
      _profile = Map<String, dynamic>.from(response.data);
      _isUpdatingPhoto = false;
      notifyListeners();
      return true;
    } else {
      _errorMessage = response.message;
      _isUpdatingPhoto = false;
      notifyListeners();
      return false;
    }
  }
}
