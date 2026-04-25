import 'package:flutter/material.dart';

class FaceRegisterPage extends StatelessWidget {
  final int userId;
  final VoidCallback onComplete;

  const FaceRegisterPage({
    super.key,
    required this.userId,
    required this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.desktop_access_disabled, color: Colors.white54, size: 64),
            const SizedBox(height: 16),
            const Text(
              'Xác thực khuôn mặt chỉ khả dụng trên ứng dụng di động',
              style: TextStyle(color: Colors.white70, fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: onComplete,
              child: const Text('Tiếp tục'),
            ),
          ],
        ),
      ),
    );
  }
}
