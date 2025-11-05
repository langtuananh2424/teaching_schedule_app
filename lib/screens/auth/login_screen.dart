import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart'; // Đảm bảo đường dẫn này đúng

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isPasswordVisible = false;

  Future<void> _login() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    final authService = Provider.of<AuthService>(context, listen: false);
    final bool success = await authService.login(
      _emailController.text,
      _passwordController.text,
    );

    if (!mounted) return;
    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email hoặc mật khẩu không đúng.')),
      );
    }
    // AuthWrapper trong main.dart sẽ tự động xử lý điều hướng
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0D47A1), // Màu xanh navy đậm
              Color(0xFF000000), // Màu đen
            ],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // === LOGO VÀ TIÊU ĐỀ ===
                Image.asset('assets/logo.png', height: 120),
                const SizedBox(height: 20),
                const Text(
                  'Hệ thống Quản lý\nLịch trình giảng dạy',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 50),

                // === KHUNG ĐĂNG NHẬP MÀU TRẮNG ===
                Container(
                  padding: const EdgeInsets.all(24.0), // Padding đều các cạnh
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Đăng nhập',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Input Email
                      TextField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          hintText: 'Email',
                          prefixIcon: const Icon(Icons.person_outline),
                          filled: true,
                          fillColor: Colors.grey[100],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 16),
                      // Input Mật khẩu
                      TextField(
                        controller: _passwordController,
                        decoration: InputDecoration(
                          hintText: 'Mật khẩu',
                          prefixIcon: const Icon(Icons.lock_outline),
                          filled: true,
                          fillColor: Colors.grey[100],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                          // Thêm nút con mắt (IconButton) vào đây
                          suffixIcon: IconButton(
                            icon: Icon(
                              // Thay đổi icon dựa trên trạng thái _isPasswordVisible
                              _isPasswordVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                            onPressed: () {
                              // Cập nhật trạng thái khi người dùng nhấn nút
                              setState(() {
                                _isPasswordVisible = !_isPasswordVisible;
                              });
                            },
                          ),
                        ),
                        // obscureText sẽ được điều khiển bởi biến trạng thái
                        obscureText: !_isPasswordVisible,
                      ),
                      const SizedBox(height: 24),
                      // Nút Đăng nhập
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _login,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF007BFF),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 3,
                            ),
                          )
                              : const Text(
                            'ĐĂNG NHẬP',
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8), // Thêm khoảng cách nhỏ

                      // === NÚT QUÊN MẬT KHẨU (ĐÃ DI CHUYỂN VÀO ĐÂY) ===
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Vui lòng liên hệ tới văn phòng Giáo dục và Đào tạo trong thời gian sớm nhất để có thể hỗ trợ lấy lại mật khẩu.')),
                            );
                          },
                          child: const Text(
                            'Quên mật khẩu ?',
                            style: TextStyle(
                              color: Color(0xFF007BFF), // Đổi màu cho hợp với nền trắng
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ), // KẾT THÚC KHUNG TRẮNG
              ],
            ),
          ),
        ),
      ),
    );
  }
}