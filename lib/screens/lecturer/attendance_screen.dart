import 'package:flutter/material.dart';

class AttendanceScreen extends StatelessWidget {
  const AttendanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Điểm danh sinh viên')),
      body: const Center(child: Text('Danh sách sinh viên để điểm danh')),
    );
  }
}