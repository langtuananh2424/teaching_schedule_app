import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app_router.dart'; // Import bộ điều hướng
import 'services/auth_service.dart';
import 'services/api_service.dart';
import 'utils/app_theme.dart'; // Import theme cho web

void main() {
  // Không cần async hay initializeDateFormatting ở đây trừ khi có màn hình nào đó dùng
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // MultiProvider để cung cấp AuthService và ApiService cho toàn bộ ứng dụng
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        Provider(create: (_) => ApiService()),
      ],
      // Builder giúp lấy AuthService đã được khởi tạo để truyền vào router
      child: Builder(
        builder: (context) {
          // Lấy router từ AppRouter, truyền authService vào để xử lý redirect
          final router = AppRouter(context.read<AuthService>()).router;

          // Sử dụng MaterialApp.router để tích hợp go_router
          return MaterialApp.router(
            title: 'Schedule Management',
            theme: AppTheme.lightTheme, // Áp dụng theme đã định nghĩa cho web
            debugShowCheckedModeBanner: false,
            // Cấu hình router cho ứng dụng
            routerConfig: router,
          );
        },
      ),
    );
  }
}
