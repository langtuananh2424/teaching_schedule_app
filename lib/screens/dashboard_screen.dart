import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../widgets/navigation_card.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hệ thống Quản lý Đào tạo',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 20),
          Expanded(
            child: GridView.count(
              crossAxisCount: 3,
              crossAxisSpacing: 20,
              mainAxisSpacing: 20,
              childAspectRatio: 1.2,
              children: [
                NavigationCard(
                  title: 'Quản lý Giảng viên',
                  icon: Icons.people,
                  color: Colors.blue,
                  onTap: () => context.go('/lecturers'),
                ),
                NavigationCard(
                  title: 'Quản lý Sinh viên',
                  icon: Icons.school,
                  color: Colors.green,
                  onTap: () => context.go('/students'),
                ),
                NavigationCard(
                  title: 'Quản lý Lớp học',
                  icon: Icons.class_,
                  color: Colors.indigo,
                  onTap: () => context.go('/classes'),
                ),
                NavigationCard(
                  title: 'Quản lý Môn học',
                  icon: Icons.book,
                  color: Colors.amber,
                  onTap: () => context.go('/subjects'),
                ),
                NavigationCard(
                  title: 'Phân công giảng dạy',
                  icon: Icons.assignment,
                  color: Colors.deepOrange,
                  onTap: () => context.go('/assignments'),
                ),
                NavigationCard(
                  title: 'Quản lý lịch học',
                  icon: Icons.calendar_month,
                  color: Colors.cyan,
                  onTap: () => context.go('/schedules'),
                ),
                NavigationCard(
                  title: 'Duyệt Đơn xin nghỉ',
                  icon: Icons.event_busy,
                  color: Colors.red,
                  onTap: () => context.go('/absence-requests'),
                ),
                NavigationCard(
                  title: 'Duyệt Dạy bù',
                  icon: Icons.event_available,
                  color: Colors.orange,
                  onTap: () => context.go('/makeup-sessions'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
