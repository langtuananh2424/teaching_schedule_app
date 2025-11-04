import 'package:flutter/material.dart';
import '../services/api_service.dart';

class ReportDetailScreen extends StatefulWidget {
  const ReportDetailScreen({super.key});

  @override
  State<ReportDetailScreen> createState() => _ReportDetailScreenState();
}

class _ReportDetailScreenState extends State<ReportDetailScreen> {
  bool loading = true;
  Map<String, dynamic>? report;

  @override
  void initState() {
    super.initState();
    _loadDetail();
  }

  Future<void> _loadDetail() async {
    final data = await ApiService.getReportSummary(
      semester: "HK1-2025",
      teacher: "Nguyễn Văn A",
      className: "64CNTT1",
    );
    await Future.delayed(const Duration(milliseconds: 600)); // giả delay API
    setState(() {
      report = data;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text("Chi tiết báo cáo"),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Thông tin giảng viên
            Container(
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
                children: const [
                  Text(
                    "👨‍🏫  Nguyễn Văn A",
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    "Khoa: Công nghệ thông tin",
                    style: TextStyle(color: Colors.black54),
                  ),
                  Text(
                    "Lớp: 64CNTT1 - PTMNM",
                    style: TextStyle(color: Colors.black54),
                  ),
                  Text(
                    "Học kỳ: HK I_2025 - 2026",
                    style: TextStyle(color: Colors.black54),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // --- Tổng quan lớp học phần
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "TỔNG QUAN LỚP HỌC PHẦN",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      color: Color(0xFF0D5CA8),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Hoàn thành: ${report!["completed"]}/30 giờ",
                        style: const TextStyle(fontSize: 15),
                      ),
                      const Text(
                        "90%",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: 0.9,
                      color: Colors.orange,
                      backgroundColor: Colors.grey.shade200,
                      minHeight: 10,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text("Giờ nghỉ: 3 giờ     Giờ bù: 3 giờ"),
                  Text(
                    "Chuyên cần trung bình: ${report!["attendance"]}%",
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // --- Danh sách sinh viên
            const Text(
              "CHI TIẾT CHUYÊN CẦN (60 Sinh viên)",
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 15,
                color: Color(0xFF0D5CA8),
              ),
            ),
            const SizedBox(height: 12),
            ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: 6, // demo 6 sinh viên
              itemBuilder: (context, index) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: Colors.grey.withOpacity(0.3), width: 1),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        "Hoàng Văn A - 2251172xxx",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "Có mặt: 26 | Vắng: 1 (1 P, 0 KP)",
                        style: TextStyle(color: Colors.black54),
                      ),
                      SizedBox(height: 2),
                      Text(
                        "96,1%",
                        style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),

            const SizedBox(height: 20),

            // --- Nút Xuất ra Excel (đã chỉnh màu trắng)
            Center(
              child: ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Đang xuất file Excel..."),
                    ),
                  );
                },
                icon: const Icon(
                  Icons.download_rounded,
                  color: Colors.white, // icon trắng
                ),
                label: const Text(
                  "Xuất ra excel",
                  style: TextStyle(
                    color: Colors.white, // chữ trắng
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0D5CA8), // nền xanh dương
                  padding: const EdgeInsets.symmetric(
                      horizontal: 26, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 3,
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
