import 'package:flutter/material.dart';
import 'request_detail_screen.dart'; // thêm dòng này

class PendingAbsentScreen extends StatefulWidget {
  const PendingAbsentScreen({Key? key}) : super(key: key);

  @override
  State<PendingAbsentScreen> createState() => _PendingAbsentScreenState();
}

class _PendingAbsentScreenState extends State<PendingAbsentScreen> {
  List<Map<String, dynamic>> items = [
    {
      "teacher": "Trần Văn An",
      "subject": "Mạng máy tính",
      "date": "20/09/2025",
      "status": "Chờ duyệt",
      "reason": "Tham dự hội thảo"
    },
    {
      "teacher": "Nguyễn Văn A",
      "subject": "Lập trình nâng cao",
      "date": "21/09/2025",
      "status": "Chờ duyệt",
      "reason": "Ốm đột xuất"
    },
    {
      "teacher": "Trần Quang D",
      "subject": "CTDL&GT",
      "date": "22/09/2025",
      "status": "Chờ duyệt",
      "reason": "Việc gia đình"
    },
  ];

  void _handleAction(int index, String action) {
    setState(() {
      items[index]["status"] = action == "approve" ? "Đã duyệt" : "Từ chối";
    });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(action == "approve"
          ? "✅ Đã duyệt yêu cầu của ${items[index]["teacher"]}"
          : "❌ Đã từ chối yêu cầu của ${items[index]["teacher"]}"),
      backgroundColor: action == "approve" ? Colors.green : Colors.red,
      duration: const Duration(seconds: 2),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Yêu cầu nghỉ chờ duyệt"),
        backgroundColor: const Color(0xFF0F5FA8),
      ),
      backgroundColor: const Color(0xFFF8F9FB),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => RequestDetailScreen(request: item)),
              );
            },
            child: _buildCard(item, index),
          );
        },
      ),
    );
  }

  Widget _buildCard(Map<String, dynamic> item, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade400),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("[Nghỉ dạy] GV: ${item["teacher"]}",
              style: const TextStyle(fontWeight: FontWeight.bold)),
          Text("Môn: ${item["subject"]}"),
          Text(item["date"]),
          const SizedBox(height: 6),
          Text(
            "Trạng thái: ${item["status"]}",
            style: const TextStyle(
                color: Colors.orange, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          if (item["status"] == "Chờ duyệt")
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _buildButton("Duyệt", Colors.green,
                        () => _handleAction(index, "approve")),
                const SizedBox(width: 8),
                _buildButton("Từ chối", Colors.red,
                        () => _handleAction(index, "reject")),
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
