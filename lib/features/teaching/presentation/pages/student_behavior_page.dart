import 'dart:convert';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/api/api_constants.dart';
import '../../../../core/theme/app_colors.dart';

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
        setState(() {
          _data = jsonDecode(res.body) as Map<String, dynamic>;
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = 'Lỗi: ${res.statusCode}';
          _isLoading = false;
        });
      }
    } catch (e) {
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
    setState(() => _nudging = false);
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
        _buildOverviewCard(cs, isDark, totalStudents, engagement),
        const SizedBox(height: 16),
        _buildPieChart(isDark, engagement, totalStudents),
        const SizedBox(height: 16),
        if (summary.isNotEmpty) _buildAiSummary(cs, isDark, summary),
        const SizedBox(height: 16),
        if (riskStudents.isNotEmpty) _buildRiskSection(cs, isDark, riskStudents),
        const SizedBox(height: 16),
        _buildBehaviorClusters(cs, isDark, rushers, inactiveStudents, excellentStudents),
        const SizedBox(height: 16),
        if (curriculumSuggestions.isNotEmpty)
          _buildSuggestionCard(cs, isDark, '📚 Can thiệp giáo trình', curriculumSuggestions, AppColors.primary),
        const SizedBox(height: 16),
        if (causes.isNotEmpty)
          _buildSuggestionCard(cs, isDark, '⚠️ Nguyên nhân', causes, AppColors.warning),
        const SizedBox(height: 16),
        if (recommendations.isNotEmpty)
          _buildSuggestionCard(cs, isDark, '💡 Đề xuất hành động', recommendations, AppColors.success),
        const SizedBox(height: 16),
        _buildPatternsCard(cs, isDark, stats),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildOverviewCard(ColorScheme cs, bool isDark, int total, Map<String, dynamic> eng) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.accent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.courseTitle,
                  style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Text(
                  '$total sinh viên',
                  style: TextStyle(color: Colors.white.withAlpha(200)),
                ),
                const SizedBox(height: 4),
                Text(
                  '⭐ ${eng['excellent'] ?? 0}  ✅ ${eng['good'] ?? 0}  ⚡ ${eng['fair'] ?? 0}  🔴 ${eng['low'] ?? 0}',
                  style: TextStyle(color: Colors.white.withAlpha(180), fontSize: 13),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(50),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.psychology_rounded, color: Colors.white, size: 32),
          ),
        ],
      ),
    );
  }

  Widget _buildPieChart(bool isDark, Map<String, dynamic> eng, int total) {
    if (total == 0) return const SizedBox.shrink();
    final excellent = (eng['excellent'] as int? ?? 0).toDouble();
    final good = (eng['good'] as int? ?? 0).toDouble();
    final fair = (eng['fair'] as int? ?? 0).toDouble();
    final low = (eng['low'] as int? ?? 0).toDouble();

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
          Text(
            '📊 Phân bố Engagement',
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black87,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 40,
                sections: [
                  if (excellent > 0) PieChartSectionData(
                    value: excellent, color: AppColors.success,
                    title: '${excellent.toInt()}', titleStyle: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                    radius: 50,
                  ),
                  if (good > 0) PieChartSectionData(
                    value: good, color: AppColors.primary,
                    title: '${good.toInt()}', titleStyle: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                    radius: 50,
                  ),
                  if (fair > 0) PieChartSectionData(
                    value: fair, color: AppColors.warning,
                    title: '${fair.toInt()}', titleStyle: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                    radius: 50,
                  ),
                  if (low > 0) PieChartSectionData(
                    value: low, color: AppColors.error,
                    title: '${low.toInt()}', titleStyle: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                    radius: 50,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: [
              _legendItem('Xuất sắc', AppColors.success),
              _legendItem('Tốt', AppColors.primary),
              _legendItem('Trung bình', AppColors.warning),
              _legendItem('Nguy cơ', AppColors.error),
            ],
          ),
        ],
      ),
    );
  }

  Widget _legendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 12, height: 12, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3))),
        const SizedBox(width: 6),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey)),
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

  Widget _buildRiskSection(ColorScheme cs, bool isDark, List<Map<String, dynamic>> riskStudents) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.error.withAlpha(isDark ? 25 : 12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.error.withAlpha(60)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.warning_rounded, color: AppColors.error, size: 20),
              const SizedBox(width: 8),
              Text('⚠️ Sinh viên nguy cơ (${riskStudents.length})',
                  style: TextStyle(color: AppColors.error, fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
          const SizedBox(height: 12),
          ...riskStudents.take(10).map((s) => _buildRiskStudentTile(cs, isDark, s)),
        ],
      ),
    );
  }

  Widget _buildRiskStudentTile(ColorScheme cs, bool isDark, Map<String, dynamic> s) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.error.withAlpha(30),
            child: Text(
              (s['name'] as String).isNotEmpty ? (s['name'] as String)[0].toUpperCase() : '?',
              style: TextStyle(color: AppColors.error, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(s['name'] as String, style: TextStyle(color: cs.onSurface, fontWeight: FontWeight.w600, fontSize: 14)),
                const SizedBox(height: 2),
                Text(
                  'Hoàn thành: ${s['completionRate']}% · Quiz: ${s['avgQuizScore']}% · Offline: ${s['daysInactive']} ngày',
                  style: TextStyle(color: Colors.grey, fontSize: 11),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 32,
            child: TextButton.icon(
              onPressed: _nudging ? null : () => _sendNudge(s),
              icon: Icon(Icons.notifications_active_rounded, size: 14, color: AppColors.error),
              label: Text('Nudge', style: TextStyle(fontSize: 11, color: AppColors.error)),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                side: BorderSide(color: AppColors.error.withAlpha(80)),
              ),
            ),
          ),
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
          _buildClusterTile(
            cs, isDark,
            icon: Icons.speed_rounded,
            color: AppColors.error,
            title: 'Quiz đánh lụi',
            description: 'Làm nhanh < 10s/câu, điểm < 50%',
            count: rushers.length,
            students: rushers,
          ),
          _buildClusterTile(
            cs, isDark,
            icon: Icons.visibility_off_rounded,
            color: AppColors.warning,
            title: 'Không tương tác',
            description: '0 comments, 0 quiz attempts',
            count: inactive.length,
            students: inactive,
          ),
          _buildClusterTile(
            cs, isDark,
            icon: Icons.star_rounded,
            color: AppColors.success,
            title: 'Xuất sắc',
            description: 'Completion > 80%, Quiz > 80%',
            count: excellent.length,
            students: excellent,
          ),
        ],
      ),
    );
  }

  Widget _buildClusterTile(ColorScheme cs, bool isDark, {
    required IconData icon,
    required Color color,
    required String title,
    required String description,
    required int count,
    required List<Map<String, dynamic>> students,
  }) {
    return ExpansionTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: color.withAlpha(25), borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text('$title ($count)', style: TextStyle(color: cs.onSurface, fontWeight: FontWeight.w600, fontSize: 14)),
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

  Widget _buildSuggestionCard(ColorScheme cs, bool isDark, String title, List<String> items, Color accent) {
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
          Text(title, style: TextStyle(color: cs.onSurface, fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 12),
          ...items.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 6),
                  width: 8, height: 8,
                  decoration: BoxDecoration(color: accent, shape: BoxShape.circle),
                ),
                const SizedBox(width: 10),
                Expanded(child: Text(item, style: TextStyle(color: cs.onSurface, height: 1.4))),
              ],
            ),
          )),
        ],
      ),
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
              _buildPatternMetric('Hoàn thành TB', '$avgCompletion%', AppColors.primary),
              const SizedBox(width: 12),
              _buildPatternMetric('Quiz TB', '$avgQuiz%', AppColors.success),
              const SizedBox(width: 12),
              _buildPatternMetric('Bottleneck', '${(bottleneckDrop * 100).toStringAsFixed(0)}%', AppColors.error),
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

  Widget _buildPatternMetric(String label, String value, Color color) {
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
