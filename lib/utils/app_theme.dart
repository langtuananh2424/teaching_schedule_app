import 'package:flutter/material.dart';

class AppTheme {
  // Định nghĩa một chủ đề ánh sáng (light theme) cơ bản
  static final ThemeData lightTheme = ThemeData(
    primarySwatch: Colors.blue,
    primaryColor: Colors.blue.shade800,
    fontFamily: 'Roboto',
    scaffoldBackgroundColor: Colors.grey.shade100,
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.blue.shade800,
      foregroundColor: Colors.white,
      elevation: 2,
      titleTextStyle: const TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
    ),
    // Thêm các cấu hình theme khác nếu cần
    colorScheme: ColorScheme.light(
      primary: Colors.blue.shade800,
      secondary: Colors.orange.shade700,
      background: Colors.grey.shade100,
      error: Colors.red.shade700,
      surface: Colors.white,
    ),
  );
}
