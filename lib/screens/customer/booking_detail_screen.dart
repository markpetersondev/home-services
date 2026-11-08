import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/bookings_provider.dart';
import '../../providers/users_provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/phone_launcher.dart';
import '../../widgets/status_badge.dart';

class BookingDetailScreen extends ConsumerWidget {
  final int bookingId;

  const BookingDetailScreen({super.key, required this.bookingId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final booking = ref
        .watch(bookingsProvider)
        .where((b) => b.id == bookingId)
        .firstOrNull;

    if (booking == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new,
                color: AppColors.textPrimary, size: 20),
            onPressed: () => context.pop(),
          ),
        ),
        body: const Center(
          child: Text(
            'Booking not found.',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ),
      );
    }

    final allUsers = ref.watch(usersProvider);
    final provider = booking.providerId != null
        ? allUsers.where((u) => u.id == booking.providerId).firstOrNull
        : null;
    final customer =
        allUsers.where((u) => u.id == booking.customerId).firstOrNull;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              color: AppColors.textPrimary, size: 20),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Booking Details',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status + service row
            Row(
              children: [
                ServiceChip(label: booking.serviceType),
                const SizedBox(width: 10),
                StatusBadge(status: booking.status),
              ],
            ),
            const SizedBox(height: 20),

            // Detail card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _DetailRow(
                    icon: Icons.description_outlined,
                    label: 'Description',
                    value: booking.description,
                  ),
                  const _Divider(),
                  _DetailRow(
                    icon: Icons.location_on_outlined,
                    label: 'Address',
                    value: booking.address,
                  ),
                  const _Divider(),
                  _DetailRow(
                    icon: Icons.calendar_today_outlined,
                    label: 'Scheduled',
                    value: booking.formattedDate,
                  ),
                  if (customer != null) ...[
                    const _Divider(),
                    _DetailRow(
                      icon: Icons.person_outline,
                      label: 'Customer',
                      value: customer.name,
                    ),
                  ],
                  if (provider != null) ...[
                    const _Divider(),
                    _DetailRow(
                      icon: Icons.build_outlined,
                      label: 'Provider',
                      value: provider.name,
                    ),
                    const _Divider(),
                    _DetailRow(
                      icon: Icons.star_outline,
                      label: 'Provider Rating',
                      value: '⭐ ${provider.rating}',
                    ),
                  ],
                  if (booking.formattedPrice != null) ...[
                    const _Divider(),
                    _DetailRow(
                      icon: Icons.payments_outlined,
                      label: 'Price',
                      value: booking.formattedPrice!,
                      valueStyle: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 28),

            // Status-specific UI
            if (booking.status == 'completed')
              _completedBanner()
            else if (booking.status == 'cancelled')
              _cancelledBanner()
            else if (booking.status == 'pending')
              _cancelButton(context, ref)
            else if (provider != null)
              _callProviderButton(context, provider.phone),
          ],
        ),
      ),
    );
  }

  Widget _completedBanner() => Container(
        width: double.infinity,
        padding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.statusCompletedBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: AppColors.statusCompleted.withValues(alpha: 0.4)),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle_outline,
                color: AppColors.statusCompleted, size: 20),
            SizedBox(width: 10),
            Text(
              'Job done. Thank you.',
              style: TextStyle(
                color: AppColors.statusCompleted,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );

  Widget _cancelledBanner() => Container(
        width: double.infinity,
        padding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.statusCancelledBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: AppColors.statusCancelled.withValues(alpha: 0.4)),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.cancel_outlined,
                color: AppColors.statusCancelled, size: 20),
            SizedBox(width: 10),
            Text(
              'This booking was cancelled.',
              style: TextStyle(
                color: AppColors.statusCancelled,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );

  Widget _callProviderButton(BuildContext context, String phone) => SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton.icon(
          onPressed: () => openDialler(context, phone),
          icon: const Icon(Icons.phone, size: 18),
          label: const Text(
            'Call Provider',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      );

  Future<void> _confirmCancel(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Cancel this booking?',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: const Text(
          'Providers will no longer see this request.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(
              'Keep Booking',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Cancel Booking',
              style: TextStyle(color: AppColors.statusCancelled),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    final cancelled =
        await ref.read(bookingsProvider.notifier).cancelBooking(bookingId);
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          cancelled
              ? 'Booking cancelled.'
              : 'This booking can no longer be cancelled.',
        ),
        backgroundColor: AppColors.error,
      ),
    );
    if (cancelled) context.pop();
  }

  Widget _cancelButton(BuildContext context, WidgetRef ref) => SizedBox(
        width: double.infinity,
        height: 50,
        child: OutlinedButton(
          onPressed: () => _confirmCancel(context, ref),
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.redAccent,
            side: const BorderSide(color: Colors.redAccent),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text(
            'Cancel Booking',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          ),
        ),
      );
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final TextStyle? valueStyle;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.textSecondary, size: 18),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: valueStyle ??
                      const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) =>
      const Divider(color: AppColors.border, height: 1);
}
