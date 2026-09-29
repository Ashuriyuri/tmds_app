class Customer {
  Customer({
    required this.id,
    required this.name,
    required this.phone,
    required this.vehicle,
    this.address = '',
    this.plateNumber = '',
    this.color = '',
    this.notes = '',
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  final String id;
  String name;
  String phone;
  String address;
  String vehicle;
  String plateNumber;
  String color;
  String notes;
  DateTime createdAt;

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'phone': phone,
    'address': address,
    'vehicle': vehicle,
    'plate_number': plateNumber,
    'color': color,
    'notes': notes,
    'created_at': createdAt.toIso8601String(),
  };

  factory Customer.fromMap(Map<String, dynamic> map) => Customer(
    id: map['id']?.toString() ?? '',
    name: map['name'] ?? '',
    phone: map['phone'] ?? '',
    address: map['address'] ?? '',
    vehicle: map['vehicle'] ?? '',
    plateNumber: map['plate_number'] ?? map['plateNumber'] ?? '',
    color: map['color'] ?? '',
    notes: map['notes'] ?? '',
    createdAt: map['created_at'] != null
        ? DateTime.tryParse(map['created_at'])
        : null,
  );
}
