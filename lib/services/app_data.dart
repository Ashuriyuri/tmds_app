import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/customer.dart';
import '../models/customer_booking.dart';
import '../models/employee.dart';
import '../models/material.dart';
import '../models/payment.dart';
import '../models/service_item.dart';

class MasterService {
  MasterService({
    required this.id,
    required this.name,
    required this.defaultPrice,
    required this.category,
    this.description = '',
  });

  final String id;
  final String name;
  final double defaultPrice;
  final String category; // e.g. 'Detailer', 'Painter', 'Technician'
  final String description;
}

class AppData extends ChangeNotifier {
  AppData._() {
    _initMasterServices();
    _initReferenceData();
  }
  static final instance = AppData._();

  // Clean initial state: Starts completely empty as requested
  final List<CustomerBooking> bookings = [];
  List<CustomerBooking> get services => bookings;
  final List<Customer> customers = [];
  final List<Employee> employees = [];
  final List<MaterialItem> materials = [];
  final List<Payment> payments = [];

  // Master Services Catalog (Price snapshots are copied from here)
  final List<MasterService> masterServices = [];

  void _initMasterServices() {
    masterServices.addAll([
      MasterService(
        id: 'ms_1',
        name: 'Exterior Detailing',
        defaultPrice: 3000,
        category: 'Car Detailer',
        description: 'Comprehensive exterior hand wash, buff, and wax',
      ),
      MasterService(
        id: 'ms_2',
        name: 'Interior Deep Cleaning',
        defaultPrice: 2500,
        category: 'Car Detailer',
        description:
            'Deep vacuum, upholstery shampoo, and leather conditioning',
      ),
      MasterService(
        id: 'ms_3',
        name: 'Ceramic Coating',
        defaultPrice: 8500,
        category: 'Master Detailer',
        description: '9H nano-ceramic multi-year protective coating',
      ),
      MasterService(
        id: 'ms_4',
        name: 'Full Body Paint',
        defaultPrice: 60000,
        category: 'Car Painter',
        description: 'Complete exterior strip and multi-coat oven bake paint',
      ),
      MasterService(
        id: 'ms_5',
        name: 'Panel Touch-up & Repaint',
        defaultPrice: 3500,
        category: 'Car Painter',
        description: 'Single panel scratch removal and color-matched repaint',
      ),
      MasterService(
        id: 'ms_6',
        name: 'Engine Bay Cleaning',
        defaultPrice: 1500,
        category: 'Technician',
        description: 'Degrease, steam clean, and engine dressing',
      ),
    ]);
  }

  void _initReferenceData() {
    employees.addAll([
      Employee(
        name: 'Ashuri Alonzo',
        role: 'Master Detailer',
        phone: '0917 888 1234',
      ),
      Employee(
        name: 'Juan Dela Cruz',
        role: 'Car Detailer',
        phone: '0912 345 6789',
      ),
      Employee(
        name: 'Jose Dela Cruz',
        role: 'Car Painter',
        phone: '0918 777 4321',
      ),
      Employee(name: 'Ambot', role: 'Purchaser', phone: '0919 666 9876'),
    ]);

    final sampleBookings = [
      CustomerBooking(
        id: 'book-001',
        customerName: 'Mario Antonio Alano',
        phone: '0917 123 4567',
        address: 'Quezon City',
        brand: 'Toyota',
        model: 'Fortuner',
        plateNumber: 'ABC 123',
        color: 'Black',
        services: [
          ServiceItem(
            id: 'service-001',
            name: 'Exterior Detailing',
            price: 4500,
            assignedEmployee: 'Juan Dela Cruz',
            employeeRole: 'Car Detailer',
          ),
        ],
        actualAmountPaid: 2250,
        serviceStatus: 'In Progress',
        paymentStatus: 'Partially Paid',
      ),
      CustomerBooking(
        id: 'book-002',
        customerName: 'Glenn Gomez',
        phone: '0918 234 5678',
        address: 'Pasig City',
        brand: 'Mitsubishi',
        model: 'Mirage',
        plateNumber: 'XYZ 987',
        color: 'Red',
        services: [
          ServiceItem(
            id: 'service-002',
            name: 'Exterior Detailing',
            price: 1200,
            assignedEmployee: 'Ashuri Alonzo',
            employeeRole: 'Master Detailer',
          ),
        ],
        serviceStatus: 'Pending',
        paymentStatus: 'Unpaid',
      ),
      CustomerBooking(
        id: 'book-003',
        customerName: 'Anabelle Santos',
        phone: '0919 345 6789',
        address: 'Makati City',
        brand: 'Honda',
        model: 'Civic',
        plateNumber: 'NQR 456',
        color: 'White',
        services: [
          ServiceItem(
            id: 'service-003',
            name: 'Exterior Detailing',
            price: 3500,
            assignedEmployee: 'Jose Dela Cruz',
            employeeRole: 'Car Painter',
          ),
        ],
        actualAmountPaid: 3500,
        serviceStatus: 'Completed',
        paymentStatus: 'Fully Paid',
      ),
      CustomerBooking(
        id: 'book-004',
        customerName: 'Carlos De Leon',
        phone: '0920 456 7890',
        address: 'Taguig City',
        brand: 'Ford',
        model: 'Ranger',
        plateNumber: 'LMN 567',
        color: 'Silver',
        services: [
          ServiceItem(
            id: 'service-004',
            name: 'Exterior Detailing',
            price: 6000,
            assignedEmployee: 'Ashuri Alonzo',
            employeeRole: 'Master Detailer',
          ),
        ],
        actualAmountPaid: 6000,
        serviceStatus: 'Completed',
        paymentStatus: 'Fully Paid',
      ),
    ];

    bookings.addAll(sampleBookings);
    for (final booking in sampleBookings) {
      customers.add(
        Customer(
          id: booking.id,
          name: booking.customerName,
          phone: booking.phone,
          address: booking.address,
          vehicle: booking.vehicleDisplay,
          plateNumber: booking.plateNumber,
          color: booking.color,
        ),
      );
      payments.add(
        Payment(
          id: 'payment-${booking.id}',
          bookingId: booking.id,
          customer: booking.customerName,
          service: booking.servicesSummary,
          total: booking.totalAmount,
          paid: booking.actualAmountPaid,
        ),
      );
    }
  }

