import 'package:flutter/material.dart';

import '../state/budget_app_state.dart';
import '../state/budget_state_scope.dart';

class TransactionsScreen extends StatelessWidget {
  const TransactionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = BudgetStateScope.of(context);
    final transactions = state.filteredTransactions;

    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF0C9AA7), Color(0xFF67D6CB), Color(0xFFA4E9DA)],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -70,
            right: -40,
            child: _GlowCircle(size: 260, opacity: 0.14),
          ),
          Positioned(
            left: -100,
            bottom: 70,
            child: _GlowCircle(size: 300, opacity: 0.11),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: Container(
                padding: const EdgeInsets.fromLTRB(10, 10, 10, 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(22),
                  color: Colors.white.withValues(alpha: 0.26),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.5), width: 1.5),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            onChanged: state.setSearchQuery,
                            style: const TextStyle(
                              color: Color(0xFF21435D),
                              fontWeight: FontWeight.w600,
                            ),
                            decoration: InputDecoration(
                              hintText: 'Search transactions',
                              hintStyle: const TextStyle(color: Color(0xFF3A6077)),
                              prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF2E556B)),
                              suffixIcon: state.transactionSearchQuery.isEmpty
                                  ? null
                                  : IconButton(
                                      onPressed: () => state.setSearchQuery(''),
                                      icon: const Icon(Icons.close_rounded, color: Color(0xFF2E556B)),
                                    ),
                              filled: true,
                              fillColor: Colors.white.withValues(alpha: 0.82),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(18),
                                borderSide: const BorderSide(color: Color(0xFFA8DED6), width: 1.4),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(18),
                                borderSide: const BorderSide(color: Color(0xFF1DAE88), width: 1.6),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        SizedBox(
                          width: 46,
                          height: 46,
                          child: ElevatedButton(
                            onPressed: () => _openFilterSheet(context, state),
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.zero,
                              backgroundColor: const Color(0xFF2E69F2),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            ),
                            child: const Icon(Icons.tune_rounded, size: 22),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 42,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: state.transactionFilters
                            .map(
                              (label) => _FilterChip(
                                label: label,
                                selected: state.selectedTransactionFilter == label,
                                onTap: () => state.selectTransactionFilter(label),
                              ),
                            )
                            .toList(growable: false),
                      ),
                    ),
                    if (state.selectedTransactionFilter == 'By category') ...[
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 38,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: state.availableCategories
                              .map(
                                (category) => _CategoryFilterChip(
                                  label: category,
                                  selected: (state.selectedCategoryFilter ?? 'All') == category,
                                  onTap: () => state.setCategoryFilter(category),
                                ),
                              )
                              .toList(growable: false),
                        ),
                      ),
                    ],
                    const SizedBox(height: 10),
                    Expanded(
                      child: transactions.isEmpty
                          ? const Center(
                              child: Text(
                                'No transactions found',
                                style: TextStyle(
                                  color: Color(0xFF234A62),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            )
                          : ListView.builder(
                              itemCount: transactions.length,
                              itemBuilder: (context, index) {
                                final item = transactions[index];
                                return _GlassTransactionTile(
                                  title: item.title,
                                  category: item.category,
                                  date: item.dateLabel,
                                  amount: item.amount,
                                  isExpense: item.isExpense,
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Future<void> _openFilterSheet(BuildContext context, BudgetAppState state) async {
  var tempSort = state.selectedSortOption;
  var tempCategory = state.selectedCategoryFilter ?? 'All';
  var tempPayment = state.selectedPaymentFilter ?? 'All';

  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setModalState) {
          return Padding(
            padding: EdgeInsets.fromLTRB(
              16,
              8,
              16,
              16 + MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Advanced Filters',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: tempSort,
                  decoration: const InputDecoration(labelText: 'Sort'),
                  items: state.sortOptions
                      .map(
                        (option) => DropdownMenuItem(
                          value: option,
                          child: Text(option),
                        ),
                      )
                      .toList(growable: false),
                  onChanged: (value) {
                    if (value == null) return;
                    setModalState(() => tempSort = value);
                  },
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: tempCategory,
                  decoration: const InputDecoration(labelText: 'Category'),
                  items: state.availableCategories
                      .map(
                        (category) => DropdownMenuItem(
                          value: category,
                          child: Text(category),
                        ),
                      )
                      .toList(growable: false),
                  onChanged: (value) {
                    if (value == null) return;
                    setModalState(() => tempCategory = value);
                  },
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: tempPayment,
                  decoration: const InputDecoration(labelText: 'Payment Method'),
                  items: state.availablePaymentMethods
                      .map(
                        (method) => DropdownMenuItem(
                          value: method,
                          child: Text(method),
                        ),
                      )
                      .toList(growable: false),
                  onChanged: (value) {
                    if (value == null) return;
                    setModalState(() => tempPayment = value);
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          state.clearAdvancedFilters();
                          Navigator.of(context).pop();
                        },
                        child: const Text('Reset'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton(
                        onPressed: () {
                          state.setSortOption(tempSort);
                          state.setCategoryFilter(tempCategory);
                          state.setPaymentFilter(tempPayment);
                          Navigator.of(context).pop();
                        },
                        child: const Text('Apply'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      );
    },
  );
}

class _GlowCircle extends StatelessWidget {
  const _GlowCircle({required this.size, required this.opacity});

  final double size;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: opacity),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          decoration: BoxDecoration(
            color: selected ? const Color(0xFF19A87E) : Colors.white.withValues(alpha: 0.62),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFA8DDD5), width: 1.2),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: selected ? Colors.white : const Color(0xFF20485E),
              fontWeight: FontWeight.w700,
              fontSize: 16 / 1.05,
            ),
          ),
        ),
      ),
    );
  }
}

