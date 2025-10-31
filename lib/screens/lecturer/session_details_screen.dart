import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:frontend_app/models/session.dart';
import 'package:frontend_app/models/schedule_status.dart';
import 'package:intl/intl.dart';

class SessionDetailsScreen extends StatelessWidget {
  const SessionDetailsScreen({super.key});

  Widget _buildButton(String text, VoidCallback? onPressed, Color? backgroundColor) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: backgroundColor,
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
        child: Text(text, style: const TextStyle(fontSize: 16)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Session session = Get.arguments;
    final String time = DateFormat('HH:mm').format(session.sessionDate);
    final String date = DateFormat('dd/MM/yyyy').format(session.sessionDate);

    // LOGIC BẬT/TẮT NÚT
    bool luuNoiDungEnabled = false;
    bool diemDanhEnabled = false;
    bool hoanThanhEnabled = false;
    bool dangKyNghiEnabled = false;
    bool dangKyDayBuEnabled = false;

    if (session.status == ScheduleStatus.NOT_TAUGHT) {
      luuNoiDungEnabled = true;
      diemDanhEnabled = true;
      hoanThanhEnabled = true;
      dangKyNghiEnabled = true;
      dangKyDayBuEnabled = false;
    }
    else if (session.status == ScheduleStatus.ABSENT_APPROVED ||
        session.status == ScheduleStatus.ABSENT_UNAPPROVED) {
      luuNoiDungEnabled = false;
      diemDanhEnabled = false;
      hoanThanhEnabled = false;
      dangKyNghiEnabled = false;
      dangKyDayBuEnabled = true;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi Tiết Buổi Học'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              session.assignment.subject.subjectName,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('$time - $date',
                style: const TextStyle(fontSize: 20, color: Colors.red)),
            Text('${session.assignment.studentClass.className} - ${session.classroom}',
                style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),

            TextField(
              readOnly: !luuNoiDungEnabled,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Nội dung buổi học',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),

            // Các nút bấm
            _buildButton(
              'Lưu nội dung',
              luuNoiDungEnabled ? () { /* Logic */ } : null,
              Colors.blue,
            ),
            const SizedBox(height: 12),
            _buildButton(
              'Điểm danh sinh viên',
              diemDanhEnabled ? () { Get.toNamed('/attendance', arguments: session.sessionId); } : null,
              Colors.blue,
            ),
            const SizedBox(height: 12),
            _buildButton(
              'Hoàn thành',
              hoanThanhEnabled ? () { /* Logic */ } : null,
              Colors.green,
            ),
            const SizedBox(height: 12),
            _buildButton(
              'Đăng ký nghỉ',
              dangKyNghiEnabled ? () { Get.toNamed('/request_absence', arguments: session); } : null,
              Colors.orange,
            ),
            const SizedBox(height: 12),
            _buildButton(
              'Đăng ký dạy bù',
              dangKyDayBuEnabled ? () { Get.toNamed('/register_makeup', arguments: session); } : null,
              Colors.orange[700],
            ),
          ],
        ),
      ),
    );
  }
}