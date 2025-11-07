class Student {
  final int id;
  final String studentCode;
  final String fullName;
  final String email;
  final String departmentName;
  final int departmentId;
  final String className;
  final int classId;

  Student({
    required this.id,
    required this.studentCode,
    required this.fullName,
    required this.email,
    required this.departmentName,
    required this.departmentId,
    required this.className,
    required this.classId,
  });

  factory Student.fromJson(Map<String, dynamic> json) {
    // Hm helper  parse int an ton, lun tr v int khng null
    int parseIntSafely(dynamic value, {int defaultValue = 0}) {
      if (value == null) return defaultValue;
      if (value is int) return value;
      if (value is String) {
        // Th chuyn i string sang int
        return int.tryParse(value) ?? defaultValue;
      }
      return defaultValue;
    }

    try {
      return Student(
        id: parseIntSafely(json['studentId']) != 0
            ? parseIntSafely(json['studentId'])
            : parseIntSafely(
                json['id'],
              ), // Th studentId trc, fallback sang id
        studentCode: json['studentCode']?.toString() ?? '',
        fullName: json['fullName']?.toString() ?? '',
        email: json['email']?.toString() ?? '',
        departmentName: json['departmentName']?.toString() ?? '',
        departmentId: parseIntSafely(json['departmentId']),
        className: json['className']?.toString() ?? '',
        classId: parseIntSafely(json['classId']),
      );
    } catch (e) {
      print(' Error parsing student JSON: $json');
      print('Error details: $e');
      rethrow;
    }
  }

  Student copyWith({
    String? studentCode,
    String? fullName,
    int? departmentId,
    String? departmentName,
    String? className,
    int? classId,
  }) {
    return Student(
      id: id,
      studentCode: studentCode ?? this.studentCode,
      fullName: fullName ?? this.fullName,
      email: email,
      departmentName: departmentName ?? this.departmentName,
      departmentId: departmentId ?? this.departmentId,
      className: className ?? this.className,
      classId: classId ?? this.classId,
    );
  }
}

