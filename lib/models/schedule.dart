// lib/models/schedule.dart

import 'package:flutter/material.dart';

class Schedule {
  final int? sessionId;
  final int? assignmentId;
  final String? subjectName;
  final String? lecturerName;
  final String? className;
  final DateTime? sessionDate;
  final int? lessonOrder;
  final int? startPeriod;
  final int? endPeriod;
  final String? classroom;
  final String? content;
  final String? status;
  final String? notes;

  Schedule({
    this.sessionId,
    this.assignmentId,
    this.subjectName,
    this.lecturerName,
    this.className,
    this.sessionDate,
    this.lessonOrder,
    this.startPeriod,
    this.endPeriod,
    this.classroom,
    this.content,
    this.status,
    this.notes,
  });

  factory Schedule.fromJson(Map<String, dynamic> json) {
    return Schedule(
      sessionId: json['sessionId'] as int?,
      assignmentId: json['assignmentId'] as int?,
      subjectName: json['subjectName'] as String?,
      lecturerName: json['lecturerName'] as String?,
      className: json['className'] as String?,
      sessionDate: json['sessionDate'] != null
          ? DateTime.parse(json['sessionDate'] as String)
          : null,
      lessonOrder: json['lessonOrder'] as int?,
      startPeriod: json['startPeriod'] as int?,
      endPeriod: json['endPeriod'] as int?,
      classroom: json['classroom'] as String?,
      content: json['content'] as String?,
      status: json['status'] as String?,
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (sessionId != null) 'sessionId': sessionId,
      if (assignmentId != null) 'assignmentId': assignmentId,
      if (subjectName != null) 'subjectName': subjectName,
      if (lecturerName != null) 'lecturerName': lecturerName,
      if (className != null) 'className': className,
      if (sessionDate != null) 'sessionDate': sessionDate!.toIso8601String(),
      if (lessonOrder != null) 'lessonOrder': lessonOrder,
      if (startPeriod != null) 'startPeriod': startPeriod,
      if (endPeriod != null) 'endPeriod': endPeriod,
      if (classroom != null) 'classroom': classroom,
      if (content != null) 'content': content,
      if (status != null) 'status': status,
      if (notes != null) 'notes': notes,
    };
  }

  // Method riêng cho update - không bao gồm sessionId và các trường read-only
  Map<String, dynamic> toUpdateJson() {
    final map = <String, dynamic>{};

    // Các trường bắt buộc
    if (assignmentId != null) map['assignmentId'] = assignmentId;
    if (sessionDate != null)
      map['sessionDate'] = sessionDate!.toIso8601String();
    if (startPeriod != null) map['startPeriod'] = startPeriod;
    if (endPeriod != null) map['endPeriod'] = endPeriod;
    if (status != null) map['status'] = status;

    // Các trường optional - chỉ thêm nếu có giá trị
    if (lessonOrder != null) map['lessonOrder'] = lessonOrder;
    if (classroom != null && classroom!.isNotEmpty)
      map['classroom'] = classroom;
    if (content != null && content!.isNotEmpty) map['content'] = content;
    if (notes != null && notes!.isNotEmpty) map['notes'] = notes;

    return map;
  }

  // Trạng thái thực tế (tự động tính dựa trên ngày)
  String get effectiveStatus {
    // Nếu đã bị hủy thì giữ nguyên
    if (status == 'CANCELLED') return status!;

    // Nếu đã qua ngày thì tự động là COMPLETED
    if (sessionDate != null) {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final sessionDay = DateTime(
        sessionDate!.year,
        sessionDate!.month,
        sessionDate!.day,
      );

      if (sessionDay.isBefore(today)) {
        return 'COMPLETED';
      }
    }

    // Còn lại giữ nguyên status từ backend
    return status ?? 'PENDING';
  }

  String get statusDisplay {
    switch (effectiveStatus) {
      case 'PENDING':
      case 'NOT_TAUGHT':
        return 'Chưa dạy';
      case 'COMPLETED':
      case 'TAUGHT':
        return 'Đã dạy';
      case 'CANCELLED':
        return 'Đã hủy';
      default:
        return effectiveStatus;
    }
  }

  Color get statusColor {
    switch (effectiveStatus) {
      case 'PENDING':
      case 'NOT_TAUGHT':
        return Colors.orange;
      case 'COMPLETED':
      case 'TAUGHT':
        return Colors.green;
      case 'CANCELLED':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
