import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';
import '../../models/absence_request.dart';
import '../../models/session.dart';
import 'package:intl/intl.dart';

class RegisterMakeupScreen extends StatefulWidget {
  final AbsenceRequest? absenceRequest;
  final Session? session;

  const RegisterMakeupScreen({super.key, this.absenceRequest, this.session});

  @override
  State<RegisterMakeupScreen> createState() => _RegisterMakeupScreenState();
}

class _RegisterMakeupScreenState extends State<RegisterMakeupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _apiService = ApiService();
  final _classroomController = TextEditingController();

  DateTime? _makeupDate;
  int? _startPeriod;
  int? _endPeriod;
  bool _isLoading = false;

  @override
  void dispose() {
    _classroomController.dispose();
    super.dispose();
  }

  Future<void> _submitMakeupSession() async {
    if (!_formKey.currentState!.validate()) return;

    if (_makeupDate == null) {
      _showError('Vui lòng chọn ngày dạy bù');
      return;
    }

    final authService = Provider.of<AuthService>(context, listen: false);
    final token = authService.token;

    if (token == null) {
      _showError('Vui lòng đăng nhập lại');
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Nếu có absenceRequest thì dùng absenceRequest.id
      // Nếu chỉ có session thì cần tạo absence request trước
      int absenceRequestId;

      if (widget.absenceRequest != null) {
        absenceRequestId = widget.absenceRequest!.id;
      } else {
        // Tạm thời skip - cần có absence request trước khi đăng ký dạy bù
        _showError('Cần có yêu cầu nghỉ được duyệt trước');
        setState(() => _isLoading = false);
        return;
      }

      await _apiService.createMakeupSession(
        token,
        absenceRequestId: absenceRequestId,
        makeupDate: _makeupDate!,
        startPeriod: _startPeriod!,
        endPeriod: _endPeriod!,
        classroom: _classroomController.text,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đăng ký dạy bù thành công'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      _showError('Lỗi: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _makeupDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    String absentInfo;

    if (widget.absenceRequest != null) {
      absentInfo =
          'Buổi đã nghỉ: ${widget.absenceRequest!.subjectName} - ${widget.absenceRequest!.className}\n'
          'Ngày nghỉ: ${DateFormat('dd/MM/yyyy').format(widget.absenceRequest!.sessionDate)}';
    } else if (widget.session != null) {
      absentInfo =
          'Buổi học: ${widget.session!.subjectName} - ${widget.session!.className}\n'
          'Ngày: ${DateFormat('dd/MM/yyyy').format(widget.session!.sessionDate)}';
    } else {
      absentInfo = 'Không có thông tin buổi học';
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Đăng ký dạy bù')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        absentInfo,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Chọn lịch dạy bù:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    ListTile(
                      title: Text(
                        _makeupDate == null
                            ? 'Chọn ngày dạy bù *'
                            : 'Ngày: ${DateFormat('dd/MM/yyyy').format(_makeupDate!)}',
                      ),
                      leading: const Icon(Icons.calendar_today),
                      onTap: _selectDate,
                      tileColor: Colors.grey[100],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),

                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Ca học',
                        prefixIcon: Icon(Icons.access_time),
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: '1-3',
                          child: Text('Tiết 1-3 (7:00-9:40)'),
                        ),
                        DropdownMenuItem(
                          value: '4-6',
                          child: Text('Tiết 4-6 (9:45-12:20)'),
                        ),
                        DropdownMenuItem(
                          value: '7-9',
                          child: Text('Tiết 7-9 (12:55-15:35)'),
                        ),
                        DropdownMenuItem(
                          value: '10-12',
                          child: Text('Tiết 10-12 (15:40-18:15)'),
                        ),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          final parts = value.split('-');
                          setState(() {
                            _startPeriod = int.parse(parts[0]);
                            _endPeriod = int.parse(parts[1]);
                          });
                        }
                      },
                      validator: (value) {
                        if (value == null) return 'Vui lòng chọn ca học';
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _classroomController,
                      decoration: const InputDecoration(
                        labelText: 'Phòng học',
                        prefixIcon: Icon(Icons.room),
                        border: OutlineInputBorder(),
                        hintText: 'Ví dụ: A2-329',
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Vui lòng nhập phòng học';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _submitMakeupSession,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text(
                          'Gửi yêu cầu',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