class _GlassTransactionTile extends StatelessWidget {
  const _GlassTransactionTile({
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
    final state = BudgetStateScope.maybeOf(context);
    final currencyCode = state?.currencyCode ?? 'KD';
    final initial = category.isNotEmpty ? category[0].toUpperCase() : '?';
    final amountColor = isExpense ? const Color(0xFFEC4B55) : const Color(0xFF119A70);
    final amountPrefix = isExpense ? '- ' : '+ ';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.fromLTRB(10, 8, 12, 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white.withValues(alpha: 0.46),
        border: Border.all(color: Colors.white.withValues(alpha: 0.55), width: 1.4),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFCFF4EA),
              border: Border.all(color: Colors.white.withValues(alpha: 0.55), width: 1.2),
            ),
            alignment: Alignment.center,
            child: Text(
              initial,
              style: const TextStyle(
                color: Color(0xFF1A9B7B),
                fontWeight: FontWeight.w800,
                fontSize: 34 / 2,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF173C53),
                    fontWeight: FontWeight.w800,
                    fontSize: 37 / 2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$category - $date',
                  style: const TextStyle(
                    color: Color(0xFF284E66),
                    fontWeight: FontWeight.w500,
                    fontSize: 31 / 2,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '$amountPrefix${_formatTxnCurrency(amount, currencyCode)}',
            style: TextStyle(
              color: amountColor,
              fontWeight: FontWeight.w700,
              fontSize: 37 / 2,
            ),
          ),
        ],
      ),
    );
  }
}

String _formatTxnCurrency(double value, String currencyCode) => '$currencyCode ${value.toStringAsFixed(3)}';

class _CategoryFilterChip extends StatelessWidget {
  const _CategoryFilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: selected ? const Color(0xFF0E8E83) : Colors.white.withValues(alpha: 0.74),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: selected ? const Color(0xFF0E8E83) : const Color(0xFFAADAD7),
              width: 1.2,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: selected ? Colors.white : const Color(0xFF20485E),
              fontWeight: FontWeight.w700,
              fontSize: 12.5,
            ),
          ),
        ),
      ),
    );
  }
}
