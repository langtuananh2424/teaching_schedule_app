class Attendance {
  final int attendanceId;
  final int sessionId;
  final int studentId;
  final String studentCode;
  final String studentName;
  final String status; // PRESENT, ABSENT, LATE
  final String? notes;
  final DateTime? recordedAt;

  Attendance({
    required this.attendanceId,
    required this.sessionId,
    required this.studentId,
    required this.studentCode,
    required this.studentName,
    required this.status,
    this.notes,
    this.recordedAt,
  });

  factory Attendance.fromJson(Map<String, dynamic> json) {
    return Attendance(
      attendanceId: json['attendance_id'] ?? 0,
      sessionId: json['session_id'] ?? 0,
      studentId: json['student_id'] ?? 0,
      studentCode: json['student_code'] ?? '',
      studentName: json['student_name'] ?? 'N/A',
      status: json['status'] ?? 'ABSENT',
      notes: json['notes'],
      recordedAt: json['recorded_at'] != null
          ? DateTime.parse(json['recorded_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {'studentId': studentId, 'status': status, 'notes': notes};
  }
}
