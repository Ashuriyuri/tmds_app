import 'payment_transaction.dart';
import 'service_item.dart';

class CustomerBooking {
  CustomerBooking({
    required this.id,
    required this.customerName,
    required this.phone,
    this.address = '',
    this.brand = '',
    this.model = '',
    String? vehicle,
    this.plateNumber = '',
    this.color = '',
    this.notes = '',
    String? assignedMechanic,
    String? mainWorker,
    List<ServiceItem>? services,
    this.actualAmountPaid = 0.0,
    String? serviceStatus,
    String? paymentStatus,
    List<PaymentTransaction>? paymentHistory,
    DateTime? createdAt,
  }) : vehicle =
           vehicle ??
           (brand.isNotEmpty || model.isNotEmpty
               ? '$brand $model'.trim()
               : 'Vehicle'),
       services = services ?? [],
       paymentHistory = paymentHistory ?? [],
       createdAt = createdAt ?? DateTime.now(),
       _explicitServiceStatus = serviceStatus,
       _explicitPaymentStatus = paymentStatus;

  final String id;
  String customerName;
  String phone;
  String address;
  String brand;
  String model;
  String vehicle;
  String plateNumber;
  String color;
  String notes;
  List<ServiceItem> services;
  double actualAmountPaid;
  String? _explicitServiceStatus;
  String? _explicitPaymentStatus;
  List<PaymentTransaction> paymentHistory;
  DateTime createdAt;

  double get totalAmount =>
      services.fold<double>(0.0, (sum, item) => sum + item.price);

  double get suggestedDownPayment => (totalAmount * 0.50);

  double get balance {
    final rem = totalAmount - actualAmountPaid;
    return rem < 0 ? 0 : rem;
  }

  // Total commissions across all individual services for this customer
  double get totalEmployeeCommissions =>
      services.fold<double>(0.0, (sum, item) => sum + item.employeeShare);

  double get totalOwnerShare =>
      services.fold<double>(0.0, (sum, item) => sum + item.ownerShare);

  // Service Status: Pending, In Progress, Completed, Cancelled (Removed 'Released')
  String get serviceStatus {
    if (_explicitServiceStatus != null && _explicitServiceStatus!.isNotEmpty) {
      if (_explicitServiceStatus == 'In-Progress') return 'In Progress';
      return _explicitServiceStatus!;
    }
    if (actualAmountPaid <= 0) {
      return 'Pending';
    }
    return 'In Progress';
  }

  set serviceStatus(String status) {
    _explicitServiceStatus = status == 'In-Progress' ? 'In Progress' : status;
  }

  // Payment Status: Unpaid, Partially Paid, Fully Paid
  String get paymentStatus {
    if (_explicitPaymentStatus != null && _explicitPaymentStatus!.isNotEmpty) {
      return _explicitPaymentStatus!;
    }
    if (actualAmountPaid <= 0) {
      return 'Unpaid';
    }
    if (balance <= 0) {
      return 'Fully Paid';
    }
    return 'Partially Paid';
  }

  set paymentStatus(String status) {
    _explicitPaymentStatus = status;
  }

  // Receipt Ready rule: Service is Completed AND Payment is Fully Paid
  bool get isReceiptReady =>
      serviceStatus == 'Completed' && paymentStatus == 'Fully Paid';

  void recordPayment(
    double amount, {
    String method = 'Cash',
    String note = '',
    DateTime? date,
    String? referenceNumber,
  }) {
    actualAmountPaid += amount;
    paymentHistory.insert(
      0,
      PaymentTransaction(
        id: 'txn_${DateTime.now().millisecondsSinceEpoch}',
        amount: amount,
        date: date ?? DateTime.now(),
        referenceNumber: referenceNumber,
        method: method,
        note: note,
      ),
    );

    if (balance <= 0) {
      _explicitPaymentStatus = 'Fully Paid';
    } else {
      _explicitPaymentStatus = 'Partially Paid';
    }

    if ((_explicitServiceStatus == 'Pending' ||
            _explicitServiceStatus == null) &&
        actualAmountPaid > 0) {
      _explicitServiceStatus = 'In Progress';
    }
  }

  String get servicesSummary {
    if (services.isEmpty) return 'No services added';
    return services.map((s) => s.name).join(', ');
  }

  String get vehicleDisplay {
    final v = vehicle.isNotEmpty ? vehicle : '$brand $model'.trim();
    if (plateNumber.isNotEmpty) {
      return '$v ($plateNumber)';
    }
    return v.isNotEmpty ? v : 'No vehicle specified';
  }

  // Backwards compatibility getters & setters for code still querying single worker/mechanic:
  String get assignedMechanic {
    final workers = services
        .map((s) => s.assignedEmployee)
        .where((e) => e.isNotEmpty)
        .toSet()
        .toList();
    return workers.join(', ');
  }

  set assignedMechanic(String val) {
    if (val.isNotEmpty && services.isNotEmpty) {
      for (final s in services) {
        if (s.assignedEmployee.isEmpty) {
          s.assignedEmployee = val;
        }
      }
    }
  }

  String get mainWorker => assignedMechanic;
  set mainWorker(String val) => assignedMechanic = val;

  Map<String, dynamic> toMap() => {
    'id': id,
    'customer_name': customerName,
    'phone': phone,
    'address': address,
    'brand': brand,
    'model': model,
    'vehicle': vehicle,
    'plate_number': plateNumber,
    'color': color,
    'notes': notes,
    'actual_amount_paid': actualAmountPaid,
    'service_status': serviceStatus,
    'payment_status': paymentStatus,
    'created_at': createdAt.toIso8601String(),
    'services': services.map((s) => s.toMap()).toList(),
    'payment_history': paymentHistory.map((p) => p.toMap()).toList(),
  };

  factory CustomerBooking.fromMap(Map<String, dynamic> map) => CustomerBooking(
    id: map['id']?.toString() ?? '',
    customerName: map['customer_name'] ?? map['customerName'] ?? '',
    phone: map['phone'] ?? '',
    address: map['address'] ?? '',
    brand: map['brand'] ?? '',
    model: map['model'] ?? '',
    vehicle: map['vehicle'],
    plateNumber: map['plate_number'] ?? map['plateNumber'] ?? '',
    color: map['color'] ?? '',
    notes: map['notes'] ?? '',
    actualAmountPaid: (map['actual_amount_paid'] as num?)?.toDouble() ?? 0.0,
    serviceStatus: map['service_status'],
    paymentStatus: map['payment_status'],
    createdAt: map['created_at'] != null
        ? DateTime.tryParse(map['created_at'])
        : null,
    services:
        (map['services'] as List<dynamic>?)
            ?.map((e) => ServiceItem.fromMap(Map<String, dynamic>.from(e)))
            .toList() ??
        [],
    paymentHistory:
        (map['payment_history'] as List<dynamic>?)
            ?.map(
              (e) => PaymentTransaction.fromMap(Map<String, dynamic>.from(e)),
            )
            .toList() ??
        [],
  );
}
