import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../models/customer_booking.dart';

class ReceiptScreen extends StatelessWidget {
  const ReceiptScreen({required this.booking, super.key});
  final CustomerBooking booking;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text(
        'E-Receipt',
        style: TextStyle(fontWeight: FontWeight.w800),
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        IconButton(
          tooltip: 'Screenshot or Print Receipt',
          onPressed: () => showDialog<void>(
            context: context,
            builder: (_) => const AlertDialog(
              title: Text('Ready for Screenshot / Camera Capture'),
              content: Text(
                'This electronic receipt is formatted for clear screen capture or mobile printing to share with the customer.',
              ),
            ),
          ),
          icon: const Icon(Icons.camera_alt_outlined),
        ),
      ],
    ),
    body: ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: AppColors.border),
          ),
          child: Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(
                  Icons.directions_car_filled_outlined,
                  color: AppColors.burgundy,
                  size: 40,
                ),
                const SizedBox(height: 8),
                const Text(
                  'TMDS',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    color: AppColors.burgundy,
                    letterSpacing: 2,
                  ),
                ),
                const Text(
                  'Tony Marapao Car Detailing Services',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.ink,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Official Electronic Service Receipt',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.muted, fontSize: 11),
                ),
                const Divider(height: 28),

                _row('Receipt No.', 'REC-${booking.id.toUpperCase()}'),
                _row('Customer', booking.customerName),
                _row('Phone', booking.phone.isNotEmpty ? booking.phone : 'N/A'),
                _row('Vehicle', booking.vehicleDisplay),
                _row('Services', booking.servicesSummary),
                const Divider(height: 24),

                _row(
                  'Total Amount',
                  '₱${booking.totalAmount.toStringAsFixed(2)}',
                ),
                _row(
                  'Total Paid',
                  '₱${booking.actualAmountPaid.toStringAsFixed(2)}',
                ),
                _row('Balance Due', '₱${booking.balance.toStringAsFixed(2)}'),
                _row('Payment Status', booking.paymentStatus),
                _row('Service Status', booking.serviceStatus),

                if (booking.paymentHistory.isNotEmpty) ...[
                  const Divider(height: 24),
                  const Text(
                    'Payment Transactions',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.ink,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...booking.paymentHistory.map(
                    (txn) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${txn.date.month}/${txn.date.day}/${txn.date.year} • ${txn.method}',
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.muted,
                            ),
                          ),
                          Text(
                            '₱${txn.amount.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.ink,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],

                const Divider(height: 28),
                Text(
                  booking.paymentStatus == 'Fully Paid'
                      ? 'FULLY PAID & VERIFIED'
                      : 'PARTIALLY PAID / BALANCE PENDING',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: booking.paymentStatus == 'Fully Paid'
                        ? AppColors.success
                        : AppColors.burgundy,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Please take a photo or screenshot of this electronic receipt for customer validation and warranty.',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.muted, fontSize: 12),
        ),
      ],
    ),
  );

  Widget _row(String label, String value) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 105,
          child: Text(
            label,
            style: const TextStyle(
              color: AppColors.muted,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: AppColors.ink,
              fontSize: 13,
            ),
          ),
        ),
      ],
    ),
  );
}
