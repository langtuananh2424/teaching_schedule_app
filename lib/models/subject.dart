class Subject {
  final int? subjectId;
  final String subjectCode;
  final String subjectName;
  final int credits;
  final int? theoryPeriods;
  final int? practicePeriods;
  final int? departmentId;

  Subject({
    this.subjectId,
    required this.subjectCode,
    required this.subjectName,
    required this.credits,
    this.theoryPeriods,
    this.practicePeriods,
    this.departmentId,
  });

  factory Subject.fromJson(Map<String, dynamic> json) {
    return Subject(
      subjectId: json['subjectId'] as int?,
      subjectCode: json['subjectCode'] as String,
      subjectName: json['subjectName'] as String,
      credits: json['credits'] as int,
      theoryPeriods: json['theoryPeriods'] as int?,
      practicePeriods: json['practicePeriods'] as int?,
      departmentId: json['departmentId'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'subjectCode': subjectCode,
      'subjectName': subjectName,
      'credits': credits,
      if (theoryPeriods != null) 'theoryPeriods': theoryPeriods,
      if (practicePeriods != null) 'practicePeriods': practicePeriods,
      if (departmentId != null) 'departmentId': departmentId,
    };
  }
}
