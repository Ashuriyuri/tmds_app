class MaterialItem {
  MaterialItem({
    required this.name,
    required this.quantity,
    required this.price,
    String? id,
    DateTime? datePurchased,
    this.supplier = '',
    this.receiptPath,
    this.notes = '',
  }) : id = id ?? 'mat_${DateTime.now().millisecondsSinceEpoch}',
       datePurchased = datePurchased ?? DateTime.now();

  final String id;
  String name;
  int quantity;
  double price; // unit cost / price
  DateTime datePurchased;
  String supplier;
  String? receiptPath;
  String notes;

  double get totalExpense => quantity * price;

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'quantity': quantity,
    'price': price,
    'date_purchased': datePurchased.toIso8601String(),
    'supplier': supplier,
    'receipt_path': receiptPath,
    'notes': notes,
  };

  factory MaterialItem.fromMap(Map<String, dynamic> map) => MaterialItem(
    id: map['id']?.toString(),
    name: map['name'] ?? '',
    quantity: (map['quantity'] as num?)?.toInt() ?? 0,
    price: (map['price'] as num?)?.toDouble() ?? 0.0,
    datePurchased: map['date_purchased'] != null
        ? (DateTime.tryParse(map['date_purchased']) ?? DateTime.now())
        : DateTime.now(),
    supplier: map['supplier'] ?? '',
    receiptPath: map['receipt_path'] ?? map['receiptPath'],
    notes: map['notes'] ?? '',
  );
}
