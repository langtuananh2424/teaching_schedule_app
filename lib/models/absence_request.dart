// lib/models/absence_request.dart

class AbsenceRequest {
  final int id;
  final String requestType;
  final String reason;
  final DateTime createdAt;
  final String status;
  final String? approverName;

  // Thông tin buổi học gốc
  final int? lecturerId;
  final String lecturerName;
  final int? sessionId;
  final String subjectName;
  final String className;
  final DateTime sessionDate;
  final int? startPeriod;
  final int? endPeriod;
  final String? classroom;

  // Thông tin dạy bù (nếu có)
  final int? makeupId;
  final DateTime? makeupCreatedAt;
  final DateTime? makeupDate;
  final int? makeupStartPeriod;
  final int? makeupEndPeriod;
  final String? makeupClassroom;
  final String? makeupStatus;

  AbsenceRequest({
    required this.id,
    required this.requestType,
    required this.reason,
    required this.createdAt,
    required this.status,
    this.approverName,
    this.lecturerId,
    required this.lecturerName,
    this.sessionId,
    required this.subjectName,
    required this.className,
    required this.sessionDate,
    this.startPeriod,
    this.endPeriod,
    this.classroom,
    this.makeupId,
    this.makeupCreatedAt,
    this.makeupDate,
    this.makeupStartPeriod,
    this.makeupEndPeriod,
    this.makeupClassroom,
    this.makeupStatus,
  });

  // The factory constructor is updated to handle the new property
  factory AbsenceRequest.fromJson(Map<String, dynamic> json) {
    return AbsenceRequest(
      id: json['id'],
      requestType: json['requestType'] ?? 'Xin nghỉ dạy',
      reason: json['reason'] ?? '',
      createdAt: DateTime.parse(json['createdAt']),
      status: json['status'],
      approverName: json['approverName'],
      lecturerId: json['lecturerId'],
      lecturerName: json['lecturerName'] ?? 'N/A',
      sessionId: json['sessionId'],
      subjectName: json['subjectName'] ?? 'N/A',
      className: json['className'] ?? 'N/A',
      sessionDate: DateTime.parse(json['sessionDate']),
      startPeriod: json['startPeriod'],
      endPeriod: json['endPeriod'],
      classroom: json['classroom'],
      makeupId: json['makeupId'],
      makeupCreatedAt: json['makeupCreatedAt'] != null
          ? DateTime.parse(json['makeupCreatedAt'])
          : null,
      makeupDate: json['makeupDate'] != null
          ? DateTime.parse(json['makeupDate'])
          : null,
      makeupStartPeriod: json['makeupStartPeriod'],
      makeupEndPeriod: json['makeupEndPeriod'],
      makeupClassroom: json['makeupClassroom'],
      makeupStatus: json['makeupStatus'],
    );
  }
}