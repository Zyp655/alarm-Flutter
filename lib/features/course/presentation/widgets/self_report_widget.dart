import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class SelfReportWidget extends StatelessWidget {
  final VoidCallback onDismiss;
  final void Function(int level) onReport;

  const SelfReportWidget({
    super.key,
    required this.onDismiss,
    required this.onReport,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E2E),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.accent.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Bạn cảm thấy thế nào về đoạn vừa xem?',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _ReportButton(
                emoji: '😊',
                label: 'Hiểu rõ',
                color: AppColors.success,
                onTap: () => onReport(0),
              ),
              _ReportButton(
                emoji: '🤔',
                label: 'Hơi khó',
                color: AppColors.warning,
                onTap: () => onReport(1),
              ),
              _ReportButton(
                emoji: '😫',
                label: 'Không hiểu',
                color: AppColors.error,
                onTap: () => onReport(2),
              ),
              _ReportButton(
                emoji: '⏭️',
                label: 'Bỏ qua',
                color: Colors.grey,
                onTap: onDismiss,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ReportButton extends StatelessWidget {
  final String emoji;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ReportButton({
    required this.emoji,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: color.withOpacity(0.3)),
            ),
            child: Center(
              child: Text(
                emoji,
                style: const TextStyle(fontSize: 28),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
