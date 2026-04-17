import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class CategoryChip extends StatelessWidget {
  const CategoryChip({
    super.key,
    required this.label,
    this.isSelected = false,
  });

  final String label;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(label),
      avatar: isSelected
          ? const Icon(
              Icons.check_circle,
              size: 18,
              color: Colors.white,
            )
          : null,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : AppColors.textPrimary,
      ),
      backgroundColor: isSelected ? AppColors.primary : AppColors.surface,
      side: BorderSide.none,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    );
  }
}
