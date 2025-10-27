class Subject {
  // Dựa trên bảng Subjects (trong file Word có lúc ghi là Students, tôi sửa lại) [cite: 204]
  final int subjectId;
  final String subjectCode;
  final String subjectName;
  final int credits;

  Subject({
    required this.subjectId,
    required this.subjectCode,
    required this.subjectName,
    required this.credits,
  });
}