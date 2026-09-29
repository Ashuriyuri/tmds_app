import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../models/customer_booking.dart';
import '../../services/app_data.dart';
import '../../widgets/status_badge.dart';
import 'receipt_screen.dart';

class ServiceDetailScreen extends StatefulWidget {
  const ServiceDetailScreen({required this.booking, super.key});
  final CustomerBooking booking;

  @override
  State<ServiceDetailScreen> createState() => _ServiceDetailScreenState();
}

class _ServiceDetailScreenState extends State<ServiceDetailScreen> {
  late CustomerBooking _booking;
  final _paymentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _booking = widget.booking;
    _paymentController.text = _booking.actualAmountPaid.toStringAsFixed(0);
  }

  @override
  void dispose() {
    _paymentController.dispose();
    super.dispose();
  }

  void _saveChanges() {
    final enteredPaid =
        double.tryParse(_paymentController.text.replaceAll(',', '')) ??
        _booking.actualAmountPaid;

    setState(() {
      _booking.actualAmountPaid = enteredPaid;
    });

    AppData.instance.updateBooking(_booking);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Service details updated successfully!'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  void _changeServiceStatus(String newStatus) {
    setState(() {
      _booking.serviceStatus = newStatus;
    });
    AppData.instance.updateBookingServiceStatus(_booking.id, newStatus);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Service Status updated to $newStatus'),
        backgroundColor: AppColors.burgundy,
      ),
    );
  }

  void _changePaymentStatus(String newStatus) {
    setState(() {
      _booking.paymentStatus = newStatus;
    });
    AppData.instance.updateBookingPaymentStatus(_booking.id, newStatus);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Payment Status updated to $newStatus'),
        backgroundColor: AppColors.burgundy,
      ),
    );
  }

  // Record Installment Payment with Transaction History
  void _showRecordPaymentDialog() {
    final amountController = TextEditingController(
      text: _booking.balance.toStringAsFixed(0),
    );
    String paymentMethod = 'Cash';
    final noteController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Record Payment',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 18,
              color: AppColors.ink,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Customer: ${_booking.customerName}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Total Due: ₱${_booking.totalAmount.toStringAsFixed(0)}',
                  style: const TextStyle(color: AppColors.muted, fontSize: 13),
                ),
                Text(
                  'Current Paid: ₱${_booking.actualAmountPaid.toStringAsFixed(0)}',
                  style: const TextStyle(color: AppColors.muted, fontSize: 13),
                ),
                Text(
                  'Remaining Balance: ₱${_booking.balance.toStringAsFixed(0)}',
                  style: const TextStyle(
                    color: AppColors.burgundy,
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Payment Amount (₱)',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    prefixText: '₱ ',
                    hintText: 'Enter payment amount',
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Payment Method',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                ),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  initialValue: paymentMethod,
                  decoration: const InputDecoration(
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                  ),
                  items: ['Cash', 'GCash', 'Bank Transfer', 'Credit Card']
                      .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) setModalState(() => paymentMethod = val);
                  },
                ),
                const SizedBox(height: 12),
                const Text(
                  'Note / Installment Info',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: noteController,
                  decoration: const InputDecoration(
                    hintText: 'e.g. 1st installment',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                final pay = double.tryParse(amountController.text) ?? 0.0;
                if (pay > 0) {
                  AppData.instance.recordAdditionalPayment(
                    bookingId: _booking.id,
                    paymentAmount: pay,
                    method: paymentMethod,
                    note: noteController.text.trim(),
                  );
                  setState(() {
                    _paymentController.text = _booking.actualAmountPaid
                        .toStringAsFixed(0);
                  });
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Payment of ₱${pay.toStringAsFixed(0)} recorded! Remaining Balance: ₱${_booking.balance.toStringAsFixed(0)}',
                      ),
                      backgroundColor: AppColors.success,
                    ),
                  );
                }
              },
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.burgundy,
              ),
              child: const Text('Confirm Payment'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.paper,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.ink),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Service Details',
          style: TextStyle(
            color: AppColors.ink,
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          // Customer Summary Card
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: AppColors.border),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Customer Name',
                        style: TextStyle(color: AppColors.muted, fontSize: 13),
                      ),
                      Text(
                        _booking.customerName,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          color: AppColors.ink,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Phone Number',
                        style: TextStyle(color: AppColors.muted, fontSize: 13),
                      ),
                      Text(
                        _booking.phone.isNotEmpty ? _booking.phone : 'N/A',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppColors.ink,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Vehicle',
                        style: TextStyle(color: AppColors.muted, fontSize: 13),
                      ),
                      Text(
                        _booking.vehicleDisplay,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppColors.ink,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 20),

                  // Separate Service Status & Payment Status
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Service Status',
                        style: TextStyle(color: AppColors.muted, fontSize: 13),
                      ),
                      Row(
                        children: [
                          StatusBadge(_booking.serviceStatus),
                          PopupMenuButton<String>(
                            icon: const Icon(
                              Icons.arrow_drop_down,
                              color: AppColors.muted,
                              size: 20,
                            ),
                            onSelected: _changeServiceStatus,
                            itemBuilder: (_) => const [
                              PopupMenuItem(
                                value: 'Pending',
                                child: Text('Pending'),
                              ),
                              PopupMenuItem(
                                value: 'In-Progress',
                                child: Text('In-Progress'),
                              ),
                              PopupMenuItem(
                                value: 'Completed',
                                child: Text('Completed'),
                              ),
                              PopupMenuItem(
                                value: 'Released',
                                child: Text('Released'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Payment Status',
                        style: TextStyle(color: AppColors.muted, fontSize: 13),
                      ),
                      Row(
                        children: [
                          StatusBadge(_booking.paymentStatus),
                          PopupMenuButton<String>(
                            icon: const Icon(
                              Icons.arrow_drop_down,
                              color: AppColors.muted,
                              size: 20,
                            ),
                            onSelected: _changePaymentStatus,
                            itemBuilder: (_) => const [
                              PopupMenuItem(
                                value: 'Pending',
                                child: Text('Pending'),
                              ),
                              PopupMenuItem(
                                value: 'Partially Paid',
                                child: Text('Partially Paid'),
                              ),
                              PopupMenuItem(
                                value: 'Fully Paid',
                                child: Text('Fully Paid'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Services Applied Section
          const Text(
            'Services Applied',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 15,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 8),

          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: AppColors.border),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  ..._booking.services.map(
                    (service) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  service.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                    color: AppColors.ink,
                                  ),
                                ),
                                if (service.assignedWorkers.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 2),
                                    child: Text(
                                      'Assigned: ${service.assignedWorkers.join(', ')}',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: AppColors.muted,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          Text(
                            '₱${service.price.toStringAsFixed(0)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                              color: AppColors.ink,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Divider(height: 18),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total Due',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                          color: AppColors.burgundy,
                        ),
                      ),
                      Text(
                        '₱${_booking.totalAmount.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                          color: AppColors.burgundy,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Payment Summary & Installment Record Card
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: AppColors.border),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total Due',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      Text(
                        '₱${_booking.totalAmount.toStringAsFixed(0)}',
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total Paid',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      Text(
                        '₱${_booking.actualAmountPaid.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          color: AppColors.success,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Remaining Balance',
                        style: TextStyle(fontWeight: FontWeight.w800),
                      ),
                      Text(
                        '₱${_booking.balance.toStringAsFixed(0)}',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          color: _booking.balance > 0
                              ? AppColors.burgundy
                              : AppColors.success,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Center(
                    child: OutlinedButton.icon(
                      onPressed: _showRecordPaymentDialog,
                      icon: const Icon(Icons.add_card, size: 18),
                      label: const Text('Record Payment Installment'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.burgundy,
                        side: const BorderSide(color: AppColors.burgundy),
                      ),
                    ),
                  ),

                  // Payment History Audit Trail
                  if (_booking.paymentHistory.isNotEmpty) ...[
                    const Divider(height: 24),
                    const Text(
                      'Payment History',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                        color: AppColors.ink,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ..._booking.paymentHistory.map(
                      (txn) => Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${txn.date.month}/${txn.date.day}/${txn.date.year} (${txn.method})${txn.note.isNotEmpty ? ' - ${txn.note}' : ''}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.muted,
                              ),
                            ),
                            Text(
                              '₱${txn.amount.toStringAsFixed(0)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                                color: AppColors.success,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // E-Receipt Button
          OutlinedButton.icon(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ReceiptScreen(booking: _booking),
              ),
            ),
            icon: const Icon(Icons.receipt_long_outlined),
            label: const Text('View / Print E-Receipt'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.burgundy,
              side: const BorderSide(color: AppColors.burgundy),
              minimumSize: const Size.fromHeight(48),
            ),
          ),
          const SizedBox(height: 12),

          // Delete Service Button
          OutlinedButton.icon(
            onPressed: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (dialogContext) => AlertDialog(
                  title: const Text('Delete service record?'),
                  content: const Text(
                    'This will delete the service and all related payment logs.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(dialogContext, false),
                      child: const Text('Cancel'),
                    ),
                    FilledButton(
                      onPressed: () => Navigator.pop(dialogContext, true),
                      child: const Text('Delete'),
                    ),
                  ],
                ),
              );
              if (confirmed == true && context.mounted) {
                AppData.instance.removeBooking(_booking.id);
                Navigator.pop(context);
              }
            },
            icon: const Icon(Icons.delete_outline),
            label: const Text('Delete Service Record'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
              side: const BorderSide(color: Colors.red),
              minimumSize: const Size.fromHeight(48),
            ),
          ),
          const SizedBox(height: 14),

          // Save Button
          FilledButton(
            onPressed: _saveChanges,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.burgundy,
              minimumSize: const Size.fromHeight(50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'Save Changes',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }
}
