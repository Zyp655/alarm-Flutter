import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../domain/entities/assignment_entity.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../bloc/student_bloc.dart';
import '../bloc/student_event.dart';
import '../bloc/student_state.dart';
import '../../../../injection_container.dart' as di;
import '../../../../core/theme/app_colors.dart';
import '../../../../core/api/api_constants.dart';

class SubmitAssignmentPage extends StatelessWidget {
  final AssignmentEntity assignment;

  const SubmitAssignmentPage({Key? key, required this.assignment})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => di.sl<StudentBloc>(),
      child: SubmitAssignmentView(assignment: assignment),
    );
  }
}

class SubmitAssignmentView extends StatefulWidget {
  final AssignmentEntity assignment;

  const SubmitAssignmentView({Key? key, required this.assignment})
    : super(key: key);

  @override
  State<SubmitAssignmentView> createState() => _SubmitAssignmentViewState();
}

class _SubmitAssignmentViewState extends State<SubmitAssignmentView> {
  String _submissionType = 'link';
  File? _selectedFile;
  final _linkController = TextEditingController();
  final _textController = TextEditingController();
  Map<String, dynamic>? _existingSubmission;
  bool _loadingSubmission = true;
  bool _showForm = false;

  @override
  void initState() {
    super.initState();
    _loadExistingSubmission();
  }

  @override
  void dispose() {
    _linkController.dispose();
    _textController.dispose();
    super.dispose();
  }

