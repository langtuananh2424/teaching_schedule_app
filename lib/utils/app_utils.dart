import 'package:intl/intl.dart';

class AppUtils {
  // Định dạng ngày tháng
  static String formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

// Hiển thị một SnackBar thông báo
// static void showSnackBar(BuildContext context, String message) {
//   ScaffoldMessenger.of(context).showSnackBar(
//     SnackBar(content: Text(message)),
//   );
// }
}