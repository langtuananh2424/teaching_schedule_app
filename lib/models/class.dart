class ClassInfo { // Đổi tên từ Class để tránh trùng với từ khóa 'class'
  // Dựa trên bảng Classes [cite: 212]
  final int classId;
  final String classCode;
  final String className;

  ClassInfo({
    required this.classId,
    required this.classCode,
    required this.className,
  });
}