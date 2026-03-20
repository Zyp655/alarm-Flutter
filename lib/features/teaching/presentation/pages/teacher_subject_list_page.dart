import 'package:flutter/material.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../injection_container.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/subject_class_card.dart';
import '../widgets/class_options_sheet.dart';
import '../../../../core/widgets/animations.dart';

class TeacherSubjectListPage extends StatefulWidget {
  const TeacherSubjectListPage({super.key});

  @override
  State<TeacherSubjectListPage> createState() => _TeacherSubjectListPageState();
}

enum _SortMode { name, code }

class _TeacherSubjectListPageState extends State<TeacherSubjectListPage> {
  bool _loading = true;
  String? _error;
  List<Map<String, dynamic>> _classes = [];

  final TextEditingController _searchCtrl = TextEditingController();
  String _searchQuery = '';
  _SortMode _sortMode = _SortMode.name;

  int get _teacherId => sl<SharedPreferences>().getInt('current_user_id') ?? 1;

  @override
  void initState() {
    super.initState();
    _loadClasses();
    _searchCtrl.addListener(() {
      setState(() => _searchQuery = _searchCtrl.text.trim().toLowerCase());
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _filteredClasses {
    var list = _classes.where((cls) {
      if (_searchQuery.isEmpty) return true;
      final name = (cls['courseName'] ?? '').toString().toLowerCase();
      final code = (cls['courseCode'] ?? '').toString().toLowerCase();
      final classCode = (cls['classCode'] ?? '').toString().toLowerCase();
      return name.contains(_searchQuery) ||
          code.contains(_searchQuery) ||
          classCode.contains(_searchQuery);
    }).toList();

    list.sort((a, b) {
      if (_sortMode == _SortMode.name) {
        return (a['courseName'] ?? '').toString().compareTo(
              (b['courseName'] ?? '').toString(),
            );
      } else {
        return (a['courseCode'] ?? '').toString().compareTo(
              (b['courseCode'] ?? '').toString(),
            );
      }
    });
    return list;
  }

  Future<void> _loadClasses() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final api = sl<ApiClient>();
      final res = await api.get('/teacher/my-classes?teacherId=$_teacherId');
      final list = List<Map<String, dynamic>>.from(res is List ? res : []);
      if (mounted) setState(() => _classes = list);
    } catch (e) {
      if (mounted) setState(() => _error = 'Lỗi tải danh sách: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  static const _courseColors = [
    [Color(0xFF1ABC9C), Color(0xFF16A085)],
    [Color(0xFF3498DB), Color(0xFF2980B9)],
    [Color(0xFF9B59B6), Color(0xFF8E44AD)],
    [Color(0xFFE67E22), Color(0xFFD35400)],
    [Color(0xFFE74C3C), Color(0xFFC0392B)],
    [Color(0xFF2ECC71), Color(0xFF27AE60)],
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark(context);
    return Scaffold(
      backgroundColor: AppColors.background(context),
      body: RefreshIndicator(
        onRefresh: _loadClasses,
        color: Colors.white,
        backgroundColor: AppColors.primary,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            _buildAppBar(isDark),
            if (!_loading && _error == null && _classes.isNotEmpty)
              SliverToBoxAdapter(child: _buildSearchBar(isDark)),
            _buildBody(isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(bool isDark) {
    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
      surfaceTintColor: Colors.transparent,
      leading: Navigator.canPop(context)
          ? IconButton(
              icon: Icon(
                Icons.arrow_back_ios_rounded,
                color: isDark ? Colors.white : Colors.black87,
                size: 20,
              ),
              onPressed: () => Navigator.pop(context),
            )
          : null,
      automaticallyImplyLeading: false,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.primary.withAlpha(isDark ? 40 : 15),
                isDark ? AppColors.darkSurface : Colors.white,
              ],
            ),
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(56, 8, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Môn Học Được Phân Công',
                          style: TextStyle(
                            color: isDark ? Colors.white : Colors.black87,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      if (!_loading && _error == null && _classes.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [AppColors.primary, AppColors.primaryDark],
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '${_classes.length} môn',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 14),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar(bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurfaceVariant : Colors.grey.shade50,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isDark ? Colors.white.withAlpha(10) : Colors.grey.shade200,
                ),
              ),
              child: TextField(
                controller: _searchCtrl,
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black87,
                  fontSize: 14,
                ),
                decoration: InputDecoration(
                  hintText: 'Tìm theo tên, mã môn...',
                  hintStyle: TextStyle(
                    color: AppColors.textSecondary(context),
                    fontSize: 14,
                  ),
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color: AppColors.textSecondary(context),
                    size: 20,
                  ),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 18),
                          onPressed: () => _searchCtrl.clear(),
                        )
                      : null,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Container(
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurfaceVariant : Colors.grey.shade50,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isDark ? Colors.white.withAlpha(10) : Colors.grey.shade200,
              ),
            ),
            child: PopupMenuButton<_SortMode>(
              onSelected: (mode) => setState(() => _sortMode = mode),
              icon: Icon(Icons.sort_rounded, color: AppColors.primary, size: 22),
              tooltip: 'Sắp xếp',
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              itemBuilder: (_) => [
                _sortMenuItem(_SortMode.name, Icons.sort_by_alpha, 'Theo tên A-Z'),
                _sortMenuItem(_SortMode.code, Icons.tag, 'Theo mã môn'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  PopupMenuItem<_SortMode> _sortMenuItem(_SortMode mode, IconData icon, String label) {
    final isActive = _sortMode == mode;
    return PopupMenuItem(
      value: mode,
      child: Row(
        children: [
          Icon(icon, size: 20, color: isActive ? AppColors.primary : null),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: isActive ? AppColors.primary : null,
              fontWeight: isActive ? FontWeight.w600 : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(bool isDark) {
    if (_loading) {
      return const SliverFillRemaining(
        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      );
    }
    if (_error != null) {
      return SliverFillRemaining(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.error.withAlpha(20),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.wifi_off_rounded, size: 40, color: AppColors.error),
                ),
                const SizedBox(height: 16),
                Text(
                  'Không thể tải dữ liệu',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _error!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.textSecondary(context),
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 20),
                FilledButton.icon(
                  onPressed: _loadClasses,
                  icon: const Icon(Icons.refresh, size: 18),
                  label: const Text('Thử lại'),
                ),
              ],
            ),
          ),
        ),
      );
    }
    if (_classes.isEmpty) {
      return SliverFillRemaining(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primary.withAlpha(15),
                        AppColors.primaryDark.withAlpha(10),
                      ],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.school_outlined,
                    size: 56,
                    color: AppColors.primary.withAlpha(180),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Chưa có môn học',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Liên hệ quản trị viên để được gán môn',
                  style: TextStyle(
                    color: AppColors.textSecondary(context),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final filtered = _filteredClasses;

    if (filtered.isEmpty) {
      return SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.search_off_rounded, size: 48, color: AppColors.textSecondary(context)),
              const SizedBox(height: 12),
              Text(
                'Không tìm thấy môn học phù hợp',
                style: TextStyle(color: AppColors.textSecondary(context)),
              ),
            ],
          ),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
          final cls = filtered[index];
          final originalIndex = _classes.indexOf(cls);
          final gradient = _courseColors[originalIndex % _courseColors.length];

          if (_searchQuery.isNotEmpty && index == 0) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    'Tìm thấy ${filtered.length}/${_classes.length} môn',
                    style: TextStyle(
                      color: AppColors.textSecondary(context),
                      fontSize: 12,
                    ),
                  ),
                ),
                StaggeredListAnimation(
                  index: index,
                  child: SubjectClassCard(
                    cls: cls,
                    gradient: gradient,
                    onTap: () => ClassOptionsSheet.show(context: context, cls: cls),
                  ),
                ),
              ],
            );
          }
          return StaggeredListAnimation(
            index: index,
            child: SubjectClassCard(
              cls: cls,
              gradient: gradient,
              onTap: () => ClassOptionsSheet.show(context: context, cls: cls),
            ),
          );
        }, childCount: filtered.length),
      ),
    );
  }
}
