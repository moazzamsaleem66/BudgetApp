import 'package:flutter/material.dart';

import '../state/budget_state_scope.dart';

class AddExpenseScreen extends StatefulWidget {
  const AddExpenseScreen({super.key});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  final _dateController = TextEditingController();

  String _category = 'Food';
  String _paymentMethod = 'Card';
  bool _isRecurring = true;
  String? _receiptFileName;

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(now.year - 3),
      lastDate: DateTime(now.year + 3),
    );
    if (picked == null) return;
    _dateController.text = '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
  }

  Future<void> _pickReceiptImage() async {
    final choice = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library_rounded, color: Color(0xFF0A8E95)),
              title: const Text('Choose from gallery'),
              onTap: () => Navigator.of(context).pop('gallery'),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt_rounded, color: Color(0xFF0A8E95)),
              title: const Text('Take photo'),
              onTap: () => Navigator.of(context).pop('camera'),
            ),
            ListTile(
              leading: const Icon(Icons.picture_as_pdf_rounded, color: Color(0xFF0A8E95)),
              title: const Text('Attach PDF'),
              onTap: () => Navigator.of(context).pop('pdf'),
            ),
          ],
        ),
      ),
    );
    if (choice == null) return;
    if (!mounted) return;
    final suffix = switch (choice) {
      'camera' => 'jpg',
      'pdf' => 'pdf',
      _ => 'png',
    };
    final now = DateTime.now().millisecondsSinceEpoch;
    final fileName = 'receipt_$now.$suffix';
    setState(() => _receiptFileName = fileName);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Receipt attached: $fileName'),
        backgroundColor: const Color(0xFF0FA581),
      ),
    );
  }

  void _toggleRecurring(bool value) {
    setState(() => _isRecurring = value);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(value ? 'Recurring expense enabled' : 'Recurring expense disabled'),
        backgroundColor: const Color(0xFF0FA581),
      ),
    );
  }

  void _saveExpense() {
    final amountText = _amountController.text.trim();
    final amount = double.tryParse(amountText);

    if (amountText.isEmpty || amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid amount greater than 0.')),
      );
      return;
    }

    if (_dateController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a date.')),
      );
      return;
    }

    final expensePayload = <String, dynamic>{
      'amount': amount,
      'category': _category,
      'note': _noteController.text.trim(),
      'date': _dateController.text.trim(),
      'paymentMethod': _paymentMethod,
      'isRecurring': _isRecurring,
      'receiptFileName': _receiptFileName,
    };

    final state = BudgetStateScope.maybeOf(context);
    if (state != null) {
      final isAdded = state.addExpenseFromPayload(expensePayload);
      if (!isAdded) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unable to save expense. Please check details.')),
        );
        return;
      }
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Expense saved successfully.'),
        backgroundColor: Color(0xFF0FA581),
      ),
    );

    Navigator.of(context).pop(state != null ? true : expensePayload);
  }

  @override
  Widget build(BuildContext context) {
    final currencyCode = BudgetStateScope.maybeOf(context)?.currencyCode ?? 'KD';
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F9),
      appBar: AppBar(
        title: const Text('Add Expense', style: TextStyle(fontWeight: FontWeight.w800)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 6, 16, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF0FA581), Color(0xFF0A8E95)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0FA581).withValues(alpha: 0.2),
                    blurRadius: 14,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Track every spending moment',
                    style: TextStyle(color: Colors.white, fontSize: 20 / 1.2, fontWeight: FontWeight.w800),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Add details now to keep your budget accurate and actionable.',
                    style: TextStyle(color: Color(0xFFE8FCF7), fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFD8E3EC)),
              ),
              child: Column(
                children: [
                  _field(
                    controller: _amountController,
                    label: 'Amount',
                    hint: 'e.g. 12.500',
                    prefix: '$currencyCode ',
                    icon: Icons.payments_rounded,
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 12),
                  _dropdownField(
                    label: 'Category',
                    icon: Icons.category_rounded,
                    value: _category,
                    items: const ['Food', 'Fuel', 'Shopping', 'Bills', 'Travel', 'Other'],
                    onChanged: (value) => setState(() => _category = value),
                  ),
                  const SizedBox(height: 12),
                  _field(
                    controller: _noteController,
                    label: 'Note',
                    hint: 'Add short note',
                    icon: Icons.notes_rounded,
                  ),
                  const SizedBox(height: 12),
                  _field(
                    controller: _dateController,
                    label: 'Date',
                    hint: 'Select date',
                    icon: Icons.calendar_today_rounded,
                    readOnly: true,
                    onTap: _pickDate,
                  ),
                  const SizedBox(height: 12),
                  _dropdownField(
                    label: 'Payment Method',
                    icon: Icons.credit_card_rounded,
                    value: _paymentMethod,
                    items: const ['Card', 'Cash', 'Bank Transfer', 'Wallet'],
                    onChanged: (value) => setState(() => _paymentMethod = value),
                  ),
                  const SizedBox(height: 12),
                  InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: () => _toggleRecurring(!_isRecurring),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        color: const Color(0xFFF8FAFC),
                        border: Border.all(color: const Color(0xFFD9E2EC)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.autorenew_rounded, color: Color(0xFF0A8E95)),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Mark as recurring',
                                  style: TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF1E293B)),
                                ),
                                Text(
                                  _isRecurring ? 'Enabled' : 'Disabled',
                                  style: const TextStyle(
                                    color: Color(0xFF5D748A),
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Switch(
                            value: _isRecurring,
                            onChanged: _toggleRecurring,
                            activeThumbColor: const Color(0xFF0FA581),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FilledButton.tonalIcon(
                          onPressed: _pickReceiptImage,
                          icon: const Icon(Icons.image_outlined),
                          label: const Text('Attach receipt image'),
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFFEAF6F4),
                            foregroundColor: const Color(0xFF1E293B),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                        if (_receiptFileName != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 8, left: 2),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    'Selected: $_receiptFileName',
                                    style: const TextStyle(
                                      color: Color(0xFF0A8E95),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () => setState(() => _receiptFileName = null),
                                  child: const Text('Remove'),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(50),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: const Text('Cancel', style: TextStyle(fontWeight: FontWeight.w700)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: _saveExpense,
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(50),
                      backgroundColor: const Color(0xFF0FA581),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: const Text('Save Expense', style: TextStyle(fontWeight: FontWeight.w800)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    String? prefix,
    TextInputType keyboardType = TextInputType.text,
    bool readOnly = false,
    VoidCallback? onTap,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      readOnly: readOnly,
      onTap: onTap,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixText: prefix,
        prefixIcon: Icon(icon, color: const Color(0xFF0A8E95)),
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFD9E2EC)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFF0FA581), width: 1.4),
        ),
      ),
    );
  }

  Widget _dropdownField({
    required String label,
    required IconData icon,
    required String value,
    required List<String> items,
    required ValueChanged<String> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      items: items.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(growable: false),
      onChanged: (value) {
        if (value == null) return;
        onChanged(value);
      },
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFF0A8E95)),
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFD9E2EC)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFF0FA581), width: 1.4),
        ),
      ),
    );
  }
}
