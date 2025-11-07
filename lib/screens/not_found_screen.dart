// lib/screens/not_found_screen.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class NotFoundScreen extends StatelessWidget {
  const NotFoundScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              '404',
              style: TextStyle(fontSize: 100, fontWeight: FontWeight.bold),
            ),
            const Text('Trang không tồn tại', style: TextStyle(fontSize: 24)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => context.go('/'), // Go back to the home page
              child: const Text('Quay về trang chủ'),
            ),
          ],
        ),
      ),
    );
  }
}
