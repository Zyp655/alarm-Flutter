import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../../../core/api/api_constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../widgets/stat_card_widget.dart';
import '../widgets/student_status_chart.dart';
import '../widgets/review_card_widget.dart';
import '../widgets/rating_section_widget.dart';
import 'course_insights_page.dart';
import 'at_risk_students_page.dart';
import 'student_behavior_page.dart';

class TeacherCourseStatsPage extends StatefulWidget {
  final int teacherId;
  final int? courseId;

  const TeacherCourseStatsPage({
    super.key,
    required this.teacherId,
    this.courseId,
  });

  @override
  State<TeacherCourseStatsPage> createState() => _TeacherCourseStatsPageState();
}

class _TeacherCourseStatsPageState extends State<TeacherCourseStatsPage> {
  List<dynamic> _courses = [];
  Map<String, dynamic>? _stats;
  Map<String, dynamic>? _reviews;
  int? _selectedCourseId;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _selectedCourseId = widget.courseId;
    _loadCourses();
  }

  Future<void> _loadCourses() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/courses'),
        headers: {
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        final courses = jsonDecode(response.body) as List;
        setState(() {
          _courses = courses
              .where((c) => c['instructorId'] == widget.teacherId)
              .toList();
          if (_selectedCourseId != null) {
            _loadStats();
          } else if (_courses.isNotEmpty) {
            _selectedCourseId = _courses.first['id'];
            _loadStats();
          } else {
            _isLoading = false;
          }
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadStats() async {
    if (_selectedCourseId == null) return;

    setState(() => _isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final statsResponse = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/courses/$_selectedCourseId/stats'),
        headers: {
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      final reviewsResponse = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/courses/$_selectedCourseId/reviews'),
        headers: {
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (statsResponse.statusCode == 200) {
        setState(() {
          _stats = jsonDecode(statsResponse.body);
        });
      }

      if (reviewsResponse.statusCode == 200) {
        setState(() {
          _reviews = jsonDecode(reviewsResponse.body);
        });
      }

      setState(() => _isLoading = false);
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final courseName = _courses.isNotEmpty && _selectedCourseId != null
        ? (_courses.firstWhere(
            (c) => c['id'] == _selectedCourseId,
            orElse: () => {'title': ''},
          )['title'] as String? ?? '')
        : '';

    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(
        title: Text(courseName.isNotEmpty ? courseName : 'Thống kê Môn học'),
        elevation: 0,
      ),
      body: _buildContent(),
    );
  }

  Widget _buildActionCards() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final course = _courses.firstWhere(
      (c) => c['id'] == _selectedCourseId,
      orElse: () => {'title': ''},
    );
    final courseTitle = course['title'] as String? ?? '';

    return Column(
      children: [
        _buildActionCard(
          icon: Icons.psychology_rounded,
          gradient: const [Color(0xFF6C63FF), Color(0xFF4ECDC4)],
          title: 'Ph\u00e2n t\u00edch h\u00e0nh vi SV',
          subtitle: 'Theo d\u00f5i m\u1ee9c \u0111\u1ed9 tham gia v\u00e0 xu h\u01b0\u1edbng h\u1ecdc t\u1eadp',
          isDark: isDark,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => StudentBehaviorPage(
                courseId: _selectedCourseId!,
                courseTitle: courseTitle,
                teacherId: widget.teacherId,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        _buildActionCard(
          icon: Icons.auto_awesome,
          gradient: const [Color(0xFFFF6B6B), Color(0xFFFFE66D)],
          title: 'Ph\u00e2n t\u00edch AI',
          subtitle: 'G\u1ee3i \u00fd c\u1ea3i thi\u1ec7n n\u1ed9i dung v\u00e0 ph\u01b0\u01a1ng ph\u00e1p gi\u1ea3ng d\u1ea1y',
          isDark: isDark,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => CourseInsightsPage(
                courseId: _selectedCourseId!,
                courseTitle: courseTitle,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        _buildActionCard(
          icon: Icons.warning_amber_rounded,
          gradient: const [Color(0xFFFF9A56), Color(0xFFFF6B6B)],
          title: 'SV Nguy c\u01a1',
          subtitle: 'Danh s\u00e1ch sinh vi\u00ean c\u1ea7n h\u1ed7 tr\u1ee3 \u0111\u1eb7c bi\u1ec7t',
          isDark: isDark,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AtRiskStudentsPage(
                courseId: _selectedCourseId!,
                courseTitle: courseTitle,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required List<Color> gradient,
    required String title,
    required String subtitle,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: gradient[0].withAlpha(40),
            ),
            boxShadow: [
              BoxShadow(
                color: gradient[0].withAlpha(isDark ? 15 : 10),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: gradient),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.white54 : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: isDark ? Colors.white38 : Colors.grey[400],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (_courses.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.school_outlined,
              size: 64,
              color: AppColors.textSecondary(context),
            ),
            AppSpacing.gapV16,
            Text(
              'B\u1ea1n ch\u01b0a c\u00f3 m\u00f4n h\u1ecdc n\u00e0o',
              style: TextStyle(
                color: AppColors.textSecondary(context),
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    if (_stats == null) {
      return Center(
        child: Text(
          'Kh\u00f4ng c\u00f3 d\u1eef li\u1ec7u',
          style: TextStyle(color: AppColors.textSecondary(context)),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadStats,
      child: SingleChildScrollView(
        padding: AppSpacing.paddingLg,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_selectedCourseId != null) _buildActionCards(),
            AppSpacing.gapV24,
            _buildOverviewCards(),
            AppSpacing.gapV24,
            _buildStudentStatusChart(),
            AppSpacing.gapV24,
            _buildRatingSection(),
            AppSpacing.gapV24,
            _buildReviewsList(),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewCards() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.5,
      children: [
        StatCardWidget(
          icon: Icons.people,
          iconColor: AppColors.primary,
          value: '${_stats!['totalEnrollments']}',
          label: 'Học viên',
        ),
        StatCardWidget(
          icon: Icons.check_circle,
          iconColor: AppColors.success,
          value: '${_stats!['completionRate']}%',
          label: 'Hoàn thành',
        ),
        StatCardWidget(
          icon: Icons.book,
          iconColor: AppColors.warning,
          value: '${_stats!['totalLessons']}',
          label: 'Bài học',
        ),
        StatCardWidget(
          icon: Icons.star,
          iconColor: AppColors.warningLight,
          value: '${_stats!['rating']['average']}',
          label: '${_stats!['rating']['totalReviews']} đánh giá',
        ),
      ],
    );
  }

  Widget _buildStudentStatusChart() {
    final studentStatus = _stats!['studentStatus'] as Map<String, dynamic>;
    return StudentStatusChart(
      notStarted: studentStatus['notStarted'] as int,
      inProgress: studentStatus['inProgress'] as int,
      completed: studentStatus['completed'] as int,
    );
  }

  Widget _buildRatingSection() {
    if (_reviews == null) return const SizedBox();

    final distribution = _reviews!['distribution'] as Map<String, dynamic>;

    return RatingSectionWidget(
      averageRating: (_reviews!['averageRating'] as num).toDouble(),
      totalReviews: _reviews!['totalReviews'] as int,
      distribution: distribution.map((k, v) => MapEntry(k, v as int)),
    );
  }

  Widget _buildReviewsList() {
    if (_reviews == null) return const SizedBox();

    final reviewsList = _reviews!['reviews'] as List;

    if (reviewsList.isEmpty) {
      return Container(
        padding: AppSpacing.paddingXl,
        decoration: BoxDecoration(
          color: AppColors.cardColor(context),
          borderRadius: AppSpacing.borderRadiusLg,
        ),
        child: Center(
          child: Text(
            'Chưa có đánh giá',
            style: TextStyle(color: AppColors.textSecondary(context)),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Đánh giá gần đây',
          style: TextStyle(
            color: AppColors.textPrimary(context),
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        AppSpacing.gapV12,
        ...reviewsList
            .take(5)
            .map(
              (review) => ReviewCardWidget(
                userName: review['userName'] as String? ?? '',
                rating: review['rating'] as int,
                comment: review['comment'] as String?,
              ),
            ),
      ],
    );
  }
}
