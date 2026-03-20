import 'package:flutter/material.dart';
import '../../../../features/course/domain/entities/module_entity.dart';
import 'module_card.dart';

class ModuleTimelineItem extends StatelessWidget {
  final ModuleEntity module;
  final int index;
  final int totalCount;
  final int courseId;

  const ModuleTimelineItem({
    super.key,
    required this.module,
    required this.index,
    required this.totalCount,
    required this.courseId,
  });

  static const timelineColors = [
    [Color(0xFF14B8A6), Color(0xFF0D9488)],
    [Color(0xFF3498DB), Color(0xFF2980B9)],
    [Color(0xFF9B59B6), Color(0xFF8E44AD)],
    [Color(0xFFE67E22), Color(0xFFD35400)],
    [Color(0xFFE74C3C), Color(0xFFC0392B)],
    [Color(0xFF2ECC71), Color(0xFF27AE60)],
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isLast = index == totalCount - 1;
    final isFirst = index == 0;
    final gradient = timelineColors[index % timelineColors.length];

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 40,
          child: Column(
            children: [
              Container(
                width: 2,
                height: 14,
                color: isFirst
                    ? Colors.transparent
                    : (isDark ? Colors.grey[700] : Colors.grey[300]),
              ),
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: gradient,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: gradient[0].withAlpha(isDark ? 40 : 60),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
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
            ],
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              if (!isLast)
                Positioned(
                  left: -46,
                  top: 46,
                  bottom: 0,
                  child: Container(
                    width: 2,
                    color: isDark ? Colors.grey[700] : Colors.grey[300],
                  ),
                ),
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: ModuleCard(
                  module: module,
                  accentColor: gradient[0],
                  courseId: courseId,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
