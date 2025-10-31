import 'package:flutter/material.dart';
import 'package:get/get.dart';

// Import các màn hình
import 'package:frontend_app/screens/auth/login_screen.dart';
import 'package:frontend_app/screens/lecturer/session_details_screen.dart';
import 'package:frontend_app/screens/lecturer/attendance_screen.dart';
import 'package:frontend_app/screens/lecturer/lecturer_schedule_screen.dart';
import 'package:frontend_app/screens/lecturer/request_absence_screen.dart';
import 'package:frontend_app/screens/lecturer/register_makeup_screen.dart';
// Import màn hình splash (nếu bạn có logic check login)
// import 'package:frontend_app/screens/auth/splash_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Sử dụng GetMaterialApp để quản lý routes và state
    return GetMaterialApp(
      title: 'Lịch Giảng Dạy',
      theme: ThemeData( // Bạn có thể thay thế bằng app_theme.dart
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF0F2F5),
      ),
      debugShowCheckedModeBanner: false,

      // Màn hình bắt đầu (có thể là splash_screen để check login)
      initialRoute: '/login',

      // Định nghĩa tất cả các tuyến đường (routes)
      getPages: [
        GetPage(name: '/login', page: () => const LoginScreen()),
        // GetPage(name: '/splash', page: () => const SplashScreen()),
        GetPage(name: '/lecturer_schedule', page: () => const LecturerScheduleScreen()),
        GetPage(name: '/session_details', page: () => const SessionDetailsScreen()),

        // Các màn hình chi tiết
        GetPage(name: '/attendance', page: () => const AttendanceScreen()),
        GetPage(name: '/request_absence', page: () => const RequestAbsenceScreen()),
        GetPage(name: '/register_makeup', page: () => const RegisterMakeupScreen()),
      ],
    );
  }
}