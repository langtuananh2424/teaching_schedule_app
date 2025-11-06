import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ApiService _apiService = ApiService();
  bool _isLoading = true;
  Map<String, dynamic>? _profileData;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final token = authService.token;
    final userEmail = authService.userEmail;

    if (token == null) {
      setState(() {
        _errorMessage = 'Không có token xác thực';
        _isLoading = false;
      });
      return;
    }

    if (userEmail == null) {
      setState(() {
        _errorMessage = 'Không tìm thấy email người dùng';
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      print('🔍 Loading lecturer profile data...');
      print('👤 Name from token: ${authService.userName}');
      print('📧 Email from token: $userEmail');

      // Gọi API để lấy danh sách tất cả giảng viên
      print('📡 Calling API: /api/lecturers');
      final response = await _apiService.get('api/lecturers', token: token);

      // Filter theo email từ token
      List<dynamic> lecturerList = response as List<dynamic>;
      print('� Total lecturers: ${lecturerList.length}');

      final matchingLecturers = lecturerList
          .where((lecturer) => lecturer['email'] == userEmail)
          .toList();

      if (matchingLecturers.isEmpty) {
        throw Exception(
          'Không tìm thấy thông tin giảng viên với email: $userEmail',
        );
      }

      final data = matchingLecturers.first as Map<String, dynamic>;

      print('✅ Loaded profile successfully');
      print('📝 Profile data from API:');
      print('   - Name: ${data['fullName']}');
      print('   - Email: ${data['email']}');
      print('   - Lecturer ID: ${data['lecturerId']}');
      print('   - Department: ${data['departmentName']}');

      setState(() {
        _profileData = data;
        _isLoading = false;
      });
    } catch (e) {
      print('❌ Error loading profile: $e');
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  String _getDisplayValue(dynamic value) {
    if (value == null) return 'N/A';
    if (value is String && value.isEmpty) return 'N/A';
    return value.toString();
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Hồ sơ cá nhân')),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Đang tải thông tin...'),
            ],
          ),
        ),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Hồ sơ cá nhân')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'Lỗi tải thông tin',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  _errorMessage!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _loadProfileData,
                icon: const Icon(Icons.refresh),
                label: const Text('Thử lại'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Hồ sơ cá nhân')),
      body: RefreshIndicator(
        onRefresh: _loadProfileData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar và tên
              Center(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Theme.of(context).primaryColor,
                      child: Text(
                        _getInitials(
                          _profileData?['fullName'] ??
                              _profileData?['full_name'] ??
                              authService.userName ??
                              'User',
                        ),
                        style: const TextStyle(
                          fontSize: 32,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _getDisplayValue(
                        _profileData?['fullName'] ??
                            _profileData?['full_name'] ??
                            authService.userName,
                      ),
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: _getRoleColor(
                          _profileData?['role'] ?? authService.userRole,
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _getRoleLabel(
                          _profileData?['role'] ??
                              authService.userRole ??
                              'UNKNOWN',
                        ),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Thông tin cá nhân
              _buildSectionTitle('Thông tin cá nhân'),
              const SizedBox(height: 12),
              _buildInfoCard([
                _buildInfoRow(
                  Icons.badge,
                  'Mã giảng viên',
                  _getDisplayValue(
                    _profileData?['lecturerCode'] ??
                        _profileData?['lecturer_code'],
                  ),
                ),
                _buildInfoRow(
                  Icons.badge,
                  'ID',
                  _getDisplayValue(
                    _profileData?['lecturerId'] ??
                        _profileData?['lecturer_id'] ??
                        _profileData?['id'],
                  ),
                ),
                _buildInfoRow(
                  Icons.email,
                  'Email',
                  _getDisplayValue(_profileData?['email']),
                ),
                _buildInfoRow(
                  Icons.business,
                  'Khoa',
                  _getDisplayValue(
                    _profileData?['departmentName'] ??
                        _profileData?['department_name'] ??
                        _profileData?['department'],
                  ),
                ),
                if (_profileData?['departmentId'] != null ||
                    _profileData?['department_id'] != null)
                  _buildInfoRow(
                    Icons.numbers,
                    'Mã khoa',
                    _getDisplayValue(
                      _profileData?['departmentId'] ??
                          _profileData?['department_id'],
                    ),
                  ),
              ]),

              // Thông tin tài khoản
              const SizedBox(height: 24),
              _buildSectionTitle('Thông tin tài khoản'),
              const SizedBox(height: 12),
              _buildInfoCard([
                _buildInfoRow(
                  Icons.security,
                  'Vai trò',
                  _getRoleLabel(
                    _profileData?['role'] ?? authService.userRole ?? 'UNKNOWN',
                  ),
                ),
                if (_profileData?['username'] != null ||
                    _profileData?['user_name'] != null)
                  _buildInfoRow(
                    Icons.person,
                    'Tên đăng nhập',
                    _getDisplayValue(
                      _profileData?['username'] ?? _profileData?['user_name'],
                    ),
                  ),
                if (_profileData?['created_at'] != null ||
                    _profileData?['createdAt'] != null)
                  _buildInfoRow(
                    Icons.calendar_today,
                    'Ngày tạo',
                    _formatDate(
                      _profileData?['created_at'] ?? _profileData?['createdAt'],
                    ),
                  ),
              ]),

              const SizedBox(height: 32),

              // Nút đăng xuất
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Đăng xuất'),
                        content: const Text('Bạn có chắc muốn đăng xuất?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Hủy'),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                              authService.logout();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                            ),
                            child: const Text('Đăng xuất'),
                          ),
                        ],
                      ),
                    );
                  },
                  icon: const Icon(Icons.logout),
                  label: const Text('Đăng xuất'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: Theme.of(
        context,
      ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
    );
  }

  Widget _buildInfoCard(List<Widget> children) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: children),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 24, color: Colors.grey[600]),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[parts.length - 1][0]}'.toUpperCase();
  }

  Color _getRoleColor(String? role) {
    if (role == null) return Colors.grey;
    switch (role.toUpperCase()) {
      case 'ROLE_ADMIN':
        return Colors.red;
      case 'ROLE_MANAGER':
        return Colors.blue;
      case 'ROLE_LECTURER':
        return Colors.green;
      case 'ROLE_STUDENT':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  String _getRoleLabel(String role) {
    switch (role.toUpperCase()) {
      case 'ROLE_ADMIN':
        return 'Quản trị viên';
      case 'ROLE_MANAGER':
        return 'Trưởng khoa';
      case 'ROLE_LECTURER':
      case 'LECTURER':
        return 'Giảng viên';
      case 'ROLE_STUDENT':
        return 'Sinh viên';
      default:
        return role;
    }
  }

  String _formatDate(dynamic date) {
    if (date == null) return 'N/A';
    try {
      final dateTime = DateTime.parse(date.toString());
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    } catch (e) {
      return date.toString();
    }
  }
}
