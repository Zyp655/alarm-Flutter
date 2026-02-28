import 'dart:convert';
import 'dart:io' show File;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/theme/app_colors.dart';
import '../bloc/admin_bloc.dart';
import '../tabs/academic_tab.dart';
import '../tabs/course_tab.dart';
import '../tabs/analytics_tab.dart';
import '../tabs/tools_tab.dart';

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;

  List<Map<String, dynamic>> _departments = [];
  List<Map<String, dynamic>> _semesters = [];
  List<Map<String, dynamic>> _academicCourses = [];
  List<Map<String, dynamic>> _courseClasses = [];

  List<Map<String, dynamic>> _courses = [];
  bool _isLoadingCourses = false;
  String _courseSearch = '';

  Map<String, dynamic> _analytics = {};
  bool _isLoadingAnalytics = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(_onTabChanged);
    _loadAcademicData();
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) return;
    switch (_tabController.index) {
      case 1:
        if (_courses.isEmpty && !_isLoadingCourses) _loadCourses();
        break;
      case 2:
        if (_analytics.isEmpty && !_isLoadingAnalytics) _loadAnalytics();
        break;
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  void _loadAcademicData() {
    context.read<AdminBloc>().add(LoadAcademicData());
  }

  void _loadCourses() {
    setState(() => _isLoadingCourses = true);
    context.read<AdminBloc>().add(
      LoadAdminCourses(search: _courseSearch.isNotEmpty ? _courseSearch : null),
    );
  }

  void _loadAnalytics() {
    setState(() => _isLoadingAnalytics = true);
    context.read<AdminBloc>().add(LoadAnalytics());
  }

  void _togglePublish(int courseId, bool currentlyPublished) {
    context.read<AdminBloc>().add(
      TogglePublish(courseId: courseId, currentlyPublished: currentlyPublished),
    );
  }

  Future<void> _deleteCourse(int courseId, String title) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: Icon(Icons.delete_forever, color: AppColors.error, size: 36),
        title: const Text('Xác nhận xoá'),
        content: Text(
          'Bạn có chắc muốn xoá môn học\n"$title"?\n\nThao tác này không thể hoàn tác.',
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Huỷ'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Xoá'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    context.read<AdminBloc>().add(DeleteCourse(courseId));
  }

  void _seedUsers() {
    setState(() => _isLoading = true);
    context.read<AdminBloc>().add(SeedUsers());
  }

  void _seedAchievements() {
    setState(() => _isLoading = true);
    context.read<AdminBloc>().add(SeedAchievements());
  }

  void _seedRoadmap() {
    setState(() => _isLoading = true);
    context.read<AdminBloc>().add(SeedRoadmap());
  }

  Future<void> _assignRoadmapTeacher() async {
    final emailCtrl = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        final cs = Theme.of(ctx).colorScheme;
        return AlertDialog(
          title: const Text('Gán Roadmap cho Giảng viên'),
          content: TextField(
            controller: emailCtrl,
            decoration: InputDecoration(
              labelText: 'Email giảng viên',
              hintText: 'teacher@example.com',
              prefixIcon: const Icon(Icons.email_outlined),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Hủy'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: FilledButton.styleFrom(backgroundColor: cs.primary),
              child: const Text('Gán'),
            ),
          ],
        );
      },
    );
    if (confirmed != true || emailCtrl.text.trim().isEmpty) return;
    setState(() => _isLoading = true);
    context.read<AdminBloc>().add(AssignRoadmapTeacher(emailCtrl.text.trim()));
  }

  Future<void> _importFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv', 'xlsx'],
      withData: true,
    );
    if (result == null || result.files.isEmpty) return;
    setState(() => _isLoading = true);
    final file = result.files.first;
    Uint8List? bytes = file.bytes;
    if (bytes == null && file.path != null) {
      bytes = await File(file.path!).readAsBytes();
    }
    if (bytes == null) {
      _snack('Không đọc được file', isError: true);
      setState(() => _isLoading = false);
      return;
    }
    final ext = file.extension?.toLowerCase() ?? '';
    final body = ext == 'xlsx'
        ? {'xlsxBase64': base64Encode(bytes)}
        : {'csvContent': utf8.decode(bytes)};
    context.read<AdminBloc>().add(ImportStudents(body));
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('current_user_id');
    await prefs.remove('token');
    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed('/');
  }

  void _snack(String message, {bool isError = false}) {
    if (!mounted) return;
    final cs = Theme.of(context).colorScheme;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle_outline,
              color: isError ? cs.onError : cs.onInverseSurface,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: isError ? cs.error : null,
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AdminBloc, AdminState>(
      listener: (context, state) {
        if (state is AcademicDataLoaded) {
          setState(() {
            _departments = state.departments;
            _semesters = state.semesters;
            _academicCourses = state.academicCourses;
            _courseClasses = state.courseClasses;
          });
        } else if (state is AdminCoursesLoaded) {
          setState(() {
            _courses = state.courses;
            _isLoadingCourses = false;
          });
        } else if (state is AnalyticsLoaded) {
          setState(() {
            _analytics = state.analytics;
            _isLoadingAnalytics = false;
          });
        } else if (state is AdminActionSuccess) {
          setState(() => _isLoading = false);
          _snack(state.message);
          _loadAcademicData();
        } else if (state is AdminError) {
          setState(() {
            _isLoading = false;
            _isLoadingCourses = false;
            _isLoadingAnalytics = false;
          });
          _snack(state.message, isError: true);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Quản Trị Hệ Thống',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          centerTitle: true,
          automaticallyImplyLeading: false,
          actions: [
            IconButton(
              icon: const Icon(Icons.logout_rounded),
              tooltip: 'Đăng xuất',
              onPressed: _logout,
            ),
          ],
          bottom: TabBar(
            controller: _tabController,
            indicatorSize: TabBarIndicatorSize.tab,
            dividerColor: Colors.transparent,
            isScrollable: false,
            tabs: const [
              Tab(
                icon: Icon(Icons.school_rounded, size: 20),
                text: 'Học thuật',
              ),
              Tab(
                icon: Icon(Icons.menu_book_rounded, size: 20),
                text: 'Môn học',
              ),
              Tab(
                icon: Icon(Icons.analytics_rounded, size: 20),
                text: 'Thống kê',
              ),
              Tab(
                icon: Icon(Icons.build_circle_rounded, size: 20),
                text: 'Công cụ',
              ),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            AcademicTab(
              departments: _departments,
              semesters: _semesters,
              academicCourses: _academicCourses,
              courseClasses: _courseClasses,
              onRefresh: () async => _loadAcademicData(),
            ),
            CourseTab(
              courses: _courses,
              isLoading: _isLoadingCourses,
              searchQuery: _courseSearch,
              onSearchChanged: (v) {
                _courseSearch = v;
                _loadCourses();
              },
              onRefresh: () async => _loadCourses(),
              onTogglePublish: _togglePublish,
              onDeleteCourse: _deleteCourse,
            ),
            AnalyticsTab(
              analytics: _analytics,
              isLoading: _isLoadingAnalytics,
              onRefresh: () async => _loadAnalytics(),
            ),
            ToolsTab(
              isLoading: _isLoading,
              onSeedUsers: _seedUsers,
              onSeedAchievements: _seedAchievements,
              onSeedRoadmap: _seedRoadmap,
              onImportFile: _importFile,
              onAssignRoadmapTeacher: _assignRoadmapTeacher,
            ),
          ],
        ),
      ),
    );
  }
}
