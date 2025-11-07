// lib/models/makeup_session.dart

class MakeupSession {
  final int makeupSessionId;
  final int absentSessionId;
  final DateTime makeupDate;
  final int makeupStartPeriod;
  final int makeupEndPeriod;
  final String makeupClassroom;
  final DateTime createdAt;
  final String managerStatus; // PENDING, APPROVED, REJECTED
  final String academicAffairsStatus; // PENDING, APPROVED, REJECTED

  MakeupSession({
    required this.makeupSessionId,
    required this.absentSessionId,
    required this.makeupDate,
    required this.makeupStartPeriod,
    required this.makeupEndPeriod,
    required this.makeupClassroom,
    required this.createdAt,
    required this.managerStatus,
    required this.academicAffairsStatus,
  });

  factory MakeupSession.fromJson(Map<String, dynamic> json) {
    return MakeupSession(
      makeupSessionId: json['makeupSessionId'],
      absentSessionId: json['absentSessionId'],
      makeupDate: DateTime.parse(json['makeupDate']),
      makeupStartPeriod: json['makeupStartPeriod'] ?? 0,
      makeupEndPeriod: json['makeupEndPeriod'] ?? 0,
      makeupClassroom: json['makeupClassroom'] ?? '',
      createdAt: DateTime.parse(json['createdAt']),
      managerStatus: json['managerStatus'] ?? 'PENDING',
      academicAffairsStatus: json['academicAffairsStatus'] ?? 'PENDING',
    );
  }
}
