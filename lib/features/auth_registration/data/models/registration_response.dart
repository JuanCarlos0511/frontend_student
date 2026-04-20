/// Registration API response wrapper.
class RegistrationResponse {
  final bool success;
  final String message;
  final dynamic data;
  final List<Map<String, dynamic>>? errors;

  RegistrationResponse({
    required this.success,
    required this.message,
    this.data,
    this.errors,
  });

  factory RegistrationResponse.fromJson(Map<String, dynamic> json) {
    return RegistrationResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'],
      errors: json['errors'] != null
          ? List<Map<String, dynamic>>.from(json['errors'])
          : null,
    );
  }
}
