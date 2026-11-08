import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/booking.dart';
import '../repositories/booking_repository.dart';
import 'users_provider.dart';

/// Swap this for an API version when the backend is ready.
final bookingRepositoryProvider = Provider<BookingRepository>((ref) {
  return InMemoryBookingRepository();
});

// ── Main bookings provider ────────────────────────────────────────────────────

final bookingsProvider =
    StateNotifierProvider<BookingsNotifier, List<Booking>>((ref) {
  return BookingsNotifier(ref, ref.watch(bookingRepositoryProvider));
});

class BookingsNotifier extends StateNotifier<List<Booking>> {
  final Ref _ref;
  final BookingRepository _repository;

  BookingsNotifier(this._ref, this._repository) : super(const []) {
    _refresh();
  }

  Future<void> _refresh() async {
    final bookings = await _repository.fetchBookings();
    if (mounted) state = bookings;
  }

  Future<void> createBooking(Booking booking) async {
    await _repository.createBooking(booking);
    await _refresh();
  }

  /// Returns false if the job is no longer available.
  Future<bool> acceptBooking(int bookingId, int providerId, double price) async {
    final accepted =
        await _repository.acceptBooking(bookingId, providerId, price);
    await _refresh();
    return accepted;
  }

  /// Hides the booking from this provider. It stays open for other providers.
  Future<bool> declineBooking(int bookingId, int providerId) async {
    final declined = await _repository.declineBooking(bookingId, providerId);
    await _refresh();
    return declined;
  }

  Future<bool> startJob(int bookingId) async {
    final started = await _repository.startJob(bookingId);
    await _refresh();
    return started;
  }

  /// Completes the job and adds its price to the provider's earnings.
  Future<bool> completeJob(int bookingId) async {
    final completed = await _repository.completeJob(bookingId);
    await _refresh();
    if (completed == null) return false;

    final providerId = completed.providerId;
    final price = completed.price;
    if (providerId != null && price != null) {
      await _ref.read(usersProvider.notifier).addEarnings(providerId, price);
    }
    return true;
  }

  /// Marks a pending booking as cancelled. The record is kept.
  Future<bool> cancelBooking(int bookingId) async {
    final cancelled = await _repository.cancelBooking(bookingId);
    await _refresh();
    return cancelled;
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

// Args: (providerId, serviceType, areaCovered, isOnline)
final providerIncomingJobsProvider =
    Provider.family<List<Booking>, (int, String, String, bool)>((ref, args) {
  final (providerId, serviceType, areaCovered, isOnline) = args;
  if (!isOnline) return const [];
  return ref.watch(bookingsProvider).where((b) {
    return b.status == 'pending' &&
        b.providerId == null &&
        !b.declinedBy.contains(providerId) &&
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
