// lib/models/student_class.dart

class StudentClass {
  final int? classId;
  final String classCode;
  final String className;
  final String semester;

  StudentClass({
    this.classId,
    required this.classCode,
    required this.className,
    required this.semester,
  });

  factory StudentClass.fromJson(Map<String, dynamic> json) {
    return StudentClass(
      classId: json['classId'] as int?,
      classCode: json['classCode'] as String,
      className: json['className'] as String,
      semester: json['semester'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'classCode': classCode,
      'className': className,
      'semester': semester,
    };
  }
}
