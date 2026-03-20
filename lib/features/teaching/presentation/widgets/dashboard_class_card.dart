import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/animations.dart';

class DashboardClassCard extends StatelessWidget {
  final Map<String, dynamic> cls;
  final VoidCallback onTap;

  const DashboardClassCard({
    super.key,
    required this.cls,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark(context);
    final cardColor = isDark ? AppColors.darkSurface : Colors.white;
    final textColor = AppColors.textPrimary(context);
    final subColor = AppColors.textSecondary(context);

    final courseName = cls['courseName'] ?? '';
    final courseCode = cls['courseCode'] ?? '';
    final studentCount = cls['studentCount'] ?? 0;
    final classCode = cls['classCode'] ?? '';

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: ScaleOnTap(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border(context)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.08 : 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.school_rounded,
                  color: AppColors.primary,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$courseName – $courseCode',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.people_outline, size: 14, color: subColor),
                        const SizedBox(width: 4),
                        Text(
                          '$studentCount',
                          style: TextStyle(fontSize: 12, color: subColor),
                        ),
                        const SizedBox(width: 16),
                        Icon(Icons.class_rounded, size: 14, color: subColor),
                        const SizedBox(width: 4),
                        Text(
                          classCode,
                          style: TextStyle(fontSize: 12, color: subColor),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: subColor, size: 22),
            ],
          ),
        ),
      ),
    );
  }
}
