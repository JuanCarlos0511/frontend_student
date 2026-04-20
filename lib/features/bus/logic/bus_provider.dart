/// State management for bus map — collaborative bus tracking.
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uni_social_student/features/bus/data/repositories/bus_repository.dart';

class BusReport {
  final int id;
  final int studentId;
  final double latitude;
  final double longitude;
  final String icon;
  final String? firstName;
  final String? lastName;
  final DateTime createdAt;

  BusReport({
    required this.id,
    required this.studentId,
    required this.latitude,
    required this.longitude,
    required this.icon,
    this.firstName,
    this.lastName,
    required this.createdAt,
  });

  factory BusReport.fromJson(Map<String, dynamic> json) {
    return BusReport(
      id: json['id'] ?? 0,
      studentId: json['student_id'] ?? 0,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      icon: json['icon'] ?? 'bus_red',
      firstName: json['first_name'],
      lastName: json['last_name'],
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
    );
  }

  String get reporterName => '${firstName ?? ''} ${lastName ?? ''}'.trim();

  /// Remaining seconds before auto-expiry (10 min = 600s).
  int get remainingSeconds {
    final elapsed = DateTime.now().difference(createdAt).inSeconds;
    return (600 - elapsed).clamp(0, 600);
  }
}

class BusProvider extends ChangeNotifier {
  final BusRepository _repository;

  BusProvider({BusRepository? repository})
      : _repository = repository ?? BusRepository();

  List<BusReport> _reports = [];
  bool _isLoading = false;
  bool _isReporting = false;
  bool _hasActiveReport = false;
  String _errorMessage = '';
  Timer? _refreshTimer;
  int? _currentStudentId;

  List<BusReport> get reports => _reports;
  bool get isLoading => _isLoading;
  bool get isReporting => _isReporting;
  bool get hasActiveReport => _hasActiveReport;
  String get errorMessage => _errorMessage;

  /// Initialize — load student ID and start polling.
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _currentStudentId = prefs.getInt('student_id');
    await loadReports();
    _startPolling();
  }

  void _startPolling() {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(const Duration(seconds: 15), (_) {
      loadReports();
    });
  }

  /// Loads active reports and checks if user has an active one.
  Future<void> loadReports() async {
    final response = await _repository.getActiveReports();

    if (response.success && response.data != null) {
      final list = response.data as List;
      _reports = list
          .map((json) => BusReport.fromJson(json as Map<String, dynamic>))
          .toList();

      // Check if current user has an active report
      _hasActiveReport =
          _reports.any((r) => r.studentId == _currentStudentId);
      _errorMessage = '';
    } else {
      _errorMessage = response.message;
    }

    notifyListeners();
  }

  /// Reports bus arrival at given coordinates.
  Future<bool> reportBus(double latitude, double longitude) async {
    _isReporting = true;
    notifyListeners();

    final response = await _repository.reportBus(latitude, longitude);
    _isReporting = false;

    if (response.success) {
      await loadReports();
      return true;
    } else {
      _errorMessage = response.message;
      notifyListeners();
      return false;
    }
  }

  /// Cancels the user's active report.
  Future<bool> cancelReport() async {
    _isReporting = true;
    notifyListeners();

    final response = await _repository.cancelReport();
    _isReporting = false;

    if (response.success) {
      await loadReports();
      return true;
    } else {
      _errorMessage = response.message;
      notifyListeners();
      return false;
    }
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }
}
