import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../data/models/budget_models.dart';
import '../state/budget_app_state.dart';
import '../state/budget_state_scope.dart';
import 'add_expense_screen.dart';
import 'add_income_screen.dart';
import 'notification_center_screen.dart';

class HomeDashboardScreen extends StatefulWidget {
  const HomeDashboardScreen({super.key, required this.onSelectTab});

  final ValueChanged<int> onSelectTab;

  @override
  State<HomeDashboardScreen> createState() => _HomeDashboardScreenState();
}

class _HomeDashboardScreenState extends State<HomeDashboardScreen> {
  int _activeDotIndex = 0;
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _activeDotIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _goToPage(int index) async {
    if (_activeDotIndex == index || !_pageController.hasClients) return;
    setState(() => _activeDotIndex = index);
    await _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _openAddExpenseFlow(BudgetAppState state) async {
    final result = await Navigator.of(context).push<Object?>(
      MaterialPageRoute<Object?>(builder: (_) => const AddExpenseScreen()),
    );
    if (!mounted) return;
    final isSaved = switch (result) {
      true => true,
      final Map<String, dynamic> payload => state.addExpenseFromPayload(payload),
      _ => false,
    };
    if (!isSaved) return;

    final messenger = ScaffoldMessenger.maybeOf(context);
    state.clearAdvancedFilters();
    state.selectTransactionFilter('This month');
    messenger?.showSnackBar(
      const SnackBar(
        content: Text('Expense added. It is shown in Transactions tab.'),
        backgroundColor: Color(0xFF0E8E83),
      ),
    );
    widget.onSelectTab(1);
  }

  Future<void> _openAddIncomeFlow(BudgetAppState state) async {
    final result = await Navigator.of(context).push<Object?>(
      MaterialPageRoute<Object?>(builder: (_) => const AddIncomeScreen()),
    );
    if (!mounted) return;
    final isSaved = switch (result) {
      true => true,
      final Map<String, dynamic> payload => state.addIncomeFromPayload(payload),
      _ => false,
    };
    if (!isSaved) return;

    final messenger = ScaffoldMessenger.maybeOf(context);
    state.clearAdvancedFilters();
    state.selectTransactionFilter('This month');
    messenger?.showSnackBar(
      const SnackBar(
        content: Text('Income added. It is shown in Transactions tab.'),
        backgroundColor: Color(0xFF0E8E83),
      ),
    );
    widget.onSelectTab(1);
  }

  @override
  Widget build(BuildContext context) {
    final state = BudgetStateScope.of(context);
    final currencyCode = state.currencyCode;
    final summary = state.summary;
    final categories = state.categories;
    final insights = state.analytics.insights.take(2).toList(growable: false);
    final recentTransactions = state.recentTransactions.take(3).toList(growable: false);

    return Stack(
      children: [
        DecoratedBox(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF0E8F8A), Color(0xFFBEEFEB), Color(0xFFF5FAFB)],
              stops: [0.0, 0.40, 0.82],
            ),
          ),
          child: SafeArea(
            top: true,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 140),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
              const SizedBox(height: 4),
              _HeroHeader(
                greeting: summary.greeting,
                month: state.selectedMonth,
                budget: summary.totalBudget,
                spent: summary.totalSpent,
                remaining: summary.remainingBudget,
                progress: summary.progress,
                currencyCode: currencyCode,
                onBellTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(builder: (_) => const NotificationCenterScreen()),
                  );
                },
              ),
              const SizedBox(height: 14),
              _MonthFilterRow(
                months: state.months,
                selectedMonth: state.selectedMonth,
                onSelectMonth: state.selectMonth,
              ),
              const SizedBox(height: 12),
              _MiniInsightsCard(insights: insights),
              const SizedBox(height: 14),
              const Text(
                'Quick Actions',
                style: TextStyle(
                  color: Color(0xFF22364A),
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 10),
              GridView.count(
                crossAxisCount: 4,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 0.88,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _QuickActionTile(
                    label: 'Add Expense',
                    icon: Icons.add_card_rounded,
                    color: const Color(0xFF18A47F),
                    onTap: () => _openAddExpenseFlow(state),
                  ),
                  _QuickActionTile(
                    label: 'Add Income',
                    icon: Icons.savings_rounded,
                    color: const Color(0xFF3B82F6),
                    onTap: () => _openAddIncomeFlow(state),
                  ),
                  _QuickActionTile(
                    label: 'Set Budget',
                    icon: Icons.tune_rounded,
                    color: const Color(0xFFF59E0B),
                    onTap: () => widget.onSelectTab(3),
                  ),
                  _QuickActionTile(
                    label: 'Reports',
                    icon: Icons.bar_chart_rounded,
                    color: const Color(0xFF0EA5A4),
                    onTap: () => widget.onSelectTab(2),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.78),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFD6E4EE)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Budget Insight',
                      style: TextStyle(
                        color: Color(0xFF22364A),
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'You have used ${(summary.progress * 100).toStringAsFixed(0)}% of this month budget. Keep your spending balanced.',
                      style: const TextStyle(
                        color: Color(0xFF4F667F),
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                'Categories',
                style: TextStyle(
                  color: Color(0xFF22364A),
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 315,
                child: PageView(
                  controller: _pageController,
                  pageSnapping: true,
                  physics: const BouncingScrollPhysics(),
                  onPageChanged: (index) {
                    if (_activeDotIndex != index) {
                      setState(() => _activeDotIndex = index);
                    }
                  },
                  children: [
                    _CategoriesCard(
                      headingLabel: 'Overview',
                      categories: categories,
                      total: summary.totalBudget,
                      remaining: summary.remainingBudget,
                      onAddExpense: () => _openAddExpenseFlow(state),
                      currencyCode: currencyCode,
                    ),
                    _CategoriesCard(
                      headingLabel: 'Highest Spend',
                      categories: ([...categories]..sort((a, b) => b.spent.compareTo(a.spent))),
                      total: summary.totalBudget,
                      remaining: summary.remainingBudget,
                      onAddExpense: () => _openAddExpenseFlow(state),
                      currencyCode: currencyCode,
                    ),
                    _CategoriesCard(
                      headingLabel: 'Remaining Focus',
                      categories: ([...categories]..sort((a, b) => a.progress.compareTo(b.progress))),
                      total: summary.totalBudget,
                      remaining: summary.remainingBudget,
                      onAddExpense: () => _openAddExpenseFlow(state),
                      currencyCode: currencyCode,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _PagerDot(active: _activeDotIndex == 0, onTap: () => _goToPage(0)),
                  const SizedBox(width: 8),
                  _PagerDot(active: _activeDotIndex == 1, onTap: () => _goToPage(1)),
                  const SizedBox(width: 8),
                  _PagerDot(active: _activeDotIndex == 2, onTap: () => _goToPage(2)),
                ],
              ),
              const SizedBox(height: 16),
              _RecentTransactionsCard(items: recentTransactions, currencyCode: currencyCode),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          right: 18,
          bottom: 94,
          child: FloatingActionButton(
            onPressed: () => _openAddExpenseFlow(state),
            backgroundColor: const Color(0xFF0E8E83),
            foregroundColor: Colors.white,
            elevation: 6,
            child: const Icon(Icons.add_rounded),
          ),
        ),
      ],
    );
  }
}

