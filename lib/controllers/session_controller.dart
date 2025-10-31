// lib/controllers/session_controller.dart
import 'package:get/get.dart';
import 'package:frontend_app/models/session.dart';
import 'package:frontend_app/services/api_service.dart';

class SessionController extends GetxController {
  final ApiService _apiService = ApiService();

  var isLoading = true.obs;
  var sessionList = <Session>[].obs; // Danh sách đầy đủ từ API

  // BIẾN MỚI: Dùng để lọc
  var selectedDate = DateTime.now().obs;

  @override
  void onInit() {
    super.onInit();
    fetchSessions();
  }

  Future<void> fetchSessions() async {
    try {
      isLoading(true);
      final sessions = await _apiService.getSessions();
      sessionList.assignAll(sessions); // Gán vào danh sách đầy đủ
    } catch (e) {
      Get.snackbar('Lỗi', 'Không thể tải danh sách buổi học.');
    } finally {
      isLoading(false);
    }
  }

  // HÀM MỚI: Để thay đổi ngày
  void changeSelectedDate(DateTime date) {
    selectedDate.value = date;
  }

  // GETTER MỚI: Tự động lọc danh sách
  List<Session> get filteredSessions {

    return sessionList.where((session) {
      // So sánh Y-M-D (bỏ qua giờ, phút)
      return session.sessionDate.year == selectedDate.value.year &&
          session.sessionDate.month == selectedDate.value.month &&
          session.sessionDate.day == selectedDate.value.day;
    }).toList();
  }
}