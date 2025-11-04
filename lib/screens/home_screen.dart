import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'pending_absent_screen.dart';
import 'pending_makeup_screen.dart';
import 'report_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  List<dynamic> pendingList = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadPending();
  }

  Future<void> _loadPending() async {
    final data = await ApiService.getPendingAssignments();
    setState(() {
      pendingList = data;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),

      // 👉 Hiển thị nội dung theo tab
      body: SafeArea(
        child: IndexedStack(
          index: _currentIndex,
          children: [
            _HomeTab(
              loading: loading,
              pendingList: pendingList,
            ),
            const ReportScreen(),
            const _AccountTab(),
          ],
        ),
      ),

      // 👉 Thanh điều hướng dưới
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: const Color(0xFF0F5FA8),
        unselectedItemColor: Colors.grey,
        onTap: (i) => setState(() => _currentIndex = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Trang chủ'),
          BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart_outlined), label: 'Báo cáo'),
          BottomNavigationBarItem(
              icon: Icon(Icons.account_circle_outlined), label: 'Tài khoản'),
        ],
      ),
    );
  }
}

// -----------------------------
// 🏠 Trang chủ (Tab 1)
// -----------------------------
class _HomeTab extends StatelessWidget {
  final bool loading;
  final List<dynamic> pendingList;

  const _HomeTab({
    required this.loading,
    required this.pendingList,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Chào, Thầy Dũng của phòng đào tạo",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F5FA8),
            ),
          ),
          const SizedBox(height: 20),
          const Text("Tổng quan nhanh",
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
          const SizedBox(height: 10),

          // Hai ô tổng quan
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const PendingAbsentScreen()),
                  ),
                  child: _buildQuickBox("3 yêu cầu nghỉ chờ duyệt"),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const PendingMakeupScreen()),
                  ),
                  child: _buildQuickBox("2 yêu cầu dạy bù chờ duyệt"),
                ),
              ),
            ],
          ),

          const SizedBox(height: 22),
          const Text("Cần phê duyệt gần đây",
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
          const SizedBox(height: 10),

          if (loading)
            const Center(child: CircularProgressIndicator())
          else if (pendingList.isEmpty)
            const Text("Không có yêu cầu nào cần phê duyệt.")
          else
            Column(
              children: pendingList
                  .take(2)
                  .map((e) => _buildPendingCard(
                  e["title"], e["subject"], e["status"]))
                  .toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildQuickBox(String text) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Center(
        child: Text(text,
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.w500)),
      ),
    );
  }

  Widget _buildPendingCard(String title, String subtitle, String status) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style:
              const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
          const SizedBox(height: 4),
          Text(subtitle, style: const TextStyle(color: Colors.black54)),
        ],
      ),
    );
  }
}

// -----------------------------
// 👤 Tài khoản (Tab 3)
// -----------------------------
class _AccountTab extends StatelessWidget {
  const _AccountTab();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        "Thông tin tài khoản\n(Sẽ cập nhật sau)",
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 16, color: Colors.black54),
      ),
    );
  }
}
