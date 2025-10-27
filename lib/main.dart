import 'package:flutter/material.dart';
import 'package:frontend_app/Screen/schedule_screen.dart'; // Updated to match your folder

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Schedule App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: ScheduleScreen(),
    );
  }
}