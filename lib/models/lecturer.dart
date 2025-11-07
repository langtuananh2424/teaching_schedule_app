class Lecturer {
  final int id;
  final String? lecturerCode;
  final String fullName;
  final String email;
  final String departmentName;
  final int departmentId;
  final String role;

  Lecturer({
    required this.id,
    this.lecturerCode,
    required this.fullName,
    required this.email,
    required this.departmentName,
    required this.departmentId,
    required this.role,
  });

  factory Lecturer.fromJson(Map<String, dynamic> json) {
    return Lecturer(
      id: json['lecturerId'] as int, // API trả về lecturerId không phải id
      lecturerCode: json['lecturerCode'] as String?,
      fullName: json['fullName'] as String,
      email: json['email'] as String,
      departmentName: json['departmentName'] as String,
      departmentId: json['departmentId'] as int,
      role: json['role'] as String,
    );
  }

  Lecturer copyWith({
    String? lecturerCode,
    String? fullName,
    int? departmentId,
    String? departmentName,
    String? role,
  }) {
    return Lecturer(
      id: id,
      lecturerCode: lecturerCode ?? this.lecturerCode,
      fullName: fullName ?? this.fullName,
      email: email,
      departmentName: departmentName ?? this.departmentName,
      departmentId: departmentId ?? this.departmentId,
      role: role ?? this.role,
    );
  }
}
