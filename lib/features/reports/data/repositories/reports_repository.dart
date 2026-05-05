import 'package:dio/dio.dart';
import 'package:uni_social_student/core/network/network_client.dart';

class ReportsRepository {
  final Dio _dio;

  ReportsRepository({Dio? dio}) : _dio = dio ?? NetworkClient.instance;

  Future<void> createReport({
    required String targetId,
    required String targetType,
    required int targetItemId,
    required String subject,
    required String description,
    String? evidenceImagePath,
  }) async {
    final formData = FormData.fromMap({
      'targetId': targetId,
      'targetType': targetType,
      'targetItemId': targetItemId,
      'subject': subject,
      'description': description,
    });

    if (evidenceImagePath != null) {
      formData.files.add(MapEntry(
        'evidenceImage',
        await MultipartFile.fromFile(evidenceImagePath),
      ));
    }

    final response = await _dio.post('/reports', data: formData);

    if (response.statusCode != 201) {
      throw Exception('Error al enviar el reporte');
    }
  }

  Future<List<dynamic>> getReports() async {
    final response = await _dio.get('/reports');
    if (response.statusCode == 200) {
      return response.data['data'] ?? []; // Fallback to empty list just in case
    }
    throw Exception('Failed to load reports');
  }

  Future<void> handleAction(int reportId, String action) async {
    final response = await _dio.put('/reports/$reportId/action', data: {'action': action});
    if (response.statusCode != 200) {
      throw Exception('Failed to handle action');
    }
  }
}
