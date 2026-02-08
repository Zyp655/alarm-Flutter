import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../schedule/presentation/pages/schedule_page.dart';
import '../../../task/presentation/pages/tasks_page.dart';
import '../../../user/presentation/pages/profile_page.dart';
import '../../../teaching/presentation/pages/student_assignments_page.dart';
import '../../../course/presentation/pages/course_catalog_page.dart';
import '../../../course/presentation/bloc/course_list_bloc.dart';
import '../../../roadmap/presentation/pages/learning_paths_page.dart';
import '../../../../injection_container.dart';

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
    BlocProvider(
      create: (context) => sl<CourseListBloc>(),
      child: const CourseCatalogPage(),
    ),
    const LearningPathsPage(),
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
          BottomNavigationBarItem(icon: Icon(Icons.school), label: 'Khóa Học'),
          BottomNavigationBarItem(icon: Icon(Icons.route), label: 'Lộ Trình'),
          BottomNavigationBarItem(icon: Icon(Icons.task_alt), label: 'Cá Nhân'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Hồ Sơ'),
        ],
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
