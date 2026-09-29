import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../models/customer_booking.dart';
import '../../models/employee.dart';
import '../../models/service_item.dart';
import '../../services/app_data.dart';
import '../../widgets/status_badge.dart';

class AddCustomerScreen extends StatefulWidget {
  const AddCustomerScreen({super.key});

  @override
  State<AddCustomerScreen> createState() => _AddCustomerScreenState();
}

class _AddCustomerScreenState extends State<AddCustomerScreen> {
  // Two-step customer and service form.
  int _currentStep = 0;
  final _formKeyCustomer = GlobalKey<FormState>();

  // Step 1: Customer Details (Data preserved across steps!)
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _plateController = TextEditingController();
  final _colorController = TextEditingController();
  final _notesController = TextEditingController();

  String _selectedBrand = 'Toyota';
  String _selectedModel = 'Fortuner';

  final List<String> _brands = [
    'Toyota',
    'Honda',
    'Mitsubishi',
    'Ford',
    'Nissan',
    'Hyundai',
    'Kia',
    'Mazda',
    'Subaru',
    'Suzuki',
    'Other',
  ];

  final Map<String, List<String>> _modelsByBrand = {
    'Toyota': [
      'Fortuner',
      'Vios',
      'Innova',
      'Hilux',
      'Corolla Cross',
      'Wigo',
      'Avanza',
      'Other',
    ],
    'Honda': ['Civic', 'CR-V', 'City', 'BR-V', 'HR-V', 'Brio', 'Other'],
    'Mitsubishi': ['Mirage', 'Montero Sport', 'Xpander', 'Strada', 'Other'],
    'Ford': ['Ranger', 'Everest', 'Territory', 'Explorer', 'Other'],
    'Nissan': ['Navara', 'Terra', 'Almera', 'Livina', 'Other'],
    'Hyundai': ['Tucson', 'Staria', 'Creta', 'Accent', 'Other'],
    'Kia': ['Seltos', 'Carnival', 'Stonic', 'Sonet', 'Other'],
  };

