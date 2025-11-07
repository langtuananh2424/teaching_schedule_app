class Attendance {
  // Dựa trên bảng Attendance [cite: 232]
  final int attendanceId;
  final int sessionId;
  final int studentId;
  final bool isPresent;

  Attendance({
    required this.attendanceId,
    required this.sessionId,
    required this.studentId,
    required this.isPresent,
  });
}