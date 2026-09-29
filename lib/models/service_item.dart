class ServiceItem {
  ServiceItem({
    required this.id,
    required this.name,
    required this.price,
    String assignedEmployee = '',
    this.employeeRole = '',
    List<String>? assignedWorkers,
    this.commissionRate = 0.40,
    this.commissionPaid = false,
    this.completedAt,
  }) : assignedEmployee = (assignedEmployee.isNotEmpty
           ? assignedEmployee
           : (assignedWorkers != null && assignedWorkers.isNotEmpty
                 ? assignedWorkers.first
                 : ''));

  final String id;
  String name;
  double price; // Price snapshot
  String assignedEmployee;
  String employeeRole;
  double commissionRate; // 40% = 0.40
  bool commissionPaid;
  DateTime? completedAt;

  // Compatibility getter in case old code looks for assignedWorkers
  List<String> get assignedWorkers =>
      assignedEmployee.isNotEmpty ? [assignedEmployee] : [];

  // Individual service commission calculations:
  // Employee receives 40% of the service price
  double get employeeShare => price * commissionRate;
  // Business/Owner receives 60% of the service price
  double get ownerShare => price * (1.0 - commissionRate);

  String get commissionStatus => commissionPaid ? 'Paid' : 'Unpaid';

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'price': price,
    'assigned_employee': assignedEmployee,
    'employee_role': employeeRole,
    'commission_rate': commissionRate,
    'commission_paid': commissionPaid,
    'completed_at': completedAt?.toIso8601String(),
  };

  factory ServiceItem.fromMap(Map<String, dynamic> map) => ServiceItem(
    id: map['id']?.toString() ?? '',
    name: map['name'] ?? '',
    price: (map['price'] as num?)?.toDouble() ?? 0.0,
    assignedEmployee:
        map['assigned_employee'] ??
        ((map['assigned_workers'] as List<dynamic>?)?.isNotEmpty == true
            ? (map['assigned_workers'] as List<dynamic>).first.toString()
            : ''),
    employeeRole: map['employee_role'] ?? '',
    commissionRate: (map['commission_rate'] as num?)?.toDouble() ?? 0.40,
    commissionPaid: map['commission_paid'] ?? false,
    completedAt: map['completed_at'] != null
        ? DateTime.tryParse(map['completed_at'])
        : null,
  );

  ServiceItem copyWith({
    String? id,
    String? name,
    double? price,
    String? assignedEmployee,
    String? employeeRole,
    double? commissionRate,
    bool? commissionPaid,
    DateTime? completedAt,
  }) {
    return ServiceItem(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      assignedEmployee: assignedEmployee ?? this.assignedEmployee,
      employeeRole: employeeRole ?? this.employeeRole,
      commissionRate: commissionRate ?? this.commissionRate,
      commissionPaid: commissionPaid ?? this.commissionPaid,
      completedAt: completedAt ?? this.completedAt,
    );
  }
}
