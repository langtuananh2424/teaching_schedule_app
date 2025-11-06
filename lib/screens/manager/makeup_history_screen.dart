import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';
import '../../models/makeup_session.dart';

class MakeupHistoryScreen extends StatefulWidget {
  const MakeupHistoryScreen({super.key});

  @override
  State<MakeupHistoryScreen> createState() => _MakeupHistoryScreenState();
}

class _MakeupHistoryScreenState extends State<MakeupHistoryScreen> {
  final _apiService = ApiService();
  final _searchController = TextEditingController();

  String? _selectedStatus;
  DateTime? _startDate;
  DateTime? _endDate;
  List<MakeupSession> _allMakeups = [];
  List<MakeupSession> _filteredMakeups = [];
  bool _isLoading = false;

  final List<String> _statusOptions = [
    'Tất cả',
    'PENDING',
    'APPROVED',
    'REJECTED',
    'TAUGHT',
  ];

  final Map<String, String> _statusDisplayNames = {
    'PENDING': 'Chờ duyệt',
    'APPROVED': 'Đã duyệt',
    'REJECTED': 'Từ chối',
    'TAUGHT': 'Đã dạy',
  };

  final Map<String, Color> _statusColors = {
    'PENDING': Colors.orange,
    'APPROVED': Colors.green,
    'REJECTED': Colors.red,
    'TAUGHT': Colors.blue,
  };

  @override
  void initState() {
    super.initState();
    _fetchMakeups();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchMakeups() async {
    setState(() => _isLoading = true);

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final token = authService.token;
      final userRole = authService.userRole;
      final userId = authService.userId;

      if (token == null) {
        throw Exception('Token không hợp lệ');
      }

      print('🔍 Fetching makeup sessions...');
      print('👤 User role: $userRole');

      final makeups = await _apiService.getMakeupSessions(token);

      print('✅ Fetched ${makeups.length} makeup sessions');

      // Lọc theo department nếu là Manager
      List<MakeupSession> filteredMakeups = makeups;

      if (userRole == 'ROLE_MANAGER' && userId != null) {
        print('👔 Manager detected - filtering by department');

        // Lấy department của Manager
        final managerProfile =
            await _apiService.get('api/lecturers/$userId', token: token)
                as Map<String, dynamic>;

        final managerDepartment = managerProfile['departmentName'];
        print('📌 Manager department: $managerDepartment');

        if (managerDepartment != null) {
          // Lấy danh sách lecturers trong cùng khoa
          final allLecturers =
              await _apiService.get('api/lecturers', token: token) as List;

          final departmentLecturerNames = <String>{};
          for (var lecturer in allLecturers) {
            final deptName =
                lecturer['departmentName'] ?? lecturer['department_name'];
            if (deptName == managerDepartment) {
              final lecturerName =
                  lecturer['fullName'] ?? lecturer['full_name'];
              if (lecturerName != null) {
                departmentLecturerNames.add(lecturerName.toString());
              }
            }
          }

          print(
            '📊 Found ${departmentLecturerNames.length} lecturers in department',
          );

          // Lọc makeup sessions theo lecturers trong khoa
          filteredMakeups = makeups.where((makeup) {
            return departmentLecturerNames.contains(makeup.lecturerName);
          }).toList();

          print(
            '✅ Filtered to ${filteredMakeups.length} makeup sessions in department',
          );
        }
      }

      setState(() {
        _allMakeups = filteredMakeups;
        _applyFilters();
        _isLoading = false;
      });
    } catch (e) {
      print('❌ Error fetching makeup sessions: $e');

      setState(() {
        _allMakeups = []; // Fallback to empty list
        _filteredMakeups = [];
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Backend chưa có dữ liệu lịch dạy bù'),
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
    List<MakeupSession> filtered = List.from(_allMakeups);

    // Filter theo status
    if (_selectedStatus != null && _selectedStatus != 'Tất cả') {
      filtered = filtered.where((m) => m.status == _selectedStatus).toList();
    }

    // Filter theo ngày
    if (_startDate != null) {
      filtered = filtered.where((m) {
        return m.makeupDate.isAfter(_startDate!) ||
            m.makeupDate.isAtSameMomentAs(_startDate!);
      }).toList();
    }

    if (_endDate != null) {
      filtered = filtered.where((m) {
        return m.makeupDate.isBefore(_endDate!.add(const Duration(days: 1)));
      }).toList();
    }

    // Filter theo search text (tìm trong tên giảng viên, môn học)
    final searchText = _searchController.text.toLowerCase().trim();
    if (searchText.isNotEmpty) {
      filtered = filtered.where((m) {
        final lecturerName = m.lecturerName.toLowerCase();
        final subjectName = m.subjectName.toLowerCase();
        return lecturerName.contains(searchText) ||
            subjectName.contains(searchText);
      }).toList();
    }

    // Sắp xếp theo ngày mới nhất
    filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    setState(() {
      _filteredMakeups = filtered;
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
        title: const Text('Lịch sử dạy bù'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _fetchMakeups),
        ],
      ),
      body: Column(
        children: [
          _buildFilterSection(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _buildMakeupList(),
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
            'Tìm thấy ${_filteredMakeups.length} lịch dạy bù',
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

  Widget _buildMakeupList() {
    if (_filteredMakeups.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'Không tìm thấy lịch dạy bù nào',
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
      itemCount: _filteredMakeups.length,
      itemBuilder: (context, index) {
        final makeup = _filteredMakeups[index];
        return _buildMakeupCard(makeup);
      },
    );
  }

  Widget _buildMakeupCard(MakeupSession makeup) {
    final statusColor = _statusColors[makeup.status] ?? Colors.grey;
    final statusText = _statusDisplayNames[makeup.status] ?? makeup.status;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _showMakeupDetail(makeup),
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
                    DateFormat('dd/MM/yyyy').format(makeup.makeupDate),
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
                      makeup.lecturerName,
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
                      '${makeup.subjectName} - ${makeup.className}',
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
                    'Tiết ${makeup.startPeriod}-${makeup.endPeriod}',
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
                    makeup.classroom,
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                  ),
                ],
              ),

              // Created at (footer)
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Tạo: ${DateFormat('dd/MM/yyyy HH:mm').format(makeup.createdAt)}',
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

  void _showMakeupDetail(MakeupSession makeup) {
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
                  'Chi tiết lịch dạy bù',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),

                // Status
                _buildDetailRow(
                  'Trạng thái',
                  _statusDisplayNames[makeup.status] ?? makeup.status,
                  icon: Icons.flag,
                  valueColor: _statusColors[makeup.status],
                ),
                const Divider(height: 32),

                // Basic info
                _buildDetailRow('Giảng viên', makeup.lecturerName),
                _buildDetailRow('Môn học', makeup.subjectName),
                _buildDetailRow('Lớp', makeup.className),
                _buildDetailRow(
                  'Ngày dạy bù',
                  DateFormat('dd/MM/yyyy').format(makeup.makeupDate),
                  icon: Icons.calendar_today,
                ),
                _buildDetailRow(
                  'Tiết',
                  'Tiết ${makeup.startPeriod} - ${makeup.endPeriod}',
                  icon: Icons.schedule,
                ),
                _buildDetailRow(
                  'Phòng',
                  makeup.classroom,
                  icon: Icons.location_on,
                ),

                // Timestamps
                const Divider(height: 32),
                _buildDetailRow(
                  'Ngày tạo',
                  DateFormat('dd/MM/yyyy HH:mm').format(makeup.createdAt),
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
