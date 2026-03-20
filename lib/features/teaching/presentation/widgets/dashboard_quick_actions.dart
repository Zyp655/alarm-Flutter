import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class DashboardQuickActions extends StatelessWidget {
  final Animation<double> fadeAnim;
  final List<DashboardAction> actions;

  const DashboardQuickActions({
    super.key,
    required this.fadeAnim,
    required this.actions,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark(context);
    final cardColor = isDark ? AppColors.darkSurface : Colors.white;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: FadeTransition(
        opacity: fadeAnim,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hành động nhanh',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary(context),
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: actions.map((action) {
                final isLast = action == actions.last;
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(right: isLast ? 0 : 12),
                    child: _ActionItem(
                      icon: action.icon,
                      label: action.label,
                      isDark: isDark,
                      cardColor: cardColor,
                      onTap: action.onTap,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class DashboardAction {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const DashboardAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });
}

class _ActionItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isDark;
  final Color cardColor;
  final VoidCallback onTap;

  const _ActionItem({
    required this.icon,
    required this.label,
    required this.isDark,
    required this.cardColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border(context)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.08 : 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, size: 24, color: AppColors.primary),
            ),
            const SizedBox(height: 10),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
