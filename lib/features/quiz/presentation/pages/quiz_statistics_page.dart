import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/quiz_bloc.dart';
import '../bloc/quiz_event.dart';
import '../bloc/quiz_state.dart';
import '../../domain/entities/quiz_statistics_entity.dart';
import '../../../../core/theme/app_colors.dart';

class QuizStatisticsPage extends StatefulWidget {
  final int userId;

  const QuizStatisticsPage({super.key, required this.userId});

  @override
  State<QuizStatisticsPage> createState() => _QuizStatisticsPageState();
}

class _QuizStatisticsPageState extends State<QuizStatisticsPage> {
  @override
  void initState() {
    super.initState();
    context.read<QuizBloc>().add(LoadStatisticsEvent(userId: widget.userId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Thống kê học tập'), centerTitle: true),
      body: BlocBuilder<QuizBloc, QuizState>(
        buildWhen: (prev, curr) =>
            prev.runtimeType != curr.runtimeType || prev != curr,
        builder: (context, state) {
          if (state is QuizLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is QuizError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 48,
                    color: AppColors.error.withValues(alpha: 0.35),
                  ),
                  const SizedBox(height: 16),
                  Text(state.message),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<QuizBloc>().add(
                        LoadStatisticsEvent(userId: widget.userId),
                      );
                    },
                    child: const Text('Thử lại'),
                  ),
                ],
              ),
            );
          }

          if (state is StatisticsLoaded) {
            return RefreshIndicator(
              onRefresh: () async {
                context.read<QuizBloc>().add(
                  LoadStatisticsEvent(userId: widget.userId),
                );
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SummaryCard(summary: state.stats.summary),
                    const SizedBox(height: 24),
                    if (state.stats.summary.weakTopics.isNotEmpty) ...[
                      _TopicsSection(
                        title: '📚 Cần ôn tập',
                        topics: state.stats.summary.weakTopics,
                        color: AppColors.warning,
                      ),
                      const SizedBox(height: 16),
                    ],
                    if (state.stats.summary.strongTopics.isNotEmpty) ...[
                      _TopicsSection(
                        title: '🌟 Điểm mạnh',
                        topics: state.stats.summary.strongTopics,
                        color: AppColors.success,
                      ),
                      const SizedBox(height: 16),
                    ],
                    const Text(
                      'Chi tiết theo chủ đề',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...state.stats.statistics.map(
                      (stat) => _TopicStatCard(stat: stat),
                    ),
                    if (state.stats.statistics.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32),
                          child: Column(
                            children: [
                              Icon(
                                Icons.analytics_outlined,
                                size: 64,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Chưa có dữ liệu thống kê',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Hoàn thành các bài quiz để xem thống kê!',
                                style: TextStyle(color: Colors.grey[500]),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final QuizStatisticsSummaryEntity summary;

  const _SummaryCard({required this.summary});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              'Tổng quan',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _StatItem(
                  icon: Icons.topic,
                  value: summary.totalTopics.toString(),
                  label: 'Chủ đề',
                ),
                _StatItem(
                  icon: Icons.repeat,
                  value: summary.totalAttempts.toString(),
                  label: 'Lần làm',
                ),
                _StatItem(
                  icon: Icons.score,
                  value: '${summary.overallAverageScore.toStringAsFixed(1)}%',
                  label: 'Điểm TB',
                  valueColor: _getScoreColor(summary.overallAverageScore),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getScoreColor(double score) {
    if (score >= 80) return Colors.green;
    if (score >= 60) return Colors.orange;
    return Colors.red;
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color? valueColor;

  const _StatItem({
    required this.icon,
    required this.value,
    required this.label,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 28, color: Theme.of(context).primaryColor),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: valueColor,
          ),
        ),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ],
    );
  }
}

class _TopicsSection extends StatelessWidget {
  final String title;
  final List<String> topics;
  final Color color;

  const _TopicsSection({
    required this.title,
    required this.topics,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: topics
              .map(
                (topic) => Chip(
                  label: Text(topic),
                  backgroundColor: color.withAlpha(26),
                  labelStyle: TextStyle(color: color),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}

class _TopicStatCard extends StatelessWidget {
  final QuizStatisticsEntity stat;

  const _TopicStatCard({required this.stat});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    stat.topic,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                _SkillLevelIndicator(level: stat.skillLevel),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _ProgressBar(
                    value: stat.averageScore / 100,
                    color: _getScoreColor(stat.averageScore),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '${stat.averageScore.toStringAsFixed(1)}%',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: _getScoreColor(stat.averageScore),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  '${stat.totalAttempts} lần làm',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                const SizedBox(width: 16),
                Text(
                  '${stat.totalCorrect}/${stat.totalQuestions} câu đúng',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getScoreColor(double score) {
    if (score >= 80) return Colors.green;
    if (score >= 60) return Colors.orange;
    return Colors.red;
  }
}

class _SkillLevelIndicator extends StatelessWidget {
  final double level;

  const _SkillLevelIndicator({required this.level});

  @override
  Widget build(BuildContext context) {
    String label;
    Color color;

    if (level >= 0.7) {
      label = 'Thành thạo';
      color = AppColors.success;
    } else if (level >= 0.5) {
      label = 'Khá';
      color = AppColors.info;
    } else if (level >= 0.35) {
      label = 'Cơ bản';
      color = AppColors.warning;
    } else {
      label = 'Cần cải thiện';
      color = AppColors.error;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(26),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: color,
        ),
      ),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  final double value;
  final Color color;

  const _ProgressBar({required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 8,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(4),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: value.clamp(0.0, 1.0),
        child: Container(
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }
}
