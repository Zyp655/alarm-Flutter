import 'package:flutter/material.dart';
import '../../../schedule/presentation/pages/schedule_page.dart';
import '../../../task/presentation/pages/tasks_page.dart';
import '../../../user/presentation/pages/profile_page.dart';
import '../../../teaching/presentation/pages/student_assignments_page.dart';

class MainWrapperPage extends StatefulWidget {
  const MainWrapperPage({super.key});

  @override
  State<MainWrapperPage> createState() => _MainWrapperPageState();
}

class _MainWrapperPageState extends State<MainWrapperPage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const SchedulePage(),
    const StudentAssignmentsPage(),
    const TasksPage(),
    const ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month),
            label: 'Lịch Học',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment),
            label: 'Bài Tập',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.task_alt), label: 'Cá Nhân'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Hồ Sơ'),
        ],
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
