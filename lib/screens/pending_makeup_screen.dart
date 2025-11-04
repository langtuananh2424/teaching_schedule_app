import 'package:flutter/material.dart';

class PendingMakeupScreen extends StatefulWidget {
  const PendingMakeupScreen({Key? key}) : super(key: key);

  @override
  State<PendingMakeupScreen> createState() => _PendingMakeupScreenState();
}

class _PendingMakeupScreenState extends State<PendingMakeupScreen> {
  List<Map<String, dynamic>> items = [
    {"teacher": "Trần Văn An", "subject": "Mạng máy tính", "date": "20/09/2025", "status": "Chờ duyệt"},
    {"teacher": "Nguyễn Văn A", "subject": "Lập trình nâng cao", "date": "21/09/2025", "status": "Chờ duyệt"},
  ];

  void _handleAction(int index, String action) {
    setState(() {
      items[index]["status"] = action == "approve" ? "Đã duyệt" : "Từ chối";
    });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(action == "approve"
          ? "✅ Đã duyệt yêu cầu dạy bù của ${items[index]["teacher"]}"
          : "❌ Đã từ chối yêu cầu dạy bù của ${items[index]["teacher"]}"),
      behavior: SnackBarBehavior.floating,
      backgroundColor: action == "approve" ? Colors.green : Colors.red,
      duration: const Duration(seconds: 2),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Yêu cầu dạy bù chờ duyệt"),
        backgroundColor: const Color(0xFF0F5FA8),
      ),
      backgroundColor: const Color(0xFFF8F9FB),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return _buildCard(item, index);
        },
      ),
    );
  }

  Widget _buildCard(Map<String, dynamic> item, int index) {
    Color statusColor;
    switch (item["status"]) {
      case "Đã duyệt":
        statusColor = Colors.green;
        break;
      case "Từ chối":
        statusColor = Colors.red;
        break;
      default:
        statusColor = Colors.orange;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade400),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            offset: const Offset(0, 3),
            blurRadius: 5,
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("[Dạy bù] GV: ${item["teacher"]}",
              style: const TextStyle(fontWeight: FontWeight.bold)),
          Text("Môn: ${item["subject"]}"),
          Text(item["date"] ?? ""),
          const SizedBox(height: 6),
          Text(
            "Trạng thái: ${item["status"]}",
            style: TextStyle(color: statusColor, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          if (item["status"] == "Chờ duyệt")
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _buildButton("Duyệt", Colors.green, () => _handleAction(index, "approve")),
                const SizedBox(width: 8),
                _buildButton("Từ chối", Colors.red, () => _handleAction(index, "reject")),
              ],
            )
        ],
      ),
    );
  }

  Widget _buildButton(String text, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color),
        ),
        child: Text(
          text,
          style: TextStyle(color: color, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
