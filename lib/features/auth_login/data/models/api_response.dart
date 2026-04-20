/// Generic API response wrapper.
class ApiResponse {
  final bool success;
  final String message;
  final dynamic data;
  final List<Map<String, dynamic>>? errors;

  ApiResponse({
    required this.success,
    required this.message,
    this.data,
    this.errors,
  });

  factory ApiResponse.fromJson(Map<String, dynamic> json) {
    return ApiResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'],
      errors: json['errors'] != null
          ? List<Map<String, dynamic>>.from(json['errors'])
          : null,
    );
  }
}
