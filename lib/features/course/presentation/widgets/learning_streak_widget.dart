import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class LearningStreakWidget extends StatelessWidget {
  final int currentStreak;
  final int longestStreak;
  final List<bool> weeklyActivity; 
  final int weeklyGoal;
  final int weeklyCompleted;

  const LearningStreakWidget({
    super.key,
    required this.currentStreak,
    this.longestStreak = 0,
    required this.weeklyActivity,
    this.weeklyGoal = 5,
    this.weeklyCompleted = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _buildFireIcon(),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          '$currentStreak ngày',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E1E1E),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.orange.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Streak!',
                            style: TextStyle(
                              color: Colors.orange[700],
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Kỷ lục: $longestStreak ngày',
                      style: TextStyle(color: Colors.grey[500], fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildWeeklyHeatmap(),
          const SizedBox(height: 16),
          _buildWeeklyGoalProgress(),
        ],
      ),
    ).animate().fadeIn().slideY(begin: 0.1);
  }

  Widget _buildFireIcon() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.9, end: 1.1),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOut,
      builder: (context, value, child) {
        return AnimatedBuilder(
          animation: AlwaysStoppedAnimation(value),
          builder: (context, child) {
            return Transform.scale(
              scale: currentStreak > 0 ? value : 1.0,
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  gradient: currentStreak > 0
                      ? const LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.orange, Colors.deepOrange],
                        )
                      : null,
                  color: currentStreak > 0 ? null : Colors.grey[200],
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.local_fire_department,
                  color: currentStreak > 0 ? Colors.white : Colors.grey[400],
                  size: 28,
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildWeeklyHeatmap() {
    final days = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(7, (index) {
        final isActive = index < weeklyActivity.length && weeklyActivity[index];
        final isToday = index == DateTime.now().weekday - 1;

        return Column(
          children: [
            Text(
              days[index],
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 6),
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                gradient: isActive
                    ? const LinearGradient(
                        colors: [Color(0xFF6C63FF), Color(0xFF4834DF)],
                      )
                    : null,
                color: isActive ? null : Colors.grey[100],
                shape: BoxShape.circle,
                border: isToday && !isActive
                    ? Border.all(color: const Color(0xFF6C63FF), width: 2)
                    : null,
              ),
              child: Center(
                child: Icon(
                  isActive ? Icons.check : Icons.circle,
                  color: isActive ? Colors.white : Colors.grey[300],
                  size: isActive ? 18 : 8,
                ),
              ),
            ),
          ],
        ).animate(delay: Duration(milliseconds: 50 * index)).fadeIn().scale();
      }),
    );
  }

  Widget _buildWeeklyGoalProgress() {
    final progress = weeklyGoal > 0 ? weeklyCompleted / weeklyGoal : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Mục tiêu tuần này',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '$weeklyCompleted/$weeklyGoal ngày',
              style: TextStyle(
                color: progress >= 1.0 ? Colors.green : const Color(0xFF6C63FF),
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: progress.clamp(0.0, 1.0)),
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) {
              return LinearProgressIndicator(
                value: value,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(
                  progress >= 1.0 ? Colors.green : const Color(0xFF6C63FF),
                ),
                minHeight: 6,
              );
            },
          ),
        ),
        if (progress >= 1.0) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.emoji_events, color: Colors.amber, size: 16),
              const SizedBox(width: 4),
              Text(
                'Hoàn thành mục tiêu tuần! 🎉',
                style: TextStyle(
                  color: Colors.amber[700],
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ).animate().fadeIn().shake(),
        ],
      ],
    );
  }
}

class AnimatedBuilder extends StatelessWidget {
  final Animation<double> animation;
  final Widget Function(BuildContext context, Widget? child) builder;
  final Widget? child;

  const AnimatedBuilder({
    super.key,
    required this.animation,
    required this.builder,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: builder,
      child: child,
    );
  }
}
