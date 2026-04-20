/// State management for moderator applications.
import 'package:flutter/material.dart';
import 'package:uni_social_student/features/moderator/data/repositories/moderator_repository.dart';

class ModeratorProvider extends ChangeNotifier {
  final ModeratorRepository _repository;

  ModeratorProvider({ModeratorRepository? repository})
      : _repository = repository ?? ModeratorRepository();

  bool _isSubmitting = false;
  String _errorMessage = '';

  bool get isSubmitting => _isSubmitting;
  String get errorMessage => _errorMessage;

  /// Submit a moderator application.
  Future<bool> submitApplication(String arguments) async {
    _isSubmitting = true;
    _errorMessage = '';
    notifyListeners();

    final response = await _repository.apply(arguments);

    _isSubmitting = false;
    if (response.success) {
      notifyListeners();
      return true;
    } else {
      _errorMessage = response.message;
      notifyListeners();
      return false;
    }
  }
}
