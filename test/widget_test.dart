import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_app/screens//schedule_screen.dart';

void main() {
  testWidgets('ScheduleScreen hiển thị đúng các thành phần', (WidgetTester tester) async {
    // Xây dựng chỉ ScheduleScreen.
    // Bạn cần bọc nó trong MaterialApp để cung cấp context cần thiết (như directionality).
    await tester.pumpWidget(MaterialApp(
      home: ScheduleScreen(),
    ));

    // Đợi tất cả các frame được render xong.
    await tester.pumpAndSettle();

    // --- Bắt đầu các kiểm tra ---

    // Cách tốt hơn để tìm AppBar là sử dụng kiểu (Type).
    expect(find.byType(AppBar), findsOneWidget);

    // Nếu bạn vẫn muốn kiểm tra tiêu đề, hãy tìm nó bên trong AppBar.
    // Điều này đảm bảo bạn đang kiểm tra đúng văn bản.
    expect(
      find.descendant(
        of: find.byType(AppBar),
        matching: find.text('Quay lại'), // Giả sử 'Quay lại' là tiêu đề
      ),
      findsOneWidget,
    );

    // Đối với thời gian "7:00", hãy tìm kiếm nó một cách cụ thể hơn nếu có thể.
    // Ví dụ, nếu nó nằm trong một ListTile, bạn có thể tìm ListTile đó trước.
    // Nếu "7:00" là đủ đặc trưng cho màn hình này, thì kiểm tra của bạn có thể vẫn ổn.
    expect(find.text('7:00'), findsOneWidget);

    // Ví dụ về một kiểm tra mạnh mẽ hơn:
    // expect(find.byKey(const Key('schedule_time_7_00')), findsOneWidget);
  });
}
