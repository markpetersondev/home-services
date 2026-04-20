import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/booking.dart';

final _initialBookings = <Booking>[
  Booking(
    id: 1,
    customerId: 1, // Amaya
    providerId: 3, // Kasun
    serviceType: 'Plumbing',
    address: 'Colombo 07',
    description: 'Kitchen sink repair',
    scheduledAt: DateTime(2026, 4, 16, 10, 0),
    status: 'inProgress',
    price: 3500.0,
    createdAt: DateTime(2026, 4, 15),
  ),
  Booking(
    id: 2,
    customerId: 1, // Amaya
    serviceType: 'Electrical',
    address: 'Colombo 07',
    description: 'Fix living room lights',
    scheduledAt: DateTime(2026, 4, 17, 14, 0),
    status: 'pending',
    createdAt: DateTime(2026, 4, 16),
  ),
  Booking(
    id: 3,
    customerId: 2, // Saman
    serviceType: 'Plumbing',
    address: 'Nugegoda',
    description: 'Bathroom tap replacement',
    scheduledAt: DateTime(2026, 4, 18, 9, 0),
    status: 'pending',
    createdAt: DateTime(2026, 4, 16),
  ),
  Booking(
    id: 4,
    customerId: 2, // Saman
    providerId: 5, // Ruwan
    serviceType: 'AC Repair',
    address: 'Dehiwala Station Road',
    description: 'AC unit not cooling properly',
    scheduledAt: DateTime(2026, 4, 19, 11, 0),
    status: 'accepted',
    price: 4200.0,
    createdAt: DateTime(2026, 4, 16),
  ),
];

// ── Main bookings provider ────────────────────────────────────────────────────

final bookingsProvider =
    StateNotifierProvider<BookingsNotifier, List<Booking>>((ref) {
  return BookingsNotifier();
});

class BookingsNotifier extends StateNotifier<List<Booking>> {
  BookingsNotifier() : super(_initialBookings);

  int _nextId = 5;

  void createBooking(Booking booking) {
    final newBooking = Booking(
      id: _nextId++,
      customerId: booking.customerId,
      providerId: booking.providerId,
      serviceType: booking.serviceType,
      address: booking.address,
      description: booking.description,
      scheduledAt: booking.scheduledAt,
      status: 'pending',
      price: booking.price,
      createdAt: DateTime.now(),
    );
    state = [...state, newBooking];
  }

  void acceptBooking(int bookingId, int providerId, double price) {
    state = [
      for (final b in state)
        if (b.id == bookingId)
          b.copyWith(
            providerId: providerId,
            price: price,
            status: 'accepted',
          )
        else
          b,
    ];
  }

  void declineBooking(int bookingId) {
    // No state change — booking stays pending for another provider
  }

  void startJob(int bookingId) {
    state = [
      for (final b in state)
        if (b.id == bookingId) b.copyWith(status: 'inProgress') else b,
    ];
  }

  void completeJob(int bookingId) {
    state = [
      for (final b in state)
        if (b.id == bookingId) b.copyWith(status: 'completed') else b,
    ];
  }

  void cancelBooking(int bookingId) {
    state = state
        .where((b) => !(b.id == bookingId && b.status == 'pending'))
        .toList();
  }
}

// ── Computed providers ────────────────────────────────────────────────────────

final customerBookingsProvider =
    Provider.family<List<Booking>, int>((ref, customerId) {
  return ref
      .watch(bookingsProvider)
      .where((b) => b.customerId == customerId)
      .toList();
});

final activeBookingsProvider =
    Provider.family<List<Booking>, int>((ref, customerId) {
  return ref.watch(bookingsProvider).where((b) {
    return b.customerId == customerId &&
        (b.status == 'accepted' || b.status == 'inProgress');
  }).toList();
});

// Args: (serviceType, areaCovered)
final providerIncomingJobsProvider =
    Provider.family<List<Booking>, (String, String)>((ref, args) {
  final (serviceType, areaCovered) = args;
  return ref.watch(bookingsProvider).where((b) {
    return b.status == 'pending' &&
        b.providerId == null &&
        b.serviceType == serviceType &&
        b.address.toLowerCase().contains(areaCovered.toLowerCase());
  }).toList();
});

final providerMyJobsProvider =
    Provider.family<List<Booking>, int>((ref, providerId) {
  return ref
      .watch(bookingsProvider)
      .where((b) => b.providerId == providerId)
      .toList();
});
