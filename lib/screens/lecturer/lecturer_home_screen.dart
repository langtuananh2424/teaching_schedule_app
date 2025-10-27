import 'package:flutter/material.dart';

// Màn hình Placeholder
class LecturerHomeScreen extends StatelessWidget {
  const LecturerHomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trang chủ Giảng viên'),
      ),
      body: const Center(
        child: Text('Nội dung trang chủ Giảng viên'),
      ),
    );
  }
}
