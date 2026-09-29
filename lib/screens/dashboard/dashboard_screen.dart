import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../services/app_data.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/summary_card.dart';
import '../service/service_detail_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({
    this.onNavigateToCustomers,
    this.onNavigateToPayments,
    super.key,
  });

  final VoidCallback? onNavigateToCustomers;
  final VoidCallback? onNavigateToPayments;

  @override
  Widget build(BuildContext context) {
    final data = AppData.instance;

    return ListenableBuilder(
      listenable: data,
      builder: (context, _) {
        final revenue = data.bookings.fold<double>(
          0,
          (sum, b) => sum + b.actualAmountPaid,
        );
        final pendingCount = data.bookings
            .where((b) => b.serviceStatus == 'Pending')
            .length;
        final inProgressCount = data.bookings
            .where(
              (b) =>
                  b.serviceStatus == 'In-Progress' ||
                  b.serviceStatus == 'In Progress',
            )
            .length;
        final completedCount = data.bookings
            .where((b) => b.serviceStatus == 'Completed')
            .length;

        return ListView(
          padding: const EdgeInsets.fromLTRB(18, 14, 18, 80),
          children: [
            // User requested: "dashboard remove the googdmorning admin replace with welcome"
            const Text(
              'Welcome',
              style: TextStyle(
                color: AppColors.muted,
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 2),
            const Text(
              'Business overview',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: AppColors.ink,
              ),
            ),
            const SizedBox(height: 16),

            // Revenue Highlight Card
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.burgundy, AppColors.burgundyDark],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.burgundy.withValues(alpha: 0.25),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Total Revenue Collected',
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '₱${revenue.toStringAsFixed(0)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '$completedCount Completed',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '$inProgressCount In Progress',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Quick Actions
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: onNavigateToCustomers,
                    icon: const Icon(Icons.people_outline, size: 18),
                    label: const Text(
                      'Customers & Services',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.burgundy,
                      minimumSize: const Size.fromHeight(46),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onNavigateToPayments,
                    icon: const Icon(Icons.receipt_long, size: 18),
                    label: const Text(
                      'Payments',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.burgundy,
                      side: const BorderSide(color: AppColors.burgundy),
                      minimumSize: const Size.fromHeight(46),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),

            // Metric Summary Grid
            GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.35,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                SummaryCard(
                  label: 'Customers',
                  value: '${data.bookings.length}',
                  icon: Icons.people_outline,
                ),
                SummaryCard(
                  label: 'In-Progress',
                  value: '$inProgressCount',
                  icon: Icons.autorenew,
                ),
                SummaryCard(
                  label: 'Pending',
                  value: '$pendingCount',
                  icon: Icons.schedule_outlined,
                ),
                SummaryCard(
                  label: 'Staff',
                  value: '${data.employees.length}',
                  icon: Icons.badge_outlined,
                ),
              ],
            ),
            const SizedBox(height: 22),

            // At a glance
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
                side: const BorderSide(color: AppColors.border),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _metricRow(
                      'Pending services',
                      '$pendingCount bookings',
                      Icons.hourglass_empty,
                      AppColors.warning,
                    ),
                    const Divider(height: 20),
                    _metricRow(
                      'Active detailing',
                      '$inProgressCount vehicles',
                      Icons.directions_car_filled,
                      AppColors.burgundy,
                    ),
                    const Divider(height: 20),
                    _metricRow(
                      'Materials in stock',
                      '${data.materials.fold<int>(0, (sum, m) => sum + m.quantity)} items',
                      Icons.inventory_2_outlined,
                      AppColors.success,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 22),

            // Recent Bookings Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Recent bookings',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: AppColors.ink,
                  ),
                ),
                if (data.bookings.isNotEmpty)
                  TextButton(
                    onPressed: onNavigateToCustomers,
                    child: const Text(
                      'View all',
                      style: TextStyle(
                        color: AppColors.burgundy,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),

            // Clean state if no bookings yet
            if (data.bookings.isEmpty)
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: AppColors.border),
                ),
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                  child: Center(
                    child: Text(
                      'No bookings added yet.\nTap "Add Customer" above to enter a new booking.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.muted),
                    ),
                  ),
                ),
              )
            else
              ...data.bookings
                  .take(4)
                  .map(
                    (booking) => Card(
                      elevation: 0,
                      margin: const EdgeInsets.only(bottom: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: const BorderSide(color: AppColors.border),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 4,
                        ),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                ServiceDetailScreen(booking: booking),
                          ),
                        ),
                        leading: CircleAvatar(
                          backgroundColor: AppColors.burgundyLight,
                          child: const Icon(
                            Icons.car_repair,
                            color: AppColors.burgundy,
                          ),
                        ),
                        title: Text(
                          booking.customerName,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        subtitle: Text(
                          '${booking.vehicleDisplay} • ₱${booking.totalAmount.toStringAsFixed(0)}',
                        ),
                        trailing: StatusBadge(booking.serviceStatus),
                      ),
                    ),
                  ),
          ],
        );
      },
    );
  }

  Widget _metricRow(
    String label,
    String value,
    IconData icon,
    Color iconColor,
  ) {
    return Row(
      children: [
        Icon(icon, color: iconColor, size: 22),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: AppColors.muted,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.w800,
            color: AppColors.ink,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}
