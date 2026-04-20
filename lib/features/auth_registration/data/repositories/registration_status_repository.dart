/// Repository to check the status of a previous registration by email.
import 'package:dio/dio.dart';
import 'package:uni_social_student/core/network/api_constants.dart';
import 'package:uni_social_student/core/network/network_client.dart';

class RegistrationStatusResult {
  final String status; // 'pending', 'approved', 'rejected', 'not_found'
  final String? rejectionReason;

  const RegistrationStatusResult({
    required this.status,
    this.rejectionReason,
  });
}

class RegistrationStatusRepository {
  final Dio _dio;

  RegistrationStatusRepository({Dio? dio})
      : _dio = dio ?? NetworkClient.instance;

  /// Check the registration status for the given email.
  Future<RegistrationStatusResult> checkStatus(String email) async {
    try {
      final response = await _dio.get(
        ApiConstants.registrationStatus,
        queryParameters: {'email': email},
      );

      final data = response.data as Map<String, dynamic>;
      if (data['success'] == true && data['data'] != null) {
        final result = data['data'] as Map<String, dynamic>;
        return RegistrationStatusResult(
          status: result['status'] as String? ?? 'not_found',
          rejectionReason: result['rejectionReason'] as String?,
        );
      }

      return const RegistrationStatusResult(status: 'not_found');
    } on DioException {
      return const RegistrationStatusResult(status: 'not_found');
    } catch (_) {
      return const RegistrationStatusResult(status: 'not_found');
    }
  }
}
