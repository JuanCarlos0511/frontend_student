/// Student model for registration responses.
class StudentModel {
  final int id;
  final String firstName;
  final String lastName;
  final String email;
  final String status;
  final String? voucherPath;
  final String? createdAt;

  StudentModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.status,
    this.voucherPath,
    this.createdAt,
  });

  factory StudentModel.fromJson(Map<String, dynamic> json) {
    return StudentModel(
      id: json['id'] ?? 0,
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      email: json['email'] ?? '',
      status: json['status'] ?? 'pending',
      voucherPath: json['voucher_path'],
      createdAt: json['created_at'],
    );
  }

  String get fullName => '$firstName $lastName';
}
