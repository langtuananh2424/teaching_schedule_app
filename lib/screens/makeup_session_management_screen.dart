import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/makeup_session.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';

class MakeupSessionManagementScreen extends StatefulWidget {
  const MakeupSessionManagementScreen({super.key});

  @override
  State<MakeupSessionManagementScreen> createState() =>
      _MakeupSessionManagementScreenState();
}

class _MakeupSessionManagementScreenState
    extends State<MakeupSessionManagementScreen> {
  late Future<List<MakeupSession>> _sessionsFuture;
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _loadSessions();
  }

  Future<void> _loadSessions() async {
    final token = context.read<AuthService>().token;
    if (token != null) {
      setState(() {
        _sessionsFuture = _apiService.getMakeupSessions(token);
      });
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'PENDING':
        return 'Chờ duyệt';
      case 'APPROVED':
        return 'Đã duyệt';
      case 'REJECTED':
        return 'Đã từ chối';
      default:
        return status;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'PENDING':
        return Colors.orange;
      case 'APPROVED':
        return Colors.green;
      case 'REJECTED':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Future<void> _updateManagerApproval(
    MakeupSession session,
    String status,
  ) async {
    final token = context.read<AuthService>().token;
    if (token == null) return;

    try {
      await _apiService.updateMakeupSessionManagerApproval(
        token,
        session.makeupSessionId,
        status,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Cập nhật trạng thái thành công'),
          backgroundColor: Colors.green,
        ),
      );

      _loadSessions();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _updateAcademicAffairsApproval(
    MakeupSession session,
    String status,
  ) async {
    final token = context.read<AuthService>().token;
    if (token == null) return;

    try {
      await _apiService.updateMakeupSessionAcademicAffairsApproval(
        token,
        session.makeupSessionId,
        status,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Cập nhật trạng thái thành công'),
          backgroundColor: Colors.green,
        ),
      );

      _loadSessions();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quản lý Yêu cầu Dạy bù')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.event_available, size: 32),
                const SizedBox(width: 10),
                const Text(
                  'Danh sách Yêu cầu Dạy bù',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: _loadSessions,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Làm mới'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: FutureBuilder<List<MakeupSession>>(
                future: _sessionsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text('Lỗi: ${snapshot.error}'));
                  }

                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                      child: Text('Không có yêu cầu dạy bù nào'),
                    );
                  }

                  final sessions = snapshot.data!;

                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      headingTextStyle: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                      columnSpacing: 20,
                      columns: const [
                        DataColumn(label: Text('STT')),
                        DataColumn(label: Text('ID buổi nghỉ')),
                        DataColumn(label: Text('Ngày dạy bù')),
                        DataColumn(label: Text('Tiết dạy bù')),
                        DataColumn(label: Text('Phòng')),
                        DataColumn(label: Text('Ngày tạo')),
                        DataColumn(label: Text('Trưởng khoa')),
                        DataColumn(label: Text('Phòng ĐT')),
                        DataColumn(label: Text('Thao tác')),
                      ],
                      rows: List<DataRow>.generate(sessions.length, (index) {
                        final session = sessions[index];
                        return DataRow(
                          cells: [
                            DataCell(Text('${index + 1}')),
                            DataCell(Text('#${session.absentSessionId}')),
                            DataCell(
                              Text(
                                DateFormat(
                                  'dd/MM/yyyy',
                                ).format(session.makeupDate),
                              ),
                            ),
                            DataCell(
                              Text(
                                'Tiết ${session.makeupStartPeriod}-${session.makeupEndPeriod}',
                              ),
                            ),
                            DataCell(Text(session.makeupClassroom)),
                            DataCell(
                              Text(
                                DateFormat(
                                  'dd/MM/yyyy HH:mm',
                                ).format(session.createdAt),
                              ),
                            ),
                            DataCell(
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: _getStatusColor(
                                    session.managerStatus,
                                  ).withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  _getStatusText(session.managerStatus),
                                  style: TextStyle(
                                    color: _getStatusColor(
                                      session.managerStatus,
                                    ),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            DataCell(
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: _getStatusColor(
                                    session.academicAffairsStatus,
                                  ).withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  _getStatusText(session.academicAffairsStatus),
                                  style: TextStyle(
                                    color: _getStatusColor(
                                      session.academicAffairsStatus,
                                    ),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            DataCell(
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (session.managerStatus == 'PENDING')
                                    PopupMenuButton<String>(
                                      tooltip: 'Duyệt (Trưởng khoa)',
                                      icon: const Icon(
                                        Icons.approval,
                                        color: Colors.blue,
                                      ),
                                      onSelected: (value) {
                                        _updateManagerApproval(session, value);
                                      },
                                      itemBuilder: (context) => [
                                        const PopupMenuItem(
                                          value: 'APPROVED',
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.check,
                                                color: Colors.green,
                                              ),
                                              SizedBox(width: 8),
                                              Text('Duyệt (TK)'),
                                            ],
                                          ),
                                        ),
                                        const PopupMenuItem(
                                          value: 'REJECTED',
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.close,
                                                color: Colors.red,
                                              ),
                                              SizedBox(width: 8),
                                              Text('Từ chối (TK)'),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  const SizedBox(width: 4),
                                  if (session.academicAffairsStatus ==
                                      'PENDING')
                                    PopupMenuButton<String>(
                                      tooltip: 'Duyệt (Phòng ĐT)',
                                      icon: const Icon(
                                        Icons.admin_panel_settings,
                                        color: Colors.orange,
                                      ),
                                      onSelected: (value) {
                                        _updateAcademicAffairsApproval(
                                          session,
                                          value,
                                        );
                                      },
                                      itemBuilder: (context) => [
                                        const PopupMenuItem(
                                          value: 'APPROVED',
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.check,
                                                color: Colors.green,
                                              ),
                                              SizedBox(width: 8),
                                              Text('Duyệt (PĐT)'),
                                            ],
                                          ),
                                        ),
                                        const PopupMenuItem(
                                          value: 'REJECTED',
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.close,
                                                color: Colors.red,
                                              ),
                                              SizedBox(width: 8),
                                              Text('Từ chối (PĐT)'),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                ],
                              ),
                            ),
                          ],
                        );
                      }),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
