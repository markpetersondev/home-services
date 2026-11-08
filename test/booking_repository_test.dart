import 'package:flutter_test/flutter_test.dart';
import 'package:fixnoww/models/booking.dart';
import 'package:fixnoww/repositories/booking_repository.dart';

void main() {
  late InMemoryBookingRepository repository;

  Future<Booking> newBooking() {
    return repository.createBooking(
      Booking(
        id: 0,
        customerId: 1,
        serviceType: 'Plumbing',
        address: 'Colombo 05',
        description: 'Leaking tap',
        scheduledAt: DateTime(2030),
        status: 'pending',
        createdAt: DateTime(2030),
      ),
    );
  }

  Future<Booking> find(int id) async {
    final bookings = await repository.fetchBookings();
    return bookings.firstWhere((b) => b.id == id);
  }

  setUp(() => repository = InMemoryBookingRepository());

  test('only one provider can claim a job', () async {
    final booking = await newBooking();

    expect(await repository.acceptBooking(booking.id, 3, 2500), isTrue);
    expect(await repository.acceptBooking(booking.id, 4, 2000), isFalse);

    final saved = await find(booking.id);
    expect(saved.providerId, 3);
    expect(saved.price, 2500);
  });

  test('jobs must follow the status order', () async {
    final booking = await newBooking();

    expect(await repository.startJob(booking.id), isFalse);
    expect(await repository.completeJob(booking.id), isNull);

    await repository.acceptBooking(booking.id, 3, 2500);
    expect(await repository.completeJob(booking.id), isNull);
    expect(await repository.startJob(booking.id), isTrue);

    final completed = await repository.completeJob(booking.id);
    expect(completed?.status, 'completed');
    expect(await repository.completeJob(booking.id), isNull);
  });

  test('cancelling keeps the record and only works while pending', () async {
    final booking = await newBooking();

    expect(await repository.cancelBooking(booking.id), isTrue);
    expect((await find(booking.id)).status, 'cancelled');
    expect(await repository.acceptBooking(booking.id, 3, 2500), isFalse);

    final accepted = await newBooking();
    await repository.acceptBooking(accepted.id, 3, 2500);
    expect(await repository.cancelBooking(accepted.id), isFalse);
  });

  test('declining records the provider and leaves the job open', () async {
    final booking = await newBooking();

    expect(await repository.declineBooking(booking.id, 3), isTrue);

    final saved = await find(booking.id);
    expect(saved.declinedBy, [3]);
    expect(saved.status, 'pending');
    expect(await repository.acceptBooking(booking.id, 4, 2000), isTrue);
  });
}
