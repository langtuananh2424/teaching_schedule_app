// lib/models/absence_request.dart

class AbsenceRequest {
  final int id;
  final String requestType;
  final String reason;
  final DateTime createdAt;

  // Backend mới có 2 status thay vì 1
  final String managerStatus;
  final String academicAffairsStatus;

  // Deprecated fields - giữ lại để backward compatible
  String get status => managerStatus; // Dùng managerStatus làm status chính
  final String? approverName; // Có thể không có trong response mới

  // Thông tin buổi học gốc
  final int? sessionId; // Có thể không có trong response mới
  final int? lecturerId; // Có thể không có trong response mới
  final String lecturerName;
  final String subjectName;
  final String className;
  final DateTime sessionDate;
  final int startPeriod;
  final int endPeriod;
  final String classroom;

  // Thông tin dạy bù (nếu có)
  final int? makeupId; // Có thể không có trong response mới
  final DateTime? makeupCreatedAt;
  final DateTime? makeupDate;
  final int? makeupStartPeriod;
  final int? makeupEndPeriod;
  final String? makeupClassroom;
  final String? makeupStatus; // Có thể không có trong response mới

  AbsenceRequest({
    required this.id,
    required this.requestType,
    required this.reason,
    required this.createdAt,
    required this.managerStatus,
    required this.academicAffairsStatus,
    this.approverName,
    this.sessionId,
    this.lecturerId,
    required this.lecturerName,
    required this.subjectName,
    required this.className,
    required this.sessionDate,
    required this.startPeriod,
    required this.endPeriod,
    required this.classroom,
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
      id:
          json['absenceRequestId'] ??
          json['id'], // ✅ FIX: Backend dùng absenceRequestId
      requestType: json['requestType'] ?? 'Xin nghỉ dạy',
      reason: json['reason'] ?? '',
      createdAt: DateTime.parse(json['createdAt']),

      // Backend mới có 2 status, cũ có 1 status
      managerStatus: json['managerStatus'] ?? json['status'] ?? 'PENDING',
      academicAffairsStatus:
          json['academicAffairsStatus'] ?? json['status'] ?? 'PENDING',

      // Optional fields
      approverName: json['approverName'],
      sessionId: json['sessionId'],
      lecturerId: json['lecturerId'],

      lecturerName: json['lecturerName'] ?? 'N/A',
      subjectName: json['subjectName'] ?? 'N/A',
      className: json['className'] ?? 'N/A',
      sessionDate: DateTime.parse(json['sessionDate']),
      startPeriod: json['startPeriod'] ?? 0,
      endPeriod: json['endPeriod'] ?? 0,
      classroom: json['classroom'] ?? '',

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
