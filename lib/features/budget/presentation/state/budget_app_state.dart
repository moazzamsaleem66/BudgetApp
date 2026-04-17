import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../data/local/local_budget_database.dart';
import '../../data/models/budget_models.dart';
import '../../data/repositories/mock_budget_repository.dart';

class BudgetAppState extends ChangeNotifier {
  final MockBudgetRepository _repository;
  final String _userId;

  String _selectedMonth;
  String _selectedTransactionFilter = 'Today';
  String _transactionSearchQuery = '';
  String _selectedSortOption = 'Newest first';
  String? _selectedCategoryFilter;
  String? _selectedPaymentFilter;
  double _monthlySavingTarget = 300;
  String _selectedCurrency = 'Kuwaiti Dinar (KD)';
  String _selectedLanguage = 'English';
  bool _securityEnabled = true;
  bool _notificationsEnabled = true;
  int _activeSavingsGoals = 3;
  final Map<String, List<TransactionItem>> _manualTransactionsByMonth = {};
  bool _isHydrated = false;

  String get selectedMonth => _selectedMonth;
  String get selectedTransactionFilter => _selectedTransactionFilter;
  String get transactionSearchQuery => _transactionSearchQuery;
  String get selectedSortOption => _selectedSortOption;
  String? get selectedCategoryFilter => _selectedCategoryFilter;
  String? get selectedPaymentFilter => _selectedPaymentFilter;
  double get monthlySavingTarget => _monthlySavingTarget;
  String get selectedCurrency => _selectedCurrency;
  String get selectedLanguage => _selectedLanguage;
  bool get securityEnabled => _securityEnabled;
  bool get notificationsEnabled => _notificationsEnabled;
  int get activeSavingsGoals => _activeSavingsGoals;
  bool get isHydrated => _isHydrated;
  String get currencyCode {
    final match = RegExp(r'\(([A-Z]{2,5})\)').firstMatch(_selectedCurrency);
    return match?.group(1) ?? 'KD';
  }

  List<String> get months => _repository.getAvailableMonths();

  BudgetAppState._init({MockBudgetRepository? repository})
      : _repository = repository ?? const MockBudgetRepository(),
        _userId = FirebaseAuth.instance.currentUser?.uid ??
            (repository ?? const MockBudgetRepository())
                .getProfileOverview()
                .email
                .trim()
                .toLowerCase(),
        _selectedMonth =
            (repository ?? const MockBudgetRepository()).getAvailableMonths().first {
    _hydrateFromLocalDb();
  }

  factory BudgetAppState({MockBudgetRepository? repository}) {
    return BudgetAppState._init(repository: repository);
  }

  BudgetSummary get summary => _repository.getSummary(_selectedMonth);
  List<BudgetCategory> get categories => _repository.getCategories(_selectedMonth);
  List<TransactionItem> get recentTransactions {
    final manual = _manualTransactionsByMonth[_selectedMonth] ?? const <TransactionItem>[];
    final seeded = _repository.getRecentTransactions(_selectedMonth);
    return [...manual, ...seeded];
  }

  List<String> get transactionFilters => const [
        'Today',
        'This week',
        'This month',
        'By category',
        'By payment',
      ];

  List<String> get sortOptions => const [
        'Newest first',
        'Oldest first',
        'Amount high-low',
        'Amount low-high',
      ];

  List<String> get availableCategories {
    final all = _allTransactionsForSelectedMonth();
    final values = all.map((item) => item.category).toSet().toList()..sort();
    return ['All', ...values];
  }

  List<String> get availablePaymentMethods {
    final all = _allTransactionsForSelectedMonth();
    final values = all.map((item) => item.paymentMethod).toSet().toList()..sort();
    return ['All', ...values];
  }

  int get activeAdvancedFilterCount {
    var count = 0;
    if (_transactionSearchQuery.isNotEmpty) count++;
    if (_selectedCategoryFilter != null) count++;
    if (_selectedPaymentFilter != null) count++;
    if (_selectedSortOption != 'Newest first') count++;
    return count;
  }

