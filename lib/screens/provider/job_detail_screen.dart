import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../providers/bookings_provider.dart';
import '../../providers/users_provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/status_badge.dart';

class JobDetailScreen extends ConsumerWidget {
  final int bookingId;

  const JobDetailScreen({super.key, required this.bookingId});

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
            'Job not found.',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ),
      );
    }

    final allUsers = ref.watch(usersProvider);
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
          'Job Details',
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
            // Header chips
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
                  _row(Icons.description_outlined, 'Description',
                      booking.description),
                  const _Div(),
                  _row(Icons.location_on_outlined, 'Address',
                      booking.address),
                  const _Div(),
                  _row(Icons.calendar_today_outlined, 'Scheduled',
                      booking.formattedDate),
                  if (customer != null) ...[
                    const _Div(),
                    _row(Icons.person_outline, 'Customer',
                        customer.name),
                    const _Div(),
                    _row(Icons.phone_outlined, 'Customer Phone',
                        customer.phone),
                  ],
                  if (booking.formattedPrice != null) ...[
                    const _Div(),
                    _row(Icons.payments_outlined, 'Price',
                        booking.formattedPrice!,
                        bold: true),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 28),

            _actionArea(context, ref, booking.status),
          ],
        ),
      ),
    );
  }

  Widget _actionArea(
      BuildContext context, WidgetRef ref, String status) {
    switch (status) {
      case 'pending':
        return Row(
          children: [
            Expanded(
              child: _primaryBtn(
                context,
                label: 'Accept Job',
                color: Colors.amber,
                textColor: Colors.black,
                onPressed: () =>
                    _showAcceptDialog(context, ref, bookingId),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _outlineBtn(
                context,
                label: 'Decline',
                onPressed: () {
                  ref
                      .read(bookingsProvider.notifier)
                      .declineBooking(bookingId);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Declined.',
                        style:
                            TextStyle(color: AppColors.textPrimary),
                      ),
                      backgroundColor: AppColors.statusPendingBg,
                    ),
                  );
                  context.pop();
                },
              ),
            ),
          ],
        );

      case 'accepted':
        return _primaryBtn(
          context,
          label: 'Mark as Started',
          color: AppColors.primary,
          onPressed: () {
            ref.read(bookingsProvider.notifier).startJob(bookingId);
            _snack(context, 'Job marked as started!', AppColors.primary);
          },
        );

      case 'inProgress':
        return _primaryBtn(
          context,
          label: 'Mark as Completed',
          color: AppColors.statusCompleted,
          onPressed: () {
            ref
                .read(bookingsProvider.notifier)
                .completeJob(bookingId);
            _snack(context, 'Job completed!',
                AppColors.statusCompleted);
          },
        );

      case 'completed':
        return Container(
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
              Icon(Icons.check_circle,
                  color: AppColors.statusCompleted, size: 20),
              SizedBox(width: 10),
              Text(
                'Job Completed ✓',
                style: TextStyle(
                  color: AppColors.statusCompleted,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        );

      default:
        return const SizedBox();
    }
  }

  void _showAcceptDialog(
      BuildContext context, WidgetRef ref, int id) {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.card,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        title: const Text('Set Job Price',
            style: TextStyle(color: AppColors.textPrimary)),
        content: TextField(
          controller: ctrl,
          keyboardType: TextInputType.number,
          style: const TextStyle(color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: 'e.g. 3500',
            hintStyle:
                const TextStyle(color: AppColors.textSecondary),
            prefixText: 'Rs. ',
            prefixStyle:
                const TextStyle(color: AppColors.textSecondary),
            filled: true,
            fillColor: AppColors.background,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                  color: AppColors.primary, width: 1.5),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel',
                style:
                    TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () {
              final price = double.tryParse(ctrl.text);
              if (price == null) return;
              final user = ref.read(currentUserProvider);
              if (user == null) return;
              ref
                  .read(bookingsProvider.notifier)
                  .acceptBooking(id, user.id, price);
              Navigator.pop(ctx);
              _snack(context, 'Job accepted!',
                  const Color(0xFF1B8A6B));
            },
            child: const Text('Confirm',
                style: TextStyle(
                    color: AppColors.statusInProgress)),
          ),
        ],
      ),
    );
  }

  Widget _primaryBtn(
    BuildContext context, {
    required String label,
    required Color color,
    Color textColor = Colors.white,
    required VoidCallback onPressed,
  }) =>
      SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            foregroundColor: textColor,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            label,
            style:
                const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          ),
        ),
      );

  Widget _outlineBtn(
    BuildContext context, {
    required String label,
    required VoidCallback onPressed,
  }) =>
      SizedBox(
        height: 50,
        child: OutlinedButton(
          onPressed: onPressed,
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.textSecondary,
            side: const BorderSide(color: AppColors.border),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            label,
            style:
                const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          ),
        ),
      );

  void _snack(BuildContext context, String msg, Color bg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg), backgroundColor: bg));
  }

  Widget _row(IconData icon, String label, String value,
          {bool bold = false}) =>
      Padding(
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
                  Text(label,
                      style: const TextStyle(
                          color: AppColors.textSecondary, fontSize: 12)),
                  const SizedBox(height: 3),
                  Text(
                    value,
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                      fontWeight:
                          bold ? FontWeight.bold : FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
}

class _Div extends StatelessWidget {
  const _Div();

  @override
  Widget build(BuildContext context) =>
      const Divider(color: AppColors.border, height: 1);
}
