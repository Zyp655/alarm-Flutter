import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class ModuleTimelineNode extends StatelessWidget {
  final int index;
  final bool isFirst;
  final bool isLast;
  final Widget child;

  const ModuleTimelineNode({
    super.key,
    required this.index,
    required this.isFirst,
    required this.isLast,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          width: 40,
          child: Column(
            children: [
              Expanded(
                flex: 1,
                child: isFirst
                    ? const SizedBox()
                    : VerticalDivider(
                        color: Colors.grey[300],
                        thickness: 2,
                        width: 2,
                      ),
              ),
              _TimelineNodeCircle(index: index),
              Expanded(
                flex: 6,
                child: isLast
                    ? const SizedBox()
                    : VerticalDivider(
                        color: Colors.grey[300],
                        thickness: 2,
                        width: 2,
                      ),
              ),
            ],
          ),
        ),
        AppSpacing.gapH12,
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 24),
            child: child,
          ),
        ),
      ],
    );
  }
}

class _TimelineNodeCircle extends StatelessWidget {
  final int index;

  const _TimelineNodeCircle({required this.index});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: AppColors.primary,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 4),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
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
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}
