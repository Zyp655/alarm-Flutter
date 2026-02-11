import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class AIQuizSectionWidget extends StatelessWidget {
  final VoidCallback? onPreview;
  final VoidCallback? onGenerate;

  const AIQuizSectionWidget({super.key, this.onPreview, this.onGenerate});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: AppSpacing.paddingLg,
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: AppSpacing.borderRadiusLg,
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.auto_awesome,
                color: Color(0xFFFF6B6B),
                size: 20,
              ),
              AppSpacing.gapH8,
              const Text(
                'AI Quiz Generator',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D3436),
                ),
              ),
              const Spacer(),
              _BetaBadge(),
            ],
          ),
          AppSpacing.gapV12,
          const Text(
            'Tự động tạo câu hỏi trắc nghiệm dựa trên nội dung chương này.',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
          AppSpacing.gapV16,
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onPreview,
                  icon: const Icon(Icons.visibility_outlined, size: 16),
                  label: const Text('Xem trước'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF2D3436),
                    side: BorderSide(color: Colors.grey[300]!),
                  ),
                ),
              ),
              AppSpacing.gapH12,
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: onGenerate,
                  icon: const Icon(Icons.auto_awesome, size: 16),
                  label: const Text('Tạo Quiz'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2D3436),
                    foregroundColor: Colors.white,
                    elevation: 0,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BetaBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFFF6B6B).withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Text(
        'BETA',
        style: TextStyle(
          color: Color(0xFFFF6B6B),
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
