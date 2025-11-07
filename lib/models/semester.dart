class Semester {
  final int semesterId;
  final String semesterName;
  final String? academicYear;
  final DateTime? startDate;
  final DateTime? endDate;
  final bool isActive;

  Semester({
    required this.semesterId,
    required this.semesterName,
    this.academicYear,
    this.startDate,
    this.endDate,
    required this.isActive,
  });

  factory Semester.fromJson(Map<String, dynamic> json) {
    // Xử lý semesterId có thể null hoặc string
    int parsedId;
    // Backend mới dùng 'semesterId', backend cũ dùng 'semester_id'
    final idValue = json['semesterId'] ?? json['semester_id'];
    if (idValue == null) {
      parsedId = 0;
    } else if (idValue is int) {
      parsedId = idValue;
    } else if (idValue is String) {
      parsedId = int.tryParse(idValue) ?? 0;
    } else {
      parsedId = 0;
    }

    // Backend mới dùng 'name', backend cũ dùng 'semester_name'
    final nameValue = json['name'] ?? json['semester_name'];

    // Backend mới dùng 'academicYear', backend cũ dùng 'academic_year'
    final academicYearValue = json['academicYear'] ?? json['academic_year'];

    return Semester(
      semesterId: parsedId,
      semesterName: nameValue?.toString() ?? 'Unknown',
      academicYear: academicYearValue?.toString(),
      startDate: (json['startDate'] ?? json['start_date']) != null
          ? DateTime.tryParse(
              (json['startDate'] ?? json['start_date']).toString(),
            )
          : null,
      endDate: (json['endDate'] ?? json['end_date']) != null
          ? DateTime.tryParse((json['endDate'] ?? json['end_date']).toString())
          : null,
      isActive:
          json['is_active'] == true ||
          json['is_active'] == 'true' ||
          json['isActive'] == true,
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
