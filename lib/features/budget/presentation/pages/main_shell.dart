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
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.fromLTRB(8, 4, 8, 8),
          child: SizedBox(
            height: 74,
            child: Row(
              children: [
                _GlassNavItem(
                  label: 'Home',
                  icon: Icons.home_outlined,
                  activeIcon: Icons.home,
                  selected: _index == 0,
                  onTap: () => _onSelectTab(0),
                ),
                _GlassNavItem(
                  label: 'Transactions',
                  icon: Icons.receipt_long_outlined,
                  activeIcon: Icons.receipt_long,
                  selected: _index == 1,
                  onTap: () => _onSelectTab(1),
                ),
                _GlassNavItem(
                  label: 'Analytics',
                  icon: Icons.insights_outlined,
                  activeIcon: Icons.insights,
                  selected: _index == 2,
                  onTap: () => _onSelectTab(2),
                ),
                _GlassNavItem(
                  label: 'Budget',
                  icon: Icons.account_balance_wallet_outlined,
                  activeIcon: Icons.account_balance_wallet,
                  selected: _index == 3,
                  onTap: () => _onSelectTab(3),
                ),
                _GlassNavItem(
                  label: 'Profile',
                  icon: Icons.person_outline,
                  activeIcon: Icons.person,
                  selected: _index == 4,
                  onTap: () => _onSelectTab(4),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _GlassNavItem extends StatelessWidget {
  const _GlassNavItem({
    required this.label,
    required this.icon,
    required this.activeIcon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final IconData activeIcon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    const activeColor = Color(0xFF111827);
    const inactiveColor = Color(0xFF263447);

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 3),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              color: Colors.transparent,
              border: Border.all(color: Colors.transparent),
            ),
            padding: const EdgeInsets.fromLTRB(4, 4, 4, 4),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  selected ? activeIcon : icon,
                  color: selected ? activeColor : inactiveColor.withValues(alpha: 0.82),
                  size: selected ? 21 : 20,
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: selected ? activeColor : inactiveColor.withValues(alpha: 0.92),
                    fontWeight: selected ? FontWeight.w900 : FontWeight.w800,
                    fontSize: selected ? 12.6 : 11.8,
                    letterSpacing: 0.24,
                    height: 1.0,
                    shadows: [
                      Shadow(
                        color: Colors.black.withValues(alpha: selected ? 0.12 : 0.06),
                        blurRadius: selected ? 2 : 1,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 2),
                const SizedBox(height: 2),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