class _HeroHeader extends StatelessWidget {
  const _HeroHeader({
    required this.greeting,
    required this.month,
    required this.budget,
    required this.spent,
    required this.remaining,
    required this.progress,
    required this.currencyCode,
    required this.onBellTap,
  });

  final String greeting;
  final String month;
  final double budget;
  final double spent;
  final double remaining;
  final double progress;
  final String currencyCode;
  final VoidCallback onBellTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0F9C88), Color(0xFF0C7FA0)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0C7FA0).withValues(alpha: 0.24),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$greeting,',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 20,
                      ),
                    ),
                    Text(
                      'Here\'s your expenses overview',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: onBellTap,
                icon: const Icon(Icons.notifications_none_rounded, color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: _MiniMetricCard(title: 'Today spent', value: '$currencyCode ${spent.toStringAsFixed(0)}')),
              const SizedBox(width: 8),
              Expanded(
                child: _MiniMetricCard(
                  title: 'Remaining budget',
                  value: '$currencyCode ${remaining.toStringAsFixed(0)}',
                  subtitle: '$currencyCode ${budget.toStringAsFixed(0)} total',
                  progress: progress,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _Tag(text: month),
              const SizedBox(width: 8),
              _Tag(text: '${(progress * 100).toStringAsFixed(0)}% used'),
            ],
          ),
        ],
      ),
    );
  }
}

class _MonthFilterRow extends StatelessWidget {
  const _MonthFilterRow({
    required this.months,
    required this.selectedMonth,
    required this.onSelectMonth,
  });

