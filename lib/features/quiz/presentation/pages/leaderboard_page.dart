import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../injection_container.dart' as di;
import '../bloc/leaderboard/leaderboard_bloc.dart';
import '../bloc/leaderboard/leaderboard_event.dart';
import '../bloc/leaderboard/leaderboard_state.dart';
import '../../domain/entities/leaderboard_entry.dart';
import '../../../../core/theme/app_colors.dart';

class LeaderboardPage extends StatelessWidget {
  final int classId;

  const LeaderboardPage({super.key, required this.classId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          di.sl<LeaderboardBloc>()..add(LoadLeaderboard(classId: classId)),
      child: LeaderboardView(classId: classId),
    );
  }
}

class LeaderboardView extends StatefulWidget {
  final int classId;
  const LeaderboardView({super.key, required this.classId});

  @override
  State<LeaderboardView> createState() => _LeaderboardViewState();
}

class _LeaderboardViewState extends State<LeaderboardView> {
  String _selectedPeriod = 'all_time';

  void _onPeriodChanged(String period) {
    if (_selectedPeriod != period) {
      setState(() {
        _selectedPeriod = period;
      });
      context.read<LeaderboardBloc>().add(
        LoadLeaderboard(classId: widget.classId, period: period),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bảng xếp hạng'),
        centerTitle: true,
        elevation: 0,
      ),
      body: BlocConsumer<LeaderboardBloc, LeaderboardState>(
        listener: (context, state) {
          if (state is LeaderboardError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        builder: (context, state) {
          final isDarkMode = Theme.of(context).brightness == Brightness.dark;
          final cardColor = isDarkMode ? AppColors.darkSurface : Colors.white;
          final textColor = isDarkMode ? Colors.white : Colors.black87;

          List<LeaderboardEntry> entries = [];
          if (state is LeaderboardLoaded) {
            entries = state.entries;
          }

          return Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                color: cardColor,
                child: Row(
                  children: [
                    _buildPeriodChip('Tuần', 'weekly', context),
                    const SizedBox(width: 8),
                    _buildPeriodChip('Tháng', 'monthly', context),
                    const SizedBox(width: 8),
                    _buildPeriodChip('Tất cả', 'all_time', context),
                  ],
                ),
              ),
              if (state is LeaderboardLoading)
                const Expanded(
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (entries.isEmpty)
                const Expanded(
                  child: Center(child: Text("Chưa có dữ liệu xếp hạng")),
                )
              else ...[
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      if (entries.length > 1)
                        _buildTopPlayer(entries[1], 2, Colors.grey, 70),
                      if (entries.isNotEmpty)
                        _buildTopPlayer(entries[0], 1, Colors.amber, 90),
                      if (entries.length > 2)
                        _buildTopPlayer(entries[2], 3, Colors.brown, 70),
                    ],
                  ),
                ),
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                    ),
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: entries.length > 3 ? entries.length - 3 : 0,
                      itemBuilder: (context, index) {
                        final entry = entries[index + 3];
                        return _buildLeaderboardItem(
                          entry,
                          textColor,
                          isDarkMode,
                        );
                      },
                    ),
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _buildPeriodChip(String label, String value, BuildContext context) {
    final isSelected = _selectedPeriod == value;
    return GestureDetector(
      onTap: () => _onPeriodChanged(value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.amber : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? Colors.amber : Colors.grey),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildTopPlayer(
    LeaderboardEntry data,
    int rank,
    Color color,
    double size,
  ) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomCenter,
          children: [
            Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withAlpha(50),
                border: Border.all(color: color, width: 3),
              ),
              child: Center(
                child: Text(
                  data.name.isNotEmpty
                      ? data.name.substring(0, 1).toUpperCase()
                      : '?',
                  style: TextStyle(
                    fontSize: size * 0.4,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              child: Text(
                '$rank',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          data.name,
          style: const TextStyle(fontWeight: FontWeight.w600),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        Text(
          '${data.totalScore.toStringAsFixed(0)} điểm',
          style: TextStyle(color: color, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildLeaderboardItem(
    LeaderboardEntry data,
    Color textColor,
    bool isDarkMode,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[850] : Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.grey.withAlpha(50),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '${data.rank}',
                style: TextStyle(fontWeight: FontWeight.bold, color: textColor),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.name,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
                Text(
                  '${data.quizzesCompleted} quiz hoàn thành',
                  style: TextStyle(
                    fontSize: 12,
                    color: textColor.withAlpha(150),
                  ),
                ),
              ],
            ),
          ),
          Text(
            data.totalScore.toStringAsFixed(0),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.warning.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }
}
