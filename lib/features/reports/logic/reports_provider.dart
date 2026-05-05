import 'package:flutter/material.dart';
import '../data/repositories/reports_repository.dart';

class ReportsProvider with ChangeNotifier {
  final _repository = ReportsRepository();

  bool _isSubmitting = false;
  bool get isSubmitting => _isSubmitting;

  Future<void> createReport({
    required String targetId,
    required String targetType,
    required int targetItemId,
    required String subject,
    required String description,
    String? evidenceImagePath,
  }) async {
    _isSubmitting = true;
    notifyListeners();
    try {
      await _repository.createReport(
        targetId: targetId,
        targetType: targetType,
        targetItemId: targetItemId,
        subject: subject,
        description: description,
        evidenceImagePath: evidenceImagePath,
      );
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }
}