  // --- CRUD & Business Logic ---

  void addBooking(CustomerBooking booking) {
    bookings.insert(0, booking);

    // Sync or add customer
    customers.removeWhere(
      (c) => c.name.toLowerCase() == booking.customerName.toLowerCase(),
    );
    customers.insert(
      0,
      Customer(
        id: booking.id,
        name: booking.customerName,
        phone: booking.phone,
        address: booking.address,
        vehicle: booking.vehicleDisplay,
        plateNumber: booking.plateNumber,
        color: booking.color,
        notes: booking.notes,
      ),
    );

    // Record initial payment entry in payments master list
    payments.insert(
      0,
      Payment(
        id: 'pay-${booking.id}-${DateTime.now().millisecondsSinceEpoch}',
        bookingId: booking.id,
        customer: booking.customerName,
        service: booking.servicesSummary,
        total: booking.totalAmount,
        paid: booking.actualAmountPaid,
      ),
    );

    notifyListeners();
    _safeSupabaseSyncBooking(booking);
  }

  void updateBooking(CustomerBooking updated) {
    final index = bookings.indexWhere((b) => b.id == updated.id);
    if (index != -1) {
      bookings[index] = updated;

      final pIndex = payments.indexWhere((p) => p.bookingId == updated.id);
      if (pIndex != -1) {
        payments[pIndex].total = updated.totalAmount;
        payments[pIndex].paid = updated.actualAmountPaid;
        payments[pIndex].service = updated.servicesSummary;
      }

      notifyListeners();
      _safeSupabaseSyncBooking(updated);
    }
  }

  // Record additional installment payment with strict validation and reference number
  String? recordAdditionalPayment({
    required String bookingId,
    required double paymentAmount,
    String method = 'Cash',
    String note = '',
  }) {
    final bIndex = bookings.indexWhere((b) => b.id == bookingId);
    if (bIndex == -1) return 'Booking not found';

    final booking = bookings[bIndex];
    if (paymentAmount > booking.balance) {
      return 'Payment cannot be greater than the remaining balance (₱${booking.balance.toStringAsFixed(0)})';
    }

    booking.recordPayment(paymentAmount, method: method, note: note);

    final pIndex = payments.indexWhere((p) => p.bookingId == bookingId);
    if (pIndex != -1) {
      payments[pIndex].paid = booking.actualAmountPaid;
      payments[pIndex].method = method;
    } else {
      payments.insert(
        0,
        Payment(
          id: 'pay-$bookingId-${DateTime.now().millisecondsSinceEpoch}',
          bookingId: bookingId,
          customer: booking.customerName,
          service: booking.servicesSummary,
          total: booking.totalAmount,
          paid: booking.actualAmountPaid,
          method: method,
        ),
      );
    }

    notifyListeners();
    _safeSupabaseSyncBooking(booking);
    return null;
  }

  void updateBookingServiceStatus(String bookingId, String newStatus) {
    final bIndex = bookings.indexWhere((b) => b.id == bookingId);
    if (bIndex != -1) {
      bookings[bIndex].serviceStatus = newStatus;
      notifyListeners();
      _safeSupabaseSyncBooking(bookings[bIndex]);
    }
  }

  void updateBookingPaymentStatus(String bookingId, String newStatus) {
    final bIndex = bookings.indexWhere((b) => b.id == bookingId);
    if (bIndex != -1) {
      bookings[bIndex].paymentStatus = newStatus;
      notifyListeners();
      _safeSupabaseSyncBooking(bookings[bIndex]);
    }
  }

