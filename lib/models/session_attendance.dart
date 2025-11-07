class SessionAttendance {
  final int id;
  final String subject;
  final String lecturerName;
  final int startPeriod;
  final int endPeriod;
  final bool isPresent;
  final DateTime date;

  SessionAttendance({
    required this.id,
    required this.subject,
    required this.lecturerName,
    required this.startPeriod,
    required this.endPeriod,
    required this.isPresent,
    required this.date,
  });

  factory SessionAttendance.fromJson(Map<String, dynamic> json) {
    return SessionAttendance(
      id: json['id'] as int,
      subject: json['subject'] as String,
      lecturerName: json['lecturer_name'] as String,
      startPeriod: json['start_period'] as int,
      endPeriod: json['end_period'] as int,
      isPresent: json['is_present'] as bool,
      date: DateTime.parse(json['date'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'subject': subject,
      'lecturer_name': lecturerName,
      'start_period': startPeriod,
      'end_period': endPeriod,
      'is_present': isPresent,
      'date': date.toIso8601String(),
    };
  }
}
