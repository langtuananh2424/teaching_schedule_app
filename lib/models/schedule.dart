import 'dart:convert';
// Gói 'http' được sử dụng để gọi API, không cần import ở đây
// nhưng cần thiết trong lớp dịch vụ (Service class)

// ------------------------------------------------------------------
// 1. MÔ HÌNH: TeachingSchedule (Lịch Dạy)
// Dùng để ánh xạ dữ liệu lịch dạy từ endpoint /api/schedules
// ------------------------------------------------------------------

class TeachingSchedule {
  final int scheduleId; // ID của lịch dạy
  final String subjectName; // Tên môn học
  final String className; // Lớp (Ví dụ: 62PM1)
  final String room; // Phòng học
  final DateTime startTime; // Thời gian bắt đầu (Ví dụ: 2024-10-25T07:00:00)
  final DateTime endTime; // Thời gian kết thúc
  final String teacherName; // Tên giáo viên (nếu API trả về)

  TeachingSchedule({
    required this.scheduleId,
    required this.subjectName,
    required this.className,
    required this.room,
    required this.startTime,
    required this.endTime,
    required this.teacherName,
  });

  /// Factory constructor để tạo đối tượng TeachingSchedule từ JSON Map
  /// Keys JSON (camelCase) phải khớp với keys từ API Spring Boot
  factory TeachingSchedule.fromJson(Map<String, dynamic> json) {
    return TeachingSchedule(
      scheduleId: json['scheduleId'] as int,
      subjectName: json['subjectName'] as String,
      className: json['className'] as String,
      room: json['room'] as String,
      // Chuyển đổi chuỗi ISO 8601 sang đối tượng DateTime
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: DateTime.parse(json['endTime'] as String),
      teacherName: json['teacherName'] as String,
    );
  }

  /// Phương thức giúp chuyển đổi đối tượng Dart thành JSON Map (Nếu cần gửi data lên server)
  Map<String, dynamic> toJson() {
    return {
      'scheduleId': scheduleId,
      'subjectName': subjectName,
      'className': className,
      'room': room,
      'startTime': startTime.toIso8601String(), // Chuyển DateTime về chuỗi để gửi
      'endTime': endTime.toIso8601String(),
      'teacherName': teacherName,
    };
  }
}


// ------------------------------------------------------------------
// 2. MÔ HÌNH: AbsenceRequest (Yêu Cầu Nghỉ Phép)
// Dùng để ánh xạ dữ liệu từ endpoint /api/absence-requests
// ------------------------------------------------------------------

class AbsenceRequest {
  final int requestId; // ID yêu cầu
  final String teacherId; // Mã giáo viên gửi yêu cầu
  final String reason; // Lý do nghỉ
  final String status; // Trạng thái yêu cầu (PENDING, APPROVED, REJECTED)
  final DateTime requestDate; // Ngày gửi yêu cầu
  final List<String> absenceDates; // Danh sách các ngày nghỉ (dưới dạng chuỗi ngày YYYY-MM-DD)

  AbsenceRequest({
    required this.requestId,
    required this.teacherId,
    required this.reason,
    required this.status,
    required this.requestDate,
    required this.absenceDates,
  });

  /// Factory constructor để tạo đối tượng AbsenceRequest từ JSON Map
  factory AbsenceRequest.fromJson(Map<String, dynamic> json) {
    // Ép kiểu danh sách từ dynamic sang List<String>
    final datesJson = json['absenceDates'] as List<dynamic>;

    return AbsenceRequest(
      requestId: json['requestId'] as int,
      teacherId: json['teacherId'] as String,
      reason: json['reason'] as String,
      status: json['status'] as String,
      requestDate: DateTime.parse(json['requestDate'] as String),
      absenceDates: datesJson.map((date) => date.toString()).toList(),
    );
  }

  /// Phương thức giúp chuyển đổi đối tượng Dart thành JSON Map (Gửi data lên server)
  Map<String, dynamic> toJson() {
    return {
      'requestId': requestId,
      'teacherId': teacherId,
      'reason': reason,
      'status': status,
      'requestDate': requestDate.toIso8601String(),
      'absenceDates': absenceDates,
    };
  }
}
