// lib/models/makeup_session.dart

class MakeupSession {
  final int makeupSessionId;
  final int absentSessionId;
  final DateTime makeupDate;
  // Thêm các trường khác...

  // Các trường bổ sung để hiển thị trên UI (giả sử backend trả về)
  final String lecturerName;
  final String subjectName;


  MakeupSession({
    required this.makeupSessionId,
    required this.absentSessionId,
    required this.makeupDate,
    required this.lecturerName,
    required this.subjectName,
  });

  // THÊM PHƯƠ-NG THỨC NÀY VÀO ĐỂ SỬA LỖI
  factory MakeupSession.fromJson(Map<String, dynamic> json) {
    return MakeupSession(
      makeupSessionId: json['makeup_session_id'],
      absentSessionId: json['absent_session_id'],
      makeupDate: DateTime.parse(json['makeup_date']),
      // Giả sử API trả về các trường này sau khi join bảng
      lecturerName: json['lecturer_name'] ?? 'Chưa có tên',
      subjectName: json['subject_name'] ?? 'Chưa có môn học',
    );
  }
}