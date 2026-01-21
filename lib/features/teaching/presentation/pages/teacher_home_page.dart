import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../injection_container.dart';
import '../bloc/teacher_bloc.dart';
import '../../../user/presentation/pages/profile_page.dart';
import 'teacher_subject_list_page.dart';
import 'teacher_tasks_page.dart';

class TeacherHomePage extends StatefulWidget {
  const TeacherHomePage({super.key});

  @override
  State<TeacherHomePage> createState() => _TeacherHomePageState();
}

class _TeacherHomePageState extends State<TeacherHomePage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const TeacherSubjectListPage(),
    const TeacherTasksPage(),
    const ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<TeacherBloc>(),
      child: Scaffold(
        body: _pages[_currentIndex],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          selectedItemColor: Colors.blueAccent,
          unselectedItemColor: Colors.grey,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.class_),
              label: "Môn Học ",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.assignment),
              label: "Bài tập",
            ),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: "Cá nhân"),
          ],
        ),
      ),
    );
  }
}
