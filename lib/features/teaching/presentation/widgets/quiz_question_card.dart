import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class QuizQuestionCard extends StatelessWidget {
  final Map<String, dynamic> question;
  final int index;
  final VoidCallback onToggleEdit;
  final VoidCallback onDelete;
  final ValueChanged<Map<String, dynamic>> onChanged;

  const QuizQuestionCard({
    super.key,
    required this.question,
    required this.index,
    required this.onToggleEdit,
    required this.onDelete,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isEditing = question['_editing'] == true;
    final correctIdx = question['correctIndex'] as int? ?? 0;
    final options = (question['options'] as List).cast<String>();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(isDark ? 20 : 10),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(cs, isEditing),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isEditing)
                  TextFormField(
                    initialValue: question['question'] as String? ?? '',
                    style: TextStyle(color: cs.onSurface, fontSize: 14),
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: 'Câu hỏi',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onChanged: (v) {
                      question['question'] = v;
                      onChanged(question);
                    },
                  )
                else
                  Text(
                    question['question'] as String? ?? '',
                    style: TextStyle(
                      color: cs.onSurface,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                const SizedBox(height: 12),
                ...List.generate(options.length, (oi) {
                  final isCorrect = oi == correctIdx;
                  if (isEditing) {
                    return _buildEditOption(cs, options, oi, isCorrect, correctIdx);
                  }
                  return _buildViewOption(cs, options[oi], isCorrect);
                }),
                if ((question['explanation'] as String?)?.isNotEmpty == true) ...[
                  const SizedBox(height: 8),
                  if (isEditing)
                    TextFormField(
                      initialValue: question['explanation'] as String? ?? '',
                      style: TextStyle(color: cs.onSurface, fontSize: 13),
                      maxLines: 2,
                      decoration: InputDecoration(
                        labelText: 'Giải thích',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onChanged: (v) {
                        question['explanation'] = v;
                        onChanged(question);
                      },
                    )
                  else
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.info.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.lightbulb_outline, color: AppColors.info, size: 16),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              question['explanation'] as String,
                              style: TextStyle(
                                color: cs.onSurfaceVariant,
                                fontSize: 12,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(ColorScheme cs, bool isEditing) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.06),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                '${index + 1}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Câu ${index + 1}',
              style: TextStyle(color: cs.onSurface, fontWeight: FontWeight.w600),
            ),
          ),
          IconButton(
            icon: Icon(
              isEditing ? Icons.check_circle : Icons.edit,
              color: isEditing ? AppColors.success : cs.onSurfaceVariant,
              size: 20,
            ),
            onPressed: onToggleEdit,
            tooltip: isEditing ? 'Xong' : 'Sửa',
            constraints: const BoxConstraints(),
            padding: const EdgeInsets.all(4),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: AppColors.error, size: 20),
            onPressed: onDelete,
            tooltip: 'Xóa',
            constraints: const BoxConstraints(),
            padding: const EdgeInsets.all(4),
          ),
        ],
      ),
    );
  }

  Widget _buildEditOption(ColorScheme cs, List<String> options, int oi, bool isCorrect, int correctIdx) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Radio<int>(
            value: oi,
            groupValue: correctIdx,
            onChanged: (v) {
              question['correctIndex'] = v;
              onChanged(question);
            },
            activeColor: AppColors.success,
          ),
          Expanded(
            child: TextFormField(
              initialValue: options[oi],
              style: TextStyle(color: cs.onSurface, fontSize: 13),
              decoration: InputDecoration(
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onChanged: (v) {
                options[oi] = v;
                question['options'] = options;
                onChanged(question);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildViewOption(ColorScheme cs, String text, bool isCorrect) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isCorrect ? AppColors.success.withValues(alpha: 0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isCorrect
              ? AppColors.success.withValues(alpha: 0.4)
              : cs.outlineVariant.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          if (isCorrect)
            const Icon(Icons.check_circle, color: AppColors.success, size: 16)
          else
            Icon(Icons.circle_outlined, color: cs.onSurfaceVariant, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: isCorrect ? AppColors.success : cs.onSurface,
                fontWeight: isCorrect ? FontWeight.w600 : FontWeight.normal,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
