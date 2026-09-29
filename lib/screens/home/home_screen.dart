import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../widgets/app_drawer.dart';
import '../dashboard/dashboard_screen.dart';
import '../module/module_screen.dart';
import '../profile/profile_screen.dart';
import '../reports/reports_screen.dart';
import '../settings/settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({this.initialIndex = 0, super.key});
  final int initialIndex;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late int selectedIndex;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    selectedIndex = widget.initialIndex;
  }

  void openDrawerModule(AppModule module) {
    Navigator.pop(context);
    if (module == AppModule.customers || module == AppModule.services) {
      setState(() => selectedIndex = 1);
    } else if (module == AppModule.payments) {
      setState(() => selectedIndex = 2);
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => ModuleScreen(module: module)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // 3 consistent main tabs: Home | Customers | Payments
    final titles = ['Dashboard', 'Customers & Services', 'Payments'];

    final pages = [
      DashboardScreen(
        onNavigateToCustomers: () => setState(() => selectedIndex = 1),
        onNavigateToPayments: () => setState(() => selectedIndex = 2),
      ),
      const ModuleScreen(module: AppModule.customers, embedded: true),
      const ModuleScreen(module: AppModule.payments, embedded: true),
    ];

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.paper,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: AppColors.ink),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        title: Text(
          titles[selectedIndex],
          style: const TextStyle(
            color: AppColors.ink,
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
        actions:
            const [], // User requested: No notification bell in upper right
      ),
      drawer: TmdsDrawer(currentRoute: titles[selectedIndex]),
      body: IndexedStack(index: selectedIndex, children: pages),
      // Consistent Easy Access Navigation: Home | Customers | Payments
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (index) => setState(() => selectedIndex = index),
        indicatorColor: const Color(0xffffe8e9),
        backgroundColor: Colors.white,
        elevation: 8,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home, color: AppColors.burgundy),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.people_outline),
            selectedIcon: Icon(Icons.people, color: AppColors.burgundy),
            label: 'Customers',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long, color: AppColors.burgundy),
            label: 'Payments',
          ),
        ],
      ),
    );
  }
}
