class ServiceRecord {
  ServiceRecord({
    required this.customer,
    required this.vehicle,
    required this.type,
    required this.price,
    this.status = 'Pending',
  });
  String customer;
  String vehicle;
  String type;
  double price;
  String status;
}
