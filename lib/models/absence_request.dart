// lib/models/absence_request.dart

class AbsenceRequest {
  final int id;
  final String requestType;
  final String reason;
  final DateTime createdAt;
  final String managerStatus; // PENDING, APPROVED, REJECTED
  final String academicAffairsStatus; // PENDING, APPROVED, REJECTED
  final String lecturerName;
  final String subjectName;
  final String className;
  final DateTime sessionDate;
  final int startPeriod;
  final int endPeriod;
  final String classroom;
  final DateTime? makeupCreatedAt;
  final DateTime? makeupDate;
  final int? makeupStartPeriod;
  final int? makeupEndPeriod;
  final String? makeupClassroom;

  AbsenceRequest({
    required this.id,
    required this.requestType,
    required this.reason,
    required this.createdAt,
    required this.managerStatus,
    required this.academicAffairsStatus,
    required this.lecturerName,
    required this.subjectName,
    required this.className,
    required this.sessionDate,
    required this.startPeriod,
    required this.endPeriod,
    required this.classroom,
    this.makeupCreatedAt,
    this.makeupDate,
    this.makeupStartPeriod,
    this.makeupEndPeriod,
    this.makeupClassroom,
  });

  factory AbsenceRequest.fromJson(Map<String, dynamic> json) {
    return AbsenceRequest(
      id: (json['id'] ?? 0) is int
          ? (json['id'] ?? 0)
          : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      requestType: json['requestType'] ?? '',
      reason: json['reason'] ?? '',
      createdAt: DateTime.parse(json['createdAt']),
      managerStatus: json['managerStatus'] ?? 'PENDING',
      academicAffairsStatus: json['academicAffairsStatus'] ?? 'PENDING',
      lecturerName: json['lecturerName'] ?? 'N/A',
      subjectName: json['subjectName'] ?? 'N/A',
      className: json['className'] ?? 'N/A',
      sessionDate: DateTime.parse(json['sessionDate']),
      startPeriod: (json['startPeriod'] ?? 0) is int
          ? (json['startPeriod'] ?? 0)
          : int.tryParse(json['startPeriod']?.toString() ?? '0') ?? 0,
      endPeriod: (json['endPeriod'] ?? 0) is int
          ? (json['endPeriod'] ?? 0)
          : int.tryParse(json['endPeriod']?.toString() ?? '0') ?? 0,
      classroom: json['classroom'] ?? '',
      makeupCreatedAt: json['makeupCreatedAt'] != null
          ? DateTime.parse(json['makeupCreatedAt'])
          : null,
      makeupDate: json['makeupDate'] != null
          ? DateTime.parse(json['makeupDate'])
          : null,
      makeupStartPeriod:
          json['makeupStartPeriod'] is int || json['makeupStartPeriod'] == null
          ? json['makeupStartPeriod']
          : int.tryParse(json['makeupStartPeriod']?.toString() ?? ''),
      makeupEndPeriod:
          json['makeupEndPeriod'] is int || json['makeupEndPeriod'] == null
          ? json['makeupEndPeriod']
          : int.tryParse(json['makeupEndPeriod']?.toString() ?? ''),
      makeupClassroom: json['makeupClassroom'],
    );
  }
}
