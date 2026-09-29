import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/theme/app_colors.dart';
import '../../models/customer_booking.dart';
import '../../models/employee.dart';
import '../../models/material.dart';
import '../../services/app_data.dart';
import '../../widgets/status_badge.dart';
import '../customer/add_customer_screen.dart';
import '../service/receipt_screen.dart';
import '../service/service_detail_screen.dart';

enum AppModule { customers, services, employees, materials, payments }

class ModuleScreen extends StatefulWidget {
  const ModuleScreen({required this.module, this.embedded = false, super.key});

  final AppModule module;
  final bool embedded;

  @override
  State<ModuleScreen> createState() => _ModuleScreenState();
}

class _ModuleScreenState extends State<ModuleScreen> {
  final searchController = TextEditingController();
  String _selectedFilter = 'All';
  String _paymentFilter = 'All';
  String _employeeRoleFilter = 'All roles';

  String get title => switch (widget.module) {
    AppModule.customers || AppModule.services => 'Customers & Services',
    AppModule.employees => 'Employees',
    AppModule.materials => 'Material Records',
    AppModule.payments => 'Payments',
  };

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void _openAddCustomerAndService() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const AddCustomerScreen()),
    );
    if (result == true && mounted) {
      setState(() {});
    }
  }

  void _openServiceDetails(CustomerBooking booking) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ServiceDetailScreen(booking: booking)),
    );
    if (mounted) setState(() {});
  }

  void _openAddGenericRecord() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => _AddGenericRecordScreen(module: widget.module),
      ),
    );
    if (result == true && mounted) {
      setState(() {});
    }
  }

  // Quick dialog to record installment payment (Ashuri Alonzo pays 3,000 on 5,000 balance)
  void _openRecordPaymentDialog(CustomerBooking booking) {
    final amountController = TextEditingController(
      text: booking.balance.toStringAsFixed(0),
    );
    String method = 'Cash';
    final noteController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Record Payment - ${booking.customerName}',
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 16,
              color: AppColors.ink,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Vehicle: ${booking.vehicleDisplay}',
                style: const TextStyle(fontSize: 13, color: AppColors.muted),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total: ₱${booking.totalAmount.toStringAsFixed(0)}',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  Text(
                    'Balance: ₱${booking.balance.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      color: AppColors.burgundy,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              const Text(
                'Amount to Pay (₱)',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  prefixText: '₱ ',
                  hintText: 'e.g. 3000',
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Payment Method',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
              ),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                initialValue: method,
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
                  if (val != null) setModalState(() => method = val);
                },
              ),
              const SizedBox(height: 12),
              const Text(
                'Note / Remarks',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: noteController,
                decoration: const InputDecoration(
                  hintText: 'e.g. Partial downpayment',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                final pay =
                    double.tryParse(amountController.text.trim()) ?? 0.0;
                if (pay > 0) {
                  AppData.instance.recordAdditionalPayment(
                    bookingId: booking.id,
                    paymentAmount: pay,
                    method: method,
                    note: noteController.text.trim(),
                  );
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        '₱${pay.toStringAsFixed(0)} payment recorded for ${booking.customerName}! Remaining balance: ₱${booking.balance.toStringAsFixed(0)}',
                      ),
                      backgroundColor: AppColors.success,
                    ),
                  );
                }
              },
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.burgundy,
              ),
              child: const Text('Save Payment'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final body = _buildBody();

    if (widget.embedded) {
      return body;
    }

    // Secondary screen: use regular back button and NO bottom navigation bar
    return Scaffold(
      backgroundColor: AppColors.paper,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.ink),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: AppColors.ink,
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
      ),
      body: body,
      // User requested: "remove add payments in payments interface"
      // Only show FAB for Employees and Materials
      floatingActionButton:
          (widget.module == AppModule.employees ||
              widget.module == AppModule.materials)
          ? FloatingActionButton.extended(
              onPressed: _openAddGenericRecord,
              backgroundColor: AppColors.burgundy,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.add),
              label: Text('Add ${_shortTitle()}'),
            )
          : null,
    );
  }

  String _shortTitle() => switch (widget.module) {
    AppModule.employees => 'Employee',
    AppModule.materials => 'Material Record',
    _ => 'Record',
  };

  Widget _buildBody() {
    final data = AppData.instance;
    return ListenableBuilder(
      listenable: data,
      builder: (context, _) {
        if (widget.module == AppModule.customers ||
            widget.module == AppModule.services) {
          return _buildCustomersServicesView(data);
        } else if (widget.module == AppModule.payments) {
          return _buildPaymentsView(data);
        } else if (widget.module == AppModule.employees) {
          return _buildEmployeesView(data);
        } else {
          return _buildMaterialsView(data);
        }
      },
    );
  }

  // --- 1. CUSTOMERS & SERVICES VIEW ---
  Widget _buildCustomersServicesView(AppData data) {
    final query = searchController.text.trim().toLowerCase();
    var filtered = data.bookings.where((b) {
      final text =
          '${b.customerName} ${b.phone} ${b.vehicleDisplay} ${b.servicesSummary} ${b.serviceStatus}'
              .toLowerCase();
      final matchesQuery = query.isEmpty || text.contains(query);
      if (!matchesQuery) return false;

      if (_selectedFilter == 'All') return true;
      if (_selectedFilter == 'Pending') return b.serviceStatus == 'Pending';
      if (_selectedFilter == 'In-Progress') {
        return b.serviceStatus == 'In-Progress' ||
            b.serviceStatus == 'In Progress';
      }
      if (_selectedFilter == 'Completed') return b.serviceStatus == 'Completed';
      if (_selectedFilter == 'Released') return b.serviceStatus == 'Released';
      return true;
    }).toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Column(
            children: [
              // Search input field
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.border),
                ),
                child: TextField(
                  controller: searchController,
                  onChanged: (_) => setState(() {}),
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.search, color: AppColors.muted),
                    hintText: 'Search customer name or vehicle...',
                    hintStyle: TextStyle(color: AppColors.muted, fontSize: 13),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Full-Width Burgundy Button: "+ Add Customer & Service"
              FilledButton.icon(
                onPressed: _openAddCustomerAndService,
                icon: const Icon(Icons.add_circle_outline, size: 18),
                label: const Text(
                  'Add Customer & Service',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.burgundy,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(46),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // Filter Chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _filterChip('All'),
                    const SizedBox(width: 8),
                    _filterChip('Pending'),
                    const SizedBox(width: 8),
                    _filterChip('In-Progress'),
                    const SizedBox(width: 8),
                    _filterChip('Completed'),
                    const SizedBox(width: 8),
                    _filterChip('Released'),
                  ],
                ),
              ),
            ],
          ),
        ),

        // List of Customers & Services cards
        Expanded(
          child: filtered.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.people_outline,
                        size: 48,
                        color: AppColors.muted,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        query.isEmpty
                            ? 'No customers or services yet.\nTap "+ Add Customer & Service" to get started.'
                            : 'No records matching "$query"',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: AppColors.muted),
                      ),
                    ],
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 80),
                  itemCount: filtered.length,
                  separatorBuilder: (_, index) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final booking = filtered[index];
                    return _buildCustomerServiceCard(booking);
                  },
                ),
        ),
      ],
    );
  }

  Widget _filterChip(String label) {
    final isSelected = _selectedFilter == label;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (val) {
        if (val) setState(() => _selectedFilter = label);
      },
      selectedColor: AppColors.burgundy,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : AppColors.ink,
        fontSize: 12,
        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
      ),
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isSelected ? AppColors.burgundy : AppColors.border,
        ),
      ),
    );
  }

  Widget _buildCustomerServiceCard(CustomerBooking booking) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.border),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _openServiceDetails(booking),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Row 1: Customer Name and Status Badge (Separate Service Status)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      booking.customerName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                        color: AppColors.ink,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  StatusBadge(booking.serviceStatus),
                ],
              ),
              const SizedBox(height: 4),

              // Row 2: Vehicle info
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    booking.vehicleDisplay,
                    style: const TextStyle(
                      color: AppColors.muted,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Row 3: Services & Total
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      booking.servicesSummary,
                      style: const TextStyle(
                        color: AppColors.muted,
                        fontSize: 13,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    '₱${booking.totalAmount.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                      color: AppColors.ink,
                    ),
                  ),
                ],
              ),
              const Divider(height: 18),
              // Row 4: Payment status & action
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Text(
                        'Payment: ',
                        style: TextStyle(fontSize: 12, color: AppColors.muted),
                      ),
                      StatusBadge(booking.paymentStatus),
                    ],
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.edit_outlined,
                          size: 18,
                          color: AppColors.muted,
                        ),
                        onPressed: () => _openServiceDetails(booking),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.delete_outline,
                          size: 18,
                          color: AppColors.burgundy,
                        ),
                        onPressed: () => _confirmDeleteBooking(booking),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmDeleteBooking(CustomerBooking booking) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete customer service?'),
        content: Text(
          'Are you sure you want to delete ${booking.customerName}\'s service record?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      AppData.instance.removeBooking(booking.id);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Record for ${booking.customerName} deleted')),
      );
    }
  }

  // --- 2. PAYMENTS VIEW ---
  Widget _buildPaymentsView(AppData data) {
    final query = searchController.text.trim().toLowerCase();
    final allBookings = data.bookings;
    final totalCollected = allBookings.fold<double>(
      0,
      (sum, b) => sum + b.actualAmountPaid,
    );
    final totalBalanceDue = allBookings.fold<double>(
      0,
      (sum, b) => sum + b.balance,
    );

    // User requirement: "payments filter if in progress pending or completed and release"
    final filtered = allBookings.where((b) {
      final text =
          '${b.customerName} ${b.vehicleDisplay} ${b.paymentStatus} ${b.serviceStatus}'
              .toLowerCase();
      final matchesQuery = query.isEmpty || text.contains(query);
      if (!matchesQuery) return false;

      final normStatus = b.serviceStatus.toLowerCase().replaceAll('-', ' ');
      if (_paymentFilter == 'All') return true;
      if (_paymentFilter == 'Pending') return normStatus == 'pending';
      if (_paymentFilter == 'In Progress') return normStatus == 'in progress';
      if (_paymentFilter == 'Completed') return normStatus == 'completed';
      if (_paymentFilter == 'Released') return normStatus == 'released';
      return true;
    }).toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Column(
            children: [
              // Search input field
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.border),
                ),
                child: TextField(
                  controller: searchController,
                  onChanged: (_) => setState(() {}),
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.search, color: AppColors.muted),
                    hintText: 'Search payments by customer or vehicle...',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Filter by status: All, Pending, In Progress, Completed, Released
              Align(
                alignment: Alignment.centerLeft,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children:
                        [
                              'All',
                              'Pending',
                              'In Progress',
                              'Completed',
                              'Released',
                            ]
                            .map(
                              (status) => Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: _paymentFilterChip(status),
                              ),
                            )
                            .toList(),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // Payment Metrics Row
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Total Collected',
                            style: TextStyle(
                              color: AppColors.muted,
                              fontSize: 11,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '₱${totalCollected.toStringAsFixed(0)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 16,
                              color: AppColors.success,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Balance Due',
                            style: TextStyle(
                              color: AppColors.muted,
                              fontSize: 11,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '₱${totalBalanceDue.toStringAsFixed(0)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 16,
                              color: AppColors.burgundy,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // List of payments
        Expanded(
          child: filtered.isEmpty
              ? const Center(
                  child: Text(
                    'No payment records found',
                    style: TextStyle(color: AppColors.muted),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 80),
                  itemCount: filtered.length,
                  separatorBuilder: (_, index) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final booking = filtered[index];
                    return Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: const BorderSide(color: AppColors.border),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Customer name, service status badge & payment status badge
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    booking.customerName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 15,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Row(
                                  children: [
                                    StatusBadge(booking.serviceStatus),
                                    const SizedBox(width: 6),
                                    StatusBadge(booking.paymentStatus),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              booking.vehicleDisplay,
                              style: const TextStyle(
                                color: AppColors.muted,
                                fontSize: 12,
                              ),
                            ),
                            const Divider(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Total: ₱${booking.totalAmount.toStringAsFixed(0)}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                  ),
                                ),
                                Text(
                                  'Paid: ₱${booking.actualAmountPaid.toStringAsFixed(0)}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                    color: AppColors.success,
                                  ),
                                ),
                                Text(
                                  'Bal: ₱${booking.balance.toStringAsFixed(0)}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 13,
                                    color: booking.balance > 0
                                        ? AppColors.burgundy
                                        : AppColors.muted,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),

                            // Payment Action Buttons: Quick Installment Payment & E-Receipt
                            Row(
                              children: [
                                if (booking.balance > 0)
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      onPressed: () =>
                                          _openRecordPaymentDialog(booking),
                                      icon: const Icon(
                                        Icons.add_card,
                                        size: 16,
                                      ),
                                      label: const Text('Add Payment'),
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: AppColors.burgundy,
                                        side: const BorderSide(
                                          color: AppColors.burgundy,
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 8,
                                        ),
                                      ),
                                    ),
                                  ),
                                if (booking.balance > 0)
                                  const SizedBox(width: 8),
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            ReceiptScreen(booking: booking),
                                      ),
                                    ),
                                    icon: const Icon(
                                      Icons.receipt_long,
                                      size: 16,
                                    ),
                                    label: const Text('E-Receipt'),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: AppColors.ink,
                                      side: const BorderSide(
                                        color: AppColors.border,
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 8,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _paymentFilterChip(String label) {
    final isSelected = _paymentFilter == label;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) setState(() => _paymentFilter = label);
      },
      selectedColor: AppColors.burgundy,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : AppColors.ink,
        fontSize: 12,
        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
      ),
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isSelected ? AppColors.burgundy : AppColors.border,
        ),
      ),
    );
  }

  // --- 3. EMPLOYEES VIEW ---
  Widget _buildEmployeesView(AppData data) {
    final employees = data.employees
        .where(
          (employee) =>
              _employeeRoleFilter == 'All roles' ||
              employee.role == _employeeRoleFilter,
        )
        .toList();
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: DropdownButtonFormField<String>(
            initialValue: _employeeRoleFilter,
            decoration: const InputDecoration(
              labelText: 'Filter employee type (Painter, Detailer, etc.)',
              prefixIcon: Icon(Icons.filter_list_outlined),
            ),
            items:
                [
                      'All roles',
                      ...data.employees
                          .map((employee) => employee.role)
                          .toSet(),
                    ]
                    .map(
                      (role) =>
                          DropdownMenuItem(value: role, child: Text(role)),
                    )
                    .toList(),
            onChanged: (value) =>
                setState(() => _employeeRoleFilter = value ?? 'All roles'),
          ),
        ),
        Expanded(
          child: employees.isEmpty
              ? const Center(child: Text('No employees found'))
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
                  itemCount: employees.length,
                  separatorBuilder: (_, index) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final emp = employees[index];
                    return Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: const BorderSide(color: AppColors.border),
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: AppColors.burgundyLight,
                          child: const Icon(
                            Icons.person,
                            color: AppColors.burgundy,
                          ),
                        ),
                        title: Text(
                          emp.name,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        subtitle: Text('${emp.role} • ${emp.phone}'),
                        trailing: PopupMenuButton<String>(
                          onSelected: (action) {
                            if (action == 'delete') {
                              data.removeEmployee(emp);
                            }
                            if (action == 'edit') _editEmployee(emp);
                          },
                          itemBuilder: (_) => const [
                            PopupMenuItem(value: 'edit', child: Text('Edit')),
                            PopupMenuItem(
                              value: 'delete',
                              child: Text('Delete'),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  // --- 4. MATERIAL RECORDS VIEW (Renamed from Materials Inventory) ---
  Widget _buildMaterialsView(AppData data) {
    if (data.materials.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.inventory_2_outlined,
              size: 48,
              color: AppColors.muted,
            ),
            const SizedBox(height: 8),
            const Text(
              'No material records yet.\nTap "+ Add Material Record" to add items.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.muted),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
      itemCount: data.materials.length,
      separatorBuilder: (_, index) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final mat = data.materials[index];
        return Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: AppColors.border),
          ),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: AppColors.burgundyLight,
              child: const Icon(Icons.inventory_2, color: AppColors.burgundy),
            ),
            title: Text(
              mat.name,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            subtitle: Text(
              'Qty: ${mat.quantity} in stock • ₱${mat.price.toStringAsFixed(0)} ea\n'
              '${mat.receiptPath != null ? '📷 Receipt photo attached' : 'No receipt photo'}',
            ),
            isThreeLine: true,
            trailing: PopupMenuButton<String>(
              onSelected: (action) {
                if (action == 'delete') {
                  data.removeMaterial(mat);
                }
                if (action == 'edit') _editMaterial(mat);
              },
              itemBuilder: (_) => const [
                PopupMenuItem(value: 'edit', child: Text('Edit')),
                PopupMenuItem(value: 'delete', child: Text('Delete')),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _editEmployee(Employee employee) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => _AddGenericRecordScreen(
          module: AppModule.employees,
          employee: employee,
        ),
      ),
    );
    if (result == true && mounted) setState(() {});
  }

  Future<void> _editMaterial(MaterialItem material) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => _AddGenericRecordScreen(
          module: AppModule.materials,
          material: material,
        ),
      ),
    );
    if (result == true && mounted) setState(() {});
  }
}

