import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';
import '../../models/absence_request.dart';

class AbsenceHistoryScreen extends StatefulWidget {
  const AbsenceHistoryScreen({super.key});

  @override
  State<AbsenceHistoryScreen> createState() => _AbsenceHistoryScreenState();
}

class _AbsenceHistoryScreenState extends State<AbsenceHistoryScreen> {
  final _apiService = ApiService();
  final _searchController = TextEditingController();

  String? _selectedStatus;
  DateTime? _startDate;
  DateTime? _endDate;
  List<AbsenceRequest> _allRequests = [];
  List<AbsenceRequest> _filteredRequests = [];
  bool _isLoading = false;

  final List<String> _statusOptions = [
    'Tất cả',
    'PENDING',
    'APPROVED',
    'REJECTED',
  ];

  final Map<String, String> _statusDisplayNames = {
    'PENDING': 'Chờ duyệt',
    'APPROVED': 'Đã duyệt',
    'REJECTED': 'Từ chối',
  };

  final Map<String, Color> _statusColors = {
    'PENDING': Colors.orange,
    'APPROVED': Colors.green,
    'REJECTED': Colors.red,
  };

  @override
  void initState() {
    super.initState();
    _fetchRequests();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchRequests() async {
    setState(() => _isLoading = true);

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final token = authService.token;
      final userRole = authService.userRole;

      if (token == null) {
        throw Exception('Token không hợp lệ');
      }

      print('🔍 Fetching absence requests...');
      print('👤 User role: $userRole');

      // Lấy tất cả requests
      final allRequests = await _apiService.getAbsenceRequests(token);

      print('✅ Fetched ${allRequests.length} total absence requests');

      // Lọc theo department nếu là Manager
      List<AbsenceRequest> filteredRequests = allRequests;

      if (userRole == 'ROLE_MANAGER') {
        try {
          print('🔍 [MANAGER FILTER] Starting department filtering...');
          
          // Lấy email của manager từ token
          final email = authService.userEmail;
          print('📧 Manager email: $email');
          
          if (email == null) {
            print('❌ Manager email is null - cannot filter by department');
            filteredRequests = [];
            print('⚠️ Returning empty list for security');
          } else {
            // Lấy danh sách tất cả lecturers
            print('🔍 Fetching all lecturers from /api/lecturers');
            final allLecturersData =
                await _apiService.get('api/lecturers', token: token) as List;
            
            print('📊 Total lecturers from API: ${allLecturersData.length}');
            
            // Tìm manager trong danh sách lecturers để lấy department
            final managerData = allLecturersData
                .where((l) => l['email'] == email)
                .toList();

            if (managerData.isEmpty) {
              print('❌ No lecturer found with email: $email');
              filteredRequests = [];
              print('⚠️ Returning empty list for security');
            } else {
              // Lấy department của manager
              final managerDepartment = managerData.first['departmentName'] ?? 
                                       managerData.first['department_name'];
              
              print('👔 Manager department: $managerDepartment');

              if (managerDepartment == null || managerDepartment.toString().isEmpty) {
                print('❌ Manager department is null or empty');
                filteredRequests = [];
              } else {
                // Lấy danh sách tên lecturers trong cùng khoa
                final departmentLecturerNames = <String>{};
                for (var lecturer in allLecturersData) {
                  final deptName =
                      lecturer['departmentName'] ?? lecturer['department_name'];
                  if (deptName == managerDepartment) {
                    final lecturerName =
                        lecturer['fullName'] ?? lecturer['full_name'];
                    if (lecturerName != null && lecturerName.toString().isNotEmpty) {
                      departmentLecturerNames.add(lecturerName.toString());
                    }
                  }
                }

                print('📊 Department has ${departmentLecturerNames.length} lecturers');
                print('📝 Lecturer names in department: $departmentLecturerNames');

                // Debug: Kiểm tra lecturerName trong requests
                print('📝 Checking lecturerNames in requests:');
                for (var i = 0; i < allRequests.length && i < 5; i++) {
                  print('   - Request ${allRequests[i].id}: name=${allRequests[i].lecturerName}');
                }

                // ✅ Lọc requests theo tên lecturer (department-based)
                filteredRequests = allRequests.where((r) {
                  final matches = departmentLecturerNames.contains(r.lecturerName);
                  if (matches) {
                    print('   ✓ Request ${r.id} matches: ${r.lecturerName}');
                  }
                  return matches;
                }).toList();

                print(
                  '✅ Filtered to ${filteredRequests.length} requests for department $managerDepartment',
                );
              }
            }
          }
        } catch (e, stackTrace) {
          print('❌ Error filtering by department: $e');
          print('Stack trace: $stackTrace');
          // Nếu lỗi, trả về danh sách rỗng để bảo mật
          filteredRequests = [];
        }
      }

      setState(() {
        _allRequests = filteredRequests;
        _applyFilters();
        _isLoading = false;
      });
    } catch (e) {
      print('❌ Error fetching absence requests: $e');

      setState(() {
        _allRequests = []; // Fallback to empty list
        _filteredRequests = [];
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Backend chưa có dữ liệu yêu cầu nghỉ'),
            backgroundColor: Colors.orange,
            action: SnackBarAction(
              label: 'OK',
              textColor: Colors.white,
              onPressed: () {},
            ),
          ),
        );
      }
    }
  }

  void _applyFilters() {
    List<AbsenceRequest> filtered = List.from(_allRequests);

    // Filter theo status
    if (_selectedStatus != null && _selectedStatus != 'Tất cả') {
      filtered = filtered.where((r) => r.status == _selectedStatus).toList();
    }

    // Filter theo ngày
    if (_startDate != null) {
      filtered = filtered.where((r) {
        return r.sessionDate.isAfter(_startDate!) ||
            r.sessionDate.isAtSameMomentAs(_startDate!);
      }).toList();
    }

    if (_endDate != null) {
      filtered = filtered.where((r) {
        return r.sessionDate.isBefore(_endDate!.add(const Duration(days: 1)));
      }).toList();
    }

    // Filter theo search text (tìm trong tên giảng viên, môn học)
    final searchText = _searchController.text.toLowerCase().trim();
    if (searchText.isNotEmpty) {
      filtered = filtered.where((r) {
        final lecturerName = r.lecturerName.toLowerCase();
        final subjectName = r.subjectName.toLowerCase();
        return lecturerName.contains(searchText) ||
            subjectName.contains(searchText);
      }).toList();
    }

    // Sắp xếp theo ngày mới nhất
    filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    setState(() {
      _filteredRequests = filtered;
    });
  }

  Future<void> _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      initialDateRange: _startDate != null && _endDate != null
          ? DateTimeRange(start: _startDate!, end: _endDate!)
          : null,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).primaryColor,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
        _applyFilters();
      });
    }
  }

  void _clearDateRange() {
    setState(() {
      _startDate = null;
      _endDate = null;
      _applyFilters();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lịch sử yêu cầu nghỉ'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchRequests,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilterSection(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _buildRequestList(),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.grey.shade50,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search bar
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Tìm kiếm theo tên giảng viên, môn học...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        _applyFilters();
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
            onChanged: (_) => _applyFilters(),
          ),
          const SizedBox(height: 12),

          // Status filter và Date range
          Row(
            children: [
              // Status dropdown
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedStatus ?? 'Tất cả',
                  decoration: InputDecoration(
                    labelText: 'Trạng thái',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                  items: _statusOptions.map((status) {
                    return DropdownMenuItem(
                      value: status,
                      child: Text(
                        status == 'Tất cả'
                            ? status
                            : _statusDisplayNames[status] ?? status,
                        style: const TextStyle(fontSize: 14),
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedStatus = value == 'Tất cả' ? null : value;
                      _applyFilters();
                    });
                  },
                ),
              ),
              const SizedBox(width: 12),

              // Date range button
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _selectDateRange,
                  icon: const Icon(Icons.date_range, size: 18),
                  label: Text(
                    _startDate != null && _endDate != null
                        ? '${DateFormat('dd/MM').format(_startDate!)} - ${DateFormat('dd/MM').format(_endDate!)}'
                        : 'Chọn ngày',
                    style: const TextStyle(fontSize: 13),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),

              if (_startDate != null || _endDate != null) ...[
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.clear, size: 20),
                  onPressed: _clearDateRange,
                  tooltip: 'Xóa bộ lọc ngày',
                ),
              ],
            ],
          ),

          // Result count
          const SizedBox(height: 8),
          Text(
            'Tìm thấy ${_filteredRequests.length} yêu cầu',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade700,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequestList() {
    if (_filteredRequests.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'Không tìm thấy yêu cầu nào',
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: () {
                setState(() {
                  _selectedStatus = null;
                  _startDate = null;
                  _endDate = null;
                  _searchController.clear();
                  _applyFilters();
                });
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Xóa bộ lọc'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredRequests.length,
      itemBuilder: (context, index) {
        final request = _filteredRequests[index];
        return _buildRequestCard(request);
      },
    );
  }

  Widget _buildRequestCard(AbsenceRequest request) {
    final statusColor = _statusColors[request.status] ?? Colors.grey;
    final statusText = _statusDisplayNames[request.status] ?? request.status;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _showRequestDetail(request),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Status badge và Date
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: statusColor, width: 1.5),
                    ),
                    child: Text(
                      statusText,
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  Text(
                    DateFormat('dd/MM/yyyy').format(request.sessionDate),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Lecturer info
              Row(
                children: [
                  Icon(Icons.person, size: 18, color: Colors.grey.shade600),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      request.lecturerName,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Subject & Class
              Row(
                children: [
                  Icon(Icons.book, size: 18, color: Colors.grey.shade600),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${request.subjectName} - ${request.className}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade800,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Time & Room
              Row(
                children: [
                  Icon(Icons.schedule, size: 18, color: Colors.grey.shade600),
                  const SizedBox(width: 8),
                  Text(
                    'Tiết ${request.startPeriod}-${request.endPeriod}',
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                  ),
                  const SizedBox(width: 16),
                  Icon(
                    Icons.location_on,
                    size: 18,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    request.classroom,
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                  ),
                ],
              ),

              // Reason
              if (request.reason.isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.note, size: 16, color: Colors.grey.shade700),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          request.reason,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade800,
                            fontStyle: FontStyle.italic,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // Created at (footer)
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Tạo: ${DateFormat('dd/MM/yyyy HH:mm').format(request.createdAt)}',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 14,
                    color: Colors.grey.shade400,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showRequestDetail(AbsenceRequest request) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) {
          return SingleChildScrollView(
            controller: scrollController,
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle bar
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Title
                const Text(
                  'Chi tiết yêu cầu nghỉ',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),

                // Status
                _buildDetailRow(
                  'Trạng thái',
                  _statusDisplayNames[request.status] ?? request.status,
                  icon: Icons.flag,
                  valueColor: _statusColors[request.status],
                ),
                const Divider(height: 32),

                // Basic info
                _buildDetailRow('Giảng viên', request.lecturerName),
                _buildDetailRow('Môn học', request.subjectName),
                _buildDetailRow('Lớp', request.className),
                _buildDetailRow(
                  'Ngày nghỉ',
                  DateFormat('dd/MM/yyyy').format(request.sessionDate),
                  icon: Icons.calendar_today,
                ),
                _buildDetailRow(
                  'Tiết',
                  'Tiết ${request.startPeriod} - ${request.endPeriod}',
                  icon: Icons.schedule,
                ),
                _buildDetailRow(
                  'Phòng',
                  request.classroom,
                  icon: Icons.location_on,
                ),
                const Divider(height: 32),

                // Reason
                const Text(
                  'Lý do nghỉ:',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    request.reason.isEmpty ? 'Không có lý do' : request.reason,
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
                const SizedBox(height: 16),

                // Approver note (if approved/rejected)
                if (request.approverName != null &&
                    request.approverName!.isNotEmpty) ...[
                  const Text(
                    'Người duyệt:',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Text(
                      request.approverName!,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Timestamps
                const Divider(height: 32),
                _buildDetailRow(
                  'Ngày tạo',
                  DateFormat('dd/MM/yyyy HH:mm').format(request.createdAt),
                  icon: Icons.access_time,
                ),

                const SizedBox(height: 24),

                // Close button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Đóng', style: TextStyle(fontSize: 16)),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailRow(
    String label,
    String value, {
    IconData? icon,
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 18, color: Colors.grey.shade600),
            const SizedBox(width: 8),
          ],
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: valueColor ?? Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
