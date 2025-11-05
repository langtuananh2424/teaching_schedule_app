import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/splash_screen.dart';
import 'screens/lecturer/lecturer_home_screen.dart';
import 'screens/manager/manager_dashboard_screen.dart';
import 'services/auth_service.dart';
import 'utils/app_theme.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('vi_VN', null);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
      ],
      child: MaterialApp(
        title: 'Teaching Schedule App',
        theme: AppTheme.lightTheme,
        debugShowCheckedModeBanner: false,
        home: const AuthWrapper(),
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthService>(
      builder: (context, authService, child) {
        if (authService.isLoading) {
          return const SplashScreen();
        }

        if (!authService.isAuthenticated) {
          return const LoginScreen();
        }
        print("Giá trị thực tế của userRole: '${authService.userRole}'");
        // SỬA LỖI TẠI ĐÂY: Xóa bỏ câu lệnh `if (authService.isAuthenticated)` bị thừa
        // Logic sẽ đi thẳng vào kiểm tra vai trò
        if (authService.userRole == 'ROLE_ADMIN') {
          return const ManagerDashboardScreen();
        } else {
          return const LecturerHomeScreen();
        }

        // Code cũ có một đường dẫn ở đây không trả về widget nào, gây ra lỗi.
      },
    );
  }
}