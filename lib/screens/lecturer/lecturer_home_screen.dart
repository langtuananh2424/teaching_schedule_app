import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/session.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';

class LecturerHomeScreen extends StatefulWidget {
  const LecturerHomeScreen({super.key});

  @override
  State<LecturerHomeScreen> createState() => _LecturerHomeScreenState();
}

class _LecturerHomeScreenState extends State<LecturerHomeScreen> {
  late Future<List<Session>> _sessionsFuture;
  final ApiService _apiService = ApiService();
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  void _fetchData() {
    final token = Provider.of<AuthService>(context, listen: false).token;
    if (token != null) {
      setState(() {
        _sessionsFuture = _apiService.getSessions(token, _selectedDate);
      });
    } else {
      setState(() {
        _sessionsFuture = Future.error('Không tìm thấy token xác thực.');
      });
    }
  }

  void _onDateSelected(DateTime date) {
    setState(() {
      _selectedDate = date;
    });
    _fetchData();
  }

  void _goToPreviousWeek() {
    setState(() {
      _selectedDate = _selectedDate.subtract(const Duration(days: 7));
    });
    _fetchData();
  }

  void _goToNextWeek() {
    setState(() {
      _selectedDate = _selectedDate.add(const Duration(days: 7));
    });
    _fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () { /* Điều hướng đến trang hồ sơ */ },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => Provider.of<AuthService>(context, listen: false).logout(),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildCalendarHeader(),
          const Divider(height: 1, color: Colors.grey),
          Expanded(
            child: FutureBuilder<List<Session>>(
              future: _sessionsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text('Đã xảy ra lỗi: ${snapshot.error}'),
                    ),
                  );
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('Không có lịch dạy cho ngày ${DateFormat('dd/MM').format(_selectedDate)}.'));
                }
                final sessions = snapshot.data!;
                return ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: sessions.length,
                  itemBuilder: (context, index) {
                    return _buildSessionCard(sessions[index]);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // CẬP NHẬT LẠI WIDGET NÀY
  Widget _buildCalendarHeader() {
    final today = DateTime.now();
    DateTime startOfWeek = _selectedDate.subtract(Duration(days: _selectedDate.weekday - 1));

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      color: Colors.white,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: _goToPreviousWeek,
              ),
              Expanded(
                child: Text(
                  'Tháng ${DateFormat.M('vi_VN').format(_selectedDate)}, năm ${DateFormat.y('vi_VN').format(_selectedDate)}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: _goToNextWeek,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(6, (index) {
              final date = startOfWeek.add(Duration(days: index));
              final dayOfWeek = DateFormat.E('vi_VN').format(date);
              final dayOfMonth = DateFormat.d('vi_VN').format(date);

              // Tách riêng logic: isToday để bôi đỏ, isSelected để vẽ vòng tròn
              final isToday = date.year == today.year && date.month == today.month && date.day == today.day;
              final isSelected = date.year == _selectedDate.year && date.month == _selectedDate.month && date.day == _selectedDate.day;

              return GestureDetector(
                onTap: () => _onDateSelected(date),
                child: Container(
                  padding: const EdgeInsets.all(4.0),
                  // Vẽ vòng tròn nếu ngày được chọn
                  child: Column(
                    children: [
                      Text(dayOfWeek, style: const TextStyle(fontSize: 14)),
                      const SizedBox(height: 4),
                      Text(
                        dayOfMonth,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          // Chỉ bôi đỏ nếu là ngày hôm nay
                          color: isToday ? Colors.red : Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildSessionCard(Session session) {
    // ... (Hàm này giữ nguyên không đổi)
    final statusDisplay = session.statusDisplay;
    final startTime = DateFormat('H:mm').format(session.sessionDate);

    return Card(/*...*/);
  }
}