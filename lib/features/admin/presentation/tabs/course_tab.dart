import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../injection_container.dart';
import '../bloc/admin_bloc.dart';
import '../widgets/course_class_card.dart';

class CourseTab extends StatefulWidget {
  const CourseTab({super.key});

  @override
  State<CourseTab> createState() => _CourseTabState();
}

class _CourseTabState extends State<CourseTab> {
  final _searchController = TextEditingController();
  List<Map<String, dynamic>> _courses = [];
  List<String> _allDeptNames = [];
  bool _isLoading = false;
  int? _expandedCourseId;
  String _activeFilter = 'Tất cả';

  List<String> get _filters => ['Tất cả', ..._allDeptNames];

  @override
  void initState() {
    super.initState();
    _loadCourses();
    _loadDepartments();
  }

  void _loadCourses() {
    context.read<AdminBloc>().add(LoadAcademicCoursesWithTeachers());
  }

  Future<void> _loadDepartments() async {
    try {
      final api = sl<ApiClient>();
      final res = await api.get('/academic/departments');
      final depts = List<Map<String, dynamic>>.from(res['departments'] ?? []);
      if (mounted) {
        setState(() {
          _allDeptNames =
              depts.map((d) => d['name'] as String? ?? '').where((n) => n.isNotEmpty).toList()..sort();
        });
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocListener<AdminBloc, AdminState>(
      listener: (context, state) {
        if (state is AcademicCoursesWithTeachersLoaded) {
          setState(() {
            _courses = state.courses;
            _isLoading = false;
          });
        } else if (state is AdminLoading && _courses.isEmpty) {
          setState(() => _isLoading = true);
        } else if (state is AdminActionSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.success,
            ),
          );
          _loadCourses();
        } else if (state is AssignNeedConfirm) {
          _showReplaceConfirmDialog(context, state);
        } else if (state is AdminError) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Tìm môn học...',
                      hintStyle: GoogleFonts.inter(
                        color: cs.onSurfaceVariant.withValues(alpha: 0.5),
                        fontSize: 14,
                      ),
                      prefixIcon: Icon(
                        Icons.search_rounded,
                        color: cs.onSurfaceVariant.withValues(alpha: 0.4),
                        size: 20,
                      ),
                      filled: true,
                      fillColor: isDark
                          ? cs.surfaceContainerHigh
                          : const Color(0xFFF8FAFC),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(22),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(
                    color: isDark
                        ? cs.surfaceContainerHigh
                        : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    onPressed: _loadCourses,
                    icon: Icon(
                      Icons.refresh_rounded,
                      color: cs.onSurfaceVariant,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 34,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _filters.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) {
                final f = _filters[i];
                final active = f == _activeFilter;
                return GestureDetector(
                  onTap: () => setState(() => _activeFilter = f),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: active
                          ? const Color(0xFF2563EB)
                          : (isDark
                                ? cs.surfaceContainerHigh
                                : const Color(0xFFF1F5F9)),
                      borderRadius: BorderRadius.circular(20),
                      border: active
                          ? null
                          : Border.all(
                              color: const Color(
                                0xFFE2E8F0,
                              ).withValues(alpha: isDark ? 0.2 : 0.5),
                            ),
                    ),
                    child: Text(
                      f,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: active ? Colors.white : cs.onSurfaceVariant,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          _buildStatsSummary(cs, isDark),
          const SizedBox(height: 8),
          Expanded(child: _buildBody(cs, isDark)),
        ],
      ),
    );
  }

  Widget _buildStatsSummary(ColorScheme cs, bool isDark) {
    final courses = _filteredCourses;
    final total = courses.length;
    final withTeacher = courses.where((c) {
      final teachers = c['assignedTeachers'] as List?;
      return teachers != null && teachers.isNotEmpty;
    }).length;
    final without = total - withTeacher;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _summaryChip(
            cs,
            isDark,
            '$total',
            'Tổng môn',
            const Color(0xFF2563EB),
          ),
          const SizedBox(width: 8),
          _summaryChip(
            cs,
            isDark,
            '$withTeacher',
            'Đã có GV',
            const Color(0xFF10B981),
          ),
          const SizedBox(width: 8),
          _summaryChip(
            cs,
            isDark,
            '$without',
            'Chưa phân',
            const Color(0xFFF59E0B),
          ),
        ],
      ),
    );
  }

  Widget _summaryChip(
    ColorScheme cs,
    bool isDark,
    String count,
    String label,
    Color color,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isDark ? cs.surfaceContainerHigh : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(
              0xFFE2E8F0,
            ).withValues(alpha: isDark ? 0.15 : 0.4),
          ),
        ),
        child: Column(
          children: [
            Text(
              count,
              style: GoogleFonts.montserrat(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: cs.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showReplaceConfirmDialog(BuildContext ctx, AssignNeedConfirm state) {
    showDialog(
      context: ctx,
      builder: (dialogCtx) => AlertDialog(
        icon: Icon(Icons.swap_horiz, color: AppColors.warning, size: 36),
        title: const Text('Xác nhận thay thế'),
        content: Text(state.message),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(dialogCtx);
              ctx.read<AdminBloc>().add(
                AssignCourseTeacherEvent(
                  courseClassId: state.courseClassId,
                  teacherId: state.newTeacherId,
                  force: true,
                ),
              );
            },
            style: FilledButton.styleFrom(backgroundColor: AppColors.warning),
            child: const Text('Thay thế'),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> get _filteredCourses {
    var courses = _courses;

    if (_activeFilter != 'Tất cả') {
      courses = courses.where((c) {
        final dept = (c['departmentName'] as String? ?? '').toLowerCase();
        final filter = _activeFilter.toLowerCase();
        return dept.contains(filter);
      }).toList();
    }

    final query = _searchController.text.toLowerCase();
    if (query.isNotEmpty) {
      courses = courses.where((c) {
        final name = (c['name'] as String? ?? '').toLowerCase();
        final code = (c['code'] as String? ?? '').toLowerCase();
        return name.contains(query) || code.contains(query);
      }).toList();
    }

    return courses;
  }

  Widget _buildBody(ColorScheme cs, bool isDark) {
    if (_isLoading && _courses.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    final courses = _filteredCourses;

    if (courses.isEmpty && _courses.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.school,
              size: 48,
              color: cs.onSurfaceVariant.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 8),
            Text(
              'Nhấn refresh để tải danh sách',
              style: TextStyle(color: cs.onSurfaceVariant),
            ),
          ],
        ),
      );
    }

    if (courses.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.filter_list_off_rounded,
              size: 48,
              color: cs.onSurfaceVariant.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 8),
            Text(
              'Không có môn học phù hợp',
              style: TextStyle(color: cs.onSurfaceVariant),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
      itemCount: courses.length,
      itemBuilder: (context, index) {
        final course = courses[index];
        final courseId = course['id'] as int;
        final isExpanded = _expandedCourseId == courseId;
        return CourseClassCard(
          course: course,
          isExpanded: isExpanded,
          onToggle: () {
            setState(() {
              _expandedCourseId = isExpanded ? null : courseId;
            });
          },
        );
      },
    );
  }
}
