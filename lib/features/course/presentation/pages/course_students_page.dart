import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/course_students_bloc.dart';
import '../../../../injection_container.dart' as di;

class CourseStudentsPage extends StatelessWidget {
  final int courseId;
  final String courseTitle;

  const CourseStudentsPage({
    super.key,
    required this.courseId,
    required this.courseTitle,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          di.sl<CourseStudentsBloc>()..add(LoadCourseStudentsEvent(courseId)),
      child: Scaffold(
        appBar: AppBar(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Danh sách học viên'),
              Text(
                courseTitle,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
        body: BlocBuilder<CourseStudentsBloc, CourseStudentsState>(
          builder: (context, state) {
            if (state is CourseStudentsLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is CourseStudentsError) {
              return Center(child: Text(state.message));
            } else if (state is CourseStudentsLoaded) {
              if (state.students.isEmpty) {
                return const Center(child: Text('Chưa có học viên nào.'));
              }
              return ListView.builder(
                itemCount: state.students.length,
                itemBuilder: (context, index) {
                  final student = state.students[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage: student.avatarUrl != null
                          ? NetworkImage(student.avatarUrl!)
                          : null,
                      child: student.avatarUrl == null
                          ? Text(student.fullName[0].toUpperCase())
                          : null,
                    ),
                    title: Text(student.fullName),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(student.email),
                        const SizedBox(height: 4),
                        LinearProgressIndicator(
                          value: student.progressPercent / 100,
                          backgroundColor: Colors.grey[200],
                          color: student.progressPercent == 100
                              ? Colors.green
                              : Colors.blueAccent,
                        ),
                      ],
                    ),
                    trailing: Text(
                      '${student.progressPercent.toInt()}%',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  );
                },
              );
            }
            return const SizedBox();
          },
        ),
      ),
    );
  }
}
