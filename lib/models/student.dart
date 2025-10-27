import 'package:frontend_app/models/attendance.dart';

// Model cho Sinh viên (Đã tách từ file cũ)
class Student {
  final String name;
  final String studentId;
  AttendanceStatus attendanceStatus; // Trạng thái điểm danh hiện tại

  Student({
    required this.name,
    required this.studentId,
    this.attendanceStatus = AttendanceStatus.present,
  });
}
