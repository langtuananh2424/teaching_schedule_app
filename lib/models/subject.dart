class Subject {
  final int subjectId;
  final String subjectName;

  Subject({required this.subjectId, required this.subjectName});

  factory Subject.fromJson(Map<String, dynamic> json) {
    return Subject(
      subjectId: json['subjectId'] ?? 0,
      subjectName: json['subjectName'] ?? 'N/A',
    );
  }
}