// lib/services/auth_service.dart
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  // !!! THAY ĐỔI IP NÀY !!!
  // Dùng 10.0.2.2 cho Android Emulator
  // Dùng IP của máy (ipconfig) cho điện thoại thật
  final String _baseUrl = "http://10.0.2.2:8080/api";

  final Dio _dio = Dio();
  final _storage = const FlutterSecureStorage();

  Future<bool> login(String email, String password) async {
    try {
      final response = await _dio.post(
        '$_baseUrl/auth/login',
        data: {'email': email, 'password': password},
      );
      print("===== DEBUG AUTH SERVICE =====");
      print("PHẢN HỒI TỪ SERVER: ${response.data}");
      if (response.statusCode == 200) {
        final token = response.data['accessToken'];
        // ===============================================
        print("TOKEN ĐỌC ĐƯỢC: $token");
        print("==============================");
        // ===============================================
        // Lưu token vào bộ nhớ an toàn
        await _storage.write(key: 'jwt_token', value: token);
        return true;
      }
      return false;
    } on DioException {
      // Sai mật khẩu hoặc lỗi mạng
      return false;
    }
  }

  Future<void> logout() async {
    // Xóa token khi đăng xuất
    await _storage.delete(key: 'jwt_token');
  }
}