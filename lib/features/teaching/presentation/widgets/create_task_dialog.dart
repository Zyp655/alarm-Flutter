import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../bloc/teacher_bloc.dart';
import '../bloc/teacher_event.dart';
import '../bloc/teacher_state.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart'; // Import AuthState
import '../../domain/entities/assignment_entity.dart';
import '../../../schedule/domain/enitities/schedule_entity.dart'; // Import for ScheduleEntity (Class)

class CreateTaskDialog extends StatefulWidget {
  const CreateTaskDialog({super.key});

  @override
  State<CreateTaskDialog> createState() => _CreateTaskDialogState();
}

class _CreateTaskDialogState extends State<CreateTaskDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _pointsController = TextEditingController(text: "0");
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  int? _selectedClassId;
  List<ScheduleEntity> _classes = [];

  @override
  void initState() {
    super.initState();
    _loadClasses();
  }

  void _loadClasses() {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthSuccess && authState.user != null) {
      // Check if already loaded
      final teacherState = context.read<TeacherBloc>().state;
      if (teacherState is TeacherLoaded) {
        setState(() {
          _classes = teacherState.schedules;
        });
      }
      context.read<TeacherBloc>().add(LoadTeacherClasses(authState.user!.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TeacherBloc, TeacherState>(
      listener: (context, state) {
        if (state is TeacherLoaded) {
          setState(() {
            _classes = state.schedules;
            if (_classes.isNotEmpty) {
              _selectedClassId =
                  _classes.first.classId; // Assuming classId property
            }
          });
        }
      },
      builder: (context, state) {
        // Deduplicate classes based on ID (PK) to prevent duplicates and handle null classId
        final uniqueClasses = <int, ScheduleEntity>{};
        for (var c in _classes) {
          if (c.id != null) {
            uniqueClasses[c.id!] = c;
          }
        }
        final displayClasses = uniqueClasses.values.toList();

        // Validation Logic
        if (displayClasses.isNotEmpty) {
          final exists = displayClasses.any((c) => c.id == _selectedClassId);
          if (!exists) {
            _selectedClassId = displayClasses.first.id;
          }
        } else {
          _selectedClassId = null;
        }

        return AlertDialog(
          title: const Text("Giao Bài Tập"),
          content: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (displayClasses.isEmpty)
                    const Padding(
                      padding: EdgeInsets.only(bottom: 16.0),
                      child: Text(
                        "Chưa có lớp học nào. Vui lòng tạo lớp trước.",
                        style: TextStyle(color: Colors.red),
                      ),
                    )
                  else
                    DropdownButtonFormField<int>(
                      value: _selectedClassId,
                      items: displayClasses
                          .map(
                            (c) => DropdownMenuItem(
                              value: c.id,
                              child: Text(c.subject),
                            ),
                          )
                          .toList(),
                      onChanged: (val) {
                        setState(() {
                          _selectedClassId = val;
                        });
                      },
                      decoration: const InputDecoration(labelText: "Chọn Lớp"),
                      validator: (val) =>
                          val == null ? "Vui lòng chọn lớp" : null,
                    ),
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(labelText: "Tiêu đề"),
                    validator: (val) => val!.isEmpty ? "Nhập tiêu đề" : null,
                  ),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(labelText: "Mô tả"),
                    maxLines: 3,
                  ),
                  TextFormField(
                    controller: _pointsController,
                    decoration: const InputDecoration(labelText: "Điểm thưởng"),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Text("Hạn nộp: "),
                      TextButton.icon(
                        icon: const Icon(Icons.calendar_today, size: 18),
                        label: Text(
                          DateFormat('dd/MM/yyyy').format(_selectedDate),
                        ),
                        onPressed: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: _selectedDate,
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(
                              const Duration(days: 365),
                            ),
                          );
                          if (date != null) {
                            setState(() {
                              _selectedDate = DateTime(
                                date.year,
                                date.month,
                                date.day,
                                _selectedDate.hour,
                                _selectedDate.minute,
                              );
                            });
                          }
                        },
                      ),
                      TextButton.icon(
                        icon: const Icon(Icons.access_time, size: 18),
                        label: Text(DateFormat('HH:mm').format(_selectedDate)),
                        onPressed: () async {
                          final time = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.fromDateTime(_selectedDate),
                          );
                          if (time != null) {
                            setState(() {
                              _selectedDate = DateTime(
                                _selectedDate.year,
                                _selectedDate.month,
                                _selectedDate.day,
                                time.hour,
                                time.minute,
                              );
                            });
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Hủy"),
            ),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  final authState = context.read<AuthBloc>().state;
                  if (authState is AuthSuccess && authState.user != null) {
                    final assignment = AssignmentEntity(
                      classId: _selectedClassId!,
                      title: _titleController.text,
                      description: _descriptionController.text,
                      dueDate: _selectedDate,
                      rewardPoints: int.tryParse(_pointsController.text) ?? 0,
                      createdAt: DateTime.now(),
                      // id will be handled by backend
                      // teacherId will be passed in event
                    );
                    context.read<TeacherBloc>().add(
                      CreateAssignmentRequested(assignment, authState.user!.id),
                    );
                    Navigator.pop(context);
                  }
                }
              },
              child: const Text("Tạo"),
            ),
          ],
        );
      },
    );
  }
}
