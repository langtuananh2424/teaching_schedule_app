class Student {
  final int studentId;
  final String studentCode;
  final String fullName;
  final int classId;
  final String? className;

  Student({
    required this.studentId,
    required this.studentCode,
    required this.fullName,
    required this.classId,
    this.className,
  });

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      studentId: json['studentId'] ?? json['student_id'] ?? 0,
      studentCode: json['studentCode'] ?? json['student_code'] ?? '',
      fullName: json['fullName'] ?? json['full_name'] ?? 'N/A',
      classId: json['classId'] ?? json['class_id'] ?? 0,
      className: json['className'] ?? json['class_name'],
    );
  }
}