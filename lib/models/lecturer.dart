class Lecturer {
  // Dựa trên bảng Lecturers [cite: 194]
  final int lecturerId;
  final String fullName;
  final String email;
  final String role;

  Lecturer({
    required this.lecturerId,
    required this.fullName,
    required this.email,
    required this.role,
  });
  factory Lecturer.fromJson(Map<String, dynamic> json) {
    return Lecturer(
      lecturerId: json['lecturer_id'] ?? 0, // Dữ liệu từ API
      fullName: json['full_name'] ?? 'Không có tên',
      email: json['email'] ?? '',
      role: json['role'] ?? 'lecturer',
    );
  }
}
