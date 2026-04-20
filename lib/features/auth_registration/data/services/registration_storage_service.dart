/// SharedPreferences helper to persist registration form data locally.
///
/// Allows the student to reload their previous submission data
/// when re-submitting after a rejection.
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class RegistrationStorageService {
  static const _key = 'pending_registration_data';

  /// Save registration form data to local storage.
  static Future<void> saveRegistrationData({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final data = jsonEncode({
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'password': password,
      'savedAt': DateTime.now().toIso8601String(),
    });
    await prefs.setString(_key, data);
  }

  /// Load previously saved registration data.
  /// Returns null if no data is stored.
  static Future<Map<String, dynamic>?> loadRegistrationData() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return null;
    try {
      return jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  /// Check if there is saved registration data.
  static Future<bool> hasPendingRegistration() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_key);
  }

  /// Clear stored registration data.
  static Future<void> clearRegistrationData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
