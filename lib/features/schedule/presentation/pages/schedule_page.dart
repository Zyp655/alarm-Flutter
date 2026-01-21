import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

import '../../../../core/services/notification_service.dart';
import '../../../../injection_container.dart';
import '../../domain/enitities/schedule_entity.dart';
import '../bloc/schedule_bloc.dart';
import '../bloc/schedule_event.dart';
import '../bloc/schedule_state.dart';
import '../utils/excel_schedule_parser.dart';
import '../widgets/schedule_dialogs.dart';
import '../widgets/schedule_calendar_view.dart';

class SchedulePage extends StatefulWidget {
  const SchedulePage({super.key});

  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  final NotificationService _notificationService = NotificationService();
  final CalendarController _calendarController = CalendarController();

  @override
  void initState() {
    super.initState();
    _notificationService.requestPermissions();
  }


  Future<void> _pickAndParseExcel(BuildContext context) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx'],
      );

      if (result != null) {
        String filePath = result.files.single.path!;
        List<ScheduleEntity> parsedList = await ExcelScheduleParser.parse(
          filePath,
        );

        if (parsedList.isNotEmpty && mounted) {
          final config = await ScheduleDialogs.showImportConfig(
            context,
            parsedList.length,
          );

          if (config != null) {
            _saveAndSchedule(
              context,
              parsedList,
              config['minutes'],
              config['repeat'],
            );
          }
        }
      }
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Lỗi: $e")));
    }
  }

  void _saveAndSchedule(
    BuildContext context,
    List<ScheduleEntity> schedules,
    int minutesBefore,
    bool repeat,
  ) async {
    int successCount = 0;
    int ignoredCount = 0;

    for (var item in schedules) {
      context.read<ScheduleBloc>().add(AddScheduleRequested(item));

      final scheduledTime = item.start.subtract(
        Duration(minutes: minutesBefore),
      );
      if (!repeat && scheduledTime.isBefore(DateTime.now())) {
        ignoredCount++;
      } else {
        int notificationId = item.subject.hashCode + item.start.hashCode;
        await _notificationService.scheduleClassNotification(
          id: notificationId,
          subject: item.subject,
          room: item.room,
          startTime: item.start,
          minutesBefore: minutesBefore,
          isRepeating: repeat,
        );
        successCount++;
      }
    }

    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Đã lưu lịch học")));
    }
  }

  void _onManualAdd(BuildContext context) async {
    final result = await ScheduleDialogs.showScheduleForm(context);
    if (result != null && mounted) {
      _saveAndSchedule(
        context,
        [result['schedule']],
        result['minutes'],
        result['repeat'],
      );
    }
  }

  void _onEdit(BuildContext context, ScheduleEntity item) async {
    final result = await ScheduleDialogs.showScheduleForm(
      context,
      schedule: item,
    );
    if (result != null && mounted) {
      final updatedSchedule = result['schedule'] as ScheduleEntity;
      context.read<ScheduleBloc>().add(
        UpdateScheduleRequested(updatedSchedule),
      );

      if (updatedSchedule.id != null) {
        _saveAndSchedule(
          context,
          [updatedSchedule],
          result['minutes'],
          result['repeat'],
        );
      }
    }
  }

  void _onDelete(BuildContext context, ScheduleEntity item) async {
    final confirmed = await ScheduleDialogs.showDeleteConfirmation(
      context,
      item.subject,
    );
    if (confirmed && item.id != null && mounted) {
      context.read<ScheduleBloc>().add(DeleteScheduleRequested(item.id!));
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Đã xóa lịch học")));
    }
  }

  void _showJoinClassDialog(BuildContext context) {
    final codeController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Tham Gia Lớp Học"),
        content: TextField(
          controller: codeController,
          decoration: const InputDecoration(
            labelText: "Nhập mã lớp",
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Hủy"),
          ),
          ElevatedButton(
            onPressed: () {
              if (codeController.text.isNotEmpty) {
                context.read<ScheduleBloc>().add(
                  JoinClassRequested(codeController.text.trim()),
                );
                Navigator.pop(ctx);
              }
            },
            child: const Text("Vào Lớp"),
          ),
        ],
      ),
    );
  }

  // --- UI ---

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ScheduleBloc>()..add(LoadSchedules()),
      child: Builder(
        builder: (context) {

          return Scaffold(
            appBar: AppBar(
              title: const Text("Thời Khóa Biểu"),
              actions: [
                IconButton(
                  icon: const Icon(Icons.add_link),
                  onPressed: () => _showJoinClassDialog(context),
                ),
                IconButton(
                  icon: const Icon(Icons.upload_file),
                  onPressed: () => _pickAndParseExcel(context),
                ),
                IconButton(
                  icon: const Icon(Icons.today),
                  onPressed: () =>
                      _calendarController.displayDate = DateTime.now(),
                ),
              ],
            ),
            body: BlocConsumer<ScheduleBloc, ScheduleState>(
              listener: (context, state) {
                if (state is ScheduleError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: Colors.red,
                    ),
                  );
                  context.read<ScheduleBloc>().add(LoadSchedules());
                }
                if (state is JoinClassSuccess) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Vào lớp thành công!"),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              },
              builder: (context, state) {
                if (state is ScheduleLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                List<ScheduleEntity> appointments = [];
                if (state is ScheduleLoaded) appointments = state.schedules;

                return ScheduleCalendarView(
                  appointments: appointments,
                  calendarController: _calendarController,
                  onEdit: (item) => _onEdit(context, item),
                  onDelete: (item) => _onDelete(context, item),
                );
              },
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () => _onManualAdd(context),
              child: const Icon(Icons.add),
            ),
          );
        },
      ),
    );
  }
}
