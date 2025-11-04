
class Student {
  final int id;
  final String studentCode;
  final String fullName;
  final int classId;

  Student({required this.id, required this.studentCode, required this.fullName, required this.classId});

  factory Student.fromJson(Map<String, dynamic> json) => Student(
    id: json['id'] as int,
    studentCode: json['studentCode'] as String? ?? '',
    fullName: json['fullName'] as String? ?? '',
    classId: json['classId'] as int? ?? 0,
  );
}
