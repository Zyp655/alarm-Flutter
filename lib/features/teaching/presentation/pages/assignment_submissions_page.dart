import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../injection_container.dart';
import '../widgets/submission_card.dart';
import '../widgets/submission_detail_sheet.dart';
import '../widgets/grade_sheet.dart';
import '../../../../core/widgets/animations.dart';

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

  void _onSubmissionTap(Map<String, dynamic> sub) {
    SubmissionDetailSheet.show(
      context: context,
      sub: sub,
      onGrade: () => GradeSheet.show(
        context: context,
        sub: sub,
        onGraded: _load,
      ),
    );
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
        SliverToBoxAdapter(child: _buildHeader(isDark, cs)),
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
                  (_, i) => StaggeredListAnimation(
                    index: i,
                    child: SubmissionCard(
                      sub: pending[i],
                      onTap: () => _onSubmissionTap(pending[i]),
                    ),
                  ),
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
                  (_, i) => StaggeredListAnimation(
                    index: i,
                    child: SubmissionCard(
                      sub: graded[i],
                      onTap: () => _onSubmissionTap(graded[i]),
                    ),
                  ),
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
}
