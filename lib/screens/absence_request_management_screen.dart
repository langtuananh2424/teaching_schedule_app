import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/absence_request.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';

class AbsenceRequestManagementScreen extends StatefulWidget {
  const AbsenceRequestManagementScreen({super.key});

  @override
  State<AbsenceRequestManagementScreen> createState() =>
      _AbsenceRequestManagementScreenState();
}

class _AbsenceRequestManagementScreenState
    extends State<AbsenceRequestManagementScreen> {
  late Future<List<AbsenceRequest>> _requestsFuture;
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _loadRequests();
  }

  Future<void> _loadRequests() async {
    final token = context.read<AuthService>().token;
    if (token != null) {
      setState(() {
        _requestsFuture = _apiService.getAbsenceRequests(token);
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
    AbsenceRequest request,
    String status,
  ) async {
    final token = context.read<AuthService>().token;
    if (token == null) return;

    try {
      await _apiService.updateAbsenceRequestManagerApproval(
        token,
        request.id,
        status,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Cập nhật trạng thái thành công'),
          backgroundColor: Colors.green,
        ),
      );

      _loadRequests();
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
    AbsenceRequest request,
    String status,
  ) async {
    final token = context.read<AuthService>().token;
    if (token == null) return;

    try {
      await _apiService.updateAbsenceRequestAcademicAffairsApproval(
        token,
        request.id,
        status,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Cập nhật trạng thái thành công'),
          backgroundColor: Colors.green,
        ),
      );

      _loadRequests();
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
      appBar: AppBar(title: const Text('Quản lý Đơn xin nghỉ')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.event_busy, size: 32),
                const SizedBox(width: 10),
                const Text(
                  'Danh sách Đơn xin nghỉ',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: _loadRequests,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Làm mới'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: FutureBuilder<List<AbsenceRequest>>(
                future: _requestsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text('Lỗi: ${snapshot.error}'));
                  }

                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                      child: Text('Không có đơn xin nghỉ nào'),
                    );
                  }

                  final requests = snapshot.data!;

                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      headingTextStyle: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                      columnSpacing: 20,
                      columns: const [
                        DataColumn(label: Text('STT')),
                        DataColumn(label: Text('Giảng viên')),
                        DataColumn(label: Text('Môn học')),
                        DataColumn(label: Text('Lớp')),
                        DataColumn(label: Text('Ngày nghỉ')),
                        DataColumn(label: Text('Tiết')),
                        DataColumn(label: Text('Lý do')),
                        DataColumn(label: Text('Trưởng khoa')),
                        DataColumn(label: Text('Phòng ĐT')),
                        DataColumn(label: Text('Thao tác')),
                      ],
                      rows: List<DataRow>.generate(requests.length, (index) {
                        final request = requests[index];
                        return DataRow(
                          cells: [
                            DataCell(Text('${index + 1}')),
                            DataCell(Text(request.lecturerName)),
                            DataCell(Text(request.subjectName)),
                            DataCell(Text(request.className)),
                            DataCell(
                              Text(
                                DateFormat(
                                  'dd/MM/yyyy',
                                ).format(request.sessionDate),
                              ),
                            ),
                            DataCell(
                              Text(
                                'Tiết ${request.startPeriod}-${request.endPeriod}',
                              ),
                            ),
                            DataCell(
                              SizedBox(
                                width: 150,
                                child: Text(
                                  request.reason,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 2,
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
                                    request.managerStatus,
                                  ).withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  _getStatusText(request.managerStatus),
                                  style: TextStyle(
                                    color: _getStatusColor(
                                      request.managerStatus,
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
                                    request.academicAffairsStatus,
                                  ).withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  _getStatusText(request.academicAffairsStatus),
                                  style: TextStyle(
                                    color: _getStatusColor(
                                      request.academicAffairsStatus,
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
                                  if (request.managerStatus == 'PENDING')
                                    PopupMenuButton<String>(
                                      tooltip: 'Duyệt (Trưởng khoa)',
                                      icon: const Icon(
                                        Icons.approval,
                                        color: Colors.blue,
                                      ),
                                      onSelected: (value) {
                                        _updateManagerApproval(request, value);
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
                                  if (request.academicAffairsStatus ==
                                      'PENDING')
                                    PopupMenuButton<String>(
                                      tooltip: 'Duyệt (Phòng ĐT)',
                                      icon: const Icon(
                                        Icons.admin_panel_settings,
                                        color: Colors.orange,
                                      ),
                                      onSelected: (value) {
                                        _updateAcademicAffairsApproval(
                                          request,
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
