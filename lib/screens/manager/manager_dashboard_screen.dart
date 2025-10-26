import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/absence_request.dart';
import '../../models/makeup_session.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';
import 'reports_screen.dart';
import 'request_approval_screen.dart';

class ManagerDashboardScreen extends StatefulWidget {
  const ManagerDashboardScreen({super.key});

  @override
  State<ManagerDashboardScreen> createState() => _ManagerDashboardScreenState();
}

class _ManagerDashboardScreenState extends State<ManagerDashboardScreen> {
  int _selectedIndex = 0;

  final List<Widget> _widgetOptions = <Widget>[
    const DashboardContent(), // Nội dung chính của dashboard
    const ReportsScreen(),
    const Center(child: Text('Tài khoản')), // Placeholder cho màn hình Profile
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final userName = Provider.of<AuthService>(context, listen: false).userName;
    return Scaffold(
      appBar: AppBar(
        title: Text('Chào, ${userName ?? 'Quản lý'}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => Provider.of<AuthService>(context, listen: false).logout(),
          )
        ],
      ),
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Trang chủ'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Báo cáo'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Tài khoản'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Theme.of(context).primaryColor,
        onTap: _onItemTapped,
      ),
    );
  }
}

// Chuyển DashboardContent thành StatefulWidget để gọi API
class DashboardContent extends StatefulWidget {
  const DashboardContent({super.key});

  @override
  State<DashboardContent> createState() => _DashboardContentState();
}

class _DashboardContentState extends State<DashboardContent> {
  late Future<DashboardSummary> _summaryFuture;
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  void _fetchData() {
    final token = Provider.of<AuthService>(context, listen: false).token;
    if (token != null) {
      _summaryFuture = _apiService.getDashboardSummary(token);
    } else {
      _summaryFuture = Future.error('Không tìm thấy token xác thực.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DashboardSummary>(
      future: _summaryFuture,
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
        if (snapshot.hasData) {
          return _buildDashboardUI(snapshot.data!);
        }
        return const Center(child: Text('Không có dữ liệu.'));
      },
    );
  }

  // Giao diện chính của dashboard, giờ sẽ nhận dữ liệu động
  Widget _buildDashboardUI(DashboardSummary summary) {
    return RefreshIndicator(
      onRefresh: () async {
        setState(() {
          _fetchData();
        });
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Tổng quan nhanh', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildDashboardCard(
                      summary.pendingAbsenceCount.toString(), 'Yêu cầu nghỉ chờ duyệt', context, RequestType.absence),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildDashboardCard(
                      summary.pendingMakeupCount.toString(), 'Yêu cầu dạy bù chờ duyệt', context, RequestType.makeup),
                ),
              ],
            ),

            // Chỉ hiển thị nếu có yêu cầu
            if (summary.recentRequests.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),
                  const Text('Cần phê duyệt gần đây', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  // Vòng lặp để hiển thị các yêu cầu gần đây từ API
                  ...summary.recentRequests.map((request) {
                    if (request is AbsenceRequest) {
                      return _buildRequestCard(
                          '[Nghỉ dạy] GV: ${request.lecturerName}',
                          'Môn: ${request.subjectName}\n${DateFormat('dd/MM/yyyy').format(request.sessionDate)}',
                          context);
                    }
                    if (request is MakeupSession) {
                      return _buildRequestCard(
                          '[Dạy bù] GV: ${request.lecturerName}',
                          'Môn: ${request.subjectName}\n${DateFormat('dd/MM/yyyy').format(request.makeupDate)}',
                          context);
                    }
                    return const SizedBox.shrink(); // Trả về widget rỗng nếu không khớp
                  }).toList(),
                ],
              ),
          ],
        ),
      ),
    );
  }

  // Các hàm helper giữ nguyên
  Widget _buildDashboardCard(String count, String label, BuildContext context, RequestType type) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => RequestApprovalScreen(initialTab: type)),
        ).then((_) => setState(() => _fetchData())); // Tải lại dữ liệu khi quay về
      },
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text(count, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(label, textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRequestCard(String title, String subtitle, BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          // TODO: Điều hướng đến màn hình chi tiết yêu cầu
        },
      ),
    );
  }
}