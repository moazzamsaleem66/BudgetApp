import '../models/budget_models.dart';

class MockBudgetRepository {
  const MockBudgetRepository();

  static const List<String> _months = ['April 2026', 'March 2026'];

  static const Map<String, BudgetSummary> _summaries = {
    'April 2026': BudgetSummary(
      monthLabel: 'April 2026',
      totalBudget: 1200.000,
      totalSpent: 860.200,
      remainingBudget: 339.800,
      userName: 'Moazzam',
      greeting: 'Good evening',
    ),
    'March 2026': BudgetSummary(
      monthLabel: 'March 2026',
      totalBudget: 1100.000,
      totalSpent: 780.500,
      remainingBudget: 319.500,
      userName: 'Moazzam',
      greeting: 'Good evening',
    ),
  };

  static const Map<String, List<BudgetCategory>> _categoriesByMonth = {
    'April 2026': [
      BudgetCategory(name: 'Food', spent: 122, limit: 200),
      BudgetCategory(name: 'Fuel', spent: 58, limit: 120),
      BudgetCategory(name: 'Shopping', spent: 190, limit: 220),
      BudgetCategory(name: 'Bills', spent: 138, limit: 160),
      BudgetCategory(name: 'Travel', spent: 70, limit: 130),
      BudgetCategory(name: 'Others', spent: 32, limit: 90),
    ],
    'March 2026': [
      BudgetCategory(name: 'Food', spent: 110, limit: 200),
      BudgetCategory(name: 'Fuel', spent: 50, limit: 120),
      BudgetCategory(name: 'Shopping', spent: 150, limit: 210),
      BudgetCategory(name: 'Bills', spent: 132, limit: 160),
      BudgetCategory(name: 'Travel', spent: 64, limit: 130),
      BudgetCategory(name: 'Others', spent: 28, limit: 80),
    ],
  };

  static const Map<String, List<TransactionItem>> _recentByMonth = {
    'April 2026': [
      TransactionItem(
        id: 'r1',
        title: 'Dinner with team',
        category: 'Food',
        dateLabel: 'Today, 8:40 PM',
        amount: 12.500,
        paymentMethod: 'Card',
      ),
      TransactionItem(
        id: 'r2',
        title: 'Fuel refill',
        category: 'Fuel',
        dateLabel: 'Today, 6:20 PM',
        amount: 8.100,
        paymentMethod: 'Cash',
      ),
      TransactionItem(
        id: 'r3',
        title: 'Electricity Bill',
        category: 'Bills',
        dateLabel: 'Yesterday, 4:00 PM',
        amount: 25.000,
        paymentMethod: 'Bank Transfer',
      ),
    ],
    'March 2026': [
      TransactionItem(
        id: 'mr1',
        title: 'Lunch',
        category: 'Food',
        dateLabel: 'Yesterday, 1:30 PM',
        amount: 5.700,
        paymentMethod: 'Card',
      ),
      TransactionItem(
        id: 'mr2',
        title: 'Car wash',
        category: 'Travel',
        dateLabel: 'Mon, 9:00 AM',
        amount: 3.200,
        paymentMethod: 'Cash',
      ),
      TransactionItem(
        id: 'mr3',
        title: 'Phone bill',
        category: 'Bills',
        dateLabel: 'Sun, 2:00 PM',
        amount: 10.000,
        paymentMethod: 'Bank Transfer',
      ),
    ],
  };

