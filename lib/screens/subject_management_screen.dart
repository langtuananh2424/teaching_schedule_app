import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/subject.dart';
import '../services/api_service.dart';
import '../widgets/pagination_controls.dart';

class SubjectManagementScreen extends StatefulWidget {
  const SubjectManagementScreen({super.key});

  @override
  State<SubjectManagementScreen> createState() =>
      _SubjectManagementScreenState();
}

class _SubjectManagementScreenState extends State<SubjectManagementScreen> {
  final ApiService _apiService = ApiService();
  List<Subject> _subjects = [];
  List<Subject> _filteredSubjects = [];
  bool _isLoading = true;
  String? _error;
  String? _token;

  // Pagination
  int _currentPage = 0;
  int _rowsPerPage = 10;
  final List<int> _rowsPerPageOptions = [5, 10, 25, 50];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      _token = prefs.getString('token');

      if (_token == null) {
        setState(() {
          _error = 'Không tìm thấy token. Vui lòng đăng nhập lại.';
          _isLoading = false;
        });
        return;
      }

      final subjects = await _apiService.getSubjects(_token!);
      setState(() {
        _subjects = subjects;
        _filteredSubjects = subjects;
        _currentPage = 0;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Lỗi khi tải danh sách môn học: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _addSubject() async {
    final result = await showDialog<Subject>(
      context: context,
      builder: (context) => const SubjectDialog(),
    );

    if (result != null && _token != null) {
      try {
        await _apiService.createSubject(_token!, result.toJson());
        _loadData();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Thêm môn học thành công'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Lỗi khi thêm môn học: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _editSubject(Subject subject) async {
    final result = await showDialog<Subject>(
      context: context,
      builder: (context) => SubjectDialog(subject: subject),
    );

    if (result != null && _token != null && result.subjectId != null) {
      try {
        await _apiService.updateSubject(
          _token!,
          result.subjectId!,
          result.toJson(),
        );
        _loadData();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Cập nhật môn học thành công'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Lỗi khi cập nhật môn học: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  List<Subject> _getPaginatedSubjects() {
    final startIndex = _currentPage * _rowsPerPage;
    final endIndex = startIndex + _rowsPerPage;
    return _filteredSubjects.sublist(
      startIndex,
      endIndex > _filteredSubjects.length ? _filteredSubjects.length : endIndex,
    );
  }

  Future<void> _deleteSubject(Subject subject) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text(
          'Bạn có chắc chắn muốn xóa môn học "${subject.subjectName}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );

    if (confirmed == true && _token != null && subject.subjectId != null) {
      try {
        await _apiService.deleteSubject(_token!, subject.subjectId!);
        _loadData();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Xóa môn học thành công'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Lỗi khi xóa môn học: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    _error!,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _loadData,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Thử lại'),
                  ),
                ],
              ),
            )
          : _subjects.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.book, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text(
                    'Chưa có môn học nào',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _addSubject,
                    icon: const Icon(Icons.add),
                    label: const Text('Thêm môn học'),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      FutureBuilder<int>(
                        future: Future.value(_subjects.length),
                        builder: (context, snapshot) {
                          final totalSubjects = snapshot.hasData
                              ? snapshot.data!
                              : 0;
                          return Text(
                            'Quản lý Môn học ($totalSubjects môn)',
                            style: Theme.of(context).textTheme.headlineMedium,
                          );
                        },
                      ),
                      Row(
                        children: [
                          ElevatedButton.icon(
                            onPressed: _loadData,
                            icon: const Icon(Icons.refresh),
                            label: const Text('Làm mới'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey[700],
                            ),
                          ),
                          const SizedBox(width: 10),
                          ElevatedButton.icon(
                            onPressed: _addSubject,
                            icon: const Icon(Icons.add),
                            label: const Text('Thêm Môn học'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SingleChildScrollView(
                      child: DataTable(
                        columns: const [
                          DataColumn(label: Text('Mã môn học')),
                          DataColumn(label: Text('Tên môn học')),
                          DataColumn(label: Text('Số tín chỉ')),
                          DataColumn(label: Text('Tiết lý thuyết')),
                          DataColumn(label: Text('Tiết thực hành')),
                          DataColumn(label: Text('Thao tác')),
                        ],
                        rows: _getPaginatedSubjects().map((subject) {
                          return DataRow(
                            cells: [
                              DataCell(Text(subject.subjectCode)),
                              DataCell(Text(subject.subjectName)),
                              DataCell(Text(subject.credits.toString())),
                              DataCell(
                                Text(subject.theoryPeriods?.toString() ?? '-'),
                              ),
                              DataCell(
                                Text(
                                  subject.practicePeriods?.toString() ?? '-',
                                ),
                              ),
                              DataCell(
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(
                                        Icons.edit,
                                        color: Colors.blue,
                                      ),
                                      tooltip: 'Chỉnh sửa',
                                      onPressed: () => _editSubject(subject),
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.delete,
                                        color: Colors.red,
                                      ),
                                      tooltip: 'Xóa',
                                      onPressed: () => _deleteSubject(subject),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
                PaginationControls(
                  currentPage: _currentPage,
                  totalItems: _filteredSubjects.length,
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
            ),
    );
  }
}

class SubjectDialog extends StatefulWidget {
  final Subject? subject;

  const SubjectDialog({super.key, this.subject});

  @override
  State<SubjectDialog> createState() => _SubjectDialogState();
}

class _SubjectDialogState extends State<SubjectDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _subjectCodeController;
  late TextEditingController _subjectNameController;
  late TextEditingController _creditsController;
  late TextEditingController _theoryPeriodsController;
  late TextEditingController _practicePeriodsController;

  @override
  void initState() {
    super.initState();
    _subjectCodeController = TextEditingController(
      text: widget.subject?.subjectCode ?? '',
    );
    _subjectNameController = TextEditingController(
      text: widget.subject?.subjectName ?? '',
    );
    _creditsController = TextEditingController(
      text: widget.subject?.credits.toString() ?? '',
    );
    _theoryPeriodsController = TextEditingController(
      text: widget.subject?.theoryPeriods?.toString() ?? '',
    );
    _practicePeriodsController = TextEditingController(
      text: widget.subject?.practicePeriods?.toString() ?? '',
    );
  }

  @override
  void dispose() {
    _subjectCodeController.dispose();
    _subjectNameController.dispose();
    _creditsController.dispose();
    _theoryPeriodsController.dispose();
    _practicePeriodsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.subject != null;

    return AlertDialog(
      title: Text(isEditing ? 'Chỉnh sửa môn học' : 'Thêm môn học'),
      content: Form(
        key: _formKey,
        child: SizedBox(
          width: 500,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _subjectCodeController,
                  decoration: const InputDecoration(
                    labelText: 'Mã môn học',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập mã môn học';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _subjectNameController,
                  decoration: const InputDecoration(
                    labelText: 'Tên môn học',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập tên môn học';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _creditsController,
                  decoration: const InputDecoration(
                    labelText: 'Số tín chỉ',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập số tín chỉ';
                    }
                    if (int.tryParse(value) == null) {
                      return 'Vui lòng nhập số nguyên';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _theoryPeriodsController,
                  decoration: const InputDecoration(
                    labelText: 'Số tiết lý thuyết (tuỳ chọn)',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value != null &&
                        value.isNotEmpty &&
                        int.tryParse(value) == null) {
                      return 'Vui lòng nhập số nguyên';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _practicePeriodsController,
                  decoration: const InputDecoration(
                    labelText: 'Số tiết thực hành (tuỳ chọn)',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value != null &&
                        value.isNotEmpty &&
                        int.tryParse(value) == null) {
                      return 'Vui lòng nhập số nguyên';
                    }
                    return null;
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
          child: const Text('Hủy'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              final subject = Subject(
                subjectId: widget.subject?.subjectId,
                subjectCode: _subjectCodeController.text,
                subjectName: _subjectNameController.text,
                credits: int.parse(_creditsController.text),
                theoryPeriods: _theoryPeriodsController.text.isNotEmpty
                    ? int.parse(_theoryPeriodsController.text)
                    : null,
                practicePeriods: _practicePeriodsController.text.isNotEmpty
                    ? int.parse(_practicePeriodsController.text)
                    : null,
              );
              Navigator.pop(context, subject);
            }
          },
          child: Text(isEditing ? 'Cập nhật' : 'Thêm'),
        ),
      ],
    );
  }
}
