import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import '../../domain/entities/search_result.dart';
import '../bloc/search_bloc.dart';
import '../../../../core/theme/app_colors.dart';

class GlobalSearchPage extends StatefulWidget {
  const GlobalSearchPage({super.key});

  @override
  State<GlobalSearchPage> createState() => _GlobalSearchPageState();
}

class _GlobalSearchPageState extends State<GlobalSearchPage> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
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

    return BlocProvider(
      create: (_) =>
          GetIt.instance<SearchBloc>()..add(const LoadSearchHistory()),
      child: Scaffold(
        backgroundColor: bgColor,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          titleSpacing: 0,
          title: Builder(
            builder: (ctx) => _SearchField(
              controller: _controller,
              focusNode: _focusNode,
              textColor: textColor,
              subTextColor: subTextColor,
              cardColor: cardColor,
              onChanged: (q) =>
                  ctx.read<SearchBloc>().add(SearchQueryChanged(q)),
              onClear: () {
                _controller.clear();
                ctx.read<SearchBloc>().add(const ClearSearch());
              },
            ),
          ),
        ),
        body: Builder(
          builder: (ctx) => Column(
            children: [
              _FilterChips(cardColor: cardColor, subTextColor: subTextColor),
              Expanded(
                child: BlocBuilder<SearchBloc, SearchState>(
                  builder: (context, state) {
                    if (state is SearchInitial) {
                      return _buildRecentSearches(
                        state.searchHistory,
                        cardColor,
                        textColor,
                        subTextColor,
                        context,
                      );
                    }
                    if (state is SearchSuggestions) {
                      return _buildSuggestions(
                        state.suggestions,
                        state.query,
                        textColor,
                        subTextColor,
                        context,
                      );
                    }
                    if (state is SearchLoading) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                        ),
                      );
                    }
                    if (state is SearchEmpty) {
                      return _buildEmptyResults(state.query, isDark);
                    }
                    if (state is SearchError) {
                      return Center(
                        child: Text(
                          state.message,
                          style: TextStyle(color: subTextColor),
                        ),
                      );
                    }
                    if (state is SearchLoaded) {
                      return _buildResults(
                        state.results,
                        cardColor,
                        textColor,
                        subTextColor,
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentSearches(
    List<String> history,
    Color cardColor,
    Color textColor,
    Color subTextColor,
    BuildContext context,
  ) {
    if (history.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search, size: 64, color: subTextColor.withAlpha(80)),
            const SizedBox(height: 12),
            Text(
              'Tìm kiếm khóa học, giáo viên, quiz...',
              style: TextStyle(color: subTextColor, fontSize: 15),
            ),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            Icon(Icons.history, size: 18, color: subTextColor),
            const SizedBox(width: 8),
            Text(
              'Tìm kiếm gần đây',
              style: TextStyle(
                color: subTextColor,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            GestureDetector(
              onTap: () =>
                  context.read<SearchBloc>().add(const ClearSearchHistory()),
              child: Text(
                'Xóa tất cả',
                style: TextStyle(
                  color: AppColors.error,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...history.map(
          (q) => ListTile(
            leading: Icon(Icons.north_west, size: 16, color: subTextColor),
            title: Text(q, style: TextStyle(color: textColor)),
            trailing: GestureDetector(
              onTap: () => context.read<SearchBloc>().add(RemoveHistoryItem(q)),
              child: Icon(Icons.close, size: 16, color: subTextColor),
            ),
            dense: true,
            contentPadding: EdgeInsets.zero,
            onTap: () {
              _controller.text = q;
              context.read<SearchBloc>().add(SearchQueryChanged(q));
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSuggestions(
    List<String> suggestions,
    String query,
    Color textColor,
    Color subTextColor,
    BuildContext context,
  ) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            Icon(Icons.auto_awesome, size: 16, color: AppColors.primary),
            const SizedBox(width: 8),
            Text(
              'Gợi ý',
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...suggestions.map((s) {
          final lowerS = s.toLowerCase();
          final lowerQ = query.toLowerCase();
          final matchIndex = lowerS.indexOf(lowerQ);

          return ListTile(
            leading: Icon(Icons.north_west, size: 16, color: subTextColor),
            title: matchIndex >= 0
                ? RichText(
                    text: TextSpan(
                      style: TextStyle(color: textColor, fontSize: 15),
                      children: [
                        TextSpan(text: s.substring(0, matchIndex)),
                        TextSpan(
                          text: s.substring(
                            matchIndex,
                            matchIndex + query.length,
                          ),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                        TextSpan(text: s.substring(matchIndex + query.length)),
                      ],
                    ),
                  )
                : Text(s, style: TextStyle(color: textColor)),
            dense: true,
            contentPadding: EdgeInsets.zero,
            onTap: () {
              _controller.text = s;
              _controller.selection = TextSelection.collapsed(offset: s.length);
              context.read<SearchBloc>().add(SearchQueryChanged(s));
            },
          );
        }),
      ],
    );
  }

  Widget _buildEmptyResults(String query, bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: isDark ? Colors.grey[600] : Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Không tìm thấy kết quả cho "$query"',
            style: TextStyle(
              color: isDark ? Colors.grey[400] : Colors.grey[600],
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Thử tìm với từ khóa khác',
            style: TextStyle(
              color: isDark ? Colors.grey[600] : Colors.grey[400],
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResults(
    List<SearchResult> results,
    Color cardColor,
    Color textColor,
    Color subTextColor,
  ) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: results.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final result = results[index];
        return _ResultCard(
          result: result,
          cardColor: cardColor,
          textColor: textColor,
          subTextColor: subTextColor,
        );
      },
    );
  }
}

class _SearchField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final Color textColor;
  final Color subTextColor;
  final Color cardColor;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  const _SearchField({
    required this.controller,
    required this.focusNode,
    required this.textColor,
    required this.subTextColor,
    required this.cardColor,
    required this.onChanged,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 16),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        onChanged: onChanged,
        style: TextStyle(color: textColor, fontSize: 16),
        decoration: InputDecoration(
          hintText: 'Tìm khóa học, giáo viên, quiz...',
          hintStyle: TextStyle(color: subTextColor, fontSize: 15),
          prefixIcon: Icon(Icons.search, color: subTextColor),
          suffixIcon: ValueListenableBuilder<TextEditingValue>(
            valueListenable: controller,
            builder: (_, value, __) {
              if (value.text.isEmpty) return const SizedBox.shrink();
              return IconButton(
                icon: Icon(Icons.close, color: subTextColor, size: 20),
                onPressed: onClear,
              );
            },
          ),
          filled: true,
          fillColor: cardColor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 10),
        ),
      ),
    );
  }
}

class _FilterChips extends StatelessWidget {
  final Color cardColor;
  final Color subTextColor;

  const _FilterChips({required this.cardColor, required this.subTextColor});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SearchBloc, SearchState>(
      buildWhen: (prev, curr) =>
          curr is SearchLoaded || curr is SearchInitial || curr is SearchEmpty,
      builder: (context, state) {
        final activeFilter = state is SearchLoaded ? state.activeFilter : null;

        final filters = <(SearchResultType?, String)>[
          (null, 'Tất cả'),
          (SearchResultType.course, 'ðŸ“š Khóa học'),
          (SearchResultType.teacher, 'ðŸ‘¤ Giáo viên'),
          (SearchResultType.lesson, 'ðŸ“– Bài học'),
          (SearchResultType.quiz, 'ðŸ§© Quiz'),
          (SearchResultType.discussion, 'ðŸ’¬ Thảo luận'),
        ];

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
          child: Row(
            children: filters.map((f) {
              final isSelected = activeFilter == f.$1;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(f.$2),
                  selected: isSelected,
                  onSelected: (_) {
                    context.read<SearchBloc>().add(SearchFilterChanged(f.$1));
                  },
                  selectedColor: AppColors.primary.withAlpha(40),
                  checkmarkColor: AppColors.primary,
                  labelStyle: TextStyle(
                    color: isSelected ? AppColors.primary : subTextColor,
                    fontWeight: isSelected
                        ? FontWeight.w600
                        : FontWeight.normal,
                    fontSize: 13,
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
      },
    );
  }
}

class _ResultCard extends StatelessWidget {
  final SearchResult result;
  final Color cardColor;
  final Color textColor;
  final Color subTextColor;

  const _ResultCard({
    required this.result,
    required this.cardColor,
    required this.textColor,
    required this.subTextColor,
  });

  Color get _typeColor => switch (result.type) {
    SearchResultType.course => AppColors.primary,
    SearchResultType.teacher => AppColors.accent,
    SearchResultType.lesson => AppColors.error,
    SearchResultType.quiz => AppColors.info,
    SearchResultType.discussion => AppColors.secondary,
  };

  IconData get _typeIcon => switch (result.type) {
    SearchResultType.course => Icons.school_rounded,
    SearchResultType.teacher => Icons.person_rounded,
    SearchResultType.lesson => Icons.menu_book_rounded,
    SearchResultType.quiz => Icons.quiz_rounded,
    SearchResultType.discussion => Icons.forum_rounded,
  };

  @override
  Widget build(BuildContext context) {
    return Material(
      color: cardColor,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('→ ${result.title}'),
              duration: const Duration(seconds: 1),
            ),
          );
        },
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: _typeColor.withAlpha(25),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(_typeIcon, color: _typeColor, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      result.title,
                      style: TextStyle(
                        color: textColor,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      result.subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: subTextColor, fontSize: 13),
                    ),
                  ],
                ),
              ),
              if (result.rating != null) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withAlpha(25),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.star_rounded,
                        color: AppColors.warning,
                        size: 14,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        result.rating!.toStringAsFixed(1),
                        style: const TextStyle(
                          color: AppColors.warning,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ] else
                Icon(Icons.chevron_right, color: subTextColor, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