  static const Map<String, List<TransactionItem>> _transactionsByMonth = {
    'April 2026': [
      TransactionItem(
        id: 't1',
        title: 'Star Coffee',
        category: 'Food',
        dateLabel: 'Today, 8:40 AM',
        amount: 2.250,
        paymentMethod: 'Card',
      ),
      TransactionItem(
        id: 't2',
        title: 'Gas Station',
        category: 'Fuel',
        dateLabel: 'Today, 6:00 PM',
        amount: 7.400,
        paymentMethod: 'Cash',
      ),
      TransactionItem(
        id: 't3',
        title: 'Internet Bill',
        category: 'Bills',
        dateLabel: 'This week, Sat 2:10 PM',
        amount: 15.000,
        paymentMethod: 'Bank Transfer',
      ),
      TransactionItem(
        id: 't4',
        title: 'Grocery',
        category: 'Food',
        dateLabel: 'This month, 3 Apr',
        amount: 24.500,
        paymentMethod: 'Card',
      ),
      TransactionItem(
        id: 't5',
        title: 'Salary',
        category: 'Income',
        dateLabel: 'This month, 1 Apr',
        amount: 450.000,
        paymentMethod: 'Bank Transfer',
        isExpense: false,
      ),
      TransactionItem(
        id: 't6',
        title: 'Movie night',
        category: 'Entertainment',
        dateLabel: 'This week, Fri 9:15 PM',
        amount: 6.750,
        paymentMethod: 'Card',
      ),
      TransactionItem(
        id: 't7',
        title: 'Pharmacy',
        category: 'Health',
        dateLabel: 'This month, 6 Apr',
        amount: 12.400,
        paymentMethod: 'Cash',
      ),
      TransactionItem(
        id: 't8',
        title: 'Online course',
        category: 'Education',
        dateLabel: 'This month, 4 Apr',
        amount: 18.000,
        paymentMethod: 'Card',
      ),
    ],
    'March 2026': [
      TransactionItem(
        id: 'm1',
        title: 'Bakery',
        category: 'Food',
        dateLabel: 'Today, 10:20 AM',
        amount: 1.900,
        paymentMethod: 'Card',
      ),
      TransactionItem(
        id: 'm2',
        title: 'Fuel pump',
        category: 'Fuel',
        dateLabel: 'This week, Thu 7:00 PM',
        amount: 9.100,
        paymentMethod: 'Cash',
      ),
      TransactionItem(
        id: 'm3',
        title: 'Streaming',
        category: 'Bills',
        dateLabel: 'This month, 9 Mar',
        amount: 4.900,
        paymentMethod: 'Card',
      ),
      TransactionItem(
        id: 'm4',
        title: 'Salary',
        category: 'Income',
        dateLabel: 'This month, 1 Mar',
        amount: 430.000,
        paymentMethod: 'Bank Transfer',
        isExpense: false,
      ),
      TransactionItem(
        id: 'm5',
        title: 'Cinema',
        category: 'Entertainment',
        dateLabel: 'This week, Tue 8:10 PM',
        amount: 5.250,
        paymentMethod: 'Card',
      ),
      TransactionItem(
        id: 'm6',
        title: 'Clinic visit',
        category: 'Health',
        dateLabel: 'This month, 11 Mar',
        amount: 14.000,
        paymentMethod: 'Cash',
      ),
      TransactionItem(
        id: 'm7',
        title: 'Books',
        category: 'Education',
        dateLabel: 'This month, 14 Mar',
        amount: 9.500,
        paymentMethod: 'Card',
      ),
    ],
  };

  static const Map<String, AnalyticsSnapshot> _analyticsByMonth = {
    'April 2026': AnalyticsSnapshot(
      monthlyLine: [0.85, 0.62, 0.70, 0.45, 0.58, 0.38, 0.30],
      weeklyBars: [72, 45, 88, 56, 62, 39, 70],
      pieSlices: [0.35, 0.25, 0.2, 0.2],
      insights: [
        InsightItem(
          title: 'Highest expense category',
          message: 'Shopping is your highest expense this month.',
        ),
        InsightItem(
          title: 'Savings trend',
          message: 'You saved 9% more compared to last month.',
        ),
        InsightItem(
          title: 'Insight',
          message: 'You spent 18% more on food this week.',
        ),
        InsightItem(
          title: 'Insight',
          message: 'Fuel spending is within budget.',
        ),
        InsightItem(title: 'Bill alert', message: 'Bills due in 3 days.'),
      ],
    ),
    'March 2026': AnalyticsSnapshot(
      monthlyLine: [0.80, 0.66, 0.60, 0.52, 0.47, 0.43, 0.40],
      weeklyBars: [60, 48, 76, 58, 51, 45, 63],
      pieSlices: [0.30, 0.22, 0.28, 0.2],
      insights: [
        InsightItem(
          title: 'Highest expense category',
          message: 'Bills were the highest in March.',
        ),
        InsightItem(
          title: 'Savings trend',
          message: 'You improved savings by 6% compared to February.',
        ),
      ],
    ),
  };

  List<String> getAvailableMonths() => _months;

  BudgetSummary getSummary(String month) => _summaries[month] ?? _summaries[_months.first]!;

  List<BudgetCategory> getCategories(String month) => _categoriesByMonth[month] ?? _categoriesByMonth[_months.first]!;

  List<TransactionItem> getRecentTransactions(String month) => _recentByMonth[month] ?? _recentByMonth[_months.first]!;

  List<TransactionItem> getTransactions(String month) => _transactionsByMonth[month] ?? _transactionsByMonth[_months.first]!;

  AnalyticsSnapshot getAnalytics(String month) => _analyticsByMonth[month] ?? _analyticsByMonth[_months.first]!;

  ProfileOverview getProfileOverview() {
    return const ProfileOverview(
      name: 'Moazzam',
      email: 'moazzam@email.com',
      items: [
        ProfileItem(
          title: 'Monthly target',
          subtitle: 'Save KD 300/month',
          iconName: 'flag',
        ),
        ProfileItem(
          title: 'Currency selection',
          subtitle: 'Kuwaiti Dinar (KD)',
          iconName: 'currency',
        ),
        ProfileItem(
          title: 'Language',
          subtitle: 'English',
          iconName: 'language',
        ),
        ProfileItem(
          title: 'Security',
          subtitle: 'Biometric + PIN enabled',
          iconName: 'lock',
        ),
        ProfileItem(
          title: 'Notification preferences',
          subtitle: 'Alerts and reminders on',
          iconName: 'notifications',
        ),
        ProfileItem(
          title: 'Savings goals',
          subtitle: '3 active goals',
          iconName: 'stars',
        ),
        ProfileItem(
          title: 'Premium',
          subtitle: 'Upgrade for smart recommendations',
          iconName: 'premium',
        ),
      ],
    );
  }
}
