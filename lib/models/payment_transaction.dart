class PaymentTransaction {
  PaymentTransaction({
    required this.id,
    required this.amount,
    required this.date,
    String? referenceNumber,
    this.method = 'Cash',
    this.note = '',
  }) : referenceNumber = referenceNumber ?? _generateRef(date);

  final String id;
  final double amount;
  final DateTime date;
  final String referenceNumber;
  final String method;
  final String note;

  static String _generateRef(DateTime d) {
    final y = d.year.toString().padLeft(4, '0');
    final m = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    final seq = (DateTime.now().millisecondsSinceEpoch % 1000)
        .toString()
        .padLeft(3, '0');
    return 'PAY-$y$m$day-$seq';
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'amount': amount,
    'date': date.toIso8601String(),
    'reference_number': referenceNumber,
    'method': method,
    'note': note,
  };

  factory PaymentTransaction.fromMap(Map<String, dynamic> map) =>
      PaymentTransaction(
        id: map['id']?.toString() ?? '',
        amount: (map['amount'] as num?)?.toDouble() ?? 0.0,
        date: map['date'] != null
            ? (DateTime.tryParse(map['date']) ?? DateTime.now())
            : DateTime.now(),
        referenceNumber: map['reference_number'] ?? map['referenceNumber'],
        method: map['method'] ?? 'Cash',
        note: map['note'] ?? '',
      );
}
