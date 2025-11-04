
class Subject {
  final int subjectId;
  final String subjectCode;
  final String subjectName;

  Subject({required this.subjectId, required this.subjectCode, required this.subjectName});

  factory Subject.fromJson(Map<String, dynamic> json) => Subject(
    subjectId: json['subjectId'] as int,
    subjectCode: json['subjectCode'] as String? ?? '',
    subjectName: json['subjectName'] as String? ?? '',
  );
}
