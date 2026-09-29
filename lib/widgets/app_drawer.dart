import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../screens/home/home_screen.dart';
import '../screens/module/module_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/reports/reports_screen.dart';
import '../screens/settings/settings_screen.dart';

class TmdsDrawer extends StatelessWidget {
  const TmdsDrawer({this.currentRoute = '', super.key});

  final String currentRoute;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            Container(
              color: AppColors.burgundy,
              padding: const EdgeInsets.fromLTRB(24, 26, 24, 24),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.directions_car_filled_outlined,
                    color: Colors.white,
                    size: 34,
                  ),
                  SizedBox(height: 14),
                  Text(
                    'TMDS',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    'Tony Marapao Car Detailing',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'admin@tmds.com',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ),
            _drawerItem(
              icon: Icons.dashboard_outlined,
              label: 'Dashboard',
              isSelected: currentRoute == 'Dashboard',
              onTap: () {
                Navigator.pop(context);
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const HomeScreen(initialIndex: 0),
                  ),
                  (route) => false,
                );
              },
            ),
            _drawerItem(
              icon: Icons.people_outline,
              label: 'Customers & Services',
              isSelected: currentRoute == 'Customers & Services',
              onTap: () {
                Navigator.pop(context);
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const HomeScreen(initialIndex: 1),
                  ),
                  (route) => false,
                );
              },
            ),
            _drawerItem(
              icon: Icons.payments_outlined,
              label: 'Payments',
              isSelected: currentRoute == 'Payments',
              onTap: () {
                Navigator.pop(context);
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const HomeScreen(initialIndex: 2),
                  ),
                  (route) => false,
                );
              },
            ),
            _drawerItem(
              icon: Icons.badge_outlined,
              label: 'Employees',
              isSelected: currentRoute == 'Employees',
              onTap: () {
                Navigator.pop(context);
                if (currentRoute == 'Employees') return;
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        const ModuleScreen(module: AppModule.employees),
                  ),
                );
              },
            ),
            _drawerItem(
              icon: Icons.inventory_2_outlined,
              label: 'Material Records',
              isSelected: currentRoute == 'Material Records',
              onTap: () {
                Navigator.pop(context);
                if (currentRoute == 'Material Records') return;
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        const ModuleScreen(module: AppModule.materials),
                  ),
                );
              },
            ),
            _drawerItem(
              icon: Icons.bar_chart_outlined,
              label: 'Reports',
              isSelected: currentRoute == 'Reports',
              onTap: () {
                Navigator.pop(context);
                if (currentRoute == 'Reports') return;
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ReportsScreen()),
                );
              },
            ),
            const Divider(height: 24),
            _drawerItem(
              icon: Icons.person_outline,
              label: 'Profile',
              isSelected: currentRoute == 'Profile',
              onTap: () {
                Navigator.pop(context);
                if (currentRoute == 'Profile') return;
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ProfileScreen()),
                );
              },
            ),
            _drawerItem(
              icon: Icons.settings_outlined,
              label: 'Settings',
              isSelected: currentRoute == 'Settings',
              onTap: () {
                Navigator.pop(context);
                if (currentRoute == 'Settings') return;
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SettingsScreen()),
                );
              },
            ),
            _drawerItem(
              icon: Icons.logout,
              label: 'Log out',
              isSelected: false,
              onTap: () =>
                  Navigator.popUntil(context, (route) => route.isFirst),
            ),
          ],
        ),
      ),
    );
  }

  Widget _drawerItem({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return ListTile(
      selected: isSelected,
      selectedTileColor: AppColors.burgundy.withValues(alpha: 0.08),
      selectedColor: AppColors.burgundy,
      leading: Icon(
        icon,
        color: isSelected ? AppColors.burgundy : AppColors.ink,
      ),
      title: Text(
        label,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
          fontSize: 14,
        ),
      ),
      onTap: onTap,
    );
  }
}