  Future<void> _loadExistingSubmission() async {
    try {
      final authState = context.read<AuthBloc>().state;
      if (authState is! AuthSuccess || authState.user == null) {
        setState(() => _loadingSubmission = false);
        return;
      }
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final res = await http.get(
        Uri.parse(
          '${ApiConstants.baseUrl}/student/assignments/${widget.assignment.id}/submission?userId=${authState.user!.id}',
        ),
        headers: {
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );
      if (res.statusCode == 200) {
        setState(() {
          _existingSubmission = jsonDecode(res.body);
          _loadingSubmission = false;
        });
      } else {
        setState(() => _loadingSubmission = false);
      }
    } catch (e) {
      setState(() => _loadingSubmission = false);
    }
  }

  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'zip', 'rar', 'txt'],
      );
      if (result != null && result.files.single.path != null) {
        setState(() => _selectedFile = File(result.files.single.path!));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi chọn file: $e')),
      );
    }
  }

  void _submit() {
    if (_submissionType == 'file' && _selectedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn file')),
      );
      return;
    }
    if (_submissionType == 'link' && _linkController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập link')),
      );
      return;
    }
    if (_submissionType == 'text' && _textController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập nội dung')),
      );
      return;
    }
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthSuccess || authState.user == null) return;

    context.read<StudentBloc>().add(
      SubmitAssignmentEvent(
        assignmentId: widget.assignment.id!,
        studentId: authState.user!.id,
        file: _submissionType == 'file' ? _selectedFile : null,
        link: _submissionType == 'link' ? _linkController.text.trim() : null,
        text: _submissionType == 'text' ? _textController.text.trim() : null,
      ),
    );
  }

  bool _isLate() => DateTime.now().isAfter(widget.assignment.dueDate);

  @override
  Widget build(BuildContext context) {
    final isLate = _isLate();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('Nộp Bài')),
      body: BlocConsumer<StudentBloc, StudentState>(
        listener: (context, state) {
          if (state is SubmissionSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.success,
              ),
            );
            Navigator.pop(context, true);
          } else if (state is StudentError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        builder: (context, state) {
          if (_loadingSubmission) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          if (_existingSubmission != null && !_showForm) {
            return _buildSubmissionView(isDark);
          }

          return _buildSubmitForm(state, isLate);
        },
      ),
    );
  }

  Widget _buildSubmissionView(bool isDark) {
    final sub = _existingSubmission!;
    final status = sub['status'] as String? ?? 'submitted';
    final grade = sub['grade'];
    final maxGrade = sub['maxGrade'];
    final feedback = sub['feedback'] as String?;
    final submittedAt = DateTime.parse(sub['submittedAt'] as String);
    final isGraded = status == 'graded' && grade != null;
    final cardColor = isDark ? AppColors.darkSurface : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;
    final subColor = isDark ? Colors.grey[400]! : Colors.grey[600]!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isGraded
                  ? AppColors.success.withValues(alpha: 0.1)
                  : Colors.blue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isGraded
                    ? AppColors.success.withValues(alpha: 0.3)
                    : Colors.blue.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  isGraded ? Icons.check_circle : Icons.hourglass_top,
                  color: isGraded ? AppColors.success : Colors.blue,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isGraded ? 'Đã chấm điểm' : 'Đã nộp - Chờ chấm điểm',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: isGraded ? AppColors.success : Colors.blue,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Nộp lúc: ${DateFormat('dd/MM/yyyy HH:mm').format(submittedAt)}',
                        style: TextStyle(fontSize: 12, color: subColor),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          if (isGraded) ...[
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark ? Colors.grey[700]! : Colors.grey[200]!,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Điểm',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: subColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$grade${maxGrade != null ? '/$maxGrade' : ''}',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  if (feedback != null && feedback.isNotEmpty) ...[
                    const Divider(height: 24),
                    Text(
                      'Nhận xét',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: subColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      feedback,
                      style: TextStyle(fontSize: 14, color: textColor),
                    ),
                  ],
                ],
              ),
            ),
          ],

          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark ? Colors.grey[700]! : Colors.grey[200]!,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Nội dung đã nộp',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 12),
                if (sub['textContent'] != null &&
                    (sub['textContent'] as String).isNotEmpty) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.grey[800] : Colors.grey[50],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      sub['textContent'] as String,
                      style: TextStyle(fontSize: 14, color: textColor),
                    ),
                  ),
                ],
                if (sub['linkUrl'] != null &&
                    (sub['linkUrl'] as String).isNotEmpty) ...[
                  InkWell(
                    onTap: () async {
                      final uri = Uri.tryParse(sub['linkUrl'] as String);
                      if (uri != null) {
                        await launchUrl(uri, mode: LaunchMode.externalApplication);
                      }
                    },
                    child: Row(
                      children: [
                        const Icon(Icons.link, size: 18, color: Colors.blue),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            sub['linkUrl'] as String,
                            style: const TextStyle(
                              color: Colors.blue,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                        const Icon(Icons.open_in_new_rounded, size: 16, color: Colors.blue),
                      ],
                    ),
                  ),
                ],
                if (sub['fileName'] != null &&
                    (sub['fileName'] as String).isNotEmpty) ...[
                  Row(
                    children: [
                      const Icon(
                        Icons.insert_drive_file,
                        size: 18,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          sub['fileName'] as String,
                          style: TextStyle(color: textColor),
                        ),
                      ),
                    ],
                  ),
                ],
                if (sub['version'] != null && (sub['version'] as int) > 1)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      'Lần nộp: ${sub['version']}',
                      style: TextStyle(fontSize: 12, color: subColor),
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => setState(() => _showForm = true),
              icon: const Icon(Icons.refresh),
              label: const Text('Nộp lại'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                side: const BorderSide(color: AppColors.primary),
                foregroundColor: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitForm(StudentState state, bool isLate) {
    final isSubmitting = state is StudentLoading;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.assignment.title,
                    style: Theme.of(context).textTheme.titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  if (widget.assignment.description != null)
                    Text(
                      widget.assignment.description!,
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  const Divider(height: 24),
                  Row(
                    children: [
                      Icon(
                        Icons.event,
                        size: 20,
                        color: isLate ? Colors.red : Colors.blue,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Hạn nộp: ${DateFormat('dd/MM/yyyy HH:mm').format(widget.assignment.dueDate)}',
                        style: TextStyle(
                          color: isLate ? Colors.red : null,
                          fontWeight: isLate ? FontWeight.bold : null,
                        ),
                      ),
                    ],
                  ),
                  if (isLate)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.error.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.warning, size: 16, color: AppColors.error),
                            SizedBox(width: 4),
                            Text(
                              'Đã quá hạn nộp bài',
                              style: TextStyle(
                                color: AppColors.error,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Chọn hình thức nộp bài',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(value: 'link', label: Text('Link'), icon: Icon(Icons.link)),
              ButtonSegment(value: 'file', label: Text('File'), icon: Icon(Icons.upload_file)),
              ButtonSegment(value: 'text', label: Text('Text'), icon: Icon(Icons.text_fields)),
            ],
            selected: {_submissionType},
            onSelectionChanged: (Set<String> selected) {
              setState(() {
                _submissionType = selected.first;
                if (_submissionType != 'file') _selectedFile = null;
                if (_submissionType != 'link') _linkController.clear();
                if (_submissionType != 'text') _textController.clear();
              });
            },
          ),
          const SizedBox(height: 24),
          if (_submissionType == 'file') ...[
            ElevatedButton.icon(
              onPressed: _pickFile,
              icon: const Icon(Icons.folder_open),
              label: const Text('Chọn File'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
            if (_selectedFile != null) ...[
              const SizedBox(height: 12),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.insert_drive_file),
                  title: Text(_selectedFile!.path.split('/').last),
                  subtitle: Text(
                    '${(_selectedFile!.lengthSync() / 1024).toStringAsFixed(2)} KB',
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => setState(() => _selectedFile = null),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 8),
            Text(
              'Định dạng hỗ trợ: PDF, DOC, DOCX, ZIP, RAR, TXT',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ] else if (_submissionType == 'link') ...[
            TextField(
              controller: _linkController,
              decoration: const InputDecoration(
                labelText: 'Link bài làm',
                hintText: 'https://drive.google.com/...',
                prefixIcon: Icon(Icons.link),
                border: OutlineInputBorder(),
                helperText: 'Ví dụ: Google Drive, GitHub, OneDrive, Dropbox',
              ),
              keyboardType: TextInputType.url,
            ),
          ] else if (_submissionType == 'text') ...[
            TextField(
              controller: _textController,
              maxLines: 10,
              decoration: const InputDecoration(
                labelText: 'Nội dung bài làm',
                hintText: 'Nhập nội dung bài làm của bạn...',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
            ),
          ],
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: isSubmitting ? null : _submit,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: isLate ? Colors.orange : null,
              ),
              child: isSubmitting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(
                      _existingSubmission != null
                          ? 'Nộp lại'
                          : isLate
                              ? 'Nộp Bài (Trễ hạn)'
                              : 'Nộp Bài',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
