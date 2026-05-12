import 'package:flutter/material.dart';

import '../../shared/theme/paxpayment_colors.dart';
import 'account_tab.dart';
import 'explore_tab.dart';
import 'home_tab.dart';
import 'sales_tab.dart';

/// Main app shell after login: bottom navigation (Home, Sales, Account, Explore).
class MenuShell extends StatefulWidget {
  const MenuShell({super.key});

  @override
  State<MenuShell> createState() => _MenuShellState();
}

class _MenuShellState extends State<MenuShell> {
  int _index = 0;

  static final _pages = <Widget>[
    const HomeTab(),
    const SalesTab(),
    const AccountTab(),
    const ExploreTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: _pages,
      ),
      bottomNavigationBar: NavigationBarTheme(
        data: NavigationBarThemeData(
          indicatorColor: PaxPaymentColors.primaryBlue.withValues(alpha: 0.12),
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 12,
                color: PaxPaymentColors.primaryBlue,
              );
            }
            return const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 12,
              color: PaxPaymentColors.mediumGray,
            );
          }),
        ),
        child: NavigationBar(
          height: 64,
          backgroundColor: PaxPaymentColors.white,
          surfaceTintColor: Colors.transparent,
          shadowColor: Colors.black12,
          elevation: 8,
          selectedIndex: _index,
          onDestinationSelected: (i) => setState(() => _index = i),
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home_rounded),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.bar_chart_outlined),
              selectedIcon: Icon(Icons.bar_chart_rounded),
              label: 'Sales',
            ),
            NavigationDestination(
              icon: Icon(Icons.account_circle_outlined),
              selectedIcon: Icon(Icons.account_circle_rounded),
              label: 'Account',
            ),
            NavigationDestination(
              icon: Icon(Icons.explore_outlined),
              selectedIcon: Icon(Icons.explore_rounded),
              label: 'Explore',
            ),
          ],
        ),
      ),
    );
  }
}
