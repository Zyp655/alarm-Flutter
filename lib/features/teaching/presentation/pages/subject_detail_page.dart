import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/subject_entity.dart';
import '../../../schedule/domain/enitities/schedule_entity.dart';
import '../bloc/teacher_bloc.dart';
import '../bloc/teacher_event.dart';
import '../bloc/teacher_state.dart';
import 'teacher_calendar_tab.dart';
import 'teacher_subject_classes_page.dart';

class SubjectDetailPage extends StatefulWidget {
  final SubjectEntity subject;
  final int teacherId;

  const SubjectDetailPage({
    super.key,
    required this.subject,
    required this.teacherId,
  });

  @override
  State<SubjectDetailPage> createState() => _SubjectDetailPageState();
}

class _SubjectDetailPageState extends State<SubjectDetailPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<ScheduleEntity> _schedules = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    context.read<TeacherBloc>().add(LoadTeacherClasses(widget.teacherId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.subject.name),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.yellow,
          tabs: const [
            Tab(icon: Icon(Icons.calendar_month), text: "Lịch Dạy (Calendar)"),
            Tab(icon: Icon(Icons.list), text: "Danh Sách Lớp"),
          ],
        ),
      ),
      body: BlocListener<TeacherBloc, TeacherState>(
        listener: (context, state) {
          if (state is TeacherLoaded) {
            setState(() {
              _schedules = state.schedules;
            });
          }
        },
        child: BlocBuilder<TeacherBloc, TeacherState>(
          builder: (context, state) {
            if (_schedules.isEmpty && state is TeacherLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (_schedules.isEmpty && state is TeacherError) {
              return Center(child: Text("Lỗi: ${state.message}"));
            }

            return TabBarView(
              controller: _tabController,
              children: [
                TeacherCalendarTab(
                  subjectName: widget.subject.name,
                  teacherId: widget.teacherId,
                  schedules: _schedules,
                ),
                TeacherSubjectClassesPage(
                  subjectName: widget.subject.name,
                  allSchedules: _schedules,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