class _AddGenericRecordScreen extends StatefulWidget {
  const _AddGenericRecordScreen({
    required this.module,
    this.employee,
    this.material,
  });
  final AppModule module;
  final Employee? employee;
  final MaterialItem? material;

  @override
  State<_AddGenericRecordScreen> createState() =>
      _AddGenericRecordScreenState();
}

class _AddGenericRecordScreenState extends State<_AddGenericRecordScreen> {
  final _formKey = GlobalKey<FormState>();
  late final _name = TextEditingController(
    text: widget.employee?.name ?? widget.material?.name ?? '',
  );
  late final _second = TextEditingController(
    text: widget.employee?.role ?? widget.material?.quantity.toString() ?? '',
  );
  late final _third = TextEditingController(
    text: widget.employee?.phone ?? widget.material?.price.toString() ?? '',
  );
  String? receiptPath;

  @override
  void initState() {
    super.initState();
    receiptPath = widget.material?.receiptPath;
  }

  @override
  void dispose() {
    _name.dispose();
    _second.dispose();
    _third.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final data = AppData.instance;
    if (widget.module == AppModule.employees) {
      final employee = widget.employee;
      if (employee == null) {
        data.addEmployee(
          Employee(
            name: _name.text.trim(),
            role: _second.text.trim(),
            phone: _third.text.trim(),
          ),
        );
      } else {
        employee.name = _name.text.trim();
        employee.role = _second.text.trim();
        employee.phone = _third.text.trim();
        data.updateEmployee(employee);
      }
    } else if (widget.module == AppModule.materials) {
      final material = widget.material;
      if (material == null) {
        data.addMaterial(
          MaterialItem(
            name: _name.text.trim(),
            quantity: int.tryParse(_second.text.trim()) ?? 0,
            price: double.tryParse(_third.text.trim()) ?? 0,
            receiptPath: receiptPath,
          ),
        );
      } else {
        material.name = _name.text.trim();
        material.quantity =
            int.tryParse(_second.text.trim()) ?? material.quantity;
        material.price = double.tryParse(_third.text.trim()) ?? material.price;
        material.receiptPath = receiptPath ?? material.receiptPath;
        data.updateMaterial(material);
      }
    }
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final isEmp = widget.module == AppModule.employees;
    return Scaffold(
      backgroundColor: AppColors.paper,
      appBar: AppBar(
        title: Text(
          '${widget.employee != null || widget.material != null ? 'Edit' : 'Add'} ${isEmp ? 'Employee' : 'Material Record'}',
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(18),
          children: [
            TextFormField(
              controller: _name,
              decoration: InputDecoration(
                labelText: isEmp ? 'Employee Full Name' : 'Material Name',
              ),
              validator: (v) => v!.isEmpty ? 'Required' : null,
            ),
            if (!isEmp) ...[
              const SizedBox(height: 14),
              OutlinedButton.icon(
                onPressed: () async {
                  final image = await ImagePicker().pickImage(
                    source: ImageSource.camera,
                  );
                  if (image != null && mounted) {
                    setState(() => receiptPath = image.path);
                  }
                },
                icon: const Icon(Icons.camera_alt_outlined),
                label: Text(
                  receiptPath == null
                      ? 'Take photo of receipt (optional)'
                      : 'Receipt photo captured',
                ),
              ),
            ],
            const SizedBox(height: 14),
            TextFormField(
              controller: _second,
              decoration: InputDecoration(
                labelText: isEmp
                    ? 'Role (Detailer, Painter, etc.)'
                    : 'Quantity',
              ),
              validator: (v) => v!.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _third,
              decoration: InputDecoration(
                labelText: isEmp ? 'Phone Number' : 'Unit Price (₱)',
              ),
              validator: (v) => v!.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 28),
            FilledButton(
              onPressed: _save,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.burgundy,
                minimumSize: const Size.fromHeight(48),
              ),
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
