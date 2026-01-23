import 'package:flutter/material.dart';

class TasksPage extends StatelessWidget {
  const TasksPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Deadline & Bài Tập")),
      body: const Center(child: Text("Danh sách bài tập sẽ hiện ở đây")),
    );
  }
}
