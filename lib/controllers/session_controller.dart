import 'package:flutter/material.dart'; // Import để sử dụng màu sắc

class Session {
  // --- Dữ liệu từ bảng `Schedules` ---
  final int sessionId;
  final int assignmentId;
  final DateTime sessionDate;
  final int startPeriod;
  final int endPeriod;
  final String classroom;
  final String? content; // Nội dung có thể là null
  final String status;
  final String? notes; // Ghi chú có thể là null

  // --- Dữ liệu bổ sung từ các bảng khác (để hiển thị) ---
  final String subjectName;
  final String className;

  Session({
    required this.sessionId,
    required this.assignmentId,
    required this.sessionDate,
    required this.startPeriod,
    required this.endPeriod,
    required this.classroom,
    this.content,
    required this.status,
    this.notes,
    required this.subjectName,
    required this.className,
  });

  /// Factory constructor để tạo một đối tượng `Session` từ JSON.
  /// Điều này rất quan trọng để chuyển đổi dữ liệu từ API thành một đối tượng Dart.
  factory Session.fromJson(Map<String, dynamic> json) {
    return Session(
      sessionId: json['session_id'],
      assignmentId: json['assignment_id'],
      sessionDate: DateTime.parse(json['session_date']),
      startPeriod: json['start_period'],
      endPeriod: json['end_period'],
      classroom: json['classroom'],
      content: json['content'],
      status: json['status'],
      notes: json['notes'],
      // Giả sử API của bạn trả về các trường này sau khi join bảng
      subjectName: json['subject_name'] ?? 'Không có tên môn học',
      className: json['class_name'] ?? 'Không có tên lớp',
    );
  }

  /// Getter để lấy chuỗi thời gian hiển thị, ví dụ: "7:00 - 9:40"
  String get formattedTime {
    // Đây là dữ liệu giả định, bạn nên có một cơ chế để ánh xạ tiết học sang giờ thực tế
    const periodMap = {
      1: "7:00", 2: "7:50", 3: "8:40",
      4: "9:45", 5: "10:35", 6: "11:25",
      7: "12:55", 8: "13:45", 9: "14:35",
      10: "15:40", 11: "16:30", 12: "17:20",
    };
    final startTime = periodMap[startPeriod] ?? '--:--';
    final endTime = periodMap[endPeriod] ?? '--:--';
    return '$startTime - $endTime';
  }

  /// Getter để lấy thông tin trạng thái và màu sắc tương ứng
  ({String text, Color color}) get statusDisplay {
    switch (status.toUpperCase()) {
      case 'TAUGHT':
        return (text: 'Hoàn thành', color: Colors.green);
      case 'ABSENT_APPROVED':
        return (text: 'Nghỉ', color: Colors.orange);
      case 'MAKEUP_TAUGHT':
        return (text: 'Dạy bù', color: Colors.blue);
      case 'NOT_TAUGHT':
        return (text: 'Sắp diễn ra', color: Colors.cyan);
      default:
        return (text: 'Không xác định', color: Colors.grey);
    }
  }
}