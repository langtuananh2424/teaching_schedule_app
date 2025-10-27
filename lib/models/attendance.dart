import 'package:flutter/material.dart';

// Enum và helpers cho Điểm danh (Đã tách từ file cũ)
enum AttendanceStatus {
  present, // Có mặt (Màu xanh lá)
  absent, // Vắng (Màu đỏ)
  late, // Muộn (Màu vàng)
  excused // Có phép (Màu xanh dương)
}

// Hàm tiện ích để chuyển Enum sang String tiếng Việt
String getStatusString(AttendanceStatus status) {
  switch (status) {
    case AttendanceStatus.present:
      return 'Có mặt';
    case AttendanceStatus.absent:
      return 'Vắng';
    case AttendanceStatus.late:
      return 'Muộn';
    case AttendanceStatus.excused:
      return 'Có phép';
  }
}

// Hàm tiện ích để lấy màu cho trạng thái
Color getStatusColor(AttendanceStatus status) {
  switch (status) {
    case AttendanceStatus.present:
      return Colors.green.shade600;
    case AttendanceStatus.absent:
      return Colors.red.shade600;
    case AttendanceStatus.late:
      return Colors.amber.shade600;
    case AttendanceStatus.excused:
      return Colors.blue.shade600;
  }
}
