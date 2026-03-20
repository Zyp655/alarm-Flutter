import 'package:flutter/material.dart';
import '../../../../../../core/theme/app_colors.dart';

class StudentProgressCard extends StatelessWidget {
  final Map<String, dynamic> student;
  final bool isSelected;
  final bool isSelectionMode;
  final VoidCallback onTap;
  final ValueChanged<bool?>? onSelectChanged;
  final VoidCallback onNudge;

  const StudentProgressCard({
    super.key,
    required this.student,
    this.isSelected = false,
    this.isSelectionMode = false,
    required this.onTap,
    this.onSelectChanged,
    required this.onNudge,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark(context);
    final isAtRisk = student['isAtRisk'] == true;
    final progressPercent = student['progressPercent'] ?? 0;
    final lastNudgedAt = student['lastNudgedAt'] as String?;
    final quizAverage = student['quizAverage'];
    final studentEmail = student['email'] as String? ?? '';
    final riskScore = (student['riskScore'] as num?)?.toDouble() ?? 0;
    final warningLevel = student['warningLevel'] as int? ?? 1;
    final absenceRate = (student['absenceRate'] as num?)?.toDouble() ?? 0;
    final lateRate = (student['lateRate'] as num?)?.toDouble() ?? 0;

    final avatarColor =
        Colors.primaries[studentEmail.hashCode % Colors.primaries.length];

    Color wlColor;
    String wlText;
    if (warningLevel >= 3) {
      wlColor = AppColors.error;
      wlText = 'Mức 3';
    } else if (warningLevel == 2) {
      wlColor = AppColors.warning;
      wlText = 'Mức 2';
    } else {
      wlColor = AppColors.success;
      wlText = 'Mức 1';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.cardColor(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? AppColors.accent : AppColors.border(context),
          width: isSelected ? 2 : 1,
        ),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withAlpha(8),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: isSelectionMode
              ? () => onSelectChanged?.call(!isSelected)
              : onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                if (isSelectionMode)
                  Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: Checkbox(
                      value: isSelected,
                      onChanged: onSelectChanged,
                      activeColor: AppColors.accent,
                      side: BorderSide(color: AppColors.textSecondary(context)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                Stack(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: avatarColor.withAlpha(isDark ? 50 : 30),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: avatarColor.withAlpha(isDark ? 80 : 60),
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        studentEmail.isNotEmpty
                            ? studentEmail[0].toUpperCase()
                            : 'U',
                        style: TextStyle(
                          color: avatarColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    ),
                    if (riskScore >= 40)
                      Positioned(
                        right: -2,
                        top: -2,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: wlColor,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: AppColors.cardColor(context),
                              width: 1.5,
                            ),
                          ),
                          child: Text(
                            '${riskScore.round()}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              student['fullName'] ?? student['email'] ?? '',
                              style: TextStyle(
                                color: AppColors.textPrimary(context),
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: wlColor.withAlpha(isDark ? 25 : 15),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: wlColor.withAlpha(isDark ? 50 : 30),
                              ),
                            ),
                            child: Text(
                              wlText,
                              style: TextStyle(
                                color: wlColor,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: LinearProgressIndicator(
                                value: progressPercent / 100,
                                backgroundColor: isDark
                                    ? Colors.white.withAlpha(15)
                                    : Colors.grey.shade200,
                                valueColor: AlwaysStoppedAnimation(
                                  warningLevel >= 3
                                      ? AppColors.error
                                      : warningLevel == 2
                                          ? AppColors.warning
                                          : AppColors.accent,
                                ),
                                minHeight: 5,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            '$progressPercent%',
                            style: TextStyle(
                              color: warningLevel >= 3
                                  ? AppColors.error
                                  : AppColors.accent,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          _MiniStat(
                            icon: Icons.quiz_outlined,
                            label: quizAverage != null
                                ? '${(quizAverage as num).toStringAsFixed(0)}%'
                                : '--',
                            color: quizAverage != null && quizAverage < 50
                                ? AppColors.error
                                : AppColors.textSecondary(context),
                          ),
                          const SizedBox(width: 12),
                          _MiniStat(
                            icon: Icons.event_busy_outlined,
                            label: '${absenceRate.toStringAsFixed(0)}%',
                            color: absenceRate > 10
                                ? AppColors.error
                                : AppColors.textSecondary(context),
                          ),
                          const SizedBox(width: 12),
                          _MiniStat(
                            icon: Icons.assignment_late_outlined,
                            label: '${lateRate.toStringAsFixed(0)}%',
                            color: lateRate > 20
                                ? AppColors.warning
                                : AppColors.textSecondary(context),
                          ),
                          const Spacer(),
                          if (isAtRisk) ...[
                            if (lastNudgedAt != null)
                              Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: Text(
                                  'Đã nhắc',
                                  style: TextStyle(
                                    color: AppColors.textSecondary(context),
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                            InkWell(
                              onTap: onNudge,
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(
                                    0xFF6C63FF,
                                  ).withAlpha(isDark ? 30 : 18),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: const Color(
                                      0xFF6C63FF,
                                    ).withAlpha(isDark ? 60 : 40),
                                  ),
                                ),
                                child: const Row(
                                  children: [
                                    Icon(
                                      Icons.auto_awesome,
                                      color: AppColors.secondary,
                                      size: 14,
                                    ),
                                    SizedBox(width: 6),
                                    Text(
                                      'Nhắc nhở',
                                      style: TextStyle(
                                        color: AppColors.secondary,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _MiniStat({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
