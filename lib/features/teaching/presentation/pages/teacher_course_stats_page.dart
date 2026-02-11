import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../../core/api/api_constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../widgets/stat_card_widget.dart';
import '../widgets/student_status_chart.dart';
import '../widgets/review_card_widget.dart';
import '../widgets/rating_section_widget.dart';

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
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/courses'),
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
      final statsResponse = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/courses/$_selectedCourseId/stats'),
      );

      final reviewsResponse = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/courses/$_selectedCourseId/reviews'),
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
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        title: const Text('Thống kê Khóa học'),
        backgroundColor: AppColors.darkSurface,
        foregroundColor: AppColors.textPrimaryDark,
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildCourseSelector(),
          Expanded(child: _buildContent()),
        ],
      ),
    );
  }

  Widget _buildCourseSelector() {
    return Container(
      padding: AppSpacing.paddingLg,
      color: AppColors.darkSurface,
      child: DropdownButtonFormField<int>(
        value: _selectedCourseId,
        dropdownColor: AppColors.darkSurfaceVariant,
        style: const TextStyle(color: AppColors.textPrimaryDark),
        decoration: AppDecorations.darkInputDecoration(
          labelText: 'Chọn khóa học',
        ),
        items: _courses.map<DropdownMenuItem<int>>((course) {
          return DropdownMenuItem(
            value: course['id'] as int,
            child: Text(course['title'] as String),
          );
        }).toList(),
        onChanged: (value) {
          setState(() {
            _selectedCourseId = value;
          });
          _loadStats();
        },
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.textPrimaryDark),
      );
    }

    if (_courses.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.school_outlined, size: 64, color: Colors.grey[600]),
            AppSpacing.gapV16,
            Text(
              'Bạn chưa có khóa học nào',
              style: TextStyle(color: Colors.grey[400], fontSize: 16),
            ),
          ],
        ),
      );
    }

    if (_stats == null) {
      return const Center(
        child: Text('Không có dữ liệu', style: TextStyle(color: Colors.grey)),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadStats,
      child: SingleChildScrollView(
        padding: AppSpacing.paddingLg,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
          iconColor: const Color(0xFF6C63FF),
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
          iconColor: Colors.amber,
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
          color: AppColors.darkSurface,
          borderRadius: AppSpacing.borderRadiusLg,
        ),
        child: Center(
          child: Text(
            'Chưa có đánh giá',
            style: TextStyle(color: Colors.grey[400]),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Đánh giá gần đây',
          style: TextStyle(
            color: AppColors.textPrimaryDark,
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
