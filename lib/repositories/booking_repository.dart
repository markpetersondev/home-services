import '../models/booking.dart';

/// Everything the app needs to do with bookings.
///
/// Actions return false when the booking isn't in the right state, such as a
/// job another provider already took. A real API would answer with `409`.
/// To connect a backend, write an `ApiBookingRepository` and return it from
/// `bookingRepositoryProvider`. Screens don't need to change.
abstract class BookingRepository {
  Future<List<Booking>> fetchBookings();
  Future<Booking> createBooking(Booking booking);
  Future<bool> acceptBooking(int bookingId, int providerId, double price);
  Future<bool> declineBooking(int bookingId, int providerId);
  Future<bool> startJob(int bookingId);

  /// Returns the completed booking, or null if it wasn't in progress.
  Future<Booking?> completeJob(int bookingId);

  Future<bool> cancelBooking(int bookingId);
}

/// Temporary demo data, held in memory until the app restarts.
class InMemoryBookingRepository implements BookingRepository {
  InMemoryBookingRepository({DateTime? now}) {
    final today = now ?? DateTime.now();
    final tomorrow = DateTime(today.year, today.month, today.day + 1);
    final yesterday = DateTime(today.year, today.month, today.day - 1);

    _bookings = [
      Booking(
        id: 1,
        customerId: 1, // Amaya
        providerId: 3, // Kasun
        serviceType: 'Plumbing',
        address: 'Colombo 07',
        description: 'Kitchen sink repair',
        scheduledAt: DateTime(today.year, today.month, today.day, 10),
        status: 'inProgress',
        price: 3500.0,
        createdAt: yesterday,
      ),
      Booking(
        id: 2,
        customerId: 1, // Amaya
        serviceType: 'Electrical',
        address: 'Colombo 07',
        description: 'Fix living room lights',
        scheduledAt: tomorrow.add(const Duration(hours: 14)),
        status: 'pending',
        createdAt: today,
      ),
      Booking(
        id: 3,
        customerId: 2, // Saman
        serviceType: 'Plumbing',
        address: 'Nugegoda',
        description: 'Bathroom tap replacement',
        scheduledAt: tomorrow.add(const Duration(days: 1, hours: 9)),
        status: 'pending',
        createdAt: today,
      ),
      Booking(
        id: 4,
        customerId: 2, // Saman
        providerId: 5, // Ruwan
        serviceType: 'AC Repair',
        address: 'Dehiwala Station Road',
        description: 'AC unit not cooling properly',
        scheduledAt: tomorrow.add(const Duration(days: 2, hours: 11)),
        status: 'accepted',
        price: 4200.0,
        createdAt: today,
      ),
    ];
  }

  late final List<Booking> _bookings;
  int _nextId = 5;

  @override
  Future<List<Booking>> fetchBookings() async => List.unmodifiable(_bookings);

  @override
  Future<Booking> createBooking(Booking booking) async {
    final created = booking.copyWith(
      id: _nextId++,
      status: 'pending',
      createdAt: DateTime.now(),
    );
    _bookings.add(created);
    return created;
  }

  @override
  Future<bool> acceptBooking(int bookingId, int providerId, double price) async {
    return _change(
      bookingId,
      allowed: (b) => b.status == 'pending' && b.providerId == null,
      change: (b) => b.copyWith(
        providerId: providerId,
        price: price,
        status: 'accepted',
      ),
    );
  }

  @override
  Future<bool> declineBooking(int bookingId, int providerId) async {
    return _change(
      bookingId,
      allowed: (b) => b.status == 'pending',
      change: (b) => b.copyWith(declinedBy: [...b.declinedBy, providerId]),
    );
  }

  @override
  Future<bool> startJob(int bookingId) async {
    return _change(
      bookingId,
      allowed: (b) => b.status == 'accepted',
      change: (b) => b.copyWith(status: 'inProgress'),
    );
  }

  @override
  Future<Booking?> completeJob(int bookingId) async {
    final changed = _change(
      bookingId,
      allowed: (b) => b.status == 'inProgress',
      change: (b) => b.copyWith(status: 'completed'),
    );
    if (!changed) return null;
    return _bookings.firstWhere((b) => b.id == bookingId);
  }

  @override
  Future<bool> cancelBooking(int bookingId) async {
    return _change(
      bookingId,
      allowed: (b) => b.status == 'pending',
      change: (b) => b.copyWith(status: 'cancelled'),
    );
  }

  bool _change(
    int bookingId, {
    required bool Function(Booking) allowed,
    required Booking Function(Booking) change,
  }) {
    final index = _bookings.indexWhere((b) => b.id == bookingId);
    if (index == -1 || !allowed(_bookings[index])) return false;
    _bookings[index] = change(_bookings[index]);
    return true;
  }
}