  void toggleServiceCommissionPaid({
    required String bookingId,
    required String serviceId,
    required bool isPaid,
  }) {
    final bIndex = bookings.indexWhere((b) => b.id == bookingId);
    if (bIndex != -1) {
      final sIndex = bookings[bIndex].services.indexWhere(
        (s) => s.id == serviceId,
      );
      if (sIndex != -1) {
        bookings[bIndex].services[sIndex].commissionPaid = isPaid;
        notifyListeners();
        _safeSupabaseSyncBooking(bookings[bIndex]);
      }
    }
  }

  void removeBooking(String bookingId) {
    bookings.removeWhere((b) => b.id == bookingId);
    payments.removeWhere((p) => p.bookingId == bookingId);
    notifyListeners();
  }

  // --- Employees CRUD ---
  void addEmployee(Employee employee) {
    employees.add(employee);
    notifyListeners();
  }

  void updateEmployee(Employee employee) => notifyListeners();

  void removeEmployee(Employee employee) {
    employees.remove(employee);
    notifyListeners();
  }

  // --- Material Records CRUD ---
  void addMaterial(MaterialItem material) {
    materials.insert(0, material);
    notifyListeners();
  }

  void updateMaterial(MaterialItem material) => notifyListeners();

  void removeMaterial(MaterialItem material) {
    materials.remove(material);
    notifyListeners();
  }

  // --- Employee Work Tracker & Commission Queries ---
  List<({CustomerBooking booking, ServiceItem service})>
  getEmployeeActiveServices(String employeeName) {
    final results = <({CustomerBooking booking, ServiceItem service})>[];
    for (final booking in bookings) {
      if (booking.serviceStatus != 'Completed' &&
          booking.serviceStatus != 'Cancelled') {
        for (final srv in booking.services) {
          if (srv.assignedEmployee.toLowerCase() ==
              employeeName.toLowerCase()) {
            results.add((booking: booking, service: srv));
          }
        }
      }
    }
    return results;
  }

  List<({CustomerBooking booking, ServiceItem service})>
  getEmployeeCompletedServices(String employeeName) {
    final results = <({CustomerBooking booking, ServiceItem service})>[];
    for (final booking in bookings) {
      if (booking.serviceStatus == 'Completed') {
        for (final srv in booking.services) {
          if (srv.assignedEmployee.toLowerCase() ==
              employeeName.toLowerCase()) {
            results.add((booking: booking, service: srv));
          }
        }
      }
    }
    return results;
  }

  // Total commission earned (40% of all assigned jobs handled)
  double getEmployeeTotalCommission(String employeeName) {
    double total = 0.0;
    for (final booking in bookings) {
      for (final srv in booking.services) {
        if (srv.assignedEmployee.toLowerCase() == employeeName.toLowerCase()) {
          total += srv.employeeShare;
        }
      }
    }
    return total;
  }

  double getEmployeeUnpaidCommission(String employeeName) {
    double total = 0.0;
    for (final booking in bookings) {
      for (final srv in booking.services) {
        if (srv.assignedEmployee.toLowerCase() == employeeName.toLowerCase() &&
            !srv.commissionPaid) {
          total += srv.employeeShare;
        }
      }
    }
    return total;
  }

  double getEmployeePaidCommission(String employeeName) {
    double total = 0.0;
    for (final booking in bookings) {
      for (final srv in booking.services) {
        if (srv.assignedEmployee.toLowerCase() == employeeName.toLowerCase() &&
            srv.commissionPaid) {
          total += srv.employeeShare;
        }
      }
    }
    return total;
  }

  // --- Financial & Reports Metrics ---
  double get totalServiceSales =>
      bookings.fold<double>(0.0, (sum, b) => sum + b.totalAmount);

  double get totalPaymentsCollected =>
      bookings.fold<double>(0.0, (sum, b) => sum + b.actualAmountPaid);

  double get totalOutstandingBalances =>
      bookings.fold<double>(0.0, (sum, b) => sum + b.balance);

  double get totalEmployeeCommissionsAll =>
      bookings.fold<double>(0.0, (sum, b) => sum + b.totalEmployeeCommissions);

  double get totalPaidCommissionsAll {
    double sum = 0;
    for (final b in bookings) {
      for (final s in b.services) {
        if (s.commissionPaid) sum += s.employeeShare;
      }
    }
    return sum;
  }

  double get totalUnpaidCommissionsAll {
    double sum = 0;
    for (final b in bookings) {
      for (final s in b.services) {
        if (!s.commissionPaid) sum += s.employeeShare;
      }
    }
    return sum;
  }

  double get totalMaterialExpenses =>
      materials.fold<double>(0.0, (sum, m) => sum + m.totalExpense);

  double get totalOwnerBusinessShare =>
      bookings.fold<double>(0.0, (sum, b) => sum + b.totalOwnerShare);

  Future<void> _safeSupabaseSyncBooking(CustomerBooking booking) async {
    try {
      final client = Supabase.instance.client;
      await client.from('bookings').upsert(booking.toMap());
    } catch (_) {
      // Offline fallback
    }
  }
}
