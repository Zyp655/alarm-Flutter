import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import '../../../schedule/domain/enitities/schedule_entity.dart';
import '../../../schedule/presentation/widgets/schedule_data_source.dart'; 
import '../bloc/teacher_bloc.dart';
import '../bloc/teacher_state.dart';
import 'teacher_student_list_page.dart'; 

class TeacherCalendarTab extends StatelessWidget {
  final String subjectName;

  const TeacherCalendarTab({super.key, required this.subjectName});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TeacherBloc, TeacherState>(
      builder: (context, state) {
        if (state is TeacherLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        List<ScheduleEntity> schedules = [];
        if (state is TeacherLoaded) {
          schedules = state.schedules.where((s) => s.subject == subjectName).toList();
        }

        if (schedules.isEmpty) {
          return const Center(child: Text("Chưa có lịch dạy nào cho môn này."));
        }

        return SfCalendar(
          view: CalendarView.week, 
          firstDayOfWeek: 1,
          dataSource: ScheduleDataSource(schedules),
          timeSlotViewSettings: const TimeSlotViewSettings(
            startHour: 6,
            endHour: 23,
            timeFormat: 'H:mm',
          ),
          onTap: (CalendarTapDetails details) {
            if (details.appointments != null && details.appointments!.isNotEmpty) {
              final schedule = details.appointments!.first as ScheduleEntity;
              _showScheduleOptions(context, schedule, state is TeacherLoaded ? state.schedules : []);
            }
          },
        );
      },
    );
  }

  void _showScheduleOptions(BuildContext context, ScheduleEntity schedule, List<ScheduleEntity> allSchedules) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => Wrap(
        children: [
          ListTile(
            leading: const Icon(Icons.people, color: Colors.blue),
            title: const Text('Quản lý Sinh viên / Điểm danh'),
            subtitle: Text('${schedule.subject} - ${schedule.room}'),
            onTap: () {
              Navigator.pop(ctx);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => BlocProvider.value(
                    value: context.read<TeacherBloc>(),
                    child: TeacherStudentListPage(
                      subjectName: subjectName,
                      allSchedules: allSchedules,
                      selectedDate: schedule.start,
                      weekIndex: null, 
                    ),
                  ),
                ),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.edit, color: Colors.orange),
            title: const Text('Sửa thông tin lớp (Phòng, Giờ)'),
            onTap: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Tính năng Sửa Lớp đang phát triển")));
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete, color: Colors.red),
            title: const Text('Xóa lịch học này'),
            onTap: () {
              Navigator.pop(ctx);
              _confirmDeleteSchedule(context, schedule);
            },
          ),
        ],
      ),
    );
  }

  void _confirmDeleteSchedule(BuildContext context, ScheduleEntity schedule) {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Tính năng Xóa Lớp đang phát triển")));
  }
}