
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:frontend_app/services/auth_service.dart';

class AuthController extends GetxController {
  final AuthService _authService = AuthService();
  var isLoading = false.obs;

  Future<void> login(String email, String password) async {
    try {
      isLoading(true);
      final success = await _authService.login(email, password);
      if (success) {
        // THAY ĐỔI TẠI ĐÂY:
        Get.offNamed('/lecturer_schedule'); // Chuyển đến màn hình lịch dạy
      } else {
        Get.snackbar(
          'Đăng nhập thất bại',
          'Email hoặc mật khẩu không chính xác.',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } finally {
      isLoading(false);
    }
  }

  void logout() async {
    await _authService.logout();
    Get.offAllNamed('/login');
  }
}