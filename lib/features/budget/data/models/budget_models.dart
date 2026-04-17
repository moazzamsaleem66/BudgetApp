class BudgetSummary {
  const BudgetSummary({
    required this.monthLabel,
    required this.totalBudget,
    required this.totalSpent,
    required this.remainingBudget,
    required this.userName,
    required this.greeting,
  });

  final String monthLabel;
  final double totalBudget;
  final double totalSpent;
  final double remainingBudget;
  final String userName;
  final String greeting;

  double get progress {
    if (totalBudget <= 0) return 0;
    final value = totalSpent / totalBudget;
    return value.clamp(0.0, 1.0);
  }
}

class BudgetCategory {
  const BudgetCategory({
    required this.name,
    required this.spent,
    required this.limit,
  });

  final String name;
  final double spent;
  final double limit;

  double get progress {
    if (limit <= 0) return 0;
    final value = spent / limit;
    return value.clamp(0.0, 1.0);
  }
}

class TransactionItem {
  const TransactionItem({
    required this.id,
    required this.title,
    required this.category,
    required this.dateLabel,
    required this.amount,
    required this.paymentMethod,
    this.isExpense = true,
  });

  final String id;
  final String title;
  final String category;
  final String dateLabel;
  final double amount;
  final String paymentMethod;
  final bool isExpense;
}

class InsightItem {
  const InsightItem({required this.title, required this.message});

  final String title;
  final String message;
}

class ProfileItem {
  const ProfileItem({
    required this.title,
    required this.subtitle,
    required this.iconName,
  });

  final String title;
  final String subtitle;
  final String iconName;
}

class ProfileOverview {
  const ProfileOverview({
    required this.name,
    required this.email,
    required this.items,
  });

  final String name;
  final String email;
  final List<ProfileItem> items;
}

class AnalyticsSnapshot {
  const AnalyticsSnapshot({
    required this.monthlyLine,
    required this.weeklyBars,
    required this.pieSlices,
    required this.insights,
  });

  final List<double> monthlyLine;
  final List<double> weeklyBars;
  final List<double> pieSlices;
  final List<InsightItem> insights;
}
