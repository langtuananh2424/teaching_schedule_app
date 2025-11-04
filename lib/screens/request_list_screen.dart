
import 'package:flutter/material.dart';

class RequestListScreen extends StatelessWidget {
  const RequestListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Yêu cầu dạy bù chờ duyệt'), backgroundColor: const Color(0xFF0F5FA8)),
      body: ListView.builder(padding: const EdgeInsets.all(12), itemCount: 3, itemBuilder: (context, index) {
        return Container(margin: const EdgeInsets.symmetric(vertical: 8), padding: const EdgeInsets.all(12), decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade300), color: Colors.white), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('[Dạy bù] GV: Trần Văn An', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          const Text('Môn: Mạng máy tính'),
          const SizedBox(height: 6),
          const Text('20/09/2025'),
          const SizedBox(height: 10),
          Row(children: [
            ElevatedButton(onPressed: () {}, style: ElevatedButton.styleFrom(backgroundColor: Colors.green, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))), child: const Text('Duyệt')),
            const SizedBox(width: 8),
            ElevatedButton(onPressed: () {}, style: ElevatedButton.styleFrom(backgroundColor: Colors.red, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))), child: const Text('Từ chối')),
          ])
        ]));
      }),
    );
  }
}