  // Step 2: Services Details (Starts empty until admin adds them)
  final List<ServiceItem> _selectedServices = [];
  final _paymentInputController = TextEditingController(text: '0');

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _plateController.dispose();
    _colorController.dispose();
    _notesController.dispose();
    _paymentInputController.dispose();
    super.dispose();
  }

  double get totalDue =>
      _selectedServices.fold(0.0, (sum, item) => sum + item.price);

  double get suggestedDownPayment => totalDue * 0.50;

  double get enteredPayment =>
      double.tryParse(_paymentInputController.text.replaceAll(',', '')) ?? 0.0;

  double get remainingBalance {
    final bal = totalDue - enteredPayment;
    return bal < 0 ? 0 : bal;
  }

  String get calculatedServiceStatus {
    if (enteredPayment <= 0) return 'Pending';
    return 'In Progress';
  }

  String get calculatedPaymentStatus {
    if (enteredPayment <= 0) return 'Unpaid';
    if (remainingBalance <= 0) return 'Fully Paid';
    return 'Partially Paid';
  }

  void _onBrandChanged(String? brand) {
    if (brand == null) return;
    setState(() {
      _selectedBrand = brand;
      final models = _modelsByBrand[brand];
      _selectedModel = (models != null && models.isNotEmpty)
          ? models.first
          : 'Standard';
    });
  }

  void _handleBackNavigation() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    } else {
      Navigator.pop(context);
    }
  }

  void _openAddServiceDialog() {
    String? selectedMasterServiceId;
    final customNameController = TextEditingController();
    final customPriceController = TextEditingController();
    String? assignedEmpName;
    String selectedRoleFilter = 'All roles';

    final masterServices = AppData.instance.masterServices;
    final employees = AppData.instance.employees;

    showDialog(
      context: context,
      builder: (dialogCtx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final availableRoles = [
              'All roles',
              ...employees.map((e) => e.role).toSet(),
            ];

            final filteredEmployees = employees.where((emp) {
              if (selectedRoleFilter == 'All roles') return true;
              return emp.role.toLowerCase().contains(
                selectedRoleFilter.toLowerCase(),
              );
            }).toList();

            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: const Text(
                'Add Service to Customer',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 17,
                  color: AppColors.ink,
                ),
              ),
              content: SizedBox(
                width: double.maxFinite,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Quick choose from Master Services Catalog
                      if (masterServices.isNotEmpty) ...[
                        const Text(
                          'Select from Master Services',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                            color: AppColors.muted,
                          ),
                        ),
                        const SizedBox(height: 6),
                        DropdownButtonFormField<String>(
                          value: selectedMasterServiceId,
                          hint: const Text('Choose standard service...'),
                          isExpanded: true,
                          decoration: const InputDecoration(
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                          ),
                          items: masterServices.map((ms) {
                            return DropdownMenuItem(
                              value: ms.id,
                              child: Text(
                                '${ms.name} (₱${ms.defaultPrice.toStringAsFixed(0)})',
                                overflow: TextOverflow.ellipsis,
                              ),
                            );
                          }).toList(),
                          onChanged: (id) {
                            if (id != null) {
                              final ms = masterServices.firstWhere(
                                (item) => item.id == id,
                              );
                              setDialogState(() {
                                selectedMasterServiceId = id;
                                customNameController.text = ms.name;
                                customPriceController.text = ms.defaultPrice
                                    .toStringAsFixed(0);
                                // Suggest employee category filter
                                if (ms.category.toLowerCase().contains(
                                  'detailer',
                                )) {
                                  selectedRoleFilter = availableRoles
                                      .firstWhere(
                                        (r) => r.toLowerCase().contains(
                                          'detailer',
                                        ),
                                        orElse: () => 'All roles',
                                      );
                                } else if (ms.category.toLowerCase().contains(
                                  'painter',
                                )) {
                                  selectedRoleFilter = availableRoles
                                      .firstWhere(
                                        (r) =>
                                            r.toLowerCase().contains('painter'),
                                        orElse: () => 'All roles',
                                      );
                                }
                              });
                            }
                          },
                        ),
                        const SizedBox(height: 14),
                      ],

                      // Service Name
                      const Text(
                        'Service Name',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                          color: AppColors.muted,
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        controller: customNameController,
                        decoration: const InputDecoration(
                          hintText: 'e.g. Detailing, Full Body Paint...',
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Service Price (Snapshot)
                      const Text(
                        'Service Price Snapshot (₱)',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                          color: AppColors.muted,
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        controller: customPriceController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          prefixText: '₱ ',
                          hintText: '0',
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Divider(),
                      const SizedBox(height: 6),

                      // Assigned Employee Section (No "Main Worker" - individual per service)
                      const Text(
                        'Assigned Employee (Per Service)',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                          color: AppColors.ink,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Filter employee by role and select the specific worker for this job:',
                        style: TextStyle(fontSize: 11, color: AppColors.muted),
                      ),
                      const SizedBox(height: 8),

                      DropdownButtonFormField<String>(
                        value: selectedRoleFilter,
                        decoration: const InputDecoration(
                          labelText: 'Filter role',
                          prefixIcon: Icon(Icons.filter_alt_outlined),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 10,
                          ),
                        ),
                        items: availableRoles
                            .map(
                              (role) => DropdownMenuItem(
                                value: role,
                                child: Text(role),
                              ),
                            )
                            .toList(),
                        onChanged: (value) => setDialogState(() {
                          selectedRoleFilter = value ?? 'All roles';
                          assignedEmpName = null;
                        }),
                      ),
                      const SizedBox(height: 10),

                      if (filteredEmployees.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 8),
                          child: Text(
                            'No employees found for this role. Add employees in the Employees section.',
                            style: TextStyle(
                              color: AppColors.muted,
                              fontSize: 12,
                            ),
                          ),
                        )
                      else
                        DropdownButtonFormField<String>(
                          value: assignedEmpName,
                          hint: const Text('Select Assigned Employee'),
                          isExpanded: true,
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.person_outline),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 10,
                            ),
                          ),
                          items: filteredEmployees.map((emp) {
                            return DropdownMenuItem(
                              value: emp.name,
                              child: Text(
                                '${emp.name} (${emp.role})',
                                overflow: TextOverflow.ellipsis,
                              ),
                            );
                          }).toList(),
                          onChanged: (val) =>
                              setDialogState(() => assignedEmpName = val),
                        ),

                      const SizedBox(height: 14),

                      // Live Commission Preview
                      Builder(
                        builder: (ctx) {
                          final p =
                              double.tryParse(
                                customPriceController.text.trim(),
                              ) ??
                              0.0;
                          final empShare = p * 0.40;
                          final ownerShare = p * 0.60;
                          return Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.paper,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'Employee Share (40%):',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Text(
                                      '₱${empShare.toStringAsFixed(0)}',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.burgundy,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'Owner Share (60%):',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Text(
                                      '₱${ownerShare.toStringAsFixed(0)}',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.ink,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogCtx),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () {
                    final name = customNameController.text.trim();
                    final price =
                        double.tryParse(customPriceController.text.trim()) ??
                        0.0;
                    if (name.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please enter a service name'),
                        ),
                      );
                      return;
                    }
                    if (price <= 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please enter a valid service price'),
                        ),
                      );
                      return;
                    }

                    final empRole = employees
                        .firstWhere(
                          (e) => e.name == assignedEmpName,
                          orElse: () => Employee(name: '', role: '', phone: ''),
                        )
                        .role;

                    setState(() {
                      _selectedServices.add(
                        ServiceItem(
                          id: 'srv_${DateTime.now().millisecondsSinceEpoch}',
                          name: name,
                          price: price,
                          assignedEmployee: assignedEmpName ?? 'Unassigned',
                          employeeRole: empRole,
                          commissionRate: 0.40,
                          commissionPaid: false,
                        ),
                      );
                    });
                    Navigator.pop(dialogCtx);
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.burgundy,
                    minimumSize: const Size(90, 40),
                  ),
                  child: const Text('Add Service'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _saveCustomerAndServices() {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter Customer Full Name'),
          backgroundColor: AppColors.burgundy,
        ),
      );
      setState(() => _currentStep = 0);
      return;
    }

    if (_selectedServices.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please add at least one service before saving. Services start empty until you add them.',
          ),
          backgroundColor: AppColors.burgundy,
        ),
      );
      setState(() => _currentStep = 1);
      return;
    }

    final newBooking = CustomerBooking(
      id: 'book_${DateTime.now().millisecondsSinceEpoch}',
      customerName: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      address: _addressController.text.trim(),
      brand: _selectedBrand,
      model: _selectedModel,
      plateNumber: _plateController.text.trim(),
      color: _colorController.text.trim(),
      notes: _notesController.text.trim(),
      services: List.from(_selectedServices),
      actualAmountPaid: 0.0,
      serviceStatus: calculatedServiceStatus,
      paymentStatus: calculatedPaymentStatus,
    );

    // If downpayment or initial payment entered, record transaction with generated reference number
    if (enteredPayment > 0) {
      newBooking.recordPayment(
        enteredPayment,
        method: 'Cash',
        note: 'Initial Payment / Downpayment',
      );
    }

    AppData.instance.addBooking(newBooking);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Customer & Services saved successfully for ${newBooking.customerName}!',
        ),
        backgroundColor: AppColors.success,
      ),
    );

    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _currentStep == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && _currentStep > 0) {
          setState(() => _currentStep--);
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.paper,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0.5,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.ink),
            onPressed: _handleBackNavigation,
          ),
          title: const Text(
            'Add Customer & Service',
            style: const TextStyle(
              color: AppColors.ink,
              fontWeight: FontWeight.w800,
              fontSize: 18,
            ),
          ),
        ),
        body: _currentStep == 0
            ? _buildCustomerDetailsStep()
            : _buildServiceDetailsStep(),
      ),
    );
  }

  // ==========================================================
  // TAB 1: CUSTOMER DETAILS
  // ==========================================================
  Widget _buildCustomerDetailsStep() {
    final currentModels =
        _modelsByBrand[_selectedBrand] ?? ['Standard', 'Other'];

    return Form(
      key: _formKeyCustomer,
      child: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.burgundy.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'Tab 1 of 2: Customer Information',
                  style: TextStyle(
                    color: AppColors.burgundy,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Customer Full Name
          const Text(
            'Customer Full Name *',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 13,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(hintText: 'e.g. Ashuri Alonzo'),
            validator: (val) => val == null || val.trim().isEmpty
                ? 'Customer name is required'
                : null,
          ),
          const SizedBox(height: 16),

          // Phone Number
          const Text(
            'Phone Number *',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 13,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(hintText: 'e.g. 0912 345 6789'),
            validator: (val) => val == null || val.trim().isEmpty
                ? 'Phone number is required'
                : null,
          ),
          const SizedBox(height: 16),

          // Home Address
          const Text(
            'Home Address',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 13,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: _addressController,
            decoration: const InputDecoration(hintText: 'Enter home address'),
          ),
          const SizedBox(height: 20),

          // Vehicle Information Section
          const Text(
            'Vehicle Information',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 15,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 12),

          // Brand and Model Row
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Brand',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                        color: AppColors.muted,
                      ),
                    ),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      value: _selectedBrand,
                      decoration: const InputDecoration(
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 14,
                        ),
                      ),
                      items: _brands
                          .map(
                            (b) => DropdownMenuItem(value: b, child: Text(b)),
                          )
                          .toList(),
                      onChanged: _onBrandChanged,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Model',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                        color: AppColors.muted,
                      ),
                    ),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      value: currentModels.contains(_selectedModel)
                          ? _selectedModel
                          : currentModels.first,
                      decoration: const InputDecoration(
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 14,
                        ),
                      ),
                      items: currentModels
                          .map(
                            (m) => DropdownMenuItem(value: m, child: Text(m)),
                          )
                          .toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedModel = val);
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Plate Number and Color Row
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Plate Number',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                        color: AppColors.muted,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _plateController,
                      decoration: const InputDecoration(
                        hintText: 'e.g. ABC 123',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Color',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                        color: AppColors.muted,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _colorController,
                      decoration: const InputDecoration(hintText: 'e.g. Black'),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Notes
          const Text(
            'Special Notes / Remarks',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 13,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: _notesController,
            maxLines: 2,
            decoration: const InputDecoration(
              hintText: 'Any specific instructions or customer notes...',
            ),
          ),
          const SizedBox(height: 32),

          // Proceed to Tab 2
          FilledButton(
            onPressed: () {
              if (_formKeyCustomer.currentState!.validate()) {
                setState(() => _currentStep = 1);
              }
            },
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.burgundy,
              minimumSize: const Size.fromHeight(50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Next Step',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                ),
                SizedBox(width: 8),
                Icon(Icons.arrow_forward, size: 18),
              ],
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  // ==========================================================
  // TAB 2: SERVICE DETAILS & DOWNPAYMENT
  // ==========================================================
  Widget _buildServiceDetailsStep() {
    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        // Top breadcrumb / persistence confirmation
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.check_circle_outline,
                color: AppColors.success,
                size: 20,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Customer: ${_nameController.text.trim()} • Vehicle: $_selectedBrand $_selectedModel',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.ink,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),

        // Services Header & Add Button
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Expanded(
              child: Text(
                'Services Applied',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                  color: AppColors.ink,
                ),
              ),
            ),
            FilledButton.icon(
              onPressed: _openAddServiceDialog,
              icon: const Icon(Icons.add, size: 16),
              label: const Text('Add service'),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.burgundy,
                foregroundColor: Colors.white,
                minimumSize: const Size(0, 36),
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        const SizedBox(height: 2),
        // List of Selected Services
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: AppColors.border),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                if (_selectedServices.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(
                            Icons.car_repair_outlined,
                            color: AppColors.muted,
                            size: 36,
                          ),
                          SizedBox(height: 8),
                          Text(
                            'No services added yet.\nTap "+ Add Service" to assign services & workers.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: AppColors.muted,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  ..._selectedServices.map(
                    (service) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.paper,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    service.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14,
                                      color: AppColors.ink,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    'Worker: ${service.assignedEmployee.isNotEmpty ? service.assignedEmployee : 'Unassigned'}'
                                    '${service.employeeRole.isNotEmpty ? ' (${service.employeeRole})' : ''}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.burgundy,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Employee 40%: ₱${service.employeeShare.toStringAsFixed(0)} • Owner 60%: ₱${service.ownerShare.toStringAsFixed(0)}',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: AppColors.muted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '₱${service.price.toStringAsFixed(0)}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 15,
                                    color: AppColors.ink,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete_outline,
                                    size: 20,
                                    color: AppColors.burgundy,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _selectedServices.remove(service);
                                    });
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
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
                      '₱${totalDue.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 18,
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

        // Downpayment Card
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
                      '50% Downpayment Guide',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.ink,
                        fontSize: 13,
                      ),
                    ),
                    Text(
                      '₱${suggestedDownPayment.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: AppColors.ink,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    const Expanded(
                      flex: 4,
                      child: Text(
                        'Input Downpayment',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                          color: AppColors.ink,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 5,
                      child: TextField(
                        controller: _paymentInputController,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.right,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          color: AppColors.ink,
                          fontSize: 15,
                        ),
                        decoration: const InputDecoration(
                          prefixText: '₱ ',
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                        ),
                        onChanged: (_) => setState(() {}),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ActionChip(
                      label: const Text(
                        '₱0 (Pending)',
                        style: TextStyle(fontSize: 11),
                      ),
                      onPressed: () {
                        setState(() => _paymentInputController.text = '0');
                      },
                    ),
                    const SizedBox(width: 8),
                    ActionChip(
                      label: Text(
                        '50% (₱${suggestedDownPayment.toStringAsFixed(0)})',
                        style: const TextStyle(fontSize: 11),
                      ),
                      onPressed: () {
                        setState(() {
                          _paymentInputController.text = suggestedDownPayment
                              .toStringAsFixed(0);
                        });
                      },
                    ),
                  ],
                ),
                const Divider(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Remaining Balance',
                      style: TextStyle(color: AppColors.muted, fontSize: 13),
                    ),
                    Text(
                      '₱${remainingBalance.toStringAsFixed(0)}',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                        color: remainingBalance > 0
                            ? AppColors.statusInProgressText
                            : AppColors.statusCompletedText,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Navigation Buttons
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => setState(() => _currentStep = 0),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.ink,
                  side: const BorderSide(color: AppColors.border),
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Cancel',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              flex: 2,
              child: FilledButton(
                onPressed: _saveCustomerAndServices,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.burgundy,
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Save',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(Icons.save_outlined, size: 18),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 30),
      ],
    );
  }

  // ==========================================================
  // STEP 3: REVIEW / SUMMARY SCREEN BEFORE FINAL SAVE
  // ==========================================================
  Widget _buildReviewSummaryStep() {
    final totalEmpShare = _selectedServices.fold<double>(
      0.0,
      (sum, s) => sum + s.employeeShare,
    );
    final totalOwnerShare = _selectedServices.fold<double>(
      0.0,
      (sum, s) => sum + s.ownerShare,
    );

    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        const Text(
          'Please review the booking details before final saving:',
          style: TextStyle(
            color: AppColors.muted,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 14),

        // Customer & Vehicle Review Card
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
                const Row(
                  children: [
                    Icon(
                      Icons.person_pin_outlined,
                      color: AppColors.burgundy,
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Customer & Vehicle',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                        color: AppColors.ink,
                      ),
                    ),
                  ],
                ),
                const Divider(height: 20),
                _summaryRow('Customer Name', _nameController.text.trim()),
                _summaryRow('Phone Number', _phoneController.text.trim()),
                if (_addressController.text.trim().isNotEmpty)
                  _summaryRow('Address', _addressController.text.trim()),
                _summaryRow(
                  'Vehicle',
                  '$_selectedBrand $_selectedModel'
                      '${_plateController.text.isNotEmpty ? ' (${_plateController.text.trim()})' : ''}',
                ),
                if (_colorController.text.trim().isNotEmpty)
                  _summaryRow('Color', _colorController.text.trim()),
                if (_notesController.text.trim().isNotEmpty)
                  _summaryRow('Notes', _notesController.text.trim()),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),

        // Services & Commissions Breakdown Card
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
                const Row(
                  children: [
                    Icon(
                      Icons.build_circle_outlined,
                      color: AppColors.burgundy,
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Services & Commission Breakdown',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                        color: AppColors.ink,
                      ),
                    ),
                  ],
                ),
                const Divider(height: 20),
                ..._selectedServices.map((service) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.paper,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              service.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                                color: AppColors.ink,
                              ),
                            ),
                            Text(
                              '₱${service.price.toStringAsFixed(0)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 14,
                                color: AppColors.ink,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Assigned: ${service.assignedEmployee.isNotEmpty ? service.assignedEmployee : 'Unassigned'}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.burgundy,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Employee Share (40%): ₱${service.employeeShare.toStringAsFixed(0)}',
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.muted,
                              ),
                            ),
                            Text(
                              'Owner Share (60%): ₱${service.ownerShare.toStringAsFixed(0)}',
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.muted,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }),
                const Divider(height: 18),
                _summaryRow(
                  'Total Employee Share (40%)',
                  '₱${totalEmpShare.toStringAsFixed(0)}',
                  highlight: true,
                ),
                _summaryRow(
                  'Total Owner Share (60%)',
                  '₱${totalOwnerShare.toStringAsFixed(0)}',
                  highlight: true,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),

        // Payment Summary Card
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
                const Row(
                  children: [
                    Icon(
                      Icons.payment_outlined,
                      color: AppColors.burgundy,
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Payment Summary',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                        color: AppColors.ink,
                      ),
                    ),
                  ],
                ),
                const Divider(height: 20),
                _summaryRow(
                  'Total Amount Due',
                  '₱${totalDue.toStringAsFixed(0)}',
                ),
                _summaryRow(
                  'Initial Payment / Downpayment',
                  '₱${enteredPayment.toStringAsFixed(0)}',
                ),
                _summaryRow(
                  'Remaining Balance',
                  '₱${remainingBalance.toStringAsFixed(0)}',
                  highlight: remainingBalance > 0,
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Payment Status',
                      style: TextStyle(color: AppColors.muted, fontSize: 13),
                    ),
                    StatusBadge(calculatedPaymentStatus),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Service Status',
                      style: TextStyle(color: AppColors.muted, fontSize: 13),
                    ),
                    StatusBadge(calculatedServiceStatus),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Back to Edit & Final Save Buttons
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => setState(() => _currentStep = 1),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.ink,
                  side: const BorderSide(color: AppColors.border),
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Back to Edit',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              flex: 2,
              child: FilledButton(
                onPressed: _saveCustomerAndServices,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.burgundy,
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.save_outlined, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Save Booking',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 30),
      ],
    );
  }

  Widget _summaryRow(String label, String value, {bool highlight = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: AppColors.muted, fontSize: 13),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 13,
              color: highlight ? AppColors.burgundy : AppColors.ink,
            ),
          ),
        ],
      ),
    );
  }
}
