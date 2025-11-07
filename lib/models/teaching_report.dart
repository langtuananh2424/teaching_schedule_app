class TeachingReport {
  final int reportId;
  final int lecturerId;
  final String lecturerName;
  final int totalRegisteredHours; // Tổng số giờ đăng ký
  final int totalActualHours;    // Tổng số giờ thực tế
  final List<AbsenceDetail> absences; // Chi tiết các buổi nghỉ
  final List<MakeupDetail> makeups;   // Chi tiết các buổi dạy bù

  TeachingReport({
    required this.reportId,
    required this.lecturerId,
    required this.lecturerName,
    required this.totalRegisteredHours,
    required this.totalActualHours,
    required this.absences,
    required this.makeups,
  });

  factory TeachingReport.fromJson(Map<String, dynamic> json) {
    return TeachingReport(
      reportId: json['report_id'],
      lecturerId: json['lecturer_id'],
      lecturerName: json['lecturer_name'],
      totalRegisteredHours: json['total_registered_hours'],
      totalActualHours: json['total_actual_hours'],
      absences: (json['absences'] as List)
          .map((absence) => AbsenceDetail.fromJson(absence))
          .toList(),
      makeups: (json['makeups'] as List)
          .map((makeup) => MakeupDetail.fromJson(makeup))
          .toList(),
    );
  }
}

class AbsenceDetail {
  final int absenceId;
  final DateTime date;
  final String subject;
  final int startPeriod;
  final int endPeriod;
  final String reason;
  final bool isMadeUp; // Đã dạy bù chưa

  AbsenceDetail({
    required this.absenceId,
    required this.date,
    required this.subject,
    required this.startPeriod,
    required this.endPeriod,
    required this.reason,
    required this.isMadeUp,
  });

  factory AbsenceDetail.fromJson(Map<String, dynamic> json) {
    return AbsenceDetail(
      absenceId: json['absence_id'],
      date: DateTime.parse(json['date']),
      subject: json['subject'],
      startPeriod: json['start_period'],
      endPeriod: json['end_period'],
      reason: json['reason'],
      isMadeUp: json['is_made_up'],
    );
  }
}

class MakeupDetail {
  final int makeupId;
  final int absenceId; // Liên kết với buổi nghỉ
  final DateTime date;
  final String subject;
  final int startPeriod;
  final int endPeriod;

  MakeupDetail({
    required this.makeupId,
    required this.absenceId,
    required this.date,
    required this.subject,
    required this.startPeriod,
    required this.endPeriod,
  });

  factory MakeupDetail.fromJson(Map<String, dynamic> json) {
    return MakeupDetail(
      makeupId: json['makeup_id'],
      absenceId: json['absence_id'],
      date: DateTime.parse(json['date']),
      subject: json['subject'],
      startPeriod: json['start_period'],
      endPeriod: json['end_period'],
    );
  }
}