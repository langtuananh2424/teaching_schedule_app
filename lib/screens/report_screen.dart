import 'package:flutter/material.dart';
import '../services/api_service.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  String selectedSemester = "HK_1 2025 - 2026";
  String selectedTeacher = "Nguyễn Văn A";
  String selectedClass = "64KTPM3 - PTUDCTBDD";

  Map<String, dynamic>? report;
  bool loading = false;

  Future<void> _loadReport() async {
    setState(() => loading = true);
    final data = await ApiService.getReportSummary(
      semester: selectedSemester,
      teacher: selectedTeacher,
      className: selectedClass,
    );
    await Future.delayed(const Duration(milliseconds: 500)); // mô phỏng API
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
        title: const Text("Báo cáo giảng dạy"),
        backgroundColor: const Color(0xFF0D5CA8),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ----------- TÙY CHỌN BÁO CÁO -----------
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
                children: [
                  const Text(
                    "Tùy chọn báo cáo",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Color(0xFF0D5CA8)),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: selectedSemester,
                    decoration: const InputDecoration(
                      labelText: "Học kỳ",
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(
                          value: "HK_1 2025 - 2026",
                          child: Text("HK_1 2025 - 2026")),
                      DropdownMenuItem(
                          value: "HK_2 2024 - 2025",
                          child: Text("HK_2 2024 - 2025")),
                    ],
                    onChanged: (value) => setState(() {
                      selectedSemester = value!;
                    }),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: selectedTeacher,
                    decoration: const InputDecoration(
                      labelText: "Giảng viên",
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(
                          value: "Nguyễn Văn A", child: Text("Nguyễn Văn A")),
                      DropdownMenuItem(
                          value: "Thầy Dũng", child: Text("Thầy Dũng")),
                    ],
                    onChanged: (value) => setState(() {
                      selectedTeacher = value!;
                    }),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: selectedClass,
                    decoration: const InputDecoration(
                      labelText: "Lớp học phần",
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(
                          value: "64KTPM3 - PTUDCTBDD",
                          child: Text("64KTPM3 - PTUDCTBDD")),
                      DropdownMenuItem(
                          value: "64CNTT1 - PTMNM",
                          child: Text("64CNTT1 - PTMNM")),
                    ],
                    onChanged: (value) => setState(() {
                      selectedClass = value!;
                    }),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadReport,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0D5CA8),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32, vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text("Xem báo cáo",
                        style: TextStyle(color: Colors.white, fontSize: 16)),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ----------- KẾT QUẢ TỔNG HỢP -----------
            if (loading)
              const Center(child: CircularProgressIndicator())
            else if (report != null)
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
                  children: [
                    const Text(
                      "Kết quả tổng hợp",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Color(0xFF0D5CA8)),
                    ),
                    const SizedBox(height: 12),

                    // ✅ Nếu null -> hiển thị "3 giờ"
                    _infoRow("🟢 Giờ giảng hoàn thành:",
                        "${report!["completed"] ?? 0} giờ"),
                    _infoRow("🔴 Giờ giảng đã nghỉ:",
                        "${report!["absent_hours"] ?? 3} giờ"),
                    _infoRow("🔵 Giờ giảng đã bù:",
                        "${report!["makeup_hours"] ?? 3} giờ"),
                    _infoRow("⭐ Chuyên cần lớp:",
                        "${report!["attendance"] ?? 95.8}%"),
                    const SizedBox(height: 16),

                    Center(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/report-detail');
                        },
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFF0D5CA8)),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text(
                          "Xem chi tiết",
                          style: TextStyle(
                            color: Color(0xFF0D5CA8),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            else
              const Center(
                child: Text(
                  "Vui lòng chọn thông tin và nhấn 'Xem báo cáo'",
                  style: TextStyle(color: Colors.black54),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title,
              style:
              const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
          Text(value,
              style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87)),
        ],
      ),
    );
  }
}
