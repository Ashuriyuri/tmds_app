import 'package:flutter_test/flutter_test.dart';
import 'package:tmds_app/models/customer_booking.dart';
import 'package:tmds_app/models/service_item.dart';
import 'package:tmds_app/services/app_data.dart';

void main() {
  group('Customer, Services, Workers, and Payment Workflow Tests', () {
    test('STEP 2, 3 & 4: Multiple Services, Workers, and Automatic Total', () {
      final s1 = ServiceItem(
        id: 's1',
        name: 'Exterior Detailing',
        price: 1000.0,
        assignedWorkers: ['Detailer 1'],
      );
      final s2 = ServiceItem(
        id: 's2',
        name: 'Interior Detailing',
        price: 1500.0,
        assignedWorkers: ['Detailer 2'],
      );
      final s3 = ServiceItem(
        id: 's3',
        name: 'Car Wax',
        price: 800.0,
        assignedWorkers: ['Painter'],
      );

      final booking = CustomerBooking(
        id: 'b-test-1',
        customerName: 'John Doe',
        phone: '0917 111 2222',
        brand: 'Toyota',
        model: 'Vios',
        plateNumber: 'ABC 123',
        services: [s1, s2, s3],
        actualAmountPaid: 0.0,
      );

      // Verify Total = 1000 + 1500 + 800 = 3300
      expect(booking.totalAmount, equals(3300.0));

      // Verify Suggested 50% Down Payment = 3300 * 0.50 = 1650
      expect(booking.suggestedDownPayment, equals(1650.0));

      // Verify workers are assigned to appropriate services
      expect(booking.services[0].assignedWorkers, contains('Detailer 1'));
      expect(booking.services[1].assignedWorkers, contains('Detailer 2'));
      expect(booking.services[2].assignedWorkers, contains('Painter'));
    });

    test('STEP 5 & 6: Customer saved without payment (₱0) has Pending status and Unpaid payment status', () {
      final booking = CustomerBooking(
        id: 'b-test-2',
        customerName: 'John Doe',
        phone: '0917 111 2222',
        brand: 'Toyota',
        model: 'Vios',
        services: [
          ServiceItem(id: 's1', name: 'Exterior Detailing', price: 1000.0),
          ServiceItem(id: 's2', name: 'Interior Detailing', price: 1500.0),
          ServiceItem(id: 's3', name: 'Car Wax', price: 800.0),
        ],
        actualAmountPaid: 0.0,
      );

      expect(booking.actualAmountPaid, equals(0.0));
      expect(booking.balance, equals(3300.0));
      expect(booking.serviceStatus, equals('Pending'));
      expect(booking.paymentStatus, equals('Unpaid'));
    });

    test('STEP 7: Later down payment moves Pending to In Progress', () {
      final booking = CustomerBooking(
        id: 'b-test-3',
        customerName: 'John Doe',
        phone: '0917 111 2222',
        brand: 'Toyota',
        model: 'Vios',
        services: [
          ServiceItem(id: 's1', name: 'Exterior Detailing', price: 1000.0),
          ServiceItem(id: 's2', name: 'Interior Detailing', price: 1500.0),
          ServiceItem(id: 's3', name: 'Car Wax', price: 800.0),
        ],
        actualAmountPaid: 0.0,
      );

      AppData.instance.addBooking(booking);

      expect(booking.serviceStatus, equals('Pending'));
      expect(booking.balance, equals(3300.0));

      // Customer later pays 50% down payment (₱1,650)
      AppData.instance.recordAdditionalPayment(
        bookingId: booking.id,
        paymentAmount: 1650.0,
      );

      expect(booking.actualAmountPaid, equals(1650.0));
      expect(booking.balance, equals(1650.0));
      expect(booking.serviceStatus, equals('In Progress'));
      expect(booking.paymentStatus, equals('Partially Paid'));
    });

    test('STEP 8: Final balance payment marks status as Fully Paid', () {
      final booking = CustomerBooking(
        id: 'b-test-4',
        customerName: 'John Doe',
        phone: '0917 111 2222',
        brand: 'Toyota',
        model: 'Vios',
        services: [
          ServiceItem(id: 's1', name: 'Exterior Detailing', price: 1000.0),
          ServiceItem(id: 's2', name: 'Interior Detailing', price: 1500.0),
          ServiceItem(id: 's3', name: 'Car Wax', price: 800.0),
        ],
        actualAmountPaid: 1650.0,
      );

      AppData.instance.addBooking(booking);

      // Pay remaining balance of 1650
      AppData.instance.recordAdditionalPayment(
        bookingId: booking.id,
        paymentAmount: 1650.0,
      );

      expect(booking.actualAmountPaid, equals(3300.0));
      expect(booking.balance, equals(0.0));
      expect(booking.paymentStatus, equals('Fully Paid'));
    });

    test('CALCULATION RULES: Preserves actual payment amount and 40% independent commission', () {
      final service1 = ServiceItem(
        id: 's1',
        name: 'Detailing',
        price: 3000.0,
        assignedEmployee: 'Juan',
      );
      final service2 = ServiceItem(
        id: 's2',
        name: 'Painting',
        price: 60000.0,
        assignedEmployee: 'James',
      );

      final booking = CustomerBooking(
        id: 'b-test-5',
        customerName: 'Ashuri Alonzo',
        phone: '0917 999 8888',
        brand: 'Toyota',
        model: 'Vios',
        services: [service1, service2],
        actualAmountPaid: 1500.0, // Customer pays downpayment
      );

      // Verify total
      expect(booking.totalAmount, equals(63000.0));
      expect(booking.actualAmountPaid, equals(1500.0));
      expect(booking.balance, equals(61500.0));
      expect(booking.serviceStatus, equals('In Progress'));
      expect(booking.paymentStatus, equals('Partially Paid'));

      // Verify independent 40% employee commission:
      // Detailing: 3000 * 40% = 1200
      expect(service1.employeeShare, equals(1200.0));
      expect(service1.ownerShare, equals(1800.0));

      // Painting: 60000 * 40% = 24000
      expect(service2.employeeShare, equals(24000.0));
      expect(service2.ownerShare, equals(36000.0));

      // Total commissions
      expect(booking.totalEmployeeCommissions, equals(25200.0));
      expect(booking.totalOwnerShare, equals(37800.0));
    });

    test('PAYMENT VALIDATION: Cannot pay more than remaining balance', () {
      final booking = CustomerBooking(
        id: 'b-val-1',
        customerName: 'Test Validation',
        phone: '0911 111 1111',
        services: [ServiceItem(id: 's1', name: 'Detailing', price: 3000.0)],
        actualAmountPaid: 1000.0,
      );
      AppData.instance.addBooking(booking);

      expect(booking.balance, equals(2000.0));

      // Attempt to pay 2500 when balance is 2000
      final error = AppData.instance.recordAdditionalPayment(
        bookingId: booking.id,
        paymentAmount: 2500.0,
      );

      expect(error, isNotNull);
      expect(
        error,
        contains('Payment cannot be greater than the remaining balance'),
      );
      expect(booking.balance, equals(2000.0)); // Balance remains unchanged
    });
  });
}
