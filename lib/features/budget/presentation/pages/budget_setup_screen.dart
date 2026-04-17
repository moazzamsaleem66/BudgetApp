import 'package:flutter/material.dart';

import '../../data/models/budget_models.dart';
import '../state/budget_state_scope.dart';

class BudgetSetupScreen extends StatelessWidget {
  const BudgetSetupScreen({super.key, required this.onSelectTab});

  final ValueChanged<int> onSelectTab;

  @override
  Widget build(BuildContext context) {
    final state = BudgetStateScope.of(context);
    final currencyCode = state.currencyCode;
    final summary = state.summary;
    final categories = state.categories;
    final rankedCategories = [...categories]..sort((a, b) => b.spent.compareTo(a.spent));

    final todaySpent = state.recentTransactions
        .where((t) => t.isExpense && t.dateLabel.toLowerCase().contains('today'))
        .fold<double>(0, (sum, t) => sum + t.amount);
    final thisWeekSpent = state.recentTransactions
        .where((t) => t.isExpense)
        .fold<double>(0, (sum, t) => sum + t.amount);
    final dailyAvg = summary.totalSpent / 30;

    void openCategoryTransactions(BudgetCategory category) {
      final messenger = ScaffoldMessenger.maybeOf(context);
      state.clearAdvancedFilters();
      state.selectTransactionFilter('By category');
      state.setCategoryFilter(category.name);
      messenger?.showSnackBar(
        SnackBar(
          content: Text('${_displayCategoryName(category.name)} opened in Transactions'),
          backgroundColor: const Color(0xFF0E8E83),
        ),
      );
      onSelectTab(1);
    }

    void openTransactionsWithFilter(String filter) {
      state.clearAdvancedFilters();
      state.selectTransactionFilter(filter);
      onSelectTab(1);
    }

    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF17A79F), Color(0xFF74DEBE), Color(0xFFA2EEB7)],
        ),
      ),
      child: Stack(
        children: [
          Positioned(top: -20, right: -20, child: _GlowCircle(size: 170, opacity: 0.18)),
          Positioned(bottom: -80, left: -70, child: _GlowCircle(size: 260, opacity: 0.12)),
          Positioned(bottom: -90, right: -60, child: _GlowCircle(size: 220, opacity: 0.09)),
          SafeArea(
            top: false,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Your Budget',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 48 / 2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Stay in control this month',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontWeight: FontWeight.w500,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _SummaryCard(
                    summary: summary,
                    onTap: () => openTransactionsWithFilter('This month'),
                    currencyCode: currencyCode,
                  ),
                  const SizedBox(height: 10),
                  _AlertBanner(
                    progress: summary.progress,
                    highestCategory: rankedCategories.isNotEmpty ? rankedCategories.first : null,
                    onTap: () {
                      if (rankedCategories.isEmpty) return;
                      openCategoryTransactions(rankedCategories.first);
                    },
                    currencyCode: currencyCode,
                  ),
                  const SizedBox(height: 10),
                  _BudgetStatusIndicator(
                    summary: summary,
                    onTap: () => onSelectTab(2),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _StatTile(
                          icon: Icons.calendar_today_rounded,
                          label: 'TODAY',
                          value: _formatCompactCurrency(todaySpent, currencyCode),
                          onTap: () => openTransactionsWithFilter('Today'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _StatTile(
                          icon: Icons.calendar_view_week_rounded,
                          label: 'THIS WEEK',
                          value: _formatCompactCurrency(thisWeekSpent, currencyCode),
                          onTap: () => openTransactionsWithFilter('This week'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _StatTile(
                          icon: Icons.access_time_filled_rounded,
                          label: 'DAILY AVG',
                          value: _formatCompactCurrency(dailyAvg, currencyCode),
                          onTap: () => onSelectTab(2),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'CATEGORIES',
                    style: TextStyle(
                      color: Color(0xFF0B715F),
                      fontWeight: FontWeight.w800,
                      fontSize: 32 / 2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _CategoryRankingCard(
                    rankedCategories: rankedCategories.take(3).toList(growable: false),
                    totalBudget: summary.totalBudget,
                    onCategoryTap: openCategoryTransactions,
                    currencyCode: currencyCode,
                  ),
                  const SizedBox(height: 10),
                  ...categories.take(4).map(
                        (category) => _CategoryCard(
                          category: category,
                          onTap: () => openCategoryTransactions(category),
                          currencyCode: currencyCode,
                        ),
                      ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.summary,
    required this.onTap,
    required this.currencyCode,
  });

  final BudgetSummary summary;
  final VoidCallback onTap;
  final String currencyCode;

  @override
  Widget build(BuildContext context) {
    final monthLabel = _shortMonthLabel(summary.monthLabel);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Ink(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            color: Colors.white.withValues(alpha: 0.3),
            border: Border.all(color: Colors.white.withValues(alpha: 0.5), width: 1.6),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'TOTAL REMAINING',
                      style: TextStyle(
                        color: Color(0xFF0F7A67),
                        fontWeight: FontWeight.w800,
                        fontSize: 28 / 2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatCurrency(summary.remainingBudget, currencyCode),
                      style: const TextStyle(
                        color: Color(0xFF035A49),
                        fontWeight: FontWeight.w900,
                        fontSize: 58 / 2,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  color: Colors.white.withValues(alpha: 0.28),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.55)),
                ),
                child: Text(
                  monthLabel,
                  style: const TextStyle(
                    color: Color(0xFF0E6D5D),
                    fontWeight: FontWeight.w800,
                    fontSize: 31 / 2,
                  ),
                ),
              ),
            ],
          ),
          const Text(
            'You\'re doing great 👍',
            style: TextStyle(
              color: Color(0xFF0A7D62),
              fontWeight: FontWeight.w700,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: summary.progress,
              minHeight: 12,
              backgroundColor: Colors.white.withValues(alpha: 0.4),
              color: const Color(0xFF18CA42),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'MONTHLY BUDGET',
                      style: TextStyle(
                        color: Color(0xFF0E7562),
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      _formatCurrency(summary.totalBudget, currencyCode),
                      style: const TextStyle(
                        color: Color(0xFF045D4C),
                        fontWeight: FontWeight.w900,
                        fontSize: 38 / 2,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      'SPENT SO FAR',
                      style: TextStyle(
                        color: Color(0xFF0E7562),
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      _formatCurrency(summary.totalSpent, currencyCode),
                      style: const TextStyle(
                        color: Color(0xFF045D4C),
                        fontWeight: FontWeight.w900,
                        fontSize: 38 / 2,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            ),
          ],
          ),
        ),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Ink(
          padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            color: Colors.white.withValues(alpha: 0.32),
            border: Border.all(color: Colors.white.withValues(alpha: 0.48), width: 1.4),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
          Icon(icon, size: 20, color: const Color(0xFF0C7D6B)),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF0B7462),
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              color: Color(0xFF024F42),
              fontWeight: FontWeight.w900,
              fontSize: 37 / 2,
            ),
          ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AlertBanner extends StatelessWidget {
  const _AlertBanner({
    required this.progress,
    required this.highestCategory,
    required this.onTap,
    required this.currencyCode,
  });

  final double progress;
  final BudgetCategory? highestCategory;
  final VoidCallback onTap;
  final String currencyCode;

  @override
  Widget build(BuildContext context) {
    final isHigh = progress >= 0.85;
    final title = isHigh ? 'Alert: Spending is high this month' : 'Great job: Budget is under control';
    final subtitle = highestCategory == null
        ? 'Keep tracking your transactions to maintain control.'
        : 'Highest spend: ${highestCategory!.name} (${_formatCompactCurrency(highestCategory!.spent, currencyCode)}).';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Ink(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: isHigh ? const Color(0xFFFFF0D8).withValues(alpha: 0.88) : const Color(0xFFE6F8EF).withValues(alpha: 0.88),
            border: Border.all(
              color: isHigh ? const Color(0xFFF59E0B) : const Color(0xFF13A55D),
              width: 1.2,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                isHigh ? Icons.warning_amber_rounded : Icons.verified_rounded,
                color: isHigh ? const Color(0xFFB86A00) : const Color(0xFF0F8A52),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Color(0xFF124A45),
                        fontWeight: FontWeight.w800,
                        fontSize: 13.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: Color(0xFF2C655D),
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
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

class _BudgetStatusIndicator extends StatelessWidget {
  const _BudgetStatusIndicator({
    required this.summary,
    required this.onTap,
  });

  final BudgetSummary summary;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final usedPercent = (summary.progress * 100).toStringAsFixed(0);
    final status = summary.progress >= 0.9
        ? 'Critical'
        : summary.progress >= 0.75
            ? 'Watch'
            : 'Healthy';
    final statusColor = _statusColor(summary.progress);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Ink(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            color: Colors.white.withValues(alpha: 0.28),
            border: Border.all(color: Colors.white.withValues(alpha: 0.52), width: 1.3),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
          const Text(
            'Budget Status Indicator',
            style: TextStyle(
              color: Color(0xFF0A6456),
              fontWeight: FontWeight.w800,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Text(
                  '$usedPercent% used',
                  style: const TextStyle(
                    color: Color(0xFF0D5047),
                    fontWeight: FontWeight.w900,
                    fontSize: 22 / 1.35,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  status.toUpperCase(),
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.w800,
                    fontSize: 11.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: summary.progress,
              minHeight: 9,
              backgroundColor: Colors.white.withValues(alpha: 0.55),
              color: statusColor,
            ),
          ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryRankingCard extends StatelessWidget {
  const _CategoryRankingCard({
    required this.rankedCategories,
    required this.totalBudget,
    required this.onCategoryTap,
    required this.currencyCode,
  });

  final List<BudgetCategory> rankedCategories;
  final double totalBudget;
  final ValueChanged<BudgetCategory> onCategoryTap;
  final String currencyCode;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: Colors.white.withValues(alpha: 0.26),
        border: Border.all(color: Colors.white.withValues(alpha: 0.5), width: 1.3),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Category Ranking',
            style: TextStyle(
              color: Color(0xFF0B6455),
              fontWeight: FontWeight.w800,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          if (rankedCategories.isEmpty)
            const Text(
              'No category data available',
              style: TextStyle(
                color: Color(0xFF2C655D),
                fontWeight: FontWeight.w600,
              ),
            )
          else
            for (var i = 0; i < rankedCategories.length; i++)
              Padding(
                padding: EdgeInsets.only(bottom: i == rankedCategories.length - 1 ? 0 : 7),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(10),
                    onTap: () => onCategoryTap(rankedCategories[i]),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Row(
                        children: [
                    Container(
                      width: 24,
                      height: 24,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF0B7D69).withValues(alpha: 0.16),
                      ),
                      child: Text(
                        '${i + 1}',
                        style: const TextStyle(
                          color: Color(0xFF0A5B4D),
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _displayCategoryName(rankedCategories[i].name),
                        style: const TextStyle(
                          color: Color(0xFF0E4F45),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Text(
                      '${_formatCompactCurrency(rankedCategories[i].spent, currencyCode)} (${(totalBudget <= 0 ? 0 : (rankedCategories[i].spent / totalBudget) * 100).toStringAsFixed(0)}%)',
                      style: const TextStyle(
                        color: Color(0xFF0E4F45),
                        fontWeight: FontWeight.w700,
                        fontSize: 12.5,
                      ),
                    ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
        ],
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({
    required this.category,
    required this.onTap,
    required this.currencyCode,
  });

  final BudgetCategory category;
  final VoidCallback onTap;
  final String currencyCode;

  @override
  Widget build(BuildContext context) {
    final icon = _categoryIcon(category.name);
    final accent = _categoryAccent(category.name);
    final status = _statusText(category.progress);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: onTap,
          child: Ink(
            padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              color: Colors.white.withValues(alpha: 0.3),
              border: Border.all(color: Colors.white.withValues(alpha: 0.5), width: 1.5),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        color: accent.withValues(alpha: 0.18),
                      ),
                      child: Icon(icon, color: accent),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _displayCategoryName(category.name),
                            style: const TextStyle(
                              color: Color(0xFF0A4B45),
                              fontWeight: FontWeight.w800,
                              fontSize: 31 / 2,
                            ),
                          ),
                          Text(
                            '${_formatCompactCurrency((category.limit - category.spent).clamp(0, 1000000).toDouble(), currencyCode)} remaining',
                            style: const TextStyle(
                              color: Color(0xFF286660),
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${_formatCompactCurrency(category.spent, currencyCode)} / ${_formatCompactCurrency(category.limit, currencyCode)}',
                          style: const TextStyle(
                            color: Color(0xFF0B4E46),
                            fontWeight: FontWeight.w800,
                            fontSize: 30 / 2,
                          ),
                        ),
                        Text(
                          status,
                          style: TextStyle(
                            color: _statusColor(category.progress),
                            fontWeight: FontWeight.w800,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(99),
                  child: LinearProgressIndicator(
                    value: category.progress,
                    minHeight: 10,
                    backgroundColor: Colors.white.withValues(alpha: 0.55),
                    color: _statusColor(category.progress),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
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

String _shortMonthLabel(String monthLabel) {
  final parts = monthLabel.split(' ');
  if (parts.length >= 2) {
    final month = parts.first;
    final year = parts.last;
    final short = month.length >= 3 ? month.substring(0, 3) : month;
    return '$short\n$year';
  }
  return monthLabel;
}

String _formatCurrency(double value, String currencyCode) => '$currencyCode ${value.toStringAsFixed(3)}';
String _formatCompactCurrency(double value, String currencyCode) => '$currencyCode ${value.toStringAsFixed(1)}';

String _displayCategoryName(String name) {
  switch (name) {
    case 'Food':
      return 'Food & Dining';
    case 'Fuel':
      return 'Fuel & Transit';
    default:
      return name;
  }
}

IconData _categoryIcon(String name) {
  switch (name) {
    case 'Food':
      return Icons.restaurant_rounded;
    case 'Fuel':
      return Icons.local_gas_station_rounded;
    case 'Shopping':
      return Icons.shopping_bag_rounded;
    case 'Bills':
      return Icons.receipt_long_rounded;
    default:
      return Icons.category_rounded;
  }
}

Color _categoryAccent(String name) {
  switch (name) {
    case 'Food':
      return const Color(0xFFEE7E2A);
    case 'Fuel':
      return const Color(0xFF0A9F57);
    case 'Shopping':
      return const Color(0xFFE24B57);
    case 'Bills':
      return const Color(0xFF2A64E3);
    default:
      return const Color(0xFF0A8A6D);
  }
}

Color _statusColor(double progress) {
  if (progress >= 0.95) return const Color(0xFFEB2A2A);
  if (progress >= 0.75) return const Color(0xFFF59E0B);
  return const Color(0xFF12A150);
}

String _statusText(double progress) {
  if (progress >= 0.95) return 'NEAR LIMIT';
  if (progress >= 0.75) return 'WATCH LIST';
  return 'HEALTHY';
}
