import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../injection_container.dart';
import '../../../schedule/domain/enitities/schedule_entity.dart';
import '../bloc/teacher_bloc.dart';
import '../bloc/teacher_event.dart';
import '../bloc/teacher_state.dart';
import 'teacher_student_list_page.dart';

class TeacherSubjectClassesPage extends StatefulWidget {
  final String subjectName;
  final List<ScheduleEntity> allSchedules;

  const TeacherSubjectClassesPage({
    super.key,
    required this.subjectName,
    required this.allSchedules,
  });

  @override
  State<TeacherSubjectClassesPage> createState() =>
      _TeacherSubjectClassesPageState();
}

class _TeacherSubjectClassesPageState extends State<TeacherSubjectClassesPage> {
  int _getCurrentUserId() {
    return sl<SharedPreferences>().getInt('current_user_id') ?? 1;
  }

  void _showClassCodeManager(BuildContext context, ScheduleEntity classItem) {
    String currentCode = classItem.classCode ?? "Chưa có";

    showDialog(
      context: context,
      builder: (ctx) {
        return BlocProvider.value(
          value: context.read<TeacherBloc>(),
          child: StatefulBuilder(
            builder: (context, setStateDialog) {
              return BlocListener<TeacherBloc, TeacherState>(
                listener: (context, state) {
                  if (state is CodeRegeneratedSuccess) {
                    setStateDialog(() {
                      currentCode = state.newCode;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.message),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                },
                child: AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  title: const Row(
                    children: [
                      Icon(Icons.vpn_key, color: Colors.blueAccent),
                      SizedBox(width: 10),
                      Text("Mã Lớp Học"),
                    ],
                  ),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "Lớp: ${classItem.subject}",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      if (classItem.room != null)
                        Text("Phòng: ${classItem.room}"),
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 16,
                          horizontal: 24,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.blue.shade200),
                        ),
                        child: Column(
                          children: [
                            const Text(
                              "Mã tham gia:",
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 4),
                            SelectableText(
                              currentCode,
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                                letterSpacing: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          TextButton.icon(
                            onPressed: () {
                              Clipboard.setData(
                                ClipboardData(text: currentCode),
                              );
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Đã sao chép mã!"),
                                ),
                              );
                            },
                            icon: const Icon(Icons.copy, size: 20),
                            label: const Text("Sao chép"),
                          ),
                          TextButton.icon(
                            onPressed: () {
                              context.read<TeacherBloc>().add(
                                RegenerateCodeRequested(
                                  _getCurrentUserId(),
                                  classItem.subject,
                                  true,
                                ),
                              );
                            },
                            icon: const Icon(
                              Icons.refresh,
                              color: Colors.red,
                              size: 20,
                            ),
                            label: const Text(
                              "Làm mới",
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text("Đóng"),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  void _showCreateClassDialog(BuildContext context) {
    final TextEditingController classNameController = TextEditingController();
    final TextEditingController roomController = TextEditingController();
    final TextEditingController repeatWeeksController = TextEditingController(
      text: "1",
    );
    // Default credits to 2 as per user request
    final TextEditingController creditsController = TextEditingController(
      text: "2",
    );
    final TextEditingController notificationMinutesController =
        TextEditingController(text: "15");

    TimeOfDay? startTime;
    TimeOfDay? endTime;
    DateTime? startDate;

    showDialog(
      context: context,
      barrierDismissible: false, // Prevent accidental close
      builder: (ctx) {
        return BlocProvider.value(
          value: context.read<TeacherBloc>(),
          child: StatefulBuilder(
            builder: (context, setDialogState) {
              return BlocListener<TeacherBloc, TeacherState>(
                listener: (context, state) {
                  if (state is ClassCreatedSuccess) {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Tạo lớp thành công!"),
                        backgroundColor: Colors.green,
                      ),
                    );
                  } else if (state is TeacherError) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Lỗi: ${state.message}"),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                child: Dialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Stack(
                    clipBehavior: Clip.none,
                    alignment: Alignment.topRight,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 24,
                        ),
                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const Text(
                                "Tạo Lớp Học Mới",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blueAccent,
                                ),
                              ),
                              const SizedBox(height: 24),

                              // Class Name
                              TextField(
                                controller: classNameController,
                                decoration: const InputDecoration(
                                  labelText: "Tên lớp học",
                                  hintText: "VD: Lớp A",
                                  border: OutlineInputBorder(),
                                  prefixIcon: Icon(Icons.class_),
                                  isDense: true,
                                ),
                              ),
                              const SizedBox(height: 16),

                              // Room
                              TextField(
                                controller: roomController,
                                decoration: const InputDecoration(
                                  labelText: "Phòng học",
                                  hintText: "VD: A101",
                                  border: OutlineInputBorder(),
                                  prefixIcon: Icon(Icons.room),
                                  isDense: true,
                                ),
                              ),
                              const SizedBox(height: 16),

                              // Start Date
                              InkWell(
                                onTap: () async {
                                  final picked = await showDatePicker(
                                    context: context,
                                    initialDate: DateTime.now(),
                                    firstDate: DateTime.now().subtract(
                                      const Duration(days: 365),
                                    ),
                                    lastDate: DateTime.now().add(
                                      const Duration(days: 365),
                                    ),
                                  );
                                  if (picked != null) {
                                    setDialogState(() {
                                      startDate = picked;
                                    });
                                  }
                                },
                                child: InputDecorator(
                                  decoration: const InputDecoration(
                                    labelText: "Ngày bắt đầu",
                                    border: OutlineInputBorder(),
                                    prefixIcon: Icon(Icons.calendar_today),
                                    isDense: true,
                                  ),
                                  child: Text(
                                    startDate != null
                                        ? "${startDate!.day}/${startDate!.month}/${startDate!.year}"
                                        : 'Chọn ngày',
                                    style: TextStyle(
                                      color: startDate != null
                                          ? Colors.black87
                                          : Colors.grey[600],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),

                              // Time Row
                              Row(
                                children: [
                                  Expanded(
                                    child: InkWell(
                                      onTap: () async {
                                        final picked = await showTimePicker(
                                          context: context,
                                          initialTime: TimeOfDay.now(),
                                        );
                                        if (picked != null) {
                                          setDialogState(() {
                                            startTime = picked;
                                          });
                                        }
                                      },
                                      child: InputDecorator(
                                        decoration: const InputDecoration(
                                          labelText: "Bắt đầu",
                                          border: OutlineInputBorder(),
                                          isDense: true,
                                          contentPadding: EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 14,
                                          ),
                                        ),
                                        child: Text(
                                          startTime != null
                                              ? startTime!.format(context)
                                              : '--:--',
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  const Icon(
                                    Icons.arrow_forward,
                                    color: Colors.grey,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: InkWell(
                                      onTap: () async {
                                        final picked = await showTimePicker(
                                          context: context,
                                          initialTime:
                                              startTime ?? TimeOfDay.now(),
                                        );
                                        if (picked != null) {
                                          setDialogState(() {
                                            endTime = picked;
                                          });
                                        }
                                      },
                                      child: InputDecorator(
                                        decoration: const InputDecoration(
                                          labelText: "Kết thúc",
                                          border: OutlineInputBorder(),
                                          isDense: true,
                                          contentPadding: EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 14,
                                          ),
                                        ),
                                        child: Text(
                                          endTime != null
                                              ? endTime!.format(context)
                                              : '--:--',
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),

                              // Configuration Row: Repeat - Notify - Credits
                              Row(
                                children: [
                                  Expanded(
                                    child: TextField(
                                      controller: repeatWeeksController,
                                      keyboardType: TextInputType.number,
                                      textAlign: TextAlign.center,
                                      decoration: const InputDecoration(
                                        labelText: "Tuần",
                                        hintText: "1",
                                        border: OutlineInputBorder(),
                                        isDense: true,
                                        contentPadding: EdgeInsets.all(12),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: TextField(
                                      controller: notificationMinutesController,
                                      keyboardType: TextInputType.number,
                                      textAlign: TextAlign.center,
                                      decoration: const InputDecoration(
                                        labelText: "Phút báo",
                                        hintText: "15",
                                        border: OutlineInputBorder(),
                                        isDense: true,
                                        contentPadding: EdgeInsets.all(12),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: TextField(
                                      controller: creditsController,
                                      keyboardType: TextInputType.number,
                                      textAlign: TextAlign.center,
                                      decoration: const InputDecoration(
                                        labelText: "Tín chỉ",
                                        hintText: "2",
                                        border: OutlineInputBorder(),
                                        isDense: true,
                                        contentPadding: EdgeInsets.all(12),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),

                              // Create Button
                              ElevatedButton(
                                onPressed: () {
                                  final className = classNameController.text
                                      .trim();
                                  final room = roomController.text.trim();
                                  final repeatWeeks =
                                      int.tryParse(
                                        repeatWeeksController.text.trim(),
                                      ) ??
                                      1;
                                  final notificationMinutes =
                                      int.tryParse(
                                        notificationMinutesController.text
                                            .trim(),
                                      ) ??
                                      15;
                                  final credits =
                                      int.tryParse(
                                        creditsController.text.trim(),
                                      ) ??
                                      2;

                                  // Validation
                                  if (className.isEmpty ||
                                      room.isEmpty ||
                                      startDate == null ||
                                      startTime == null ||
                                      endTime == null) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          "Vui lòng điền đầy đủ thông tin!",
                                        ),
                                        backgroundColor: Colors.orange,
                                      ),
                                    );
                                    return;
                                  }

                                  final now = DateTime.now();
                                  final startDateTime = DateTime(
                                    now.year,
                                    now.month,
                                    now.day,
                                    startTime!.hour,
                                    startTime!.minute,
                                  );
                                  final endDateTime = DateTime(
                                    now.year,
                                    now.month,
                                    now.day,
                                    endTime!.hour,
                                    endTime!.minute,
                                  );

                                  if (!endDateTime.isAfter(startDateTime)) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          "Giờ kết thúc phải sau giờ bắt đầu",
                                        ),
                                        backgroundColor: Colors.orange,
                                      ),
                                    );
                                    return;
                                  }

                                  context.read<TeacherBloc>().add(
                                    CreateClassRequested(
                                      className: className,
                                      teacherId: _getCurrentUserId(),
                                      subjectName: widget.subjectName,
                                      room: room,
                                      startTime: startDateTime,
                                      endTime: endDateTime,
                                      startDate: startDate!,
                                      repeatWeeks: repeatWeeks,
                                      notificationMinutes: notificationMinutes,
                                      credits: credits,
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blueAccent,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: const Text(
                                  "TẠO LỚP",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Close Button (X)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: IconButton(
                          onPressed: () => Navigator.pop(ctx),
                          icon: const Icon(Icons.close, color: Colors.grey),
                          style: IconButton.styleFrom(
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // 👇 Logic lọc danh sách lớp
    final subjectSchedules = List<ScheduleEntity>.from(
      widget.allSchedules.where((s) => s.subject == widget.subjectName),
    );

    // 👇 Nếu không có lớp, hiện Scaffold với FAB để tạo lớp
    if (subjectSchedules.isEmpty) {
      return Scaffold(
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.class_, size: 80, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                "Chưa có lớp học nào được tạo.",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              SizedBox(height: 8),
              Text(
                "Nhấn nút + bên dưới để tạo lớp mới",
                style: TextStyle(fontSize: 13, color: Colors.grey),
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _showCreateClassDialog(context),
          backgroundColor: Colors.blueAccent,
          child: const Icon(Icons.add, color: Colors.white),
        ),
      );
    }

    return Scaffold(
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: subjectSchedules.length,
        itemBuilder: (context, index) {
          final item = subjectSchedules[index];

          return Card(
            elevation: 2,
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              leading: CircleAvatar(
                backgroundColor: Colors.blue.shade100,
                child: const Icon(Icons.class_, color: Colors.blue),
              ),
              title: Text(
                item.subject,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (item.room != null) Text("Phòng: ${item.room}"),
                  const Text("Giảng viên: Tôi"),
                  if (item.createdAt != null)
                    Text(
                      "Tạo lúc: ${item.createdAt!.day.toString().padLeft(2, '0')}/${item.createdAt!.month.toString().padLeft(2, '0')}/${item.createdAt!.year} ${item.createdAt!.hour.toString().padLeft(2, '0')}:${item.createdAt!.minute.toString().padLeft(2, '0')}",
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                ],
              ),
              
              trailing: IconButton(
                icon: const Icon(Icons.vpn_key, color: Colors.orange),
                tooltip: "Xem/Lấy Mã Lớp",
                onPressed: () {
                  _showClassCodeManager(context, item);
                },
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BlocProvider.value(
                      value: context.read<TeacherBloc>(),
                      child: TeacherStudentListPage(
                        subjectName: widget.subjectName,
                        allSchedules: widget.allSchedules,
                        selectedDate: item.start,
                        weekIndex: null,
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateClassDialog(context),
        backgroundColor: Colors.blueAccent,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
