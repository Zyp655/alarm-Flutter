import 'package:flutter/material.dart';
import '../../../../features/user/presentation/pages/profile_page.dart';
import 'teacher_courses_page.dart';
import 'teacher_students_page.dart';
import 'teacher_course_stats_page.dart';
import '../../../roadmap/presentation/pages/learning_paths_page.dart';

class TeacherDashboardPage extends StatefulWidget {
  final int teacherId;

  const TeacherDashboardPage({super.key, required this.teacherId});

  @override
  State<TeacherDashboardPage> createState() => _TeacherDashboardPageState();
}

class _TeacherDashboardPageState extends State<TeacherDashboardPage> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {

    final List<Widget> pages = [
      _buildDashboardGrid(),
      const ProfilePage(),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      body: pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Hồ sơ'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: const Color(0xFF6C63FF),
        unselectedItemColor: Colors.grey,
        backgroundColor: const Color(0xFF16213E),
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }

  Widget _buildDashboardGrid() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Teacher Dashboard',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Quản lý nội dung và học viên của bạn',
              style: TextStyle(color: Colors.grey[400], fontSize: 14),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.1,
                children: [
                  _buildDashboardTile(
                    icon: Icons.school,
                    color: const Color(0xFF6C63FF),
                    title: 'Khóa học',
                    subtitle: 'Quản lý khóa học',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            TeacherCoursesPage(teacherId: widget.teacherId),
                      ),
                    ),
                  ),
                  _buildDashboardTile(
                    icon: Icons.map,
                    color: Colors.orange,
                    title: 'Roadmap',
                    subtitle: 'Lộ trình học tập',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const LearningPathsPage(),
                      ),
                    ),
                  ),
                  _buildDashboardTile(
                    icon: Icons.people,
                    color: Colors.green,
                    title: 'Học viên',
                    subtitle: 'Quản lý học viên',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            TeacherStudentsPage(teacherId: widget.teacherId),
                      ),
                    ),
                  ),
                  _buildDashboardTile(
                    icon: Icons.bar_chart,
                    color: Colors.blueAccent,
                    title: 'Thống kê',
                    subtitle: 'Hiệu suất khóa học',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            TeacherCourseStatsPage(teacherId: widget.teacherId),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardTile({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: const Color(0xFF16213E),
      borderRadius: BorderRadius.circular(20),
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 32, color: color),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[400], fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
