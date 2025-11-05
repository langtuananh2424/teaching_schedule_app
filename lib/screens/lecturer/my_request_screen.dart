import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';
import '../../models/absence_request.dart';
import '../../models/makeup_session.dart';
import 'package:intl/intl.dart';

class MyRequestScreen extends StatefulWidget {
  const MyRequestScreen({super.key});

  @override
  State<MyRequestScreen> createState() => _MyRequestScreenState();
}

class _MyRequestScreenState extends State<MyRequestScreen> {
  final _apiService = ApiService();

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Quản lý Yêu cầu'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Yêu cầu nghỉ'),
              Tab(text: 'Yêu cầu dạy bù'),
            ],
          ),
        ),
        body: TabBarView(
          children: [_buildAbsenceRequestsList(), _buildMakeupSessionsList()],
        ),
      ),
    );
  }

  Widget _buildAbsenceRequestsList() {
    final authService = Provider.of<AuthService>(context);
    final token = authService.token;

    if (token == null) {
      return const Center(child: Text('Vui lòng đăng nhập'));
    }

    // TODO: Lấy lecturerId từ AuthService
    final lecturerId = 1; // Tạm thời hardcode

    return FutureBuilder<List<AbsenceRequest>>(
      future: _apiService.getAbsenceRequests(token, lecturerId: lecturerId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                Text('Lỗi: ${snapshot.error}'),
                ElevatedButton(
                  onPressed: () => setState(() {}),
                  child: const Text('Thử lại'),
                ),
              ],
            ),
          );
        }

        final requests = snapshot.data ?? [];

        if (requests.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.inbox, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text('Chưa có yêu cầu nghỉ nào'),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(8.0),
          itemCount: requests.length,
          itemBuilder: (context, index) {
            final request = requests[index];
            return Card(
              child: ListTile(
                title: Text('${request.subjectName} - ${request.className}'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ngày: ${DateFormat('dd/MM/yyyy').format(request.sessionDate)}',
                    ),
                    Text('Lý do: ${request.reason}'),
                    if (request.makeupDate != null)
                      Text(
                        'Dạy bù: ${DateFormat('dd/MM/yyyy').format(request.makeupDate!)}',
                      ),
                  ],
                ),
                trailing: Chip(
                  label: Text(
                    _getStatusText(request.status),
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                  backgroundColor: _getStatusColor(request.status),
                ),
                onTap: () => _showRequestDetail(request),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildMakeupSessionsList() {
    final authService = Provider.of<AuthService>(context);
    final token = authService.token;

    if (token == null) {
      return const Center(child: Text('Vui lòng đăng nhập'));
    }

    final lecturerId = 1; // TODO: Lấy từ AuthService

    return FutureBuilder<List<MakeupSession>>(
      future: _apiService.getMakeupSessions(token, lecturerId: lecturerId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Lỗi: ${snapshot.error}'));
        }

        final sessions = snapshot.data ?? [];

        if (sessions.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.inbox, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text('Chưa có lịch dạy bù nào'),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(8.0),
          itemCount: sessions.length,
          itemBuilder: (context, index) {
            final session = sessions[index];
            return Card(
              child: ListTile(
                title: Text('${session.subjectName} - ${session.className}'),
                subtitle: Text(
                  'Ngày: ${DateFormat('dd/MM/yyyy').format(session.makeupDate)}\n'
                      'Phòng: ${session.classroom}',
                ),
                trailing: Chip(
                  label: Text(
                    _getStatusText(session.status),
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                  backgroundColor: _getStatusColor(session.status),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showRequestDetail(AbsenceRequest request) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Chi tiết yêu cầu'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Môn học', request.subjectName),
              _buildDetailRow('Lớp', request.className),
              _buildDetailRow(
                'Ngày nghỉ',
                DateFormat('dd/MM/yyyy').format(request.sessionDate),
              ),
              _buildDetailRow('Phòng', request.classroom ?? 'N/A'),
              _buildDetailRow('Lý do', request.reason),
              _buildDetailRow('Trạng thái', _getStatusText(request.status)),
              if (request.approverName != null)
                _buildDetailRow('Người duyệt', request.approverName!),
              if (request.makeupDate != null) ...[
                const Divider(),
                const Text(
                  'Thông tin dạy bù:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                _buildDetailRow(
                  'Ngày',
                  DateFormat('dd/MM/yyyy').format(request.makeupDate!),
                ),
                _buildDetailRow('Phòng', request.makeupClassroom ?? 'N/A'),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  String _getStatusText(String status) {
    switch (status.toUpperCase()) {
      case 'PENDING':
        return 'Chờ duyệt';
      case 'APPROVED':
        return 'Đã duyệt';
      case 'REJECTED':
        return 'Từ chối';
      case 'TAUGHT':
        return 'Đã dạy';
      default:
        return status;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'APPROVED':
      case 'TAUGHT':
        return Colors.green;
      case 'PENDING':
        return Colors.orange;
      case 'REJECTED':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}