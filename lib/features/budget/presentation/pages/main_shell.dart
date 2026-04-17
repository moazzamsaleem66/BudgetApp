import 'package:flutter/material.dart';

import '../state/budget_app_state.dart';
import '../state/budget_state_scope.dart';
import 'analytics_screen.dart';
import 'budget_setup_screen.dart';
import 'home_dashboard_screen.dart';
import 'profile_screen.dart';
import 'transactions_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;
  late final BudgetAppState _state;

  @override
  void initState() {
    super.initState();
    _state = BudgetAppState();
  }

  @override
  void dispose() {
    _state.dispose();
    super.dispose();
  }

  late final List<Widget> _pages = [
    HomeDashboardScreen(onSelectTab: _onSelectTab),
    const TransactionsScreen(),
    const AnalyticsScreen(),
    BudgetSetupScreen(onSelectTab: _onSelectTab),
    const ProfileScreen(),
  ];

  void _onSelectTab(int value) {
    setState(() => _index = value);
  }

  @override
  Widget build(BuildContext context) {
    return BudgetStateScope(
      state: _state,
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F7F9),
        body: SafeArea(
          bottom: false,
          child: IndexedStack(
            index: _index,
            children: _pages,
          ),
        ),
        bottomNavigationBar: SafeArea(
          top: false,
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.transparent,
              border: Border(
                top: BorderSide(color: Color(0x14000000)),
              ),
            ),
            child: BottomNavigationBar(
              currentIndex: _index,
              onTap: _onSelectTab,
              type: BottomNavigationBarType.fixed,
              elevation: 0,
              backgroundColor: const Color(0xFFF7FBFB),
              selectedItemColor: const Color(0xFF0C8E6A),
              unselectedItemColor: const Color(0xFF526071),
              selectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 12,
              ),
              unselectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 11.5,
              ),
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home_outlined),
                  activeIcon: Icon(Icons.home),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.receipt_long_outlined),
                  activeIcon: Icon(Icons.receipt_long),
                  label: 'Transactions',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.insights_outlined),
                  activeIcon: Icon(Icons.insights),
                  label: 'Analytics',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.account_balance_wallet_outlined),
                  activeIcon: Icon(Icons.account_balance_wallet),
                  label: 'Budget',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person_outline),
                  activeIcon: Icon(Icons.person),
                  label: 'Profile',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
