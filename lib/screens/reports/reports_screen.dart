import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../services/app_data.dart';
import '../../widgets/summary_card.dart';
import '../module/module_screen.dart';
import '../profile/profile_screen.dart';
import '../settings/settings_screen.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  String period = 'Monthly';

  @override
  Widget build(BuildContext context) {
    final data = AppData.instance;
    final revenue = data.bookings.fold<double>(
      0,
      (sum, item) => sum + item.actualAmountPaid,
    );
    final materials = data.materials.fold<double>(
      0,
      (sum, item) => sum + item.price * item.quantity,
    );
    final totalServicesCount = data.bookings.fold<int>(
      0,
      (sum, item) => sum + item.services.length,
    );
    final completedCount = data.bookings
        .where((item) => item.serviceStatus == 'Completed')
        .length;

    return Scaffold(
      backgroundColor: AppColors.paper,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        // User requested: "remove left upper arrow in reports instead put the 3line menu"
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: AppColors.ink),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: const Text(
          'Reports',
          style: TextStyle(
            color: AppColors.ink,
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
      ),
      drawer: Drawer(
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
                  ],
                ),
              ),
              _drawerItem(context, Icons.dashboard_outlined, 'Dashboard', () {
                Navigator.pop(context);
                Navigator.pop(context);
              }),
              _drawerItem(
                context,
                Icons.people_outline,
                'Customers & Services',
                () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          const ModuleScreen(module: AppModule.customers),
                    ),
                  );
                },
              ),
              _drawerItem(context, Icons.payments_outlined, 'Payments', () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        const ModuleScreen(module: AppModule.payments),
                  ),
                );
              }),
              _drawerItem(context, Icons.badge_outlined, 'Employees', () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        const ModuleScreen(module: AppModule.employees),
                  ),
                );
              }),
              _drawerItem(
                context,
                Icons.inventory_2_outlined,
                'Material Records',
                () {
                  Navigator.pop(context);
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
                context,
                Icons.bar_chart_outlined,
                'Reports',
                () => Navigator.pop(context),
              ),
              const Divider(height: 24),
              _drawerItem(context, Icons.person_outline, 'Profile', () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ProfileScreen()),
                );
              }),
              _drawerItem(context, Icons.settings_outlined, 'Settings', () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SettingsScreen()),
                );
              }),
            ],
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          const Text(
            'Business performance',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Live overview of services, payments & material records',
            style: TextStyle(color: AppColors.muted),
          ),
          const SizedBox(height: 18),
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(value: 'Weekly', label: Text('Weekly')),
              ButtonSegment(value: 'Monthly', label: Text('Monthly')),
              ButtonSegment(value: 'Yearly', label: Text('Yearly')),
            ],
            selected: {period},
            onSelectionChanged: (value) => setState(() => period = value.first),
          ),
          const SizedBox(height: 14),
          Card(
            child: ListTile(
              leading: Icon(Icons.insights_outlined, color: AppColors.burgundy),
              title: Text('$period progress'),
              subtitle: Text(_progressMessage(revenue, totalServicesCount)),
              trailing: Text(
                _progressLabel(revenue),
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                  color: _progressLabel(revenue) == 'HIGH'
                      ? AppColors.success
                      : AppColors.warning,
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              SummaryCard(
                label: 'Total services',
                value: '$totalServicesCount',
                icon: Icons.car_repair_outlined,
              ),
              SummaryCard(
                label: 'Completed',
                value: '$completedCount',
                icon: Icons.check_circle_outline,
              ),
              SummaryCard(
                label: 'Collected',
                value: '₱${revenue.toStringAsFixed(0)}',
                icon: Icons.payments_outlined,
              ),
              SummaryCard(
                label: 'Materials Value',
                value: '₱${materials.toStringAsFixed(0)}',
                icon: Icons.inventory_2_outlined,
              ),
            ],
          ),
          const SizedBox(height: 20),
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: AppColors.border),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Recent Payment Collection',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.ink,
                    ),
                  ),
                  const SizedBox(height: 14),
                  if (data.bookings
                      .where((b) => b.actualAmountPaid > 0)
                      .isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Text(
                        'No payments recorded yet for this period.',
                        style: TextStyle(color: AppColors.muted),
                      ),
                    )
                  else
                    ...data.bookings
                        .where((b) => b.actualAmountPaid > 0)
                        .take(6)
                        .map(
                          (booking) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      booking.customerName,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 14,
                                      ),
                                    ),
                                    Text(
                                      booking.vehicleDisplay,
                                      style: const TextStyle(
                                        color: AppColors.muted,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  '₱${booking.actualAmountPaid.toStringAsFixed(0)}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.burgundy,
                                    fontSize: 15,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _progressLabel(double revenue) => revenue >= 10000 ? 'HIGH' : 'LOW';

  String _progressMessage(double revenue, int services) => revenue >= 10000
      ? 'Revenue and service activity are strong for this period.'
      : 'Activity is low for this period ($period indicator: LOW).';

  Widget _drawerItem(
    BuildContext context,
    IconData icon,
    String label,
    VoidCallback onTap,
  ) => ListTile(
    leading: Icon(icon, color: AppColors.ink),
    title: Text(label),
    onTap: onTap,
  );
}
