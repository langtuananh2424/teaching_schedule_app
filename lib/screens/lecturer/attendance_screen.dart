import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AttendanceScreen extends StatelessWidget {
  const AttendanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final int sessionId = Get.arguments; // Nhận sessionId
    return Scaffold(
      appBar: AppBar(title: Text('Điểm danh cho buổi $sessionId')),
      body: Center(child: Text('Giao diện điểm danh')),
    );
  }
}