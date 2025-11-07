import 'package:flutter/material.dart';

class Sidebar extends StatelessWidget {
  final String currentPath;
  final Function(String) onNavigate;

  const Sidebar({
    super.key,
    required this.currentPath,
    required this.onNavigate,
  });

  // Nhóm các menu items theo group
  Map<String, List<Map<String, dynamic>>> _groupNavItems(
    List<Map<String, dynamic>> items,
  ) {
    final grouped = <String, List<Map<String, dynamic>>>{};
    for (var item in items) {
      final group = item['group'] as String;
      if (!grouped.containsKey(group)) {
        grouped[group] = [];
      }
      grouped[group]!.add(item);
    }
    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    final navItems = [
      {
        'path': '/',
        'icon': Icons.dashboard,
        'label': 'Trang chủ',
        'group': 'Tổng quan',
      },
      {
        'path': '/lecturers',
        'icon': Icons.people,
        'label': 'Quản lý Giảng viên',
        'group': 'Quản lý người dùng',
      },
      {
        'path': '/students',
        'icon': Icons.school,
        'label': 'Quản lý Sinh viên',
        'group': 'Quản lý người dùng',
      },
      {
        'path': '/classes',
        'icon': Icons.class_,
        'label': 'Quản lý Lớp học',
        'group': 'Quản lý học tập',
      },
      {
        'path': '/subjects',
        'icon': Icons.book,
        'label': 'Quản lý Môn học',
        'group': 'Quản lý học tập',
      },
      {
        'path': '/assignments',
        'icon': Icons.assignment,
        'label': 'Phân công giảng dạy',
        'group': 'Quản lý lịch học',
      },
      {
        'path': '/schedules',
        'icon': Icons.calendar_month,
        'label': 'Quản lý Lịch học',
        'group': 'Quản lý lịch học',
      },
      {
        'path': '/absence-requests',
        'icon': Icons.event_busy,
        'label': 'Duyệt Đơn xin nghỉ',
        'group': 'Duyệt yêu cầu',
      },
      {
        'path': '/makeup-sessions',
        'icon': Icons.event_available,
        'label': 'Duyệt Dạy bù',
        'group': 'Duyệt yêu cầu',
      },
    ];

    return Container(
      width: 250,
      color: const Color(0xFF2c3e50),
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(20.0),
            child: Text(
              'Quản lý Đào tạo',
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _groupNavItems(navItems).entries
                    .map(
                      (entry) => Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                            child: Text(
                              entry.key.toUpperCase(),
                              style: TextStyle(
                                color: Colors.grey[500],
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ),
                          ...entry.value.map((item) {
                            final bool isActive = currentPath == item['path'];
                            return MouseRegion(
                              cursor: SystemMouseCursors.click,
                              child: Container(
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  color: isActive
                                      ? Colors.blue.withOpacity(0.2)
                                      : Colors.transparent,
                                ),
                                child: ListTile(
                                  leading: Icon(
                                    item['icon'] as IconData,
                                    color: isActive
                                        ? Colors.blue
                                        : Colors.grey[400],
                                    size: 20,
                                  ),
                                  title: Text(
                                    item['label'] as String,
                                    style: TextStyle(
                                      color: isActive
                                          ? Colors.blue
                                          : Colors.grey[400],
                                      fontSize: 14,
                                    ),
                                  ),
                                  dense: true,
                                  visualDensity: VisualDensity.compact,
                                  onTap: () =>
                                      onNavigate(item['path'] as String),
                                ),
                              ),
                            );
                          }).toList(),
                        ],
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
