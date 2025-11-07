import 'package:flutter/material.dart';
import '../../models/session.dart';
import 'attendance_screen.dart';
import 'request_absence_screen.dart';
import 'register_makeup_screen.dart';
import 'package:intl/intl.dart';

class SessionDetailsScreen extends StatefulWidget {
  final Session session;

  const SessionDetailsScreen({super.key, required this.session});

  @override
  State<SessionDetailsScreen> createState() => _SessionDetailsScreenState();
}

class _SessionDetailsScreenState extends State<SessionDetailsScreen> {
  final _contentController = TextEditingController();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _contentController.text = widget.session.content ?? '';
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  void _saveContent() {
    // TODO: Implement save content API
    setState(() => _isSaving = true);
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Lưu nội dung thành công'),
            backgroundColor: Colors.green,
          ),
        );
      }
    });
  }

  void _navigateToAttendance() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AttendanceScreen(session: widget.session),
      ),
    );
  }

  void _navigateToRequestAbsence() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RequestAbsenceScreen(session: widget.session),
      ),
    );

    if (result == true && mounted) {
      Navigator.pop(context, true);
    }
  }

  void _navigateToRegisterMakeup() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RegisterMakeupScreen(session: widget.session),
      ),
    );

    if (result == true && mounted) {
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final realtimeStatus = widget.session.realtimeStatus;

    // Logic hiển thị nút theo trạng thái
    final canEditContent =
        realtimeStatus == 'NOT_TAUGHT' ||
        realtimeStatus == 'ONGOING' ||
        realtimeStatus == 'ABSENT_APPROVED';

    final canRequestAbsence = realtimeStatus == 'NOT_TAUGHT';

    final canAttendance = realtimeStatus == 'ONGOING';

    final canRegisterMakeup = realtimeStatus == 'ABSENT_APPROVED';

    final isCompleted =
        realtimeStatus == 'TAUGHT' || realtimeStatus == 'MAKEUP_TAUGHT';

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.session.subjectName),
        backgroundColor: widget.session.statusDisplay.color,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildInfoCard(context),
            const SizedBox(height: 20),

            // Nội dung buổi học
            TextField(
              controller: _contentController,
              decoration: const InputDecoration(
                labelText: 'Nội dung buổi học',
                border: OutlineInputBorder(),
                hintText: 'Nhập nội dung đã dạy...',
              ),
              maxLines: 3,
              enabled: canEditContent,
            ),
            const SizedBox(height: 10),

            // Nút Lưu nội dung
            ElevatedButton(
              onPressed: (canEditContent && !_isSaving) ? _saveContent : null,
              child: _isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Lưu nội dung'),
            ),

            const SizedBox(height: 20),

            // Nút Điểm danh (chỉ hiện khi Đang diễn ra)
            if (canAttendance)
              ElevatedButton.icon(
                onPressed: _navigateToAttendance,
                icon: const Icon(Icons.check_circle),
                label: const Text('Điểm danh sinh viên'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
              ),

            if (canAttendance) const SizedBox(height: 10),

            // Hàng nút: Đăng ký nghỉ / Đăng ký dạy bù
            Row(
              children: [
                // Nút Đăng ký nghỉ (chỉ hiện khi Sắp diễn ra)
                if (canRequestAbsence)
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _navigateToRequestAbsence,
                      icon: const Icon(Icons.event_busy),
                      label: const Text('Đăng ký nghỉ'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),

                // Nút Đăng ký dạy bù (chỉ hiện khi Nghỉ)
                if (canRegisterMakeup)
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _navigateToRegisterMakeup,
                      icon: const Icon(Icons.event_available),
                      label: const Text('Đăng ký dạy bù'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
              ],
            ),

            // Thông báo khi hoàn thành
            if (isCompleted)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.green.shade700),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Buổi học đã hoàn thành. Không thể thao tác.',
                          style: TextStyle(
                            color: Colors.green.shade700,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    widget.session.subjectName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: widget.session.statusDisplay.color,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    widget.session.statusDisplay.text,
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ],
            ),
            const Divider(height: 20),
            _buildInfoRow(Icons.class_, 'Lớp', widget.session.className),
            _buildInfoRow(Icons.room, 'Phòng', widget.session.classroom),
            _buildInfoRow(
              Icons.access_time,
              'Thời gian',
              '${widget.session.formattedTime}, ${DateFormat('dd/MM/yyyy').format(widget.session.sessionDate)}',
            ),
            _buildInfoRow(
              Icons.schedule,
              'Tiết',
              'Tiết ${widget.session.startPeriod}-${widget.session.endPeriod}',
            ),
            if (widget.session.notes != null &&
                widget.session.notes!.isNotEmpty)
              _buildInfoRow(Icons.note, 'Ghi chú', widget.session.notes!),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(fontSize: 14, color: Colors.black87),
                children: [
                  TextSpan(
                    text: '$label: ',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(text: value),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
