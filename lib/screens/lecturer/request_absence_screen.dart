import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';
import '../../models/session.dart';
import 'package:intl/intl.dart';

class RequestAbsenceScreen extends StatefulWidget {
  final Session session;

  const RequestAbsenceScreen({super.key, required this.session});

  @override
  State<RequestAbsenceScreen> createState() => _RequestAbsenceScreenState();
}

class _RequestAbsenceScreenState extends State<RequestAbsenceScreen> {
  final _formKey = GlobalKey<FormState>();
  final _reasonController = TextEditingController();
  final _apiService = ApiService();
  bool _isLoading = false;
  bool _includeMakeup = false;

  // File proof
  String? _proofFileName;
  // ignore: unused_field
  String?
  _proofFilePath; // TODO: Sẽ dùng để upload file khi backend hỗ trợ multipart/form-data

  // Makeup fields
  DateTime? _makeupDate;
  int? _makeupStartPeriod;
  int? _makeupEndPeriod;
  String? _makeupClassroom;

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _submitRequest() async {
    if (!_formKey.currentState!.validate()) return;

    final authService = Provider.of<AuthService>(context, listen: false);
    final token = authService.token;
    final lecturerId = authService.userId; // Lấy userId từ token

    if (token == null) {
      _showError('Vui lòng đăng nhập lại');
      return;
    }

    if (lecturerId == null) {
      _showError('Không tìm thấy thông tin giảng viên');
      return;
    }

    setState(() => _isLoading = true);

    try {
      print('📤 Gửi absence request:');
      print('  sessionId: ${widget.session.sessionId}');
      print('  lecturerId: $lecturerId');
      print('  reason: ${_reasonController.text}');
      print('  makeupDate: $_makeupDate');
      print('  makeupStartPeriod: $_makeupStartPeriod');
      print('  makeupEndPeriod: $_makeupEndPeriod');
      print('  makeupClassroom: $_makeupClassroom');

      await _apiService.createAbsenceRequest(
        token,
        sessionId: widget.session.sessionId,
        lecturerId: lecturerId,
        reason: _reasonController.text,
        makeupDate: _includeMakeup ? _makeupDate : null,
        makeupStartPeriod: _includeMakeup ? _makeupStartPeriod : null,
        makeupEndPeriod: _includeMakeup ? _makeupEndPeriod : null,
        makeupClassroom: _includeMakeup ? _makeupClassroom : null,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gửi yêu cầu xin nghỉ thành công'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true); // Trả về true để reload
      }
    } catch (e) {
      print('❌ Lỗi gửi absence request: $e');
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

  Future<void> _selectProofFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png', 'doc', 'docx'],
      );

      if (result != null) {
        setState(() {
          _proofFileName = result.files.single.name;
          _proofFilePath = result.files.single.path;
        });
      }
    } catch (e) {
      _showError('Lỗi khi chọn file: ${e.toString()}');
    }
  }

  Future<void> _selectMakeupDate() async {
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
    final sessionInfo =
        '${widget.session.subjectName}, ${widget.session.className}\n'
        '${widget.session.classroom}\n'
        'Trạng thái: ${widget.session.statusDisplay.text}';

    return Scaffold(
      appBar: AppBar(title: const Text('Đăng ký nghỉ')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                sessionInfo,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 24),

              TextFormField(
                controller: _reasonController,
                decoration: const InputDecoration(
                  labelText: 'Lý do nghỉ *',
                  border: OutlineInputBorder(),
                ),
                maxLines: 4,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Vui lòng nhập lý do nghỉ';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),
              const Text(
                'Minh chứng (Tuỳ chọn)',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: _selectProofFile,
                icon: const Icon(Icons.attach_file),
                label: const Text('Chọn tệp'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                ),
              ),
              if (_proofFileName != null) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: Colors.green.shade700,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _proofFileName!,
                          style: TextStyle(color: Colors.green.shade700),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          setState(() {
                            _proofFileName = null;
                            _proofFilePath = null;
                          });
                        },
                        color: Colors.red,
                        iconSize: 20,
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 16),
              CheckboxListTile(
                title: const Text('Đề xuất lịch dạy bù'),
                value: _includeMakeup,
                onChanged: (value) =>
                    setState(() => _includeMakeup = value ?? false),
              ),

              if (_includeMakeup) ...[
                const SizedBox(height: 16),
                ListTile(
                  title: Text(
                    _makeupDate == null
                        ? 'Chọn ngày dạy bù *'
                        : 'Ngày: ${DateFormat('dd/MM/yyyy').format(_makeupDate!)}',
                  ),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: _selectMakeupDate,
                  tileColor: Colors.grey[100],
                ),

                const SizedBox(height: 16),
                DropdownButtonFormField<int>(
                  decoration: const InputDecoration(
                    labelText: 'Tiết bắt đầu *',
                    border: OutlineInputBorder(),
                  ),
                  initialValue: _makeupStartPeriod,
                  items: List.generate(12, (i) => i + 1)
                      .map(
                        (p) => DropdownMenuItem(
                      value: p,
                      child: Text('Tiết $p'),
                    ),
                  )
                      .toList(),
                  onChanged: (value) =>
                      setState(() => _makeupStartPeriod = value),
                  validator: _includeMakeup
                      ? (value) =>
                  value == null ? 'Chọn tiết bắt đầu' : null
                      : null,
                ),

                const SizedBox(height: 16),
                DropdownButtonFormField<int>(
                  decoration: const InputDecoration(
                    labelText: 'Tiết kết thúc *',
                    border: OutlineInputBorder(),
                  ),
                  initialValue: _makeupEndPeriod,
                  items: List.generate(12, (i) => i + 1)
                      .map(
                        (p) => DropdownMenuItem(
                      value: p,
                      child: Text('Tiết $p'),
                    ),
                  )
                      .toList(),
                  onChanged: (value) =>
                      setState(() => _makeupEndPeriod = value),
                  validator: _includeMakeup
                      ? (value) =>
                  value == null ? 'Chọn tiết kết thúc' : null
                      : null,
                ),

                const SizedBox(height: 16),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Phòng học *',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) => _makeupClassroom = value,
                  validator: _includeMakeup
                      ? (value) => value == null || value.isEmpty
                      ? 'Nhập phòng học'
                      : null
                      : null,
                ),
              ],

              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitRequest,
                  child: const Text('Gửi yêu cầu'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}