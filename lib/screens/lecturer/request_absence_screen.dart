import 'package:flutter/material.dart';
import 'package:frontend_app/models/schedule.dart';
import 'package:frontend_app/main.dart';

import '../../utils/app_utils.dart';
import '../schedule_screen.dart';

// ĐỔI TÊN: AbsenceRegistrationScreen -> RequestAbsenceScreen
class RequestAbsenceScreen extends StatelessWidget {
  final Schedule schedule;

  RequestAbsenceScreen({required this.schedule});

  // Widget Lịch Tuần
  Widget _buildDetailWeekCalendar(BuildContext context) {
    return Container(
      color: Theme.of(context).primaryColor,
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Column(
        children: [
          const Text(
            'Tháng 9, năm 2025',
            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 10),
          Row(
            children: List.generate(7, (index) {
              final List<String> daysOfWeek = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];
              final List<String> dates = ['19', '20', '21', '22', '23', '24', '25'];
              bool isSelected = index == 1;
              Color dayColor = isSelected ? Colors.red : Colors.white;

              return Expanded(
                child: Column(
                  children: [
                    Text(daysOfWeek[index], style: TextStyle(color: dayColor, fontWeight: FontWeight.bold, fontSize: 15)),
                    const SizedBox(height: 8),
                    Text(dates[index], style: TextStyle(color: dayColor, fontWeight: FontWeight.w600)),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  // Widget thông tin buổi học
  Widget _buildLessonInfoBlock() {
    Color statusColor;
    switch (schedule.status) {
      case 'Hoàn thành':
        statusColor = AppColors.statusCompleted;
        break;
      case 'Sắp diễn ra':
        statusColor = AppColors.statusUpcoming;
        break;
      case 'Dạy bù':
        statusColor = AppColors.statusMakeup;
        break;
      case 'Nghỉ':
        statusColor = AppColors.statusCancelled;
        break;
      default:
        statusColor = Colors.black;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: AppColors.lightBlueBackground.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                schedule.time,
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.red.shade700),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      schedule.subject,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      softWrap: true,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      schedule.room,
                      style: TextStyle(color: Colors.grey.shade800, fontSize: 16),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text(
                'Trạng thái: ',
                style: TextStyle(color: Colors.grey.shade700, fontSize: 15),
              ),
              Text(
                schedule.status,
                style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 15),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            const Text('Quay lại'),
            const Spacer(),
            CircleAvatar(
              backgroundColor: Colors.grey.shade300,
              radius: 18,
              child: const Icon(Icons.person, color: Colors.blue),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          _buildDetailWeekCalendar(context),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLessonInfoBlock(),
                  const SizedBox(height: 20),

                  const Text('Lý do nghỉ:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 8),
                  const TextField(
                    maxLines: 4,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(8))),
                      contentPadding: EdgeInsets.all(10),
                    ),
                  ),
                  const SizedBox(height: 20),

                  const Text('Minh chứng (Tùy chọn)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade400),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Chọn file...', style: TextStyle(color: Colors.grey.shade700)),
                        ElevatedButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Mở trình duyệt file để chọn minh chứng')),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey.shade300,
                            foregroundColor: Colors.black,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                          ),
                          child: const Text('browse'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),

                  Row(
                    children: [
                      Expanded(
                        child: _buildSubmitButton(
                            'Gửi yêu cầu',
                            Colors.orange.shade700,
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Đã gửi yêu cầu đăng ký nghỉ')),
                              );
                            }
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: _buildSubmitButton(
                            'Quay lại',
                            Colors.blue.shade700,
                            onPressed: () => Navigator.pop(context)
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton(String text, Color color, {VoidCallback? onPressed}) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Text(
          text,
          style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
