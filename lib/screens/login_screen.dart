import 'package:flutter/material.dart';
import '../services/api_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController(text: 'admin@thuyloi.edu.vn');
  final _passwordController = TextEditingController(text: 'admin123');
  bool _loading = false;
  String? _error;

  Future<void> _login() async {
    setState(() { _loading = true; _error = null; });
    final ok = await ApiService.login(_emailController.text.trim(), _passwordController.text.trim());
    setState(() => _loading = false);
    if (ok) {
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      setState(() => _error = 'Đăng nhập thất bại — kiểm tra email/mật khẩu');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF2F56A8), Color(0xFF0E2038)],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 40),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 140,
                  height: 140,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.08),
                    shape: BoxShape.circle,
                  ),
                  child: Container(
                    width: 160,
                    height: 160,
                    decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                    padding: const EdgeInsets.all(8.0),
                    child: ClipOval(child: Image.asset('assets/images/logo_dhtl.png', fit: BoxFit.contain)),
                  ),
                ),
                const SizedBox(height: 18),
                const Text('Hệ thống Quản lý\nLịch trình giảng dạy', textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
                const SizedBox(height: 28),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(children: [
                    const Text('Đăng nhập', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 16),
                    _buildInput(controller: _emailController, hint: 'Email', icon: Icons.person_outline),
                    const SizedBox(height: 12),
                    _buildInput(controller: _passwordController, hint: 'Mật khẩu', icon: Icons.lock_outline, obscure: true),
                    const SizedBox(height: 16),
                    if (_error != null) ...[ Text(_error!, style: const TextStyle(color: Colors.red)), const SizedBox(height: 8) ],
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _loading ? null : _login,
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0DA6FF), padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                        child: _loading ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('ĐĂNG NHẬP', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextButton(onPressed: () {}, child: const Text('Quên mật khẩu ?')),
                  ]),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInput({required TextEditingController controller, required String hint, required IconData icon, bool obscure = false}) {
    return Container(
      decoration: BoxDecoration(color: const Color(0xFFF5F7FA), borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 6, offset: const Offset(0, 4))]),
      child: TextField(controller: controller, obscureText: obscure, decoration: InputDecoration(prefixIcon: Icon(icon), hintText: hint, border: InputBorder.none, contentPadding: const EdgeInsets.symmetric(vertical: 14))),
    );
  }
}