  final List<String> months;
  final String selectedMonth;
  final ValueChanged<String> onSelectMonth;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Date Filter',
          style: TextStyle(
            color: Color(0xFF22364A),
            fontWeight: FontWeight.w800,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              for (final month in months)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(month),
                    selected: selectedMonth == month,
                    onSelected: (_) => onSelectMonth(month),
                    selectedColor: const Color(0xFF0E8E83),
                    backgroundColor: Colors.white.withValues(alpha: 0.9),
                    labelStyle: TextStyle(
                      color: selectedMonth == month ? Colors.white : const Color(0xFF3F556B),
                      fontWeight: FontWeight.w700,
                    ),
                    side: BorderSide(
                      color: selectedMonth == month ? const Color(0xFF0E8E83) : const Color(0xFFD3E2EC),
                    ),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MiniInsightsCard extends StatelessWidget {
  const _MiniInsightsCard({required this.insights});

  final List<InsightItem> insights;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.84),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFD7E3ED)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Mini Insights',
            style: TextStyle(
              color: Color(0xFF22364A),
              fontWeight: FontWeight.w800,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          if (insights.isEmpty)
            const Text(
              'No insights available for now.',
              style: TextStyle(color: Color(0xFF5E7389), fontWeight: FontWeight.w600),
            )
          else
            for (var i = 0; i < insights.length; i++)
              Padding(
                padding: EdgeInsets.only(bottom: i == insights.length - 1 ? 0 : 8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: const Color(0xFFF4F9FC),
                    border: Border.all(color: const Color(0xFFDDE8F1)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        margin: const EdgeInsets.only(top: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0E8E83).withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.insights_rounded, size: 14, color: Color(0xFF0E8E83)),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              insights[i].title,
                              style: const TextStyle(
                                color: Color(0xFF2A3D54),
                                fontWeight: FontWeight.w800,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              insights[i].message,
                              style: const TextStyle(
                                color: Color(0xFF5E7389),
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
        ],
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.35)),
      ),
      child: Text(
        text,
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12),
      ),
    );
  }
}

class _MiniMetricCard extends StatelessWidget {
  const _MiniMetricCard({required this.title, required this.value, this.subtitle, this.progress});

  final String title;
  final String value;
  final String? subtitle;
  final double? progress;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 102,
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: Color(0xFF4B6078), fontWeight: FontWeight.w700, fontSize: 12)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(color: Color(0xFF22364A), fontWeight: FontWeight.w800, fontSize: 18)),
          if (progress != null) ...[
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                minHeight: 7,
                value: progress,
                backgroundColor: const Color(0xFFE6ECF2),
                color: const Color(0xFF13A57D),
              ),
            ),
          ] else
            const SizedBox(height: 13),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(subtitle!, style: const TextStyle(color: Color(0xFF70839B), fontWeight: FontWeight.w600, fontSize: 11)),
          ] else
            const SizedBox(height: 15),
        ],
      ),
    );
  }
}

class _QuickActionTile extends StatelessWidget {
  const _QuickActionTile({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Ink(
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.88),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFD6E2EC)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF2F6A8A).withValues(alpha: 0.07),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(11),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFF354A61), fontWeight: FontWeight.w700, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoriesCard extends StatelessWidget {
  const _CategoriesCard({
    required this.headingLabel,
    required this.categories,
    required this.total,
    required this.remaining,
    required this.onAddExpense,
    required this.currencyCode,
  });

  final String headingLabel;
  final List<BudgetCategory> categories;
  final double total;
  final double remaining;
  final VoidCallback onAddExpense;
  final String currencyCode;

  @override
  Widget build(BuildContext context) {
    final shown = categories.take(5).toList(growable: false);
    final ringValues = shown.map((e) => e.spent).toList(growable: false);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFD7E3EC), width: 1.2),
        color: const Color(0xFFFDFEFF),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF5B6B7F).withValues(alpha: 0.10),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFE6F6F0),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  headingLabel,
                  style: const TextStyle(color: Color(0xFF0F7A63), fontWeight: FontWeight.w800, fontSize: 12),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '$currencyCode ${total.toStringAsFixed(0)}',
                style: const TextStyle(color: Color(0xFF24364A), fontWeight: FontWeight.w800, fontSize: 20),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _CategoryList(categories: shown, currencyCode: currencyCode)),
              const SizedBox(width: 8),
              _RingSection(total: total, remaining: remaining, values: ringValues, currencyCode: currencyCode),
            ],
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton.icon(
              onPressed: onAddExpense,
              icon: const Icon(Icons.add),
              label: const Text('Add Expense'),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF0E8E83),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
                textStyle: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryList extends StatelessWidget {
  const _CategoryList({required this.categories, required this.currencyCode});

  final List<BudgetCategory> categories;
  final String currencyCode;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < categories.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: _ringColors[i % _ringColors.length].withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(_categoryIcon(categories[i].name), size: 14, color: _ringColors[i % _ringColors.length]),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    categories[i].name,
                    style: const TextStyle(color: Color(0xFF2A3D54), fontWeight: FontWeight.w700, fontSize: 15),
                  ),
                ),
                Text('$currencyCode ${categories[i].spent.toStringAsFixed(0)}', style: const TextStyle(color: Color(0xFF56677E), fontWeight: FontWeight.w700)),
              ],
            ),
          ),
      ],
    );
  }
}

