import 'package:flutter/widgets.dart';

import 'budget_app_state.dart';

class BudgetStateScope extends InheritedNotifier<BudgetAppState> {
  const BudgetStateScope({
    super.key,
    required BudgetAppState state,
    required super.child,
  }) : super(notifier: state);

  static BudgetAppState of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<BudgetStateScope>();
    assert(scope != null, 'BudgetStateScope not found in context');
    return scope!.notifier!;
  }

  static BudgetAppState read(BuildContext context) {
    final element = context.getElementForInheritedWidgetOfExactType<BudgetStateScope>();
    final scope = element?.widget as BudgetStateScope?;
    assert(scope != null, 'BudgetStateScope not found in context');
    return scope!.notifier!;
  }

  static BudgetAppState? maybeOf(BuildContext context) {
    final element = context.getElementForInheritedWidgetOfExactType<BudgetStateScope>();
    final scope = element?.widget as BudgetStateScope?;
    return scope?.notifier;
  }
}
