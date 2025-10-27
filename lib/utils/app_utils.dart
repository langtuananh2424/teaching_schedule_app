import 'package:flutter/material.dart';



// Tệp này chứa các hằng số và hàm tiện ích dùng chung
class AppColors {
  static const Color primaryColor = Color(0xFF0D47A1); // Màu xanh đậm
  static const Color lightBlueBackground = Color(0xFFAEE4FF);

  // Màu trạng thái
  static final Color statusCompleted = Colors.green.shade600;
  static final Color statusUpcoming = Colors.blue.shade700;
  static final Color statusMakeup = Colors.orange.shade700;
  static final Color statusCancelled = Colors.red.shade700;
}

class ApiConstants {
  static const String baseUrl = "http://10.0.2.2:8080/api"; // Ví dụ cho Android Emulator
}

// Bạn có thể thêm các hàm tiện ích khác ở đây
class AppUtils {
  static void showSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
