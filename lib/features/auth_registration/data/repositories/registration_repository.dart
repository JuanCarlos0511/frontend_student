/// Data source for registration API calls using Dio.
///
/// Sends a multipart/form-data POST with text fields, profile photo and PDF voucher.
import 'package:dio/dio.dart';
import 'package:uni_social_student/core/network/api_constants.dart';
import 'package:uni_social_student/core/network/network_client.dart';
import 'package:uni_social_student/features/auth_registration/data/models/registration_response.dart';

class RegistrationRepository {
  final Dio _dio;

  RegistrationRepository({Dio? dio}) : _dio = dio ?? NetworkClient.instance;

  /// Register a new student.
  ///
  /// [profilePhotoPath] is the local file path to the profile image.
  /// [voucherPath] is the local file path to the PDF selected by the user.
  /// Returns a [RegistrationResponse] with success/failure info.
  /// The [onSendProgress] callback can be used to show upload progress.
  Future<RegistrationResponse> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    String? profilePhotoPath,
    String? voucherPath,
    void Function(int sent, int total)? onSendProgress,
  }) async {
    try {
      final formData = FormData.fromMap({
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'password': password,
        if (profilePhotoPath != null && profilePhotoPath.isNotEmpty)
          'profilePhoto': await MultipartFile.fromFile(profilePhotoPath),
        if (voucherPath != null && voucherPath.isNotEmpty)
          'voucher': await MultipartFile.fromFile(
            voucherPath,
            filename: 'voucher.pdf',
            contentType: DioMediaType('application', 'pdf'),
          ),
      });

      final response = await _dio.post(
        ApiConstants.register,
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
        onSendProgress: onSendProgress,
      );

      return RegistrationResponse.fromJson(
          response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.response != null && e.response!.data is Map) {
        return RegistrationResponse.fromJson(
            e.response!.data as Map<String, dynamic>);
      }
      return RegistrationResponse(
        success: false,
        message: 'No se pudo conectar al servidor. Verifica tu conexión.',
      );
    } catch (e) {
      return RegistrationResponse(
        success: false,
        message: 'Error inesperado: $e',
      );
    }
  }
}

