import 'package:flutter/material.dart';
import '../services/api_service.dart';

class RequestDetailScreen extends StatefulWidget {
  final Map<String, dynamic> request;

  const RequestDetailScreen({super.key, required this.request});

  @override
  State<RequestDetailScreen> createState() => _RequestDetailScreenState();
}

class _RequestDetailScreenState extends State<RequestDetailScreen> {
  late String status;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    status = widget.request["status"] ?? "Chờ duyệt";
  }

  Future<void> _updateStatus(String newStatus) async {
    setState(() => isLoading = true);

    // Gọi API cập nhật trạng thái
    final success = await ApiService.updateRequestStatus(
      widget.request["id"],
      newStatus,
    );

    setState(() {
      isLoading = false;
      if (success) status = newStatus;
    });

    // Hiển thị snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success
            ? "Cập nhật trạng thái thành công: $newStatus"
            : "Cập nhật thất bại"),
        backgroundColor: success ? Colors.green : Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final req = widget.request;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Chi tiết yêu cầu"),
        backgroundColor: const Color(0xFF0D5CA8),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.15),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _infoRow("Người yêu cầu:", req["teacher"] ?? "GV Trần Văn An"),
              _infoRow("Loại yêu cầu:", req["type"] ?? "Đăng ký nghỉ"),
              _infoRow("Môn học:", req["subject"] ?? "Mạng máy tính"),
              _infoRow("Lớp:", req["class"] ?? "64KTPM3"),
              _infoRow("Thời gian:", req["time"] ?? "Tiết 1-3, 20/09/2025"),
              _infoRow("Lý do:", req["reason"] ?? "Tham dự hội thảo"),
              const SizedBox(height: 20),

              const Center(
                child: Text(
                  "Trạng thái",
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87),
                ),
              ),
              const SizedBox(height: 10),

              if (isLoading)
                const Center(child: CircularProgressIndicator())
              else
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Nút phê duyệt
                      ElevatedButton.icon(
                        onPressed: status == "Phê duyệt"
                            ? null
                            : () => _updateStatus("Phê duyệt"),
                        icon: const Icon(Icons.check_circle, color: Colors.white),
                        label: const Text("Phê duyệt"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(width: 20),
                      // Nút từ chối
                      OutlinedButton.icon(
                        onPressed: status == "Từ chối"
                            ? null
                            : () => _updateStatus("Từ chối"),
                        icon: const Icon(Icons.close, color: Colors.red),
                        label: const Text(
                          "Từ chối",
                          style: TextStyle(color: Colors.red),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.red),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 20),

              Center(
                child: Text(
                  "Trạng thái hiện tại: $status",
                  style: TextStyle(
                    color: status == "Phê duyệt"
                        ? Colors.green
                        : status == "Từ chối"
                        ? Colors.red
                        : Colors.orange,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 120, child: Text(title, style: const TextStyle(fontWeight: FontWeight.w500))),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
