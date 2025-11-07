import 'package:flutter/material.dart';

class AppTheme {
  // Bảng màu chính cho trang quản lý
  static const Color primaryColor = Color(0xFF007BFF); // Màu xanh dương chính
  static const Color sidebarColor = Color(0xFF2c3e50); // Màu nền thanh sidebar
  static const Color backgroundColor = Color(0xFFF4F6F9); // Màu nền chính
  static const Color textColor = Color(0xFF333333); // Màu chữ chính
  static const Color headerColor = Colors.white; // Màu nền header

  // Định nghĩa Theme chính cho ứng dụng
  static final ThemeData lightTheme = ThemeData(
    primaryColor: primaryColor,
    scaffoldBackgroundColor: backgroundColor,
    fontFamily: 'Roboto', // Sử dụng font Roboto cho web
    // Cấu hình AppBar
    appBarTheme: const AppBarTheme(
      backgroundColor: headerColor,
      foregroundColor: textColor, // Màu chữ và icon trên AppBar
      elevation: 1,
      titleTextStyle: TextStyle(
        color: textColor,
        fontSize: 22,
        fontWeight: FontWeight.w500,
      ),
    ),

    // Cấu hình Nút bấm
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    ),

    // Cấu hình Thẻ (Card)
    cardTheme: CardThemeData(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
    ),

    // Cấu hình Bảng dữ liệu (DataTable)
    dataTableTheme: DataTableThemeData(
      headingRowColor: MaterialStateProperty.all(Colors.grey[100]),
      headingTextStyle: const TextStyle(
        fontWeight: FontWeight.bold,
        color: textColor,
      ),
      dataRowColor: MaterialStateProperty.all(Colors.white),
      dividerThickness: 1,
    ),

    // Cấu hình ô nhập liệu
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: const BorderSide(color: primaryColor, width: 2),
      ),
      labelStyle: TextStyle(color: Colors.grey[600]),
    ),

    // Cấu hình màu sắc chung
    colorScheme: ColorScheme.fromSwatch(
      primarySwatch: Colors.blue,
    ).copyWith(secondary: primaryColor),
  );
}