class _RecentTransactionsCard extends StatelessWidget {
  const _RecentTransactionsCard({required this.items, required this.currencyCode});

  final List<TransactionItem> items;
  final String currencyCode;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFD5E3EC)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Recent Transactions',
            style: TextStyle(
              color: Color(0xFF22364A),
              fontWeight: FontWeight.w800,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 10),
          if (items.isEmpty)
            const Text(
              'No recent transactions.',
              style: TextStyle(color: Color(0xFF5E7389), fontWeight: FontWeight.w600),
            )
          else
            for (var i = 0; i < items.length; i++)
              Padding(
                padding: EdgeInsets.only(bottom: i == items.length - 1 ? 0 : 9),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(13),
                    color: const Color(0xFFF7FBFD),
                    border: Border.all(color: const Color(0xFFE0EAF1)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: _transactionColor(items[i]).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          _categoryIcon(items[i].category),
                          size: 18,
                          color: _transactionColor(items[i]),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              items[i].title,
                              style: const TextStyle(
                                color: Color(0xFF2A3D54),
                                fontWeight: FontWeight.w800,
                                fontSize: 13,
                              ),
                            ),
                            Text(
                              '${items[i].category} • ${items[i].dateLabel}',
                              style: const TextStyle(
                                color: Color(0xFF6B7F95),
                                fontWeight: FontWeight.w600,
                                fontSize: 11.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '${items[i].isExpense ? '-' : '+'} $currencyCode ${items[i].amount.toStringAsFixed(3)}',
                        style: TextStyle(
                          color: items[i].isExpense ? const Color(0xFFE05A5F) : const Color(0xFF0E8E83),
                          fontWeight: FontWeight.w800,
                          fontSize: 12.5,
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

class _RingSection extends StatelessWidget {
  const _RingSection({required this.total, required this.remaining, required this.values, required this.currencyCode});

  final double total;
  final double remaining;
  final List<double> values;
  final String currencyCode;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 178,
      height: 178,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(size: const Size(178, 178), painter: _DonutPainter(values: values, colors: _ringColors)),
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 8, offset: const Offset(0, 3))],
            ),
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('$currencyCode ${remaining.toStringAsFixed(0)}', style: const TextStyle(color: Color(0xFF2E4766), fontWeight: FontWeight.w800, fontSize: 17)),
                Text('of $currencyCode ${total.toStringAsFixed(0)}', style: const TextStyle(color: Color(0xFF718096), fontWeight: FontWeight.w600, fontSize: 11.5)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DonutPainter extends CustomPainter {
  const _DonutPainter({required this.values, required this.colors});

  final List<double> values;
  final List<Color> colors;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 8;
    const stroke = 20.0;

    final total = values.fold<double>(0, (sum, item) => sum + item);
    final basePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.butt
      ..strokeWidth = stroke
      ..color = const Color(0xFFE8EEF3);

    canvas.drawCircle(center, radius, basePaint);

    if (total <= 0) return;

    var start = -math.pi / 2;
    for (var i = 0; i < values.length; i++) {
      final sweep = (values[i] / total) * (2 * math.pi);
      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.butt
        ..strokeWidth = stroke
        ..color = colors[i % colors.length];
      canvas.drawArc(Rect.fromCircle(center: center, radius: radius), start, sweep, false, paint);
      start += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutPainter oldDelegate) => oldDelegate.values != values;
}

class _PagerDot extends StatelessWidget {
  const _PagerDot({required this.active, required this.onTap});

  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: active,
      child: SizedBox(
        width: 28,
        height: 28,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: Center(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: active ? 11 : 7,
              height: active ? 11 : 7,
              decoration: BoxDecoration(
                color: active ? const Color(0xFF1CA5C6) : const Color(0xFFA6C0C8),
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

const List<Color> _ringColors = [
  Color(0xFFF5B75E),
  Color(0xFFE87A87),
  Color(0xFF8C80E0),
  Color(0xFF6F92F2),
  Color(0xFF58C2B6),
];

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
    case 'Travel':
      return Icons.flight_takeoff_rounded;
    default:
      return Icons.more_horiz_rounded;
  }
}

Color _transactionColor(TransactionItem item) {
  if (!item.isExpense) return const Color(0xFF0E8E83);
  switch (item.category) {
    case 'Food':
      return const Color(0xFFF5B75E);
    case 'Fuel':
      return const Color(0xFF58C2B6);
    case 'Shopping':
      return const Color(0xFF8C80E0);
    case 'Bills':
      return const Color(0xFF6F92F2);
    case 'Travel':
      return const Color(0xFF0EA5A4);
    default:
      return const Color(0xFF6B7F95);
  }
}