  List<TransactionItem> get filteredTransactions {
    var items = _allTransactionsForSelectedMonth();

    switch (_selectedTransactionFilter) {
      case 'Today':
        items = items
            .where((item) => item.dateLabel.toLowerCase().contains('today'))
            .toList();
        break;
      case 'This week':
        items = items
            .where(
              (item) => item.dateLabel.toLowerCase().contains('today') ||
                  item.dateLabel.toLowerCase().contains('this week'),
            )
            .toList();
        break;
      case 'This month':
      case 'By category':
      case 'By payment':
      default:
        break;
    }

    if (_transactionSearchQuery.isNotEmpty) {
      final query = _transactionSearchQuery.toLowerCase();
      items = items
          .where(
            (item) => item.title.toLowerCase().contains(query) ||
                item.category.toLowerCase().contains(query),
          )
          .toList();
    }

    if (_selectedCategoryFilter != null) {
      items =
          items.where((item) => item.category == _selectedCategoryFilter).toList();
    }

    if (_selectedPaymentFilter != null) {
      items = items
          .where((item) => item.paymentMethod == _selectedPaymentFilter)
          .toList();
    }

    switch (_selectedSortOption) {
      case 'Oldest first':
        items = items.reversed.toList();
        break;
      case 'Amount high-low':
        items.sort((a, b) => b.amount.compareTo(a.amount));
        break;
      case 'Amount low-high':
        items.sort((a, b) => a.amount.compareTo(b.amount));
        break;
      case 'Newest first':
      default:
        break;
    }

    return items;
  }

  bool addExpenseFromPayload(Map<String, dynamic>? payload) {
    if (payload == null) return false;
    final amount = payload['amount'];
    final category = (payload['category'] ?? '').toString().trim();
    final paymentMethod = (payload['paymentMethod'] ?? '').toString().trim();
    final note = (payload['note'] ?? '').toString().trim();
    final dateRaw = (payload['date'] ?? '').toString().trim();

    if (amount is! num || amount <= 0 || category.isEmpty || paymentMethod.isEmpty || dateRaw.isEmpty) {
      return false;
    }

    final parsedDate = DateTime.tryParse(dateRaw) ?? DateTime.now();
    final dateLabel = _toDateLabel(parsedDate);
    final tx = TransactionItem(
      id: 'u_${DateTime.now().microsecondsSinceEpoch}',
      title: note.isNotEmpty ? note : '$category Expense',
      category: category,
      dateLabel: dateLabel,
      amount: amount.toDouble(),
      paymentMethod: paymentMethod,
      isExpense: true,
    );

    final list = _manualTransactionsByMonth.putIfAbsent(_selectedMonth, () => <TransactionItem>[]);
    list.insert(0, tx);
    _persistTransaction(month: _selectedMonth, transaction: tx);
    notifyListeners();
    return true;
  }

  bool addIncomeFromPayload(Map<String, dynamic>? payload) {
    if (payload == null) return false;
    final amount = payload['amount'];
    final category = (payload['category'] ?? '').toString().trim();
    final paymentMethod = (payload['paymentMethod'] ?? '').toString().trim();
    final note = (payload['note'] ?? '').toString().trim();
    final dateRaw = (payload['date'] ?? '').toString().trim();

    if (amount is! num || amount <= 0 || category.isEmpty || paymentMethod.isEmpty || dateRaw.isEmpty) {
      return false;
    }

    final parsedDate = DateTime.tryParse(dateRaw) ?? DateTime.now();
    final dateLabel = _toDateLabel(parsedDate);
    final tx = TransactionItem(
      id: 'u_${DateTime.now().microsecondsSinceEpoch}',
      title: note.isNotEmpty ? note : '$category Income',
      category: category,
      dateLabel: dateLabel,
      amount: amount.toDouble(),
      paymentMethod: paymentMethod,
      isExpense: false,
    );

    final list = _manualTransactionsByMonth.putIfAbsent(_selectedMonth, () => <TransactionItem>[]);
    list.insert(0, tx);
    _persistTransaction(month: _selectedMonth, transaction: tx);
    notifyListeners();
    return true;
  }

  AnalyticsSnapshot get analytics => _repository.getAnalytics(_selectedMonth);

  ProfileOverview get profile {
    final base = _repository.getProfileOverview();
    final formattedTarget = _monthlySavingTarget % 1 == 0
        ? _monthlySavingTarget.toInt().toString()
        : _monthlySavingTarget.toStringAsFixed(1);
    final t = _translatedProfileLabels();

    final updatedItems = base.items
        .map(
          (item) => item.title.toLowerCase() == 'monthly target'
              ? ProfileItem(
                  title: t['monthly_target_title']!,
                  subtitle: '${t['save_prefix']!} $currencyCode $formattedTarget/${t['per_month']!}',
                  iconName: item.iconName,
                )
              : item.title.toLowerCase() == 'currency selection'
                  ? ProfileItem(
                      title: t['currency_title']!,
                      subtitle: _selectedCurrency,
                      iconName: item.iconName,
                    )
                  : item.title.toLowerCase() == 'language'
                      ? ProfileItem(
                          title: t['language_title']!,
                          subtitle: _selectedLanguage,
                          iconName: item.iconName,
                        )
                      : item.title.toLowerCase() == 'security'
                          ? ProfileItem(
                              title: t['security_title']!,
                              subtitle: _securityEnabled
                                  ? t['security_on']!
                                  : t['security_off']!,
                              iconName: item.iconName,
                            )
                          : item.title.toLowerCase() ==
                                  'notification preferences'
                              ? ProfileItem(
                                  title: t['notifications_title']!,
                                  subtitle: _notificationsEnabled
                                      ? t['notifications_on']!
                                      : t['notifications_off']!,
                                  iconName: item.iconName,
                                )
                              : item.title.toLowerCase() == 'savings goals'
                                  ? ProfileItem(
                                      title: t['savings_goals_title']!,
                                      subtitle: '$_activeSavingsGoals ${t['active_goals']!}',
                                      iconName: item.iconName,
                                    )
              : item,
        )
        .toList();

    return ProfileOverview(
      name: base.name,
      email: base.email,
      items: updatedItems,
    );
  }

