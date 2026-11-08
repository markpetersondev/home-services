import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../models/booking.dart';
import '../../providers/auth_provider.dart';
import '../../providers/bookings_provider.dart';
import '../../providers/users_provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/price_dialog.dart';
import '../../widgets/status_badge.dart';

class ProviderHomeScreen extends ConsumerStatefulWidget {
  const ProviderHomeScreen({super.key});

  @override
  ConsumerState<ProviderHomeScreen> createState() =>
      _ProviderHomeScreenState();
}

class _ProviderHomeScreenState extends ConsumerState<ProviderHomeScreen> {
  bool _bannerDismissed = false;

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    if (user == null) return const SizedBox();

    final isOnline = user.isOnline;
    final incomingJobs = ref.watch(
      providerIncomingJobsProvider((
        user.id,
        user.serviceType ?? '',
        user.areaCovered ?? '',
        isOnline,
      )),
    );
    final myJobs = ref.watch(providerMyJobsProvider(user.id));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // ── Header ────────────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Welcome back 👋',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            user.name,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              letterSpacing: -0.3,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Icon(Icons.star,
                                  color: Colors.amber, size: 15),
                              const SizedBox(width: 4),
                              Text(
                                '${user.rating}  ·  ${user.serviceType ?? ''}',
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Online toggle
                    GestureDetector(
                      onTap: () {
                        ref
                            .read(usersProvider.notifier)
                            .toggleOnline(user.id);
                        setState(() => _bannerDismissed = false);
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: isOnline
                              ? Colors.amber.withValues(alpha: 0.15)
                              : AppColors.card,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color:
                                isOnline ? Colors.amber : AppColors.border,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.power_settings_new,
                              color: isOnline
                                  ? Colors.amber
                                  : AppColors.textSecondary,
                              size: 15,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              isOnline ? 'Online' : 'Offline',
                              style: TextStyle(
                                color: isOnline
                                    ? Colors.amber
                                    : AppColors.textSecondary,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Online banner ─────────────────────────────────────────────
            if (isOnline && !_bannerDismissed)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.statusCompletedBg,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.statusCompleted
                            .withValues(alpha: 0.45),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.wifi,
                            color: AppColors.statusCompleted, size: 18),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Text(
                            "You're online! Ready to receive jobs.",
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () =>
                              setState(() => _bannerDismissed = true),
                          child: const Icon(Icons.close,
                              color: AppColors.textSecondary, size: 18),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            // ── Stats row ─────────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Row(
                  children: [
                    _StatCard(
                        label: 'Jobs',
                        value: '${myJobs.length} total'),
                    const SizedBox(width: 10),
                    _StatCard(
                        label: 'Earnings',
                        value: user.formattedEarnings),
                    const SizedBox(width: 10),
                    _StatCard(
                        label: 'Rating',
                        value: '⭐ ${user.rating}'),
                  ],
                ),
              ),
            ),

            // ── Incoming requests ─────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 28, 20, 14),
                child: Text(
                  'Incoming Requests (${incomingJobs.length})',
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            if (incomingJobs.isEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                  child: Text(
                    isOnline
                        ? 'No incoming requests right now.'
                        : "You're offline. Go online to receive requests.",
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, i) =>
                        _IncomingCard(booking: incomingJobs[i]),
                    childCount: incomingJobs.length,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;

  const _StatCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _IncomingCard extends ConsumerWidget {
  final Booking booking;

  const _IncomingCard({required this.booking});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allUsers = ref.watch(usersProvider);
    final customer =
        allUsers.where((u) => u.id == booking.customerId).firstOrNull;

    return Container(
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
          ServiceChip(label: booking.serviceType),
          const SizedBox(height: 10),
          Text(
            booking.description,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Text('📍', style: TextStyle(fontSize: 13)),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  booking.address,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      color: AppColors.textSecondary, fontSize: 13),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.calendar_today_outlined,
                  color: AppColors.textSecondary, size: 13),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  booking.formattedDate,
                  style: const TextStyle(
                      color: AppColors.textSecondary, fontSize: 13),
                ),
              ),
            ],
          ),
          if (customer != null) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.person_outline,
                    color: AppColors.textSecondary, size: 13),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    customer.name,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        color: AppColors.textSecondary, fontSize: 13),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 40,
                  child: ElevatedButton(
                    onPressed: () => _accept(context, ref),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber,
                      foregroundColor: Colors.black,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      '✓ Accept',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: SizedBox(
                  height: 40,
                  child: OutlinedButton(
                    onPressed: () => _decline(context, ref),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textSecondary,
                      side: const BorderSide(color: AppColors.border),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      '✕ Decline',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // This card leaves the list once the job is accepted or declined, so its
  // context can't be used afterwards. Capture what's needed up front.
  Future<void> _accept(BuildContext context, WidgetRef ref) async {
    final router = GoRouter.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final user = ref.read(currentUserProvider);
    final bookings = ref.read(bookingsProvider.notifier);
    if (user == null) return;

    final price = await showSetPriceDialog(context);
    if (price == null) return;

    final accepted = await bookings.acceptBooking(booking.id, user.id, price);
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          accepted ? 'Job accepted!' : 'This job is no longer available.',
        ),
        backgroundColor: accepted ? AppColors.success : AppColors.error,
      ),
    );
    if (accepted) router.push('/provider/job-detail', extra: booking.id);
  }

  Future<void> _decline(BuildContext context, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.of(context);
    final user = ref.read(currentUserProvider);
    if (user == null) return;

    await ref
        .read(bookingsProvider.notifier)
        .declineBooking(booking.id, user.id);
    messenger.showSnackBar(
      const SnackBar(
        content: Text('Job declined.'),
        backgroundColor: AppColors.statusPendingBg,
      ),
    );
  }
}
