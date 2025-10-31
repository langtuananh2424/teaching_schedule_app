// lib/models/session.dart

// Import lại các model lồng nhau
import 'package:frontend_app/models/assignment.dart';
import 'package:frontend_app/models/schedule_status.dart';
import 'package:frontend_app/models/subject.dart';
import 'package:frontend_app/models/class.dart';
import 'package:frontend_app/models/lecturer.dart';

class Session {
  final int sessionId;
  final DateTime sessionDate;
  final int startPeriod;
  final int endPeriod;
  final String classroom;
  final ScheduleStatus status;

  // === TRẢ LẠI TRƯỜNG 'assignment' ===
  final Assignment assignment;
  // ===================================

  String get statusText {
    switch (status) {
      case ScheduleStatus.NOT_TAUGHT:
        return 'Sắp diễn ra';
      case ScheduleStatus.ABSENT_APPROVED:
      case ScheduleStatus.ABSENT_UNAPPROVED:
        return 'Nghỉ';
      case ScheduleStatus.TAUGHT:
        return 'Hoàn thành';
      case ScheduleStatus.MAKEUP_TAUGHT:
        return 'Đã dạy bù';
      default:
        return 'Không rõ';
    }
  }

  Session({
    required this.sessionId,
    required this.sessionDate,
    required this.startPeriod,
    required this.endPeriod,
    required this.classroom,
    required this.status,
    required this.assignment, // <-- Thêm lại vào constructor
  });

  // === FACTORY ĐÃ ĐƯỢC CẬP NHẬT ===
  // Nó sẽ đọc JSON "phẳng" và "tái cấu trúc" (re-nest) lại
  // ===================================
  factory Session.fromJson(Map<String, dynamic> json) {

    // 1. Tạo các đối tượng con "giả" từ dữ liệu phẳng
    final subject = Subject(
        subjectId: 0, // API không cung cấp, dùng 0
        subjectName: json['subjectName'] ?? 'N/A'
    );

    final studentClass = StudentClass(
        id: 0, // API không cung cấp, dùng 0
        className: json['className'] ?? 'N/A'
    );

    final lecturer = Lecturer(
        lecturerId: 0, // API không cung cấp, dùng 0
        fullName: json['lecturerName'] ?? 'N/A',
        email: '' // API không cung cấp
    );

    // 2. Tạo đối tượng Assignment "giả"
    final assignment = Assignment(
        assignmentId: json['assignmentId'] ?? 0,
        lecturer: lecturer,
        subject: subject,
        studentClass: studentClass
    );

    // 3. Trả về Session với đối tượng assignment đã được "tái cấu trúc"
    return Session(
      sessionId: json['sessionId'] ?? 0,
      sessionDate: DateTime.tryParse(json['sessionDate'] ?? '') ?? DateTime.now(),
      startPeriod: json['startPeriod'] ?? 0,
      endPeriod: json['endPeriod'] ?? 0,
      classroom: json['classroom'] ?? 'N/A',
      status: scheduleStatusFromString(json['status'] ?? ''),
      assignment: assignment, // <-- Gán đối tượng vừa tạo
    );
  }
}