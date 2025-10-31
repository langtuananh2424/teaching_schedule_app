import 'package:frontend_app/models/lecturer.dart';
import 'package:frontend_app/models/class.dart'; // Đổi tên file sẽ tốt hơn
import 'package:frontend_app/models/subject.dart';

class Assignment {
  final int assignmentId;
  final Lecturer lecturer;
  final Subject subject;
  final StudentClass studentClass;

  Assignment({
    required this.assignmentId,
    required this.lecturer,
    required this.subject,
    required this.studentClass,
  });

  factory Assignment.fromJson(Map<String, dynamic> json) {
    return Assignment(
      assignmentId: json['assignmentId'] ?? 0,
      lecturer: Lecturer.fromJson(json['lecturer'] ?? {}),
      subject: Subject.fromJson(json['subject'] ?? {}),
      studentClass: StudentClass.fromJson(json['studentClass'] ?? {}),
    );
  }
}