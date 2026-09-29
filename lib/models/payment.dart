class Payment {
  Payment({
    required this.customer,
    required this.service,
    required this.total,
    required this.paid,
    String? id,
    this.bookingId,
    this.method = 'Cash',
    DateTime? date,
  }) : id = id ?? DateTime.now().millisecondsSinceEpoch.toString(),
       date = date ?? DateTime.now();

  final String id;
  final String? bookingId;
  String customer;
  String service;
  double total;
  double paid;
  String method;
  DateTime date;

  double get balance => (total - paid).clamp(0, total).toDouble();
  String get status => balance <= 0
      ? 'Fully Paid'
      : paid > 0
      ? 'Balance Due'
      : 'Down Payment';

  Map<String, dynamic> toMap() => {
    'id': id,
    'booking_id': bookingId,
    'customer': customer,
    'service': service,
    'total': total,
    'paid': paid,
    'method': method,
    'date': date.toIso8601String(),
  };

  factory Payment.fromMap(Map<String, dynamic> map) => Payment(
    id: map['id']?.toString(),
    bookingId: map['booking_id']?.toString(),
    customer: map['customer'] ?? '',
    service: map['service'] ?? '',
    total: (map['total'] as num?)?.toDouble() ?? 0.0,
    paid: (map['paid'] as num?)?.toDouble() ?? 0.0,
    method: map['method'] ?? 'Cash',
    date: map['date'] != null ? DateTime.tryParse(map['date']) : null,
  );
}
