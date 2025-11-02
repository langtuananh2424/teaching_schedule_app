// lib/models/makeup_session.dart

class MakeupSession {
  final int id;
  final int absenceRequestId;
  final DateTime makeupDate;
  final int startPeriod;
  final int endPeriod;
  final String classroom;
  final String status;
  final DateTime createdAt;

  // Thông tin hiển thị
  final String lecturerName;
  final String subjectName;
  final String className;

  MakeupSession({
    required this.id,
    required this.absenceRequestId,
    required this.makeupDate,
    required this.startPeriod,
    required this.endPeriod,
    required this.classroom,
    required this.status,
    required this.createdAt,
    required this.lecturerName,
    required this.subjectName,
    required this.className,
  });

  factory MakeupSession.fromJson(Map<String, dynamic> json) {
    return MakeupSession(
      id: json['id'],
      absenceRequestId: json['absenceRequestId'],
      makeupDate: DateTime.parse(json['makeupDate']),
      startPeriod: json['startPeriod'],
      endPeriod: json['endPeriod'],
      classroom: json['classroom'],
      status: json['status'],
      createdAt: DateTime.parse(json['createdAt']),
      lecturerName: json['lecturerName'] ?? 'Chưa có tên',
      subjectName: json['subjectName'] ?? 'Chưa có môn học',
      className: json['className'] ?? 'Chưa có lớp',
    );
  }
}
