import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../state/budget_state_scope.dart';

class AddIncomeScreen extends StatefulWidget {
  const AddIncomeScreen({super.key});

  @override
  State<AddIncomeScreen> createState() => _AddIncomeScreenState();
}

class _AddIncomeScreenState extends State<AddIncomeScreen> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  String _incomeSource = 'Salary';
  String _depositMethod = 'Bank Transfer';
  bool _isRecurringIncome = false;

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    FocusScope.of(context).unfocus();
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(now.year - 3),
      lastDate: DateTime(now.year + 3),
    );
    if (picked == null || !mounted) return;
    _dateController.text = '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
  }

  void _saveIncome() {
    final amountText = _amountController.text.trim();
    final amount = double.tryParse(amountText);

    if (amountText.isEmpty || amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid income amount.')),
      );
      return;
    }

    if (_dateController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a date.')),
      );
      return;
    }

    final incomePayload = <String, dynamic>{
      'amount': amount,
      'category': _incomeSource,
      'note': _noteController.text.trim(),
      'date': _dateController.text.trim(),
      'paymentMethod': _depositMethod,
      'isRecurring': _isRecurringIncome,
    };

    final state = BudgetStateScope.maybeOf(context);
    if (state != null) {
      final isAdded = state.addIncomeFromPayload(incomePayload);
      if (!isAdded) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unable to save income. Please check details.')),
        );
        return;
      }
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Income saved successfully.'),
        backgroundColor: Color(0xFF0FA581),
      ),
    );

    Navigator.of(context).pop(state != null ? true : incomePayload);
  }

  @override
  Widget build(BuildContext context) {
    final currencyCode = BudgetStateScope.maybeOf(context)?.currencyCode ?? 'KD';
    return Scaffold(
      appBar: AppBar(title: const Text('Add Income')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(labelText: 'Amount', prefixText: '$currencyCode '),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _incomeSource,
              decoration: const InputDecoration(labelText: 'Income Source'),
              items: const [
                DropdownMenuItem(value: 'Salary', child: Text('Salary')),
                DropdownMenuItem(value: 'Bonus', child: Text('Bonus')),
                DropdownMenuItem(value: 'Freelance', child: Text('Freelance')),
                DropdownMenuItem(value: 'Investment', child: Text('Investment')),
                DropdownMenuItem(value: 'Other', child: Text('Other')),
              ],
              onChanged: (value) {
                if (value == null) return;
                setState(() => _incomeSource = value);
              },
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _noteController,
              decoration: const InputDecoration(labelText: 'Note'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _dateController,
              readOnly: true,
              onTap: _pickDate,
              decoration: const InputDecoration(
                labelText: 'Date',
                suffixIcon: Icon(Icons.calendar_today_rounded),
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _depositMethod,
              decoration: const InputDecoration(labelText: 'Deposit Method'),
              items: const [
                DropdownMenuItem(value: 'Bank Transfer', child: Text('Bank Transfer')),
                DropdownMenuItem(value: 'Cash', child: Text('Cash')),
                DropdownMenuItem(value: 'Card', child: Text('Card')),
              ],
              onChanged: (value) {
                if (value == null) return;
                setState(() => _depositMethod = value);
              },
            ),
            const SizedBox(height: 12),
            SwitchListTile(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: AppColors.border),
              ),
              value: _isRecurringIncome,
              onChanged: (value) => setState(() => _isRecurringIncome = value),
              title: const Text('Mark as recurring income'),
              secondary: const Icon(Icons.autorenew_rounded),
            ),
            const SizedBox(height: 22),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: _saveIncome,
                    child: const Text('Save Income'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
