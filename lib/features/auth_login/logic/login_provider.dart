/// State management for login with token persistence.
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uni_social_student/features/auth_login/data/repositories/login_repository.dart';

enum AuthStatus { idle, loading, success, error }

class LoginProvider extends ChangeNotifier {
  final LoginRepository _repository;

  LoginProvider({LoginRepository? repository})
      : _repository = repository ?? LoginRepository();

  AuthStatus _status = AuthStatus.idle;
  String _message = '';
  String? _token;
  int? _studentId;
  String? _studentName;
  String? _role;

  AuthStatus get status => _status;
  String get message => _message;
  String? get token => _token;
  int? get studentId => _studentId;
  String? get studentName => _studentName;
  String? get role => _role;
  bool get isModerator => _role == 'moderador';
  bool get isLoading => _status == AuthStatus.loading;
  bool get isAuthenticated => _token != null && _token!.isNotEmpty;

  /// Intenta restaurar la sesión desde SharedPreferences.
  Future<bool> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final savedToken = prefs.getString('auth_token');
    if (savedToken != null && savedToken.isNotEmpty) {
      _token = savedToken;
      _studentId = prefs.getInt('student_id');
      _studentName = prefs.getString('student_name');
      _role = prefs.getString('student_role');
      _status = AuthStatus.success;
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _status = AuthStatus.loading;
    _message = '';
    notifyListeners();

    final response = await _repository.login(email: email, password: password);

    if (response.success) {
      _status = AuthStatus.success;
      _message = response.message;
      _token = response.data?['token'];

      // Extraer datos del estudiante
      final studentData = response.data?['student'];
      if (studentData != null) {
        _studentId = studentData['id'];
        _studentName =
            '${studentData['firstName']} ${studentData['lastName']}';
        _role = studentData['role'];
      }

      // Persistir en SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      if (_token != null) await prefs.setString('auth_token', _token!);
      if (_studentId != null) await prefs.setInt('student_id', _studentId!);
      if (_studentName != null) {
        await prefs.setString('student_name', _studentName!);
      }
      if (_role != null) {
        await prefs.setString('student_role', _role!);
      }
    } else {
      _status = AuthStatus.error;
      _message = response.message;
    }
    notifyListeners();
    return response.success;
  }

  /// Cierra la sesión y limpia los datos persistidos.
  Future<void> logout() async {
    _status = AuthStatus.idle;
    _message = '';
    _token = null;
    _studentId = null;
    _studentName = null;
    _role = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('student_id');
    await prefs.remove('student_name');
    await prefs.remove('student_role');

    notifyListeners();
  }

  void reset() {
    _status = AuthStatus.idle;
    _message = '';
    notifyListeners();
  }
}
