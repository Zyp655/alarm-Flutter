import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../domain/entities/major_entity.dart';


class MajorFilterWidget extends StatelessWidget {
  final List<MajorEntity> majors;
  final int? selectedMajorId;
  final ValueChanged<int?> onMajorSelected;
  final bool isLoading;

  const MajorFilterWidget({
    super.key,
    required this.majors,
    required this.selectedMajorId,
    required this.onMajorSelected,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return _buildLoadingState();
    }

    if (majors.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              const Icon(
                Icons.school_outlined,
                size: 18,
                color: Color(0xFF6C63FF),
              ),
              const SizedBox(width: 8),
              Text(
                'Chuyên ngành',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              _buildMajorChip(
                label: 'Tất cả',
                courseCount: null,
                isSelected: selectedMajorId == null,
                icon: Icons.apps,
                onTap: () => onMajorSelected(null),
              ),
              ...majors.asMap().entries.map((entry) {
                final index = entry.key;
                final major = entry.value;
                return _buildMajorChip(
                  label: major.name,
                  courseCount: major.courseCount,
                  isSelected: selectedMajorId == major.id,
                  icon: _getMajorIcon(major.code),
                  onTap: () => onMajorSelected(
                    selectedMajorId == major.id ? null : major.id,
                  ),
                ).animate().fadeIn(delay: Duration(milliseconds: 50 * index));
              }),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMajorChip({
    required String label,
    required int? courseCount,
    required bool isSelected,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            gradient: isSelected
                ? const LinearGradient(
                    colors: [Color(0xFF6C63FF), Color(0xFF4834DF)],
                  )
                : null,
            color: isSelected ? null : Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: isSelected
                    ? const Color(0xFF6C63FF).withOpacity(0.3)
                    : Colors.black.withOpacity(0.05),
                blurRadius: isSelected ? 12 : 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 16,
                color: isSelected ? Colors.white : const Color(0xFF6C63FF),
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.grey[700],
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  fontSize: 13,
                ),
              ),
              if (courseCount != null) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Colors.white.withOpacity(0.2)
                        : const Color(0xFF6C63FF).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '$courseCount',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: isSelected
                          ? Colors.white
                          : const Color(0xFF6C63FF),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: List.generate(3, (index) {
          return Container(
            margin: const EdgeInsets.only(right: 10),
            width: 100,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(12),
            ),
          );
        }),
      ),
    );
  }

  IconData _getMajorIcon(String code) {
    switch (code.toUpperCase()) {
      case 'CNTT':
        return Icons.computer;
      case 'KT':
        return Icons.architecture;
      case 'KD':
        return Icons.business;
      case 'Y':
        return Icons.local_hospital;
      case 'NN':
        return Icons.language;
      default:
        return Icons.school;
    }
  }
}
