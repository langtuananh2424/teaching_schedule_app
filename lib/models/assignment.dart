class Assignment {
  final int? assignmentId;
  final String? semester;
  final int subjectId;
  final int classId;
  final int lecturerId;
  final String? subjectName;
  final String? className;
  final String? lecturerName;

  Assignment({
    this.assignmentId,
    this.semester,
    required this.subjectId,
    required this.classId,
    required this.lecturerId,
    this.subjectName,
    this.className,
    this.lecturerName,
  });

  factory Assignment.fromJson(Map<String, dynamic> json) {
    // API trả về nested objects: {assignmentId, subject: {}, studentClass: {}, lecturer: {}, semester: {}}
    // Extract data from nested objects
    final subject = json['subject'] as Map<String, dynamic>?;
    final studentClass = json['studentClass'] as Map<String, dynamic>?;
    final lecturer = json['lecturer'] as Map<String, dynamic>?;
    final semester = json['semester'] as Map<String, dynamic>?;

    return Assignment(
      assignmentId: json['assignmentId'] as int?,
      semester:
          semester?['name'] as String? ?? semester?['academicYear'] as String?,
      subjectId: subject?['id'] as int? ?? json['subjectId'] as int? ?? 0,
      classId: studentClass?['classId'] as int? ?? json['classId'] as int? ?? 0,
      lecturerId:
          lecturer?['lecturerId'] as int? ?? json['lecturerId'] as int? ?? 0,
      subjectName: subject?['subjectName'] as String?,
      className:
          studentClass?['className'] as String? ??
          studentClass?['classCode'] as String?,
      lecturerName: lecturer?['fullName'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (semester != null) 'semesterId': semester,
      'subjectId': subjectId,
      'classId': classId,
      'lecturerId': lecturerId,
    };
  }
}
