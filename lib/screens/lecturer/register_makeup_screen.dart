import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:frontend_app/models/session.dart';

class RegisterMakeupScreen extends StatelessWidget {
  const RegisterMakeupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Session session = Get.arguments; // Nhận cả buổi học
    return Scaffold(
      appBar: AppBar(title: Text('Đăng ký dạy bù')),
      body: Center(child: Text('Form đăng ký dạy bù cho buổi ${session.sessionId}')),
    );
  }
}