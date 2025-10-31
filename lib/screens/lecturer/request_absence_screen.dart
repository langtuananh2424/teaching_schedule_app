import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:frontend_app/models/session.dart';

class RequestAbsenceScreen extends StatelessWidget {
  const RequestAbsenceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Session session = Get.arguments; // Nhận cả buổi học
    return Scaffold(
      appBar: AppBar(title: Text('Đăng ký nghỉ')),
      body: Center(child: Text('Form đăng ký nghỉ cho buổi ${session.sessionId}')),
    );
  }
}