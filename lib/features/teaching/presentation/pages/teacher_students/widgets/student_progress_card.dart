import 'package:flutter/material.dart';

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
    final isAtRisk = student['isAtRisk'] == true;
    final progressPercent = student['progressPercent'] ?? 0;
    final lastNudgedAt = student['lastNudgedAt'] as String?;
    final quizAverage = student['quizAverage'];

    final studentEmail = student['email'] as String? ?? '';

    final avatarColor =
        Colors.primaries[studentEmail.hashCode % Colors.primaries.length];

    Color statusColor = const Color(0xFF00C853);
    String statusText = 'Tốt';
    if (isAtRisk) {
      statusColor = const Color(0xFFFF5252);
      statusText = 'Cần chú ý';
    } else if (progressPercent < 50) {
      statusColor = const Color(0xFFFFAB40);
      statusText = 'Trung bình';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12, left: 16, right: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected
              ? const Color(0xFFFF6636)
              : Colors.white.withOpacity(0.1),
          width: isSelected ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: isSelectionMode
            ? () => onSelectChanged?.call(!isSelected)
            : onTap,
        borderRadius: BorderRadius.circular(16),
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
                    activeColor: const Color(0xFFFF6636),
                    side: BorderSide(color: Colors.grey[600]!),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: avatarColor.withOpacity(0.2),
                  shape: BoxShape.circle,
                  border: Border.all(color: avatarColor.withOpacity(0.5)),
                ),
                alignment: Alignment.center,
                child: Text(
                  studentEmail.isNotEmpty ? studentEmail[0].toUpperCase() : 'U',
                  style: TextStyle(
                    color: avatarColor.withOpacity(0.9),
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
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
                            student['email'] ?? '',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: statusColor.withOpacity(0.2),
                            ),
                          ),
                          child: Text(
                            statusText,
                            style: TextStyle(
                              color: statusColor,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    Row(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: LinearProgressIndicator(
                              value: progressPercent / 100,
                              backgroundColor: Colors.white.withOpacity(0.1),
                              valueColor: AlwaysStoppedAnimation(
                                isAtRisk
                                    ? const Color(0xFFFF5252)
                                    : const Color(0xFFFF6636),
                              ),
                              minHeight: 4,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          '$progressPercent%',
                          style: TextStyle(
                            color: isAtRisk
                                ? const Color(0xFFFF5252)
                                : const Color(0xFFFF6636),
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    Row(
                      children: [
                        Icon(
                          Icons.book_outlined,
                          size: 16,
                          color: Colors.grey[500],
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${student['completedLessons'] ?? 0}/${student['totalLessons'] ?? 0}',
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Icon(
                          Icons.quiz_outlined,
                          size: 16,
                          color: Colors.grey[500],
                        ),
                        const SizedBox(width: 6),
                        Text(
                          quizAverage != null
                              ? '${(quizAverage as num).toStringAsFixed(1)}%'
                              : '--',
                          style: TextStyle(
                            color: quizAverage != null
                                ? const Color(0xFFFFAB40)
                                : Colors.grey[400],
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const Spacer(),

                        if (isAtRisk) ...[
                          if (lastNudgedAt != null)
                            Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: Text(
                                'Đã nhắc',
                                style: TextStyle(
                                  color: Colors.grey[500],
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
                                ).withOpacity(0.15),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: const Color(
                                    0xFF6C63FF,
                                  ).withOpacity(0.3),
                                ),
                              ),
                              child: Row(
                                children: const [
                                  Icon(
                                    Icons.auto_awesome,
                                    color: Color(0xFF8C86FF),
                                    size: 14,
                                  ),
                                  SizedBox(width: 6),
                                  Text(
                                    'Nhắc nhở',
                                    style: TextStyle(
                                      color: Color(0xFF8C86FF),
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
    );
  }
}
