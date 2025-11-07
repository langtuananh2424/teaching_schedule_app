import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/lecturer.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../widgets/pagination_controls.dart';

class LecturerManagementScreen extends StatefulWidget {
  const LecturerManagementScreen({super.key});

  @override
  State<LecturerManagementScreen> createState() =>
      _LecturerManagementScreenState();
}

class _LecturerManagementScreenState extends State<LecturerManagementScreen> {
  late Future<List<Lecturer>> _lecturersFuture;
  final ApiService _apiService = ApiService();

  // Pagination
  int _currentPage = 0;
  int _rowsPerPage = 10;
  final List<int> _rowsPerPageOptions = [5, 10, 25, 50];
  List<Lecturer> _allLecturers = [];

  // Bộ lọc
  int? _selectedDepartmentId;
  String? _selectedRole;

  @override
  void initState() {
    super.initState();
    _loadLecturers();
  }

  Future<void> _loadLecturers() async {
    final token = context.read<AuthService>().token;
    if (token == null) {
      print('ERROR: Khng c token xc thc');
      setState(() {
        _lecturersFuture = Future.error('Khng c token xc thc');
      });
      return;
    }

    print(
      'Loading lecturers with filter - Department: $_selectedDepartmentId, Role: $_selectedRole',
    );
    setState(() {
      _lecturersFuture = _apiService
          .getFilteredLecturers(token, _selectedDepartmentId, _selectedRole)
          .then((lecturers) {
            print('=== LECTURERS FROM API ===');
            print('Total count: ${lecturers.length}');
            for (var lecturer in lecturers) {
              print('Lecturer: ${lecturer.fullName}');
              print('Role: "${lecturer.role}"');
              print('Email: ${lecturer.email}');
              print('Department: ${lecturer.departmentName}');
              print('---');
            }
            return lecturers;
          })
          .catchError((error) {
            print('ERROR loading lecturers: $error');
            throw error;
          });
    });
  }

  void _clearFilters() {
    setState(() {
      _selectedDepartmentId = null;
      _selectedRole = null;
    });
    _loadLecturers();
  }