  void selectMonth(String month) {
    if (_selectedMonth == month) return;
    _selectedMonth = month;
    notifyListeners();
  }

  void selectTransactionFilter(String filter) {
    if (_selectedTransactionFilter == filter) return;
    _selectedTransactionFilter = filter;
    notifyListeners();
  }

  void setSearchQuery(String value) {
    final next = value.trim();
    if (_transactionSearchQuery == next) return;
    _transactionSearchQuery = next;
    notifyListeners();
  }

  void setSortOption(String value) {
    if (_selectedSortOption == value) return;
    _selectedSortOption = value;
    notifyListeners();
  }

  void setCategoryFilter(String? value) {
    final normalized = (value == null || value == 'All') ? null : value;
    if (_selectedCategoryFilter == normalized) return;
    _selectedCategoryFilter = normalized;
    notifyListeners();
  }

  void setPaymentFilter(String? value) {
    final normalized = (value == null || value == 'All') ? null : value;
    if (_selectedPaymentFilter == normalized) return;
    _selectedPaymentFilter = normalized;
    notifyListeners();
  }

  void setMonthlySavingTarget(double amount) {
    if (amount <= 0) return;
    if (_monthlySavingTarget == amount) return;
    _monthlySavingTarget = amount;
    _persistMonthlyTarget(amount);
    notifyListeners();
  }

  void setCurrency(String currency) {
    final next = currency.trim();
    if (next.isEmpty || _selectedCurrency == next) return;
    _selectedCurrency = next;
    _persistSetting('currency', next);
    notifyListeners();
  }

  void setLanguage(String language) {
    final next = language.trim();
    if (next.isEmpty || _selectedLanguage == next) return;
    _selectedLanguage = next;
    _persistSetting('language', next);
    notifyListeners();
  }

  void setSecurityEnabled(bool enabled) {
    if (_securityEnabled == enabled) return;
    _securityEnabled = enabled;
    _persistSetting('security_enabled', enabled ? '1' : '0');
    notifyListeners();
  }

  void setNotificationsEnabled(bool enabled) {
    if (_notificationsEnabled == enabled) return;
    _notificationsEnabled = enabled;
    _persistSetting('notifications_enabled', enabled ? '1' : '0');
    notifyListeners();
  }

  void setActiveSavingsGoals(int count) {
    if (count <= 0 || _activeSavingsGoals == count) return;
    _activeSavingsGoals = count;
    _persistSetting('active_savings_goals', count.toString());
    notifyListeners();
  }

  void clearAdvancedFilters() {
    _transactionSearchQuery = '';
    _selectedSortOption = 'Newest first';
    _selectedCategoryFilter = null;
    _selectedPaymentFilter = null;
    notifyListeners();
  }

  List<TransactionItem> _allTransactionsForSelectedMonth() {
    final manual = _manualTransactionsByMonth[_selectedMonth] ?? const <TransactionItem>[];
    final seeded = _repository.getTransactions(_selectedMonth);
    return [...manual, ...seeded];
  }

  String _toDateLabel(DateTime date) {
    final now = DateTime.now();
    final isToday = date.year == now.year && date.month == now.month && date.day == now.day;
    if (isToday) {
      final hour = date.hour % 12 == 0 ? 12 : date.hour % 12;
      final minute = date.minute.toString().padLeft(2, '0');
      final period = date.hour >= 12 ? 'PM' : 'AM';
      return 'Today, $hour:$minute $period';
    }
    const monthNames = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return 'This month, ${date.day} ${monthNames[date.month - 1]}';
  }

