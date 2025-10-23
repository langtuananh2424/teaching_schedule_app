// lib/models/absence_request.dart

class AbsenceRequest {
  final int requestId;
  final int sessionId;
  final String reason;
  final String approvalStatus;
  final DateTime createdAt;
  final int lecturerId;

  // Các trường bổ sung để hiển thị trên UI (giả sử backend trả về)
  final String lecturerName;
  final String subjectName;

  AbsenceRequest({
    required this.requestId,
    required this.sessionId,
    required this.reason,
    required this.approvalStatus,
    required this.createdAt,
    required this.lecturerId,
    required this.lecturerName,
    required this.subjectName,
  });

  // THÊM PHƯƠNG THỨC NÀY VÀO ĐỂ SỬA LỖI
  factory AbsenceRequest.fromJson(Map<String, dynamic> json) {
    return AbsenceRequest(
      requestId: json['request_id'],
      sessionId: json['session_id'],
      reason: json['reason'] ?? '',
      approvalStatus: json['approval_status'],
      createdAt: DateTime.parse(json['created_at']),
      lecturerId: json['lecturer_id'],
      // Giả sử API trả về các trường này sau khi join bảng
      lecturerName: json['lecturer_name'] ?? 'Chưa có tên',
      subjectName: json['subject_name'] ?? 'Chưa có môn học',
    );
  }
}