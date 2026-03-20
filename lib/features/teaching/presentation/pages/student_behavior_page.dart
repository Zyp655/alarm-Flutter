import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/api/api_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../widgets/behavior_widgets.dart';

class StudentBehaviorPage extends StatefulWidget {
  final int courseId;
  final String courseTitle;
  final int teacherId;

  const StudentBehaviorPage({
    super.key,
    required this.courseId,
    required this.courseTitle,
    required this.teacherId,
  });

  @override
  State<StudentBehaviorPage> createState() => _StudentBehaviorPageState();
}

class _StudentBehaviorPageState extends State<StudentBehaviorPage> {
  Map<String, dynamic>? _data;
  bool _isLoading = true;
  String? _error;
  bool _nudging = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final res = await http.get(
        Uri.parse(
          '${ApiConstants.baseUrl}/courses/${widget.courseId}/analytics/student-behaviors',
        ),
        headers: {
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );
      if (res.statusCode == 200) {
        if (!mounted) return;
        setState(() {
          _data = jsonDecode(res.body) as Map<String, dynamic>;
          _isLoading = false;
        });
      } else {
        if (!mounted) return;
        setState(() {
          _error = 'Lỗi: ${res.statusCode}';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Không thể tải dữ liệu';
        _isLoading = false;
      });
    }
  }

  Future<void> _sendNudge(Map<String, dynamic> student) async {
    setState(() => _nudging = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      await http.post(
        Uri.parse('${ApiConstants.baseUrl}/ai/nudge'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'studentId': student['userId'],
          'courseId': widget.courseId,
          'teacherId': widget.teacherId,
          'daysInactive': student['daysInactive'],
          'progressPercent': student['completionRate'],
        }),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đã gửi nhắc nhở cho ${student['name']}'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi gửi: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
    if (mounted) setState(() => _nudging = false);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: const Text('🧠 Phân tích hành vi SV', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          if (_data != null && _data!['cached'] == true)
            Tooltip(
              message: 'Dữ liệu cache',
              child: Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Icon(Icons.cached_rounded, color: AppColors.success, size: 20),
              ),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : _error != null
              ? _buildError(cs)
              : RefreshIndicator(onRefresh: _loadData, child: _buildContent(cs, isDark)),
    );
  }

  Widget _buildError(ColorScheme cs) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 48, color: AppColors.error),
          const SizedBox(height: 16),
          Text(_error!, style: TextStyle(color: cs.onSurface)),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: _loadData,
            icon: const Icon(Icons.refresh),
            label: const Text('Thử lại'),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(ColorScheme cs, bool isDark) {
    final stats = _data!['stats'] as Map<String, dynamic>;
    final aiInsights = _data!['aiInsights'] as Map<String, dynamic>? ?? {};
    final engagement = stats['engagement'] as Map<String, dynamic>? ?? {};
    final students = (stats['students'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    final totalStudents = stats['totalStudents'] as int? ?? 0;

    final summary = aiInsights['summary'] as String? ?? '';
    final causes = (aiInsights['causes'] as List?)?.cast<String>() ?? [];
    final curriculumSuggestions = (aiInsights['curriculumSuggestions'] as List?)?.cast<String>() ?? [];
    final recommendations = (aiInsights['recommendations'] as List?)?.cast<String>() ?? [];

    final riskStudents = students.where((s) => s['level'] == 'low').toList();
    final rushers = students.where((s) => s['quizSpeed'] == 'rush' && (s['avgQuizScore'] as int) < 50).toList();
    final excellentStudents = students.where((s) => s['level'] == 'excellent').toList();
    final inactiveStudents = students.where((s) => s['commentCount'] == 0 && s['quizAttemptCount'] == 0).toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        BehaviorOverviewCard(
          courseTitle: widget.courseTitle,
          totalStudents: totalStudents,
          engagement: engagement,
        ),
        const SizedBox(height: 16),
        BehaviorPieChart(engagement: engagement, totalStudents: totalStudents),
        const SizedBox(height: 16),
        if (summary.isNotEmpty) _buildAiSummary(cs, isDark, summary),
        const SizedBox(height: 16),
        if (riskStudents.isNotEmpty)
          RiskStudentSection(
            riskStudents: riskStudents,
            nudging: _nudging,
            onNudge: _sendNudge,
          ),
        const SizedBox(height: 16),
        _buildBehaviorClusters(cs, isDark, rushers, inactiveStudents, excellentStudents),
        const SizedBox(height: 16),
        if (curriculumSuggestions.isNotEmpty)
          SuggestionCard(title: '📚 Can thiệp giáo trình', items: curriculumSuggestions, accent: AppColors.primary),
        const SizedBox(height: 16),
        if (causes.isNotEmpty)
          SuggestionCard(title: '⚠️ Nguyên nhân', items: causes, accent: AppColors.warning),
        const SizedBox(height: 16),
        if (recommendations.isNotEmpty)
          SuggestionCard(title: '💡 Đề xuất hành động', items: recommendations, accent: AppColors.success),
        const SizedBox(height: 16),
        _buildPatternsCard(cs, isDark, stats),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildAiSummary(ColorScheme cs, bool isDark, String summary) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withAlpha(80)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.auto_awesome, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text('Phân tích AI', style: TextStyle(color: cs.onSurface, fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
          const SizedBox(height: 12),
          Text(summary, style: TextStyle(color: cs.onSurface, height: 1.5)),
        ],
      ),
    );
  }

  Widget _buildBehaviorClusters(ColorScheme cs, bool isDark,
      List<Map<String, dynamic>> rushers,
      List<Map<String, dynamic>> inactive,
      List<Map<String, dynamic>> excellent) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(isDark ? 30 : 15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('👥 Nhóm hành vi', style: TextStyle(color: cs.onSurface, fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 12),
          _buildClusterTile(cs, Icons.speed_rounded, AppColors.error, 'Quiz đánh lụi', 'Làm nhanh < 10s/câu, điểm < 50%', rushers),
          _buildClusterTile(cs, Icons.visibility_off_rounded, AppColors.warning, 'Không tương tác', '0 comments, 0 quiz attempts', inactive),
          _buildClusterTile(cs, Icons.star_rounded, AppColors.success, 'Xuất sắc', 'Completion > 80%, Quiz > 80%', excellent),
        ],
      ),
    );
  }

  Widget _buildClusterTile(ColorScheme cs, IconData icon, Color color, String title, String description, List<Map<String, dynamic>> students) {
    return ExpansionTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: color.withAlpha(25), borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text('$title (${students.length})', style: TextStyle(color: cs.onSurface, fontWeight: FontWeight.w600, fontSize: 14)),
      subtitle: Text(description, style: TextStyle(color: AppColors.textSecondary(context), fontSize: 11)),
      children: students.take(10).map((s) => ListTile(
        dense: true,
        leading: CircleAvatar(
          radius: 14,
          backgroundColor: color.withAlpha(20),
          child: Text((s['name'] as String)[0], style: TextStyle(color: color, fontSize: 12)),
        ),
        title: Text(s['name'] as String, style: TextStyle(color: cs.onSurface, fontSize: 13)),
        subtitle: Text(
          'Quiz: ${s['avgQuizScore']}% · ${s['completionRate']}% hoàn thành',
          style: TextStyle(fontSize: 11, color: AppColors.textSecondary(context)),
        ),
      )).toList(),
    );
  }

  Widget _buildPatternsCard(ColorScheme cs, bool isDark, Map<String, dynamic> stats) {
    final bottleneckModule = stats['bottleneckModule'] as String? ?? 'N/A';
    final bottleneckDrop = stats['bottleneckDropRate'] as num? ?? 0;
    final students = (stats['students'] as List?)?.cast<Map<String, dynamic>>() ?? [];

    final avgCompletion = students.isNotEmpty
        ? (students.fold<int>(0, (s, st) => s + (st['completionRate'] as int)) / students.length).round()
        : 0;
    final avgQuiz = students.isNotEmpty
        ? (students.fold<int>(0, (s, st) => s + (st['avgQuizScore'] as int)) / students.length).round()
        : 0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(isDark ? 30 : 15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('📈 Patterns', style: TextStyle(color: cs.onSurface, fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 16),
          Row(
            children: [
              _patternMetric('Hoàn thành TB', '$avgCompletion%', AppColors.primary),
              const SizedBox(width: 12),
              _patternMetric('Quiz TB', '$avgQuiz%', AppColors.success),
              const SizedBox(width: 12),
              _patternMetric('Bottleneck', '${(bottleneckDrop * 100).toStringAsFixed(0)}%', AppColors.error),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Điểm nghẽn: $bottleneckModule',
            style: TextStyle(color: AppColors.textSecondary(context), fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _patternMetric(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withAlpha(15),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(value, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(color: color, fontSize: 11), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