  Future<void> _hydrateFromLocalDb() async {
    try {
      final persisted = await LocalBudgetDatabase.instance.readPersistedState(
        userId: _userId,
      );
      _manualTransactionsByMonth
        ..clear()
        ..addAll(persisted.transactionsByMonth);

      if (persisted.monthlySavingTarget != null && persisted.monthlySavingTarget! > 0) {
        _monthlySavingTarget = persisted.monthlySavingTarget!;
      }
      final settings = persisted.settings;
      _selectedCurrency =
          settings['${_userId}_currency'] ?? _selectedCurrency;
      _selectedLanguage =
          settings['${_userId}_language'] ?? _selectedLanguage;
      _securityEnabled =
          (settings['${_userId}_security_enabled'] ?? (_securityEnabled ? '1' : '0')) == '1';
      _notificationsEnabled =
          (settings['${_userId}_notifications_enabled'] ??
                  (_notificationsEnabled ? '1' : '0')) ==
              '1';
      _activeSavingsGoals = int.tryParse(
            settings['${_userId}_active_savings_goals'] ?? '',
          ) ??
          _activeSavingsGoals;
    } catch (_) {
      // Ignore local DB read failures and continue with in-memory defaults.
    } finally {
      _isHydrated = true;
      notifyListeners();
    }
  }

  void _persistTransaction({
    required String month,
    required TransactionItem transaction,
  }) {
    LocalBudgetDatabase.instance
        .upsertTransaction(userId: _userId, month: month, item: transaction)
        .catchError((_) {});
  }

  void _persistMonthlyTarget(double amount) {
    LocalBudgetDatabase.instance
        .saveMonthlyTarget(userId: _userId, target: amount)
        .catchError((_) {});
  }

  void _persistSetting(String key, String value) {
    LocalBudgetDatabase.instance
        .saveUserSetting(userId: _userId, key: key, value: value)
        .catchError((_) {});
  }

  Map<String, String> _translatedProfileLabels() {
    switch (_selectedLanguage.toLowerCase()) {
      case 'arabic':
        return const {
          'monthly_target_title': 'الهدف الشهري',
          'currency_title': 'اختيار العملة',
          'language_title': 'اللغة',
          'security_title': 'الأمان',
          'notifications_title': 'تفضيلات الإشعارات',
          'savings_goals_title': 'أهداف الادخار',
          'save_prefix': 'ادخر',
          'per_month': 'شهر',
          'security_on': 'البصمة + الرقم السري مفعل',
          'security_off': 'الأمان غير مفعل',
          'notifications_on': 'التنبيهات والتذكيرات مفعلة',
          'notifications_off': 'التنبيهات والتذكيرات متوقفة',
          'active_goals': 'أهداف نشطة',
        };
      case 'urdu':
        return const {
          'monthly_target_title': 'ماہانہ ہدف',
          'currency_title': 'کرنسی سلیکشن',
          'language_title': 'زبان',
          'security_title': 'سیکیورٹی',
          'notifications_title': 'نوٹیفکیشن ترجیحات',
          'savings_goals_title': 'سیونگ گولز',
          'save_prefix': 'بچت',
          'per_month': 'ماہ',
          'security_on': 'بایومیٹرک + پن فعال',
          'security_off': 'سیکیورٹی غیر فعال',
          'notifications_on': 'الارٹس اور ریمائنڈرز آن',
          'notifications_off': 'الارٹس اور ریمائنڈرز آف',
          'active_goals': 'ایکٹو گولز',
        };
      case 'hindi':
        return const {
          'monthly_target_title': 'मासिक लक्ष्य',
          'currency_title': 'करेंसी चयन',
          'language_title': 'भाषा',
          'security_title': 'सुरक्षा',
          'notifications_title': 'नोटिफिकेशन प्राथमिकताएं',
          'savings_goals_title': 'सेविंग लक्ष्य',
          'save_prefix': 'बचत',
          'per_month': 'माह',
          'security_on': 'बायोमेट्रिक + पिन चालू',
          'security_off': 'सुरक्षा बंद',
          'notifications_on': 'अलर्ट और रिमाइंडर चालू',
          'notifications_off': 'अलर्ट और रिमाइंडर बंद',
          'active_goals': 'सक्रिय लक्ष्य',
        };
      case 'english':
      default:
        return const {
          'monthly_target_title': 'Monthly target',
          'currency_title': 'Currency selection',
          'language_title': 'Language',
          'security_title': 'Security',
          'notifications_title': 'Notification preferences',
          'savings_goals_title': 'Savings goals',
          'save_prefix': 'Save',
          'per_month': 'month',
          'security_on': 'Biometric + PIN enabled',
          'security_off': 'Security disabled',
          'notifications_on': 'Alerts and reminders on',
          'notifications_off': 'Alerts and reminders off',
          'active_goals': 'active goals',
        };
    }
  }
}
