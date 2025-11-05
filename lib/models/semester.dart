class Semester {
  final int semesterId;
  final String semesterName;
  final DateTime? startDate;
  final DateTime? endDate;
  final bool isActive;

  Semester({
    required this.semesterId,
    required this.semesterName,
    this.startDate,
    this.endDate,
    required this.isActive,
  });

  factory Semester.fromJson(Map<String, dynamic> json) {
    return Semester(
      semesterId: json['semester_id'],
      semesterName: json['semester_name'],
      startDate: json['start_date'] != null
          ? DateTime.parse(json['start_date'])
          : null,
      endDate: json['end_date'] != null
          ? DateTime.parse(json['end_date'])
          : null,
      isActive: json['is_active'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'semester_id': semesterId,
      'semester_name': semesterName,
      'start_date': startDate?.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
      'is_active': isActive,
    };
  }
}