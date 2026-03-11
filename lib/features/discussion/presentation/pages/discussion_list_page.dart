import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/discussion_bloc.dart';
import '../../domain/entities/discussion_comment.dart';
import '../widgets/thread_card.dart';
import '../widgets/discussion_empty_state.dart';
import 'discussion_thread_page.dart';
import '../../../../core/theme/app_colors.dart';

enum DiscussionFilter { newest, mostVoted, unanswered }

class DiscussionListPage extends StatefulWidget {
  final int courseId;
  final String courseTitle;
  final List<int> lessonIds;
  final int userId;

  const DiscussionListPage({
    super.key,
    required this.courseId,
    required this.courseTitle,
    required this.lessonIds,
    required this.userId,
  });

  @override
  State<DiscussionListPage> createState() => _DiscussionListPageState();
}

class _DiscussionListPageState extends State<DiscussionListPage> {
  final TextEditingController _searchController = TextEditingController();
  DiscussionFilter _selectedFilter = DiscussionFilter.newest;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    if (widget.lessonIds.isNotEmpty) {
      context.read<DiscussionBloc>().add(
        LoadDiscussions(lessonId: widget.lessonIds.first),
      );
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<DiscussionComment> _applyFilters(List<DiscussionComment> comments) {
    var filtered = comments.where((c) => c.parentId == null).toList();
    if (_searchQuery.isNotEmpty) {
      filtered = filtered
          .where(
            (c) => c.text.toLowerCase().contains(_searchQuery.toLowerCase()),
          )
          .toList();
    }
    switch (_selectedFilter) {
      case DiscussionFilter.newest:
        filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      case DiscussionFilter.mostVoted:
        filtered.sort((a, b) => b.score.compareTo(a.score));
      case DiscussionFilter.unanswered:
        filtered = filtered.where((c) => !c.isAnswered).toList();
        filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark
        ? AppColors.darkBackground
        : AppColors.lightBackground;
    final cardColor = isDark ? AppColors.darkBackground : Colors.white;
    final textColor = isDark ? Colors.white : AppColors.darkBackground;
    final subTextColor = isDark ? Colors.grey[400]! : Colors.grey[600]!;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text(
          'Thảo luận — ${widget.courseTitle}',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildSearchBar(cardColor, textColor, subTextColor),
          _buildFilterChips(cardColor, subTextColor),
          Expanded(
            child: BlocBuilder<DiscussionBloc, DiscussionState>(
              buildWhen: (prev, curr) =>
                  prev.runtimeType != curr.runtimeType || prev != curr,
              builder: (context, state) {
                if (state is DiscussionLoading) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  );
                }

                if (state is DiscussionError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 48,
                          color: AppColors.error.withValues(alpha: 0.35),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          state.message,
                          style: TextStyle(color: subTextColor),
                        ),
                      ],
                    ),
                  );
                }

                if (state is DiscussionLoaded) {
                  final threads = _applyFilters(state.comments);

                  if (threads.isEmpty) {
                    return DiscussionEmptyState(
                      isDark: isDark,
                      isSearchResult: _searchQuery.isNotEmpty,
                    );
                  }

                  return RefreshIndicator(
                    color: AppColors.primary,
                    onRefresh: () async {
                      if (widget.lessonIds.isNotEmpty) {
                        context.read<DiscussionBloc>().add(
                          LoadDiscussions(lessonId: widget.lessonIds.first),
                        );
                      }
                    },
                    child: ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: threads.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final thread = threads[index];
                        return ThreadCard(
                          thread: thread,
                          cardColor: cardColor,
                          textColor: textColor,
                          subTextColor: subTextColor,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => BlocProvider.value(
                                  value: context.read<DiscussionBloc>(),
                                  child: DiscussionThreadPage(
                                    lessonId: thread.lessonId,
                                    userId: widget.userId,
                                    lessonTitle: '',
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  );
                }

                return DiscussionEmptyState(isDark: isDark);
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          if (widget.lessonIds.isNotEmpty) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => BlocProvider.value(
                  value: context.read<DiscussionBloc>(),
                  child: DiscussionThreadPage(
                    lessonId: widget.lessonIds.first,
                    userId: widget.userId,
                    lessonTitle: widget.courseTitle,
                  ),
                ),
              ),
            );
          }
        },
        icon: Icon(Icons.add_comment),
        label: const Text('Đặt câu hỏi'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
    );
  }

  Widget _buildSearchBar(Color cardColor, Color textColor, Color subTextColor) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: TextField(
        controller: _searchController,
        onChanged: (v) => setState(() => _searchQuery = v),
        style: TextStyle(color: textColor),
        decoration: InputDecoration(
          hintText: 'Tìm kiếm thảo luận...',
          hintStyle: TextStyle(color: subTextColor),
          prefixIcon: Icon(Icons.search, color: subTextColor),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.close, color: subTextColor),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _searchQuery = '');
                  },
                )
              : null,
          filled: true,
          fillColor: cardColor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }

  Widget _buildFilterChips(Color cardColor, Color subTextColor) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        children: DiscussionFilter.values.map((filter) {
          final isSelected = _selectedFilter == filter;
          final label = switch (filter) {
            DiscussionFilter.newest => 'Mới nhất',
            DiscussionFilter.mostVoted => 'Nhiều vote',
            DiscussionFilter.unanswered => 'Chưa trả lời',
          };
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(label),
              selected: isSelected,
              onSelected: (_) => setState(() => _selectedFilter = filter),
              selectedColor: AppColors.primary.withAlpha(40),
              checkmarkColor: AppColors.primary,
              labelStyle: TextStyle(
                color: isSelected ? AppColors.primary : subTextColor,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
              backgroundColor: cardColor,
              side: BorderSide(
                color: isSelected ? AppColors.primary : Colors.transparent,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
