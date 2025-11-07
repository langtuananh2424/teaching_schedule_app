import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'screens/dashboard_screen.dart';
import 'screens/lecturer_management_screen.dart';
import 'screens/login_screen.dart';
import 'screens/not_found_screen.dart';
import 'screens/shell_screen.dart';
import 'screens/student_management_screen.dart';
import 'screens/absence_request_management_screen.dart';
import 'screens/makeup_session_management_screen.dart';
import 'screens/class_management_screen.dart';
import 'screens/subject_management_screen.dart';
import 'screens/assignment_management_screen.dart';
import 'screens/schedule_management_screen.dart';
import 'services/auth_service.dart';

class AppRouter {
  final AuthService authService;
  late final GoRouter router;
  final _shellNavigatorKey = GlobalKey<NavigatorState>();

  AppRouter(this.authService) {
    router = GoRouter(
      navigatorKey: GlobalKey<NavigatorState>(),
      initialLocation: '/login',
      errorBuilder: (context, state) => NotFoundScreen(),
      refreshListenable: authService,
      redirect: (context, state) {
        final isLoggedIn = authService.isAuthenticated;
        final isLoggingIn = state.matchedLocation == '/login';
        final userRole = authService.userRole; // Lấy vai trò để kiểm tra
        final isLoading = authService.isLoading;

        // Dòng print để bạn có thể kiểm tra giá trị thực tế trong console
        print(
          "Kiểm tra điều hướng -> IsLoggedIn: $isLoggedIn, Path: ${state.matchedLocation}, Role: '$userRole', isLoading: $isLoading",
        );

        // Nếu dịch vụ auth đang load (đang kiểm tra token trong storage),
        // không redirect nào được thực hiện (trả về null) để cho phép
        // quá trình load hoàn tất. Nếu trả về '/login' ở giai đoạn này,
        // app sẽ luôn bị đẩy về trang login trước khi biết token hợp lệ.
        if (isLoading) {
          return null;
        }

        // 1. Nếu chưa đăng nhập và không ở trang login -> đẩy về trang login
        if (!isLoggedIn && !isLoggingIn) {
          return '/login';
        }

        // 2. Nếu đã đăng nhập
        if (isLoggedIn) {
          // 2a. BẢO VỆ TRANG: Nếu vai trò không phải ADMIN, đăng xuất và đẩy về login
          // Điều này áp dụng cho mọi trang, kể cả khi refresh
          if (userRole != 'ADMIN' && userRole != 'ROLE_ADMIN') {
            authService.logout();
            return '/login';
          }

          print('Debug: userRole=$userRole, isLoggedIn=$isLoggedIn');
          // 2b. Nếu là ADMIN và đang ở trang login -> đẩy vào trang chủ
          if (isLoggingIn) {
            return '/';
          }
        }

        // 3. Nếu mọi điều kiện đều hợp lệ, cho phép truy cập
        return null;
      },
      routes: [
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginScreen(),
        ),
        ShellRoute(
          navigatorKey: _shellNavigatorKey,
          builder: (context, state, child) {
            return ShellScreen(child: child); // Bố cục chính
          },
          routes: [
            GoRoute(
              path: '/',
              builder: (context, state) => const DashboardScreen(),
            ),
            GoRoute(
              path: '/lecturers',
              builder: (context, state) => const LecturerManagementScreen(),
            ),
            GoRoute(
              path: '/students',
              builder: (context, state) => const StudentManagementScreen(),
            ),
            GoRoute(
              path: '/absence-requests',
              builder: (context, state) =>
                  const AbsenceRequestManagementScreen(),
            ),
            GoRoute(
              path: '/makeup-sessions',
              builder: (context, state) =>
                  const MakeupSessionManagementScreen(),
            ),
            GoRoute(
              path: '/classes',
              builder: (context, state) => const ClassManagementScreen(),
            ),
            GoRoute(
              path: '/subjects',
              builder: (context, state) => const SubjectManagementScreen(),
            ),
            GoRoute(
              path: '/assignments',
              builder: (context, state) => const AssignmentManagementScreen(),
            ),
            GoRoute(
              path: '/schedules',
              builder: (context, state) => const ScheduleManagementScreen(),
            ),
          ],
        ),
      ],
    );
  }
}