  Future<void> _showEditDialog(Lecturer lecturer) async {
    final formKey = GlobalKey<FormState>();
    String lecturerCode = lecturer.lecturerCode ?? '';
    String fullName = lecturer.fullName;
    String email = lecturer.email;
    int departmentId = lecturer.departmentId;

    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Chnh sa thng tin ti khon'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  initialValue: lecturerCode,
                  decoration: const InputDecoration(
                    labelText: 'M ging vin',
                    helperText: 'V d: GV001',
                    prefixIcon: Icon(Icons.badge),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lng nhp m ging vin';
                    }
                    return null;
                  },
                  onSaved: (value) => lecturerCode = value!,
                ),
                TextFormField(
                  initialValue: fullName,
                  decoration: const InputDecoration(
                    labelText: 'H v tn',
                    helperText: 'Nhp y  h tn',
                    prefixIcon: Icon(Icons.person),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lng nhp h v tn';
                    }
                    return null;
                  },
                  onSaved: (value) => fullName = value!,
                ),
                TextFormField(
                  initialValue: email,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    helperText: 'Nhp a ch email',
                    prefixIcon: Icon(Icons.email),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lng nhp email';
                    }
                    return null;
                  },
                  onSaved: (value) => email = value!,
                ),
                FutureBuilder<List<dynamic>>(
                  future: _apiService.getDepartments(
                    context.read<AuthService>().token ?? '',
                  ),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const LinearProgressIndicator();
                    }
                    final depts = snapshot.data!;
                    return DropdownButtonFormField<int>(
                      decoration: const InputDecoration(
                        labelText: 'Khoa',
                        prefixIcon: Icon(Icons.school),
                      ),
                      value: departmentId,
                      items: depts.map((dept) {
                        return DropdownMenuItem<int>(
                          value: dept.id,
                          child: Text(dept.name),
                        );
                      }).toList(),
                      validator: (value) {
                        if (value == null) {
                          return 'Vui lng chn khoa';
                        }
                        return null;
                      },
                      onChanged: (value) {
                        if (value != null) {
                          departmentId = value;
                        }
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hy'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                formKey.currentState!.save();
                final token = context.read<AuthService>().token;

                if (token == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Li: Khng c token xc thc'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                try {
                  await _apiService.updateLecturer(token, lecturer.id, {
                    'lecturerCode': lecturerCode.trim(),
                    'fullName': fullName.trim(),
                    'email': email.trim(),
                    'departmentId': departmentId,
                  });

                  if (!mounted) return;

                  Navigator.pop(context);
                  await _loadLecturers();
                  if (!mounted) return;

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Cp nht ti khon thnh cng'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } catch (e) {
                  if (!mounted) return;

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Li: ${e.toString()}'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('Lu'),
          ),
        ],
      ),
    );
  }

  Future<void> _showDeleteConfirmation(Lecturer lecturer) async {
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xc nhn xa'),
        content: Text('Bn c chc chn mun xa ti khon ${lecturer.fullName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hy'),
          ),
          ElevatedButton(
            onPressed: () async {
              final token = context.read<AuthService>().token;
              if (token != null) {
                try {
                  await _apiService.deleteLecturer(token, lecturer.id);
                  Navigator.pop(context);
                  _loadLecturers(); // Refresh data
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Xa ti khon thnh cng'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Li: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Xa'),
          ),
        ],
      ),
    );
  }

  Future<void> _showChangePasswordDialog(Lecturer lecturer) async {
    final formKey = GlobalKey<FormState>();
    String newPassword = '';

    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('t li mt khu - ${lecturer.fullName}'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Admin c th t li mt khu m khng cn bit mt khu c',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Mt khu mi',
                    helperText: 'Nhp mt khu mi (t nht 6 k t)',
                    prefixIcon: Icon(Icons.lock),
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lng nhp mt khu mi';
                    }
                    if (value.length < 6) {
                      return 'Mt khu phi c t nht 6 k t';
                    }
                    return null;
                  },
                  onChanged: (value) => newPassword = value,
                  onSaved: (value) => newPassword = value!,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Xc nhn mt khu mi',
                    helperText: 'Nhp li mt khu mi',
                    prefixIcon: Icon(Icons.lock_clock),
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lng xc nhn mt khu';
                    }
                    if (value != newPassword) {
                      return 'Mt khu xc nhn khng khp';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hy'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                formKey.currentState!.save();
                final token = context.read<AuthService>().token;

                if (token == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Li: Khng c token xc thc'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                try {
                  // Tm userId t email ca lecturer
                  final userId = await _apiService.getUserIdByEmail(
                    token,
                    lecturer.email,
                  );

                  if (userId == null) {
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Li: Khng tm thy userId'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }

                  print(
                    ' Resetting password for userId: $userId (email: ${lecturer.email})',
                  );

                  // Admin t li mt khu: s dng API mi cho Admin
                  // API: PUT /api/users/{id}/password ch cn newPassword
                  await _apiService.adminResetPassword(
                    token,
                    userId,
                    newPassword,
                  );

                  if (!mounted) return;

                  Navigator.pop(context);

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        't li mt khu thnh cng cho ${lecturer.fullName}',
                      ),
                      backgroundColor: Colors.green,
                    ),
                  );
                } catch (e) {
                  if (!mounted) return;

                  // Extract error message
                  String errorMessage = e.toString();
                  if (errorMessage.startsWith(
                    'Exception: Error resetting password: Exception: ',
                  )) {
                    errorMessage = errorMessage.replaceFirst(
                      'Exception: Error resetting password: Exception: ',
                      '',
                    );
                  } else if (errorMessage.startsWith('Exception: ')) {
                    errorMessage = errorMessage.replaceFirst('Exception: ', '');
                  }

                  print(' Password reset failed: $errorMessage');

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Li t li mt khu:\n$errorMessage'),
                      backgroundColor: Colors.red,
                      duration: const Duration(seconds: 5),
                    ),
                  );
                }
              }
            },
            child: const Text('t li mt khu'),
          ),
        ],
      ),
    );
  }

  Future<void> _showCreateDialog() async {
    final formKey = GlobalKey<FormState>();
    String lecturerCode = '';
    String fullName = '';
    String email = '';
    String password = '';
    int? selectedDepartmentId;
    String? selectedRole = 'LECTURER'; // Default role

    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Thm ti khon mi'),
        contentPadding: const EdgeInsets.all(24),
        content: SizedBox(
          width: 500, // Fixed width for better layout
          child: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'M ging vin',
                      hintText: 'V d: GV001',
                      hintStyle: TextStyle(color: Colors.grey[400]),
                      prefixIcon: Icon(Icons.badge),
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 16,
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Vui lng nhp m ging vin';
                      }
                      return null;
                    },
                    onSaved: (value) => lecturerCode = value!,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'H v tn',
                      hintText: 'Nhp y  h tn',
                      hintStyle: TextStyle(color: Colors.grey[400]),
                      prefixIcon: Icon(Icons.person),
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 16,
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Vui lng nhp h v tn';
                      }
                      return null;
                    },
                    onSaved: (value) => fullName = value!,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Email',
                      hintText: 'example@thuyloi.edu.vn',
                      hintStyle: TextStyle(color: Colors.grey[400]),
                      prefixIcon: Icon(Icons.email),
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 16,
                      ),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Vui lng nhp email';
                      }
                      return null;
                    },
                    onSaved: (value) => email = value!,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Mt khu',
                      hintText: 't nht 6 k t',
                      hintStyle: TextStyle(color: Colors.grey[400]),
                      prefixIcon: Icon(Icons.lock),
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 16,
                      ),
                    ),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Vui lng nhp mt khu';
                      }
                      if (value.length < 6) {
                        return 'Mt khu phi c t nht 6 k t';
                      }
                      return null;
                    },
                    onSaved: (value) => password = value!,
                  ),
                  const SizedBox(height: 16),
                  FutureBuilder<List<dynamic>>(
                    future: _apiService.getDepartments(
                      context.read<AuthService>().token ?? '',
                    ),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const LinearProgressIndicator();
                      }
                      final depts = snapshot.data!;
                      print(
                        ' Available departments: ${depts.map((d) => '${d.id}:${d.name}').toList()}',
                      );
                      return DropdownButtonFormField<int>(
                        decoration: const InputDecoration(
                          labelText: 'Khoa',
                          prefixIcon: Icon(Icons.school),
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 16,
                          ),
                        ),
                        items: depts.map((dept) {
                          return DropdownMenuItem<int>(
                            value: dept.id,
                            child: Text(dept.name),
                          );
                        }).toList(),
                        validator: (value) {
                          if (value == null) {
                            return 'Vui lng chn khoa';
                          }
                          return null;
                        },
                        onChanged: (value) {
                          selectedDepartmentId = value;
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Vai tr',
                      prefixIcon: Icon(Icons.admin_panel_settings),
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 16,
                      ),
                    ),
                    value: selectedRole,
                    items: const [
                      DropdownMenuItem<String>(
                        value: 'LECTURER',
                        child: Text('Ging vin'),
                      ),
                      DropdownMenuItem<String>(
                        value: 'MANAGER',
                        child: Text('Trng khoa'),
                      ),
                    ],
                    validator: (value) {
                      if (value == null) {
                        return 'Vui lng chn vai tr';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      selectedRole = value;
                    },
                    onSaved: (value) {
                      selectedRole = value;
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hy'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                formKey.currentState!.save();
                final token = context.read<AuthService>().token;

                if (token == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Li: Khng c token xc thc'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                try {
                  if (selectedDepartmentId == null) {
                    throw Exception('Vui lng chn khoa');
                  }

                  if (selectedRole == null) {
                    throw Exception('Vui lng chn vai tr');
                  }

                  // Match Swagger schema order exactly:
                  // lecturerCode, fullName, email, password, departmentId, role
                  final requestBody = {
                    'lecturerCode': lecturerCode.trim(),
                    'fullName': fullName.trim(),
                    'email': email.trim(),
                    'password': password,
                    'departmentId': selectedDepartmentId,
                    'role': selectedRole, // NO prefix, just LECTURER or MANAGER
                  };

                  print('Creating lecturer with data:');
                  print('  - Code: ${requestBody['lecturerCode']}');
                  print('  - Name: ${requestBody['fullName']}');
                  print('  - Email: ${requestBody['email']}');
                  print('  - Department ID: ${requestBody['departmentId']}');
                  print('  - Role: ${requestBody['role']}');
                  print('Full request body: $requestBody');

                  await _apiService.createLecturer(token, requestBody);

                  if (!mounted) return;

                  Navigator.pop(context);
                  await _loadLecturers(); // Refresh data

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Thm ti khon thnh cng'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Li: ${e.toString()}'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('Thm'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Quản lý Giảng viên',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: _loadLecturers,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Làm mới'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton.icon(
                    onPressed: _showCreateDialog,
                    icon: const Icon(Icons.add),
                    label: const Text('Thêm Giảng viên'),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          // B lc
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    const Icon(Icons.filter_list, color: Colors.blue),
                    const SizedBox(width: 10),
                    const Text(
                      'Lọc:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 20),
                    // Dropdown lọc theo khoa
                    FutureBuilder<List<dynamic>>(
                      future: _apiService.getDepartments(
                        context.read<AuthService>().token ?? '',
                      ),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const SizedBox(
                            width: 200,
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }
                        final depts = snapshot.data!;
                        return SizedBox(
                          width: 250,
                          child: DropdownButtonFormField<int>(
                            value: _selectedDepartmentId,
                            decoration: const InputDecoration(
                              labelText: 'Khoa',
                              isDense: true,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                            ),
                            items: [
                              const DropdownMenuItem<int>(
                                value: null,
                                child: Text('Tất cả khoa'),
                              ),
                              ...depts.map(
                                (dept) => DropdownMenuItem<int>(
                                  value: dept.id,
                                  child: Text(
                                    dept.name,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                ),
                              ),
                            ],
                            onChanged: (value) {
                              setState(() {
                                _selectedDepartmentId = value;
                              });
                              _loadLecturers();
                            },
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 20),
                    // Dropdown lọc theo vai trò
                    SizedBox(
                      width: 200,
                      child: DropdownButtonFormField<String>(
                        value: _selectedRole,
                        decoration: const InputDecoration(
                          labelText: 'Vai trò',
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                        items: const [
                          DropdownMenuItem<String>(
                            value: null,
                            child: Text('Tất cả vai trò'),
                          ),
                          DropdownMenuItem<String>(
                            value: 'LECTURER',
                            child: Text('Giảng viên'),
                          ),
                          DropdownMenuItem<String>(
                            value: 'MANAGER',
                            child: Text('Trưởng khoa'),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedRole = value;
                          });
                          _loadLecturers();
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    if (_selectedDepartmentId != null || _selectedRole != null)
                      TextButton.icon(
                        onPressed: _clearFilters,
                        icon: const Icon(Icons.clear),
                        label: const Text('Xóa lọc'),
                      ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: FutureBuilder<List<Lecturer>>(
              future: _lecturersFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('Đang tải danh sách giảng viên...'),
                      ],
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          color: Colors.red,
                          size: 60,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Lỗi: ${snapshot.error}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.red),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: _loadLecturers,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Thử lại'),
                        ),
                      ],
                    ),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.inbox_outlined,
                          size: 60,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 16),
                        const Text('Không có giảng viên nào trong hệ thống'),
                        const SizedBox(height: 8),
                        const Text(
                          'Kiểm tra:\n- Kết nối mạng\n- Server đang chạy\n- API endpoint đúng',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: _showCreateDialog,
                          icon: const Icon(Icons.add),
                          label: const Text('Thêm giảng viên mới'),
                        ),
                      ],
                    ),
                  );
                }

                // Hiển thị tất cả tài khoản (LECTURER, ADMIN, MANAGER)
                _allLecturers = snapshot.data!;

                if (_allLecturers.isEmpty) {
                  return const Center(child: Text('Không có tài khoản nào'));
                }

                // Pagination logic
                final startIndex = _currentPage * _rowsPerPage;
                final endIndex =
                    (startIndex + _rowsPerPage > _allLecturers.length)
                    ? _allLecturers.length
                    : startIndex + _rowsPerPage;
                final paginatedLecturers = _allLecturers.sublist(
                  startIndex,
                  endIndex,
                );

                return Column(
                  children: [
                    Expanded(
                      child: Center(
                        child: Card(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: DataTable(
                              headingTextStyle: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                              columns: const [
                                DataColumn(label: Text('STT')),
                                DataColumn(label: Text('Mã GV')),
                                DataColumn(label: Text('Họ và tên')),
                                DataColumn(label: Text('Email')),
                                DataColumn(label: Text('Khoa')),
                                DataColumn(label: Text('Vai trò')),
                                DataColumn(label: Text('Thao tác')),
                              ],
                              rows: List<DataRow>.generate(
                                paginatedLecturers.length,
                                (index) {
                                  final lecturer = paginatedLecturers[index];
                                  final actualIndex = startIndex + index;
                                  // Hiển thị role theo tiếng Việt
                                  String roleDisplay = lecturer.role;
                                  if (roleDisplay == 'LECTURER') {
                                    roleDisplay = 'Giảng viên';
                                  } else if (roleDisplay == 'MANAGER') {
                                    roleDisplay = 'Trưởng khoa';
                                  } else if (roleDisplay == 'ADMIN') {
                                    roleDisplay = 'Quản trị';
                                  }

                                  return DataRow(
                                    cells: [
                                      DataCell(Text('${actualIndex + 1}')),
                                      DataCell(
                                        Text(lecturer.lecturerCode ?? ''),
                                      ),
                                      DataCell(Text(lecturer.fullName)),
                                      DataCell(Text(lecturer.email)),
                                      DataCell(Text(lecturer.departmentName)),
                                      DataCell(
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: lecturer.role == 'ADMIN'
                                                ? Colors.red.shade100
                                                : lecturer.role == 'MANAGER'
                                                ? Colors.orange.shade100
                                                : Colors.blue.shade100,
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          child: Text(
                                            roleDisplay,
                                            style: TextStyle(
                                              color: lecturer.role == 'ADMIN'
                                                  ? Colors.red.shade900
                                                  : lecturer.role == 'MANAGER'
                                                  ? Colors.orange.shade900
                                                  : Colors.blue.shade900,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            IconButton(
                                              icon: const Icon(Icons.edit),
                                              onPressed: () =>
                                                  _showEditDialog(lecturer),
                                              color: Colors.blue,
                                              tooltip: 'Chỉnh sửa',
                                            ),
                                            IconButton(
                                              icon: const Icon(
                                                Icons.lock_reset,
                                              ),
                                              onPressed: () =>
                                                  _showChangePasswordDialog(
                                                    lecturer,
                                                  ),
                                              color: Colors.orange,
                                              tooltip: 'Đổi mật khẩu',
                                            ),
                                            IconButton(
                                              icon: const Icon(Icons.delete),
                                              onPressed: () =>
                                                  _showDeleteConfirmation(
                                                    lecturer,
                                                  ),
                                              color: Colors.red,
                                              tooltip: 'Xóa',
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    PaginationControls(
                      currentPage: _currentPage,
                      totalItems: _allLecturers.length,
                      rowsPerPage: _rowsPerPage,
                      rowsPerPageOptions: _rowsPerPageOptions,
                      onPageChanged: (page) {
                        setState(() {
                          _currentPage = page;
                        });
                      },
                      onRowsPerPageChanged: (rows) {
                        setState(() {
                          _rowsPerPage = rows;
                          _currentPage = 0;
                        });
                      },
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
