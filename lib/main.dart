import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/request_list_screen.dart';
import 'screens/request_detail_screen.dart';
import 'screens/report_screen.dart';
import 'screens/report_detail_screen.dart'; // ✅ Thêm import mới
import 'services/api_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ApiService.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Teaching Schedule',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        textTheme: GoogleFonts.poppinsTextTheme(),
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: const Color(0xFFF5F7FA),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF0D5CA8),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
      ),

      // ✅ Nếu có token → vào HomeScreen, ngược lại → Login
      initialRoute: ApiService.hasToken ? '/home' : '/',

      routes: {
        '/': (context) => const LoginScreen(),
        '/home': (context) => const HomeScreen(),
        '/requests': (context) => const RequestListScreen(),
        '/report': (context) => const ReportScreen(),
        '/report-detail': (context) => const ReportDetailScreen(), // ✅ Thêm route
      },

      // ✅ Giữ phần xử lý động cho chi tiết yêu cầu
      onGenerateRoute: (settings) {
        if (settings.name == '/request-detail') {
          final args = settings.arguments;
          if (args is Map<String, dynamic>) {
            return MaterialPageRoute(
              builder: (context) => RequestDetailScreen(request: args),
            );
          }
          return MaterialPageRoute(
            builder: (context) => const Scaffold(
              body: Center(child: Text('Không có dữ liệu yêu cầu')),
            ),
          );
        }
        return null;
      },
    );
  }
}
