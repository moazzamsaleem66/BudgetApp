import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import '../models/budget_models.dart';

class PersistedBudgetState {
  const PersistedBudgetState({
    required this.transactionsByMonth,
    required this.monthlySavingTarget,
    required this.settings,
  });

  final Map<String, List<TransactionItem>> transactionsByMonth;
  final double? monthlySavingTarget;
  final Map<String, String> settings;
}

class LocalBudgetDatabase {
  LocalBudgetDatabase._();

  static final LocalBudgetDatabase instance = LocalBudgetDatabase._();

  static const _dbName = 'pocketboss_local.db';
  static const _dbVersion = 2;
  static const _transactionsTable = 'transactions';
  static const _settingsTable = 'user_settings';

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;

    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, _dbName);
    _database = await openDatabase(
      path,
      version: _dbVersion,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $_transactionsTable (
            id TEXT PRIMARY KEY,
            user_id TEXT NOT NULL,
            month TEXT NOT NULL,
            title TEXT NOT NULL,
            category TEXT NOT NULL,
            date_label TEXT NOT NULL,
            amount REAL NOT NULL,
            payment_method TEXT NOT NULL,
            is_expense INTEGER NOT NULL,
            created_at TEXT NOT NULL
          )
        ''');

        await db.execute('''
          CREATE TABLE $_settingsTable (
            user_id TEXT NOT NULL,
            key TEXT PRIMARY KEY,
            value TEXT NOT NULL
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute(
            'ALTER TABLE $_transactionsTable ADD COLUMN user_id TEXT NOT NULL DEFAULT "default_user"',
          );
          await db.execute(
            'ALTER TABLE $_settingsTable ADD COLUMN user_id TEXT NOT NULL DEFAULT "default_user"',
          );
        }
      },
    );

    return _database!;
  }

  Future<PersistedBudgetState> readPersistedState({
    required String userId,
  }) async {
    final db = await database;
    final scopedMonthlyTargetKey = '${userId}_monthly_target';

    final txRows = await db.query(
      _transactionsTable,
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'created_at DESC',
    );
    final grouped = <String, List<TransactionItem>>{};
    for (final row in txRows) {
      final month = (row['month'] as String?) ?? 'April 2026';
      grouped.putIfAbsent(month, () => <TransactionItem>[]).add(
            TransactionItem(
              id: (row['id'] as String?) ?? '',
              title: (row['title'] as String?) ?? '',
              category: (row['category'] as String?) ?? '',
              dateLabel: (row['date_label'] as String?) ?? '',
              amount: (row['amount'] as num?)?.toDouble() ?? 0,
              paymentMethod: (row['payment_method'] as String?) ?? 'Card',
              isExpense: ((row['is_expense'] as num?)?.toInt() ?? 1) == 1,
            ),
          );
    }

    final settingRows = await db.query(
      _settingsTable,
      where: 'user_id = ?',
      whereArgs: [userId],
    );
    final settings = <String, String>{};
    for (final row in settingRows) {
      final key = (row['key'] as String?) ?? '';
      final value = (row['value'] as String?) ?? '';
      if (key.isNotEmpty) {
        settings[key] = value;
      }
    }

    double? monthlyTarget;
    if (settings.containsKey(scopedMonthlyTargetKey)) {
      monthlyTarget = double.tryParse(settings[scopedMonthlyTargetKey] ?? '');
    }

    return PersistedBudgetState(
      transactionsByMonth: grouped,
      monthlySavingTarget: monthlyTarget,
      settings: settings,
    );
  }

  Future<void> upsertTransaction({
    required String userId,
    required String month,
    required TransactionItem item,
  }) async {
    final db = await database;
    await db.insert(
      _transactionsTable,
      {
        'id': item.id,
        'user_id': userId,
        'month': month,
        'title': item.title,
        'category': item.category,
        'date_label': item.dateLabel,
        'amount': item.amount,
        'payment_method': item.paymentMethod,
        'is_expense': item.isExpense ? 1 : 0,
        'created_at': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> saveMonthlyTarget({
    required String userId,
    required double target,
  }) async {
    final db = await database;
    final scopedMonthlyTargetKey = '${userId}_monthly_target';
    await db.insert(
      _settingsTable,
      {
        'user_id': userId,
        'key': scopedMonthlyTargetKey,
        'value': target.toString(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> saveUserSetting({
    required String userId,
    required String key,
    required String value,
  }) async {
    final db = await database;
    final scopedKey = '${userId}_$key';
    await db.insert(
      _settingsTable,
      {
        'user_id': userId,
        'key': scopedKey,
        'value': value,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}
