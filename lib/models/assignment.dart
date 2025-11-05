class Assignment {
  // Dựa trên bảng Assignments [cite: 171]
  final int assignmentId;
  final int subjectId;
  final int classId;
  final int lecturerId;

  Assignment({
    required this.assignmentId,
    required this.subjectId,
    required this.classId,
    required this.lecturerId,
  });
}