import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shimmer/shimmer.dart';
import 'package:http/http.dart' as http;
import '../bloc/course_list_bloc.dart';
import '../bloc/course_list_event.dart';
import '../bloc/course_list_state.dart';
import '../widgets/course_card.dart';
import '../widgets/major_filter_widget.dart';
import '../../domain/entities/major_entity.dart';
import '../../data/datasources/major_remote_datasource.dart';
import '../../../../core/route/app_route.dart';

class CourseCatalogPage extends StatefulWidget {
  const CourseCatalogPage({super.key});

  @override
  State<CourseCatalogPage> createState() => _CourseCatalogPageState();
}

class _CourseCatalogPageState extends State<CourseCatalogPage> {
  final TextEditingController _searchController = TextEditingController();
  String? _selectedLevel;
  int? _selectedMajorId;
  final ScrollController _scrollController = ScrollController();
  List<MajorEntity> _majors = [];
  bool _isLoadingMajors = true;

  @override
  void initState() {
    super.initState();
    context.read<CourseListBloc>().add(const LoadCoursesEvent());
    _loadMajors();
  }

  Future<void> _loadMajors() async {
    try {
      final dataSource = MajorRemoteDataSourceImpl(client: http.Client());
      final majors = await dataSource.getMajors();
      if (mounted) {
        setState(() {
          _majors = majors;
          _isLoadingMajors = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingMajors = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onSearch() {
    context.read<CourseListBloc>().add(
      LoadCoursesEvent(
        search: _searchController.text.isEmpty ? null : _searchController.text,
        level: _selectedLevel,
        majorId: _selectedMajorId,
      ),
    );
  }

  void _onMajorSelected(int? majorId) {
    setState(() {
      _selectedMajorId = majorId;
    });
    _onSearch();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          _buildSliverAppBar(context),
          SliverToBoxAdapter(child: _buildSearchSection()),
          SliverToBoxAdapter(
            child: MajorFilterWidget(
              majors: _majors,
              selectedMajorId: _selectedMajorId,
              onMajorSelected: _onMajorSelected,
              isLoading: _isLoadingMajors,
            ),
          ),

          _buildCourseGrid(),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 180,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: const Color(0xFF6C63FF),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF6C63FF), Color(0xFF4834DF)],
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                right: -50,
                top: -50,
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.1),
                  ),
                ),
              ),
              Positioned(
                left: -30,
                bottom: -30,
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.05),
                  ),
                ),
              ),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      const Text(
                        'Khám phá',
                        style: TextStyle(color: Colors.white70, fontSize: 16),
                      ).animate().fadeIn().slideX(begin: -0.1),
                      const SizedBox(height: 4),
                      const Text(
                        'Khóa Học Online',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ).animate().fadeIn(delay: 100.ms).slideX(begin: -0.1),
                      const SizedBox(height: 8),
                      Text(
                        'Học mọi lúc, mọi nơi với các khóa học chất lượng',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 14,
                        ),
                      ).animate().fadeIn(delay: 200.ms),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.bookmark_outline, color: Colors.white),
          onPressed: () => Navigator.pushNamed(context, AppRoutes.myCourses),
        ),
        IconButton(
          icon: const Icon(Icons.notifications_outlined, color: Colors.white),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildSearchSection() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Tìm kiếm khóa học, chủ đề...',
                hintStyle: TextStyle(color: Colors.grey[400]),
                prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear, color: Colors.grey[400]),
                        onPressed: () {
                          _searchController.clear();
                          _onSearch();
                        },
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
              ),
              onSubmitted: (_) => _onSearch(),
              onChanged: (_) => setState(() {}),
            ),
          ).animate().fadeIn().slideY(begin: 0.1),
        ],
      ),
    );
  }

  Widget _buildCourseGrid() {
    return BlocBuilder<CourseListBloc, CourseListState>(
      builder: (context, state) {
        if (state is CourseListInitial || state is CourseListLoading) {
          return SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => _buildShimmerCard(),
                childCount: 3,
              ),
            ),
          );
        } else if (state is CourseListError) {
          return SliverFillRemaining(child: _buildErrorState(state.message));
        } else if (state is CourseListLoaded) {
          if (state.courses.isEmpty) {
            return SliverFillRemaining(child: _buildEmptyState());
          }

          return SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: CourseCard(course: state.courses[index])
                      .animate()
                      .fadeIn(delay: Duration(milliseconds: 50 * index))
                      .slideY(begin: 0.05),
                ),
                childCount: state.courses.length,
              ),
            ),
          );
        }
        return const SliverToBoxAdapter(child: SizedBox());
      },
    );
  }

  Widget _buildShimmerCard() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        height: 280,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.red[50],
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.wifi_off, size: 48, color: Colors.red[300]),
            ),
            const SizedBox(height: 24),
            const Text(
              'Không thể tải khóa học',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                context.read<CourseListBloc>().add(RefreshCoursesEvent());
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Thử lại'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6C63FF),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF6C63FF).withOpacity(0.1),
                    const Color(0xFF4834DF).withOpacity(0.1),
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.search_off,
                size: 64,
                color: Color(0xFF6C63FF),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Không tìm thấy khóa học',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Thử tìm kiếm với từ khóa khác\nhoặc thay đổi bộ lọc',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600], height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}
