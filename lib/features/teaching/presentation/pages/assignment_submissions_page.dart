import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../injection_container.dart';

class AssignmentSubmissionsPage extends StatefulWidget {
  final int assignmentId;
  final String assignmentTitle;
  final String? dueDate;

  const AssignmentSubmissionsPage({
    super.key,
    required this.assignmentId,
    required this.assignmentTitle,
    this.dueDate,
  });

  @override
  State<AssignmentSubmissionsPage> createState() =>
      _AssignmentSubmissionsPageState();
}

class _AssignmentSubmissionsPageState extends State<AssignmentSubmissionsPage> {
  bool _loading = true;
  String? _error;
  List<Map<String, dynamic>> _submissions = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final api = sl<ApiClient>();
      final res = await api.get(
        '/teacher/assignments/${widget.assignmentId}/submissions',
      );
      if (mounted) {
        setState(() {
          _submissions = List<Map<String, dynamic>>.from(res is List ? res : []);
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = '$e';
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark(context);
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(
        title: Text(
          widget.assignmentTitle,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: _buildBody(isDark, cs),
      ),
    );
  }

  Widget _buildBody(bool isDark, ColorScheme cs) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator(strokeWidth: 2));
    }
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 48, color: AppColors.error),
            const SizedBox(height: 12),
            Text(_error!, style: TextStyle(color: AppColors.error)),
            const SizedBox(height: 12),
            FilledButton(onPressed: _load, child: const Text('Thu lai')),
          ],
        ),
      );
    }

    final pending = _submissions.where((s) => s['status'] != 'graded').toList();
    final graded = _submissions.where((s) => s['status'] == 'graded').toList();

    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: _buildHeader(isDark, cs),
        ),
        if (_submissions.isEmpty)
          SliverFillRemaining(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.inbox_outlined, size: 56,
                      color: AppColors.textSecondary(context)),
                  const SizedBox(height: 12),
                  Text(
                    'Chua co bai nop nao',
                    style: TextStyle(
                      color: AppColors.textSecondary(context),
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
          )
        else ...[
          if (pending.isNotEmpty) ...[
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Text(
                  'Ch\u01b0a ch\u1ea5m (\u0111i\u1ec3m) \u2022 ${pending.length}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.warning,
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (_, i) => _buildSubmissionCard(pending[i], isDark, cs),
                  childCount: pending.length,
                ),
              ),
            ),
          ],
          if (graded.isNotEmpty) ...[
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Text(
                  '\u0110\u00e3 ch\u1ea5m \u2022 ${graded.length}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.success,
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (_, i) => _buildSubmissionCard(graded[i], isDark, cs),
                  childCount: graded.length,
                ),
              ),
            ),
          ],
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ],
    );
  }

  Widget _buildHeader(bool isDark, ColorScheme cs) {
    String dueDateText = '';
    if (widget.dueDate != null) {
      try {
        final dt = DateTime.parse(widget.dueDate!);
        dueDateText = DateFormat('dd/MM/yyyy - HH:mm').format(dt);
      } catch (_) {}
    }

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border(context)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primary.withAlpha(isDark ? 30 : 15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.assignment_rounded, color: AppColors.primary, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.assignmentTitle,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: AppColors.textPrimary(context),
                  ),
                ),
                if (dueDateText.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.schedule, size: 14, color: AppColors.textSecondary(context)),
                      const SizedBox(width: 4),
                      Text(
                        'H\u1ea1n: $dueDateText',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary(context),
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 4),
                Row(
                  children: [
                    _buildCountBadge(
                      '${_submissions.where((s) => s['status'] != 'graded').length}',
                      'Ch\u01b0a ch\u1ea5m',
                      AppColors.warning,
                    ),
                    const SizedBox(width: 8),
                    _buildCountBadge(
                      '${_submissions.where((s) => s['status'] == 'graded').length}',
                      '\u0110\u00e3 ch\u1ea5m',
                      AppColors.success,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCountBadge(String count, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '$count $label',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Widget _buildSubmissionCard(
    Map<String, dynamic> sub,
    bool isDark,
    ColorScheme cs,
  ) {
    final name = sub['studentName'] ?? '';
    final status = sub['status'] ?? 'pending';
    final isGraded = status == 'graded';
    final grade = sub['grade'];
    final isLate = sub['isLate'] == true;
    final submittedAt = sub['submittedAt'];
    final feedback = sub['feedback'] as String?;
    final fileName = sub['fileName'] as String?;
    final linkUrl = sub['linkUrl'] as String?;
    final textContent = sub['textContent'] as String?;

    String timeText = '';
    if (submittedAt != null) {
      try {
        final dt = DateTime.parse(submittedAt);
        timeText = DateFormat('dd/MM HH:mm').format(dt);
      } catch (_) {}
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border(context)),
      ),
      child: InkWell(
        onTap: isGraded ? null : () => _showGradeSheet(sub),
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: (isGraded ? AppColors.success : AppColors.primary)
                        .withAlpha(isDark ? 30 : 15),
                    child: Text(
                      name.isNotEmpty ? name[0].toUpperCase() : '?',
                      style: TextStyle(
                        color: isGraded ? AppColors.success : AppColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: AppColors.textPrimary(context),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            if (timeText.isNotEmpty)
                              Text(
                                timeText,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textSecondary(context),
                                ),
                              ),
                            if (isLate) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 1,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.error.withAlpha(15),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  'Mu\u1ed9n',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.error,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (isGraded)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.success.withAlpha(15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${grade ?? 0}/10',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: AppColors.success,
                        ),
                      ),
                    )
                  else
                    OutlinedButton.icon(
                      onPressed: () => _showGradeSheet(sub),
                      icon: const Icon(Icons.rate_review_outlined, size: 16),
                      label: const Text('Ch\u1ea5m', style: TextStyle(fontSize: 12)),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: BorderSide(color: AppColors.primary.withAlpha(80)),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                ],
              ),

              if (fileName != null || linkUrl != null || textContent != null) ...[
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.darkSurfaceVariant
                        : Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (fileName != null)
                        Row(
                          children: [
                            Icon(Icons.attach_file_rounded, size: 14,
                                color: AppColors.primary),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                fileName,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textPrimary(context),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      if (linkUrl != null) ...[
                        if (fileName != null) const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.link_rounded, size: 14,
                                color: AppColors.accent),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                linkUrl,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.accent,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                      if (textContent != null && textContent.isNotEmpty) ...[
                        if (fileName != null || linkUrl != null)
                          const SizedBox(height: 4),
                        Text(
                          textContent,
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary(context),
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
              ],

              if (isGraded && feedback != null && feedback.isNotEmpty) ...[
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.comment_outlined, size: 14,
                        color: AppColors.textSecondary(context)),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        feedback,
                        style: TextStyle(
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                          color: AppColors.textSecondary(context),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _showGradeSheet(Map<String, dynamic> sub) {
    final gradeCtrl = TextEditingController(
      text: sub['grade'] != null ? '${sub['grade']}' : '',
    );
    final feedbackCtrl = TextEditingController(
      text: sub['feedback'] as String? ?? '',
    );
    final isDark = AppColors.isDark(context);
    bool isSubmitting = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            20,
            20,
            MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Icon(Icons.grading_rounded, color: AppColors.primary, size: 22),
                  const SizedBox(width: 10),
                  Text(
                    'Ch\u1ea5m \u0111i\u1ec3m - ${sub['studentName']}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary(context),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              TextField(
                controller: gradeCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: '\u0110i\u1ec3m (0 - 10)',
                  filled: true,
                  fillColor: isDark
                      ? AppColors.darkSurfaceVariant
                      : Colors.grey.shade50,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  prefixIcon: const Icon(Icons.star_rounded),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: feedbackCtrl,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Nh\u1eadn x\u00e9t (tu\u1ef3 ch\u1ecdn)',
                  filled: true,
                  fillColor: isDark
                      ? AppColors.darkSurfaceVariant
                      : Colors.grey.shade50,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  alignLabelWithHint: true,
                  prefixIcon: const Padding(
                    padding: EdgeInsets.only(bottom: 40),
                    child: Icon(Icons.comment_outlined),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: FilledButton.icon(
                  onPressed: isSubmitting
                      ? null
                      : () async {
                          final grade = double.tryParse(gradeCtrl.text);
                          if (grade == null || grade < 0 || grade > 10) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('\u0110i\u1ec3m ph\u1ea3i t\u1eeb 0 \u0111\u1ebfn 10'),
                              ),
                            );
                            return;
                          }
                          setSheetState(() => isSubmitting = true);
                          try {
                            final prefs = await SharedPreferences.getInstance();
                            final teacherId = prefs.getInt('userId') ?? 0;
                            final api = sl<ApiClient>();
                            await api.put(
                              '/teacher/submissions/${sub['id']}/grade',
                              {
                                'grade': grade,
                                'teacherId': teacherId,
                                'feedback': feedbackCtrl.text.trim(),
                              },
                            );
                            if (mounted) {
                              Navigator.pop(ctx);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    '\u0110\u00e3 ch\u1ea5m ${sub['studentName']}: $grade/10',
                                  ),
                                  backgroundColor: AppColors.success,
                                ),
                              );
                              _load();
                            }
                          } catch (e) {
                            setSheetState(() => isSubmitting = false);
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('L\u1ed7i: $e'),
                                  backgroundColor: AppColors.error,
                                ),
                              );
                            }
                          }
                        },
                  icon: isSubmitting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.check_rounded),
                  label: Text(isSubmitting ? '\u0110ang l\u01b0u...' : 'X\u00e1c nh\u1eadn ch\u1ea5m'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
