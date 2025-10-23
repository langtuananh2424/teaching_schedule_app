import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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
      sessionId: json['session_id'],
      assignmentId: json['assignment_id'],
      sessionDate: DateTime.parse(json['session_date']),
      startPeriod: json['start_period'],
      endPeriod: json['end_period'],
      classroom: json['classroom'],
      content: json['content'],
      status: json['status'],
      notes: json['notes'],
      subjectName: json['subject_name'] ?? 'Không có tên môn học',
      className: json['class_name'] ?? 'Không có tên lớp',
    );
  }

  // THÊM PHẦN NÀY VÀO ĐỂ SỬA LỖI
  /// Getter để lấy thông tin trạng thái và màu sắc tương ứng.
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