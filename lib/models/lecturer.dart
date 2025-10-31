class Lecturer {
  final int lecturerId;
  final String fullName;
  final String email;

  Lecturer({required this.lecturerId, required this.fullName, required this.email});

  factory Lecturer.fromJson(Map<String, dynamic> json) {
    return Lecturer(
      lecturerId: json['lecturerId'] ?? 0,
      fullName: json['fullName'] ?? 'N/A',
      email: json['email'] ?? 'N/A',
    );
  }
}