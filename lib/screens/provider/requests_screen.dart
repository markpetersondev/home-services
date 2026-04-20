import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../models/booking.dart';
import '../../providers/auth_provider.dart';
import '../../providers/bookings_provider.dart';
import '../../providers/users_provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/status_badge.dart';

class ProviderRequestsScreen extends ConsumerWidget {
  const ProviderRequestsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    if (user == null) return const SizedBox();

    final myJobs = ref.watch(providerMyJobsProvider(user.id));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'My Jobs',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: myJobs.isEmpty
          ? const Center(
              child: Text(
                'No jobs assigned yet.',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              itemCount: myJobs.length,
              itemBuilder: (context, i) =>
                  _JobCard(booking: myJobs[i]),
            ),
    );
  }
}

class _JobCard extends ConsumerWidget {
  final Booking booking;

  const _JobCard({required this.booking});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allUsers = ref.watch(usersProvider);
    final customer =
        allUsers.where((u) => u.id == booking.customerId).firstOrNull;

    return GestureDetector(
      onTap: () =>
          context.push('/provider/job-detail', extra: booking.id),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ServiceChip(label: booking.serviceType),
                StatusBadge(status: booking.status),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              booking.description,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.calendar_today_outlined,
                    color: AppColors.textSecondary, size: 13),
                const SizedBox(width: 5),
                Expanded(
                  child: Text(
                    booking.formattedDate,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ),
                if (customer != null)
                  Text(
                    customer.name,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
            if (booking.formattedPrice != null) ...[
              const SizedBox(height: 6),
              Text(
                booking.formattedPrice!,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
