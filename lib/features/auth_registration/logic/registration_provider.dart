/// State management for student registration.
///
/// Tracks form state, upload progress, API result, and previous registration data.
import 'package:flutter/material.dart';
import 'package:uni_social_student/features/auth_registration/data/repositories/registration_repository.dart';
import 'package:uni_social_student/features/auth_registration/data/repositories/registration_status_repository.dart';
import 'package:uni_social_student/features/auth_registration/data/services/registration_storage_service.dart';

enum RegistrationStatus { idle, uploading, success, error }

class RegistrationProvider extends ChangeNotifier {
  final RegistrationRepository _repository;
  final RegistrationStatusRepository _statusRepository;

  RegistrationProvider({
    RegistrationRepository? repository,
    RegistrationStatusRepository? statusRepository,
  })  : _repository = repository ?? RegistrationRepository(),
        _statusRepository = statusRepository ?? RegistrationStatusRepository();

  RegistrationStatus _status = RegistrationStatus.idle;
  String _message = '';
  double _uploadProgress = 0;

  // Previous registration state
  Map<String, dynamic>? _previousData;
  String? _rejectionReason;
  String? _previousStatus; // 'pending', 'rejected', 'approved', 'not_found'

  RegistrationStatus get status => _status;
  String get message => _message;
  double get uploadProgress => _uploadProgress;
  bool get isLoading => _status == RegistrationStatus.uploading;

  Map<String, dynamic>? get previousData => _previousData;
  String? get rejectionReason => _rejectionReason;
  String? get previousStatus => _previousStatus;
  bool get hasPreviousRejection => _previousStatus == 'rejected';
  bool get hasPendingRequest => _previousStatus == 'pending';

  void reset() {
    _status = RegistrationStatus.idle;
    _message = '';
    _uploadProgress = 0;
    notifyListeners();
  }

  /// Check if there's a previous registration attempt stored locally.
  /// If so, check its status via the API.
  Future<void> checkPreviousRegistration() async {
    _previousData = await RegistrationStorageService.loadRegistrationData();
    if (_previousData == null) {
      _previousStatus = null;
      _rejectionReason = null;
      notifyListeners();
      return;
    }

    final email = _previousData!['email'] as String?;
    if (email == null || email.isEmpty) {
      _previousStatus = null;
      _rejectionReason = null;
      notifyListeners();
      return;
    }

    final result = await _statusRepository.checkStatus(email);
    _previousStatus = result.status;
    _rejectionReason = result.rejectionReason;
    notifyListeners();
  }

  /// Clear previous registration data from local storage and state.
  Future<void> clearPreviousData() async {
    await RegistrationStorageService.clearRegistrationData();
    _previousData = null;
    _previousStatus = null;
    _rejectionReason = null;
    notifyListeners();
  }

  /// Submit the multi-step registration form.
  Future<bool> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    String? profilePhotoPath,
    String? voucherPath,
  }) async {
    _status = RegistrationStatus.uploading;
    _message = '';
    _uploadProgress = 0;
    notifyListeners();

    final response = await _repository.register(
      firstName: firstName,
      lastName: lastName,
      email: email,
      password: password,
      profilePhotoPath: profilePhotoPath,
      voucherPath: voucherPath,
      onSendProgress: (sent, total) {
        if (total > 0) {
          _uploadProgress = sent / total;
          notifyListeners();
        }
      },
    );

    if (response.success) {
      _status = RegistrationStatus.success;
      _message = response.message;

      // Save registration data to local storage for potential re-use
      await RegistrationStorageService.saveRegistrationData(
        firstName: firstName,
        lastName: lastName,
        email: email,
        password: password,
      );
    } else {
      _status = RegistrationStatus.error;
      _message = response.message;
    }
    notifyListeners();
    return response.success;
  }
}
