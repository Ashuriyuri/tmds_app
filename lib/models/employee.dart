class Employee {
  Employee({
    required this.name,
    required this.role,
    required this.phone,
    String? id,
    this.active = true,
  }) : id = id ?? name.toLowerCase().replaceAll(' ', '_');

  final String id;
  String name;
  String role;
  String phone;
  bool active;

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'role': role,
    'phone': phone,
    'active': active,
  };

  factory Employee.fromMap(Map<String, dynamic> map) => Employee(
    id: map['id']?.toString(),
    name: map['name'] ?? '',
    role: map['role'] ?? '',
    phone: map['phone'] ?? '',
    active: map['active'] ?? true,
  );
}
