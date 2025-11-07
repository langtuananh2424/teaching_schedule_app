// lib/constants/constants.dart

class AppConstants {
  // Dùng localhost cho web
  // Include scheme so Uri.parse produces a valid absolute URL.
  // Keep without trailing slash; endpoints append paths like '/api/...'.
  static const String baseUrl = 'http://36.50.55.230:8080';
}
