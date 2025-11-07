import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../widgets/sidebar.dart';
import '../services/api_service.dart';

// Dialog đổi mật khẩu
void _showChangePasswordDialog(
  BuildContext context,
  AuthService authService,
  ApiService apiService,
) {
  final oldPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  bool isLoading = false;
  String? errorText;

  showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          final isAdmin =
              (authService.userRole == 'ADMIN' ||
              authService.userRole == 'ROLE_ADMIN');
          return AlertDialog(
            title: const Text('Đổi mật khẩu'),
            content: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!isAdmin)
                    TextFormField(
                      controller: oldPasswordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Mật khẩu cũ',
                      ),
                      validator: (value) => value == null || value.isEmpty
                          ? 'Nhập mật khẩu cũ'
                          : null,
                    ),
                  TextFormField(
                    controller: newPasswordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Mật khẩu mới',
                    ),
                    validator: (value) => value == null || value.isEmpty
                        ? 'Nhập mật khẩu mới'
                        : null,
                  ),
                  TextFormField(
                    controller: confirmPasswordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Xác nhận mật khẩu mới',
                    ),
                    validator: (value) => value != newPasswordController.text
                        ? 'Mật khẩu xác nhận không khớp'
                        : null,
                  ),
                  if (errorText != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        errorText!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: isLoading ? null : () => Navigator.of(context).pop(),
                child: const Text('Hủy'),
              ),
              ElevatedButton(
                onPressed: isLoading
                    ? null
                    : () async {
                        if (!formKey.currentState!.validate()) return;
                        setState(() {
                          isLoading = true;
                          errorText = null;
                        });
                        try {
                          if (isAdmin) {
                            final userId = await apiService.getUserIdByEmail(
                              authService.token ?? '',
                              authService.userName ?? '',
                            );
                            if (userId == null)
                              throw Exception('Không tìm thấy userId');
                            await apiService.adminResetPassword(
                              authService.token ?? '',
                              userId,
                              newPasswordController.text,
                            );
                          } else {
                            final userId = await apiService.getUserIdByEmail(
                              authService.token ?? '',
                              authService.userName ?? '',
                            );
                            if (userId == null)
                              throw Exception('Không tìm thấy userId');
                            await apiService.updateLecturerPassword(
                              authService.token ?? '',
                              userId,
                              oldPasswordController.text,
                              newPasswordController.text,
                            );
                          }
                          Navigator.of(context).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Đổi mật khẩu thành công!'),
                            ),
                          );
                        } catch (e) {
                          setState(() {
                            errorText =
                                'Đổi mật khẩu thất bại: ${e.toString()}';
                            isLoading = false;
                          });
                        }
                      },
                child: isLoading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Đổi mật khẩu'),
              ),
            ],
          );
        },
      );
    },
  );
}

class ShellScreen extends StatelessWidget {
  final Widget child;
  const ShellScreen({super.key, required this.child});

  void _showProfileDialog(BuildContext context, AuthService authService) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: 400,
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Avatar
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Colors.blue.shade400, Colors.blue.shade600],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.3),
                      blurRadius: 12,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: const Icon(Icons.person, size: 50, color: Colors.white),
              ),
              const SizedBox(height: 24),

              // Tên người dùng
              Text(
                authService.userName ?? 'Người dùng',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),

              // Vai trò
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.blue.shade200, width: 1),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.admin_panel_settings,
                      size: 16,
                      color: Colors.blue.shade700,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      authService.userRole ?? 'USER',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.blue.shade700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Thông tin chi tiết
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200, width: 1),
                ),
                child: Column(
                  children: [
                    _buildInfoRow(
                      Icons.email_outlined,
                      'Email',
                      authService.userName ?? 'N/A',
                      Colors.blue,
                    ),
                    const Divider(height: 24),
                    _buildInfoRow(
                      Icons.security,
                      'Quyền truy cập',
                      authService.userRole == 'ROLE_ADMIN' ||
                              authService.userRole == 'ADMIN'
                          ? 'Quản trị viên'
                          : 'Người dùng',
                      Colors.green,
                    ),
                    const Divider(height: 24),
                    _buildInfoRow(
                      Icons.verified_user,
                      'Trạng thái',
                      'Đang hoạt động',
                      Colors.green,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Nút đóng
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Đóng',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    IconData icon,
    String label,
    String value,
    Color iconColor,
  ) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 20, color: iconColor),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouter.of(
      context,
    ).routerDelegate.currentConfiguration.fullPath;

    return Scaffold(
      body: Row(
        children: [
          Sidebar(
            currentPath: location,
            onNavigate: (path) => context.go(path),
          ),
          Expanded(
            child: Column(
              children: [
                // Header với menu user
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Consumer2<AuthService, ApiService>(
                        builder: (context, authService, apiService, child) {
                          return PopupMenuButton<String>(
                            offset: const Offset(0, 45),
                            onSelected: (value) {
                              if (value == 'profile') {
                                _showProfileDialog(context, authService);
                              } else if (value == 'change_password') {
                                _showChangePasswordDialog(
                                  context,
                                  authService,
                                  apiService,
                                );
                              } else if (value == 'logout') {
                                authService.logout();
                                context.go('/login');
                              }
                            },
                            child: Row(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.blue.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.account_circle,
                                        size: 24,
                                        color: Colors.blue,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        authService.userName ?? 'Người dùng',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.blue,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      const Icon(
                                        Icons.arrow_drop_down,
                                        color: Colors.blue,
                                        size: 20,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            itemBuilder: (context) => [
                              const PopupMenuItem(
                                value: 'profile',
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.person_outline,
                                      size: 20,
                                      color: Colors.blue,
                                    ),
                                    SizedBox(width: 8),
                                    Text('Thông tin tài khoản'),
                                  ],
                                ),
                              ),
                              PopupMenuItem(
                                value: 'change_password',
                                child: Row(
                                  children: const [
                                    Icon(
                                      Icons.lock_reset,
                                      size: 20,
                                      color: Colors.orange,
                                    ),
                                    SizedBox(width: 8),
                                    Text('Đổi mật khẩu'),
                                  ],
                                ),
                              ),
                              const PopupMenuDivider(),
                              const PopupMenuItem(
                                value: 'logout',
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.logout_outlined,
                                      // ...existing code...
                                      size: 20,
                                      color: Colors.red,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      'Đăng xuất',
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
                // Nội dung chính
                Expanded(child: child),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
