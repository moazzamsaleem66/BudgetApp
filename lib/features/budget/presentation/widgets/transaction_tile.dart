import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class TransactionTile extends StatelessWidget {
  const TransactionTile({
    super.key,
    required this.title,
    required this.category,
    required this.date,
    required this.amount,
    this.isExpense = true,
  });

  final String title;
  final String category;
  final String date;
  final double amount;
  final bool isExpense;

  @override
  Widget build(BuildContext context) {
    final initial = category.isNotEmpty ? category[0] : '?';
    final amountColor = isExpense ? AppColors.danger : AppColors.success;
    final amountPrefix = isExpense ? '- ' : '+ ';

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.border),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.tint,
          child: Text(
            initial,
            style: const TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Text('$category • $date'),
        trailing: Text(
          '$amountPrefix${_formatKd(amount)}',
          style: TextStyle(fontWeight: FontWeight.w700, color: amountColor),
        ),
      ),
    );
  }
}

String _formatKd(double value) => 'KD ${value.toStringAsFixed(3)}';
