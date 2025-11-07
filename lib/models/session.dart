import 'package:flutter/material.dart';

class Session {
  final int sessionId;
  final int assignmentId;
  final DateTime sessionDate;
  final int startPeriod;
  final int endPeriod;
  final String classroom;
  final String? content;
  final String status;
  final String? notes;
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

  factory Session.fromJson(Map<String, dynamic> json) {
    return Session(
      sessionId: json['sessionId'] ?? json['session_id'],
      assignmentId: json['assignmentId'] ?? json['assignment_id'],
      sessionDate: DateTime.parse(json['sessionDate'] ?? json['session_date']),
      startPeriod: json['startPeriod'] ?? json['start_period'],
      endPeriod: json['endPeriod'] ?? json['end_period'],
      classroom: json['classroom'],
      content: json['content'],
      status: json['status'],
      notes: json['notes'],
      subjectName:
          json['subjectName'] ?? json['subject_name'] ?? 'Không có tên môn học',
      className: json['className'] ?? json['class_name'] ?? 'Không có tên lớp',
    );
  }

  /// Getter để lấy chuỗi thời gian hiển thị, ví dụ: "7:00 - 9:40"
  String get formattedTime {
    const periodMap = {
      1: "7:00",
      2: "7:50",
      3: "8:40",
      4: "9:45",
      5: "10:35",
      6: "11:25",
      7: "12:55",
      8: "13:45",
      9: "14:35",
      10: "15:40",
      11: "16:30",
      12: "17:20",
    };
    final startTime = periodMap[startPeriod] ?? '--:--';
    final endPeriodTime = periodMap[endPeriod + 1] ?? periodMap[endPeriod];
    return '$startTime - $endPeriodTime';
  }

  /// Lấy thời gian bắt đầu của tiết học
  DateTime get startTime {
    const periodStartTimes = {
      1: 7 * 60 + 0, // 7:00
      2: 7 * 60 + 50, // 7:50
      3: 8 * 60 + 40, // 8:40
      4: 9 * 60 + 45, // 9:45
      5: 10 * 60 + 35, // 10:35
      6: 11 * 60 + 25, // 11:25
      7: 12 * 60 + 55, // 12:55
      8: 13 * 60 + 45, // 13:45
      9: 14 * 60 + 35, // 14:35
      10: 15 * 60 + 40, // 15:40
      11: 16 * 60 + 30, // 16:30
      12: 17 * 60 + 20, // 17:20
    };
    final minutes = periodStartTimes[startPeriod] ?? 0;
    return DateTime(
      sessionDate.year,
      sessionDate.month,
      sessionDate.day,
      minutes ~/ 60,
      minutes % 60,
    );
  }

  /// Lấy thời gian kết thúc của tiết học
  DateTime get endTime {
    const periodEndTimes = {
      1: 7 * 60 + 50, // 7:50
      2: 8 * 60 + 40, // 8:40
      3: 9 * 60 + 30, // 9:30
      4: 10 * 60 + 35, // 10:35
      5: 11 * 60 + 25, // 11:25
      6: 12 * 60 + 15, // 12:15
      7: 13 * 60 + 45, // 13:45
      8: 14 * 60 + 35, // 14:35
      9: 15 * 60 + 25, // 15:25
      10: 16 * 60 + 30, // 16:30
      11: 17 * 60 + 20, // 17:20
      12: 18 * 60 + 10, // 18:10
    };
    final minutes = periodEndTimes[endPeriod] ?? 0;
    return DateTime(
      sessionDate.year,
      sessionDate.month,
      sessionDate.day,
      minutes ~/ 60,
      minutes % 60,
    );
  }

  /// Kiểm tra trạng thái thời gian thực dựa trên thời gian hiện tại
  String get realtimeStatus {
    final now = DateTime.now();

    // So sánh ngày trước
    final todayDate = DateTime(now.year, now.month, now.day);
    final sessionOnlyDate = DateTime(
      sessionDate.year,
      sessionDate.month,
      sessionDate.day,
    );

    // Nếu session ở ngày tương lai
    if (sessionOnlyDate.isAfter(todayDate)) {
      return 'NOT_TAUGHT'; // Sắp diễn ra (ngày trong tương lai)
    }

    // Nếu session ở ngày quá khứ
    if (sessionOnlyDate.isBefore(todayDate)) {
      // Ưu tiên status đặc biệt từ database (nghỉ, dạy bù)
      if (status.toUpperCase() == 'ABSENT_APPROVED' ||
          status.toUpperCase() == 'MAKEUP_TAUGHT') {
        return status;
      }
      return 'TAUGHT'; // Tự động hoàn thành nếu qua ngày
    }

    // Cùng ngày -> Kiểm tra thời gian thực trong ngày
    if (now.isBefore(startTime)) {
      return 'NOT_TAUGHT'; // Sắp diễn ra (chưa đến giờ)
    } else if (now.isAfter(endTime)) {
      // Đã qua giờ học -> Tự động hoàn thành
      // Trừ trường hợp đặc biệt (nghỉ có phép, dạy bù)
      if (status.toUpperCase() == 'ABSENT_APPROVED' ||
          status.toUpperCase() == 'MAKEUP_TAUGHT') {
        return status;
      }
      return 'TAUGHT'; // Tự động hoàn thành
    } else {
      return 'ONGOING'; // Đang diễn ra
    }
  }

  /// Getter để lấy thông tin trạng thái và màu sắc tương ứng (THỜI GIAN THỰC)
  ({String text, Color color}) get statusDisplay {
    final currentStatus = realtimeStatus.toUpperCase();

    switch (currentStatus) {
      case 'TAUGHT':
        return (text: 'Hoàn thành', color: const Color(0xFF4CAF50)); // Green
      case 'ABSENT_APPROVED':
        return (text: 'Nghỉ', color: const Color(0xFFF44336)); // Red
      case 'MAKEUP_TAUGHT':
        return (text: 'Dạy bù', color: const Color(0xFFFFA726)); // Orange
      case 'ONGOING':
        return (text: 'Đang diễn ra', color: const Color(0xFF2196F3)); // Blue
      case 'NOT_TAUGHT':
        return (
          text: 'Sắp diễn ra',
          color: const Color(0xFF03A9F4),
        ); // Light Blue
      default:
        return (text: 'Không xác định', color: Colors.grey);
    }
  }
}
