import 'package:flutter/material.dart';

class FilterChipGroup<T> extends StatelessWidget {
  final List<FilterOption<T>> options;
  final T selectedValue;
  final ValueChanged<T> onSelected;
  final Color selectedColor;
  final Color unselectedColor;

  const FilterChipGroup({
    super.key,
    required this.options,
    required this.selectedValue,
    required this.onSelected,
    this.selectedColor = const Color(0xFFFF6636),
    this.unselectedColor = const Color(0xFF2E2E48),
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: options.map((option) {
          final isSelected = selectedValue == option.value;
          return Container(
            margin: const EdgeInsets.only(right: 12),
            child: FilterChip(
              label: Text(
                option.label,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.grey[400],
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  fontSize: 13,
                ),
              ),
              selected: isSelected,
              onSelected: (_) => onSelected(option.value),
              backgroundColor: Colors.white.withOpacity(0.05),
              selectedColor: selectedColor,
              checkmarkColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isSelected ? Colors.transparent : Colors.white10,
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class FilterOption<T> {
  final String label;
  final T value;

  const FilterOption({required this.label, required this.value});
}
