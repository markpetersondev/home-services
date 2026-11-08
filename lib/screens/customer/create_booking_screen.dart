import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../models/booking.dart';
import '../../providers/auth_provider.dart';
import '../../providers/bookings_provider.dart';
import '../../theme/app_colors.dart';

class CreateBookingScreen extends ConsumerStatefulWidget {
  final String serviceType;

  const CreateBookingScreen({super.key, required this.serviceType});

  @override
  ConsumerState<CreateBookingScreen> createState() =>
      _CreateBookingScreenState();
}

class _CreateBookingScreenState extends ConsumerState<CreateBookingScreen> {
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  final _addressCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  String? _addressError;
  String? _dateTimeError;
  String? _descError;

  @override
  void dispose() {
    _addressCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Widget _pickerTheme(BuildContext ctx, Widget? child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: AppColors.statusInProgress,
            onPrimary: AppColors.background,
            primaryContainer: AppColors.statusInProgress,
            onPrimaryContainer: AppColors.background,
            tertiaryContainer: AppColors.statusInProgress,
            onTertiaryContainer: AppColors.background,
            surface: AppColors.card,
            onSurface: AppColors.textPrimary,
          ),
        ),
        child: child!,
      );

  /// Asks for a date, then a time. Cancelling the date stops there.
  Future<void> _pickDateAndTime() async {
    FocusScope.of(context).unfocus();

    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now.add(const Duration(days: 1)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 60)),
      builder: _pickerTheme,
    );
    if (date == null || !mounted) return;
    setState(() {
      _selectedDate = date;
      _dateTimeError = null;
    });

    final time = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
      builder: _pickerTheme,
    );
    if (time != null && mounted) setState(() => _selectedTime = time);
  }

  String get _dateTimeLabel {
    if (_selectedDate == null) return 'Select date & time';
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final d = _selectedDate!;
    final dateStr = '${months[d.month - 1]} ${d.day}, ${d.year}';
    if (_selectedTime == null) return dateStr;
    final hour =
        _selectedTime!.hourOfPeriod == 0 ? 12 : _selectedTime!.hourOfPeriod;
    final min = _selectedTime!.minute.toString().padLeft(2, '0');
    final period = _selectedTime!.period == DayPeriod.am ? 'AM' : 'PM';
    return '$dateStr · $hour:$min $period';
  }

  /// Returns the chosen date and time, or null if it's incomplete or past.
  DateTime? _validatedDateTime() {
    final date = _selectedDate;
    final time = _selectedTime;
    if (date == null || time == null) {
      _dateTimeError = 'Choose a date and time';
      return null;
    }
    final scheduledAt = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );
    if (!scheduledAt.isAfter(DateTime.now())) {
      _dateTimeError = 'Choose a time in the future';
      return null;
    }
    _dateTimeError = null;
    return scheduledAt;
  }

  Future<void> _submit() async {
    final user = ref.read(authProvider);
    if (user == null) return;

    final address = _addressCtrl.text.trim();
    final description = _descCtrl.text.trim();

    final scheduledAt = _validatedDateTime();
    setState(() {
      _addressError = address.isEmpty ? 'Enter the job address' : null;
      _descError = description.isEmpty ? 'Describe the problem' : null;
    });
    if (scheduledAt == null || address.isEmpty || description.isEmpty) return;

    await ref.read(bookingsProvider.notifier).createBooking(
          Booking(
            id: 0, // assigned by the repository
            customerId: user.id,
            serviceType: widget.serviceType,
            address: address,
            description: description,
            scheduledAt: scheduledAt,
            status: 'pending',
            createdAt: DateTime.now(),
          ),
        );
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Request submitted!'),
        backgroundColor: AppColors.success,
      ),
    );
    context.go('/customer/my-requests');
  }

  @override
  Widget build(BuildContext context) {
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
          'New Booking',
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
            // Service chip (non-editable)
            const Text(
              'Service Type',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.5)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.build_outlined,
                      color: AppColors.statusInProgress, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    widget.serviceType,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.lock_outline,
                      color: AppColors.textSecondary, size: 13),
                ],
              ),
            ),

            const SizedBox(height: 24),
            _fieldLabel('Address'),
            const SizedBox(height: 8),
            TextField(
              controller: _addressCtrl,
              style:
                  const TextStyle(color: AppColors.textPrimary, fontSize: 14),
              onChanged: (_) {
                if (_addressError != null) {
                  setState(() => _addressError = null);
                }
              },
              decoration: _inputDecor(
                'e.g. No. 42, Galle Road, Colombo 03',
                error: _addressError,
              ),
            ),

            const SizedBox(height: 24),
            _fieldLabel('Date & Time'),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _pickDateAndTime,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 15),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _dateTimeError == null
                        ? AppColors.border
                        : Theme.of(context).colorScheme.error,
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today_outlined,
                        color: AppColors.textSecondary, size: 18),
                    const SizedBox(width: 10),
                    Text(
                      _dateTimeLabel,
                      style: TextStyle(
                        color: _selectedDate == null
                            ? AppColors.textSecondary
                            : AppColors.textPrimary,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            if (_dateTimeError != null)
              Padding(
                padding: const EdgeInsets.only(left: 20, top: 8),
                child: Text(
                  _dateTimeError!,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                    fontSize: 12,
                  ),
                ),
              ),

            const SizedBox(height: 24),
            _fieldLabel('Job Description'),
            const SizedBox(height: 8),
            TextField(
              controller: _descCtrl,
              maxLines: 4,
              textInputAction: TextInputAction.done,
              style:
                  const TextStyle(color: AppColors.textPrimary, fontSize: 14),
              onChanged: (_) {
                if (_descError != null) setState(() => _descError = null);
              },
              decoration: _inputDecor(
                'Describe the issue in detail…',
                error: _descError,
              ),
            ),

            const SizedBox(height: 36),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Submit Request',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _fieldLabel(String text) => Text(
        text,
        style: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
      );

  InputDecoration _inputDecor(String hint, {String? error}) =>
      InputDecoration(
        hintText: hint,
        errorText: error,
        hintStyle: const TextStyle(color: AppColors.textSecondary),
        filled: true,
        fillColor: AppColors.card,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              const BorderSide(color: AppColors.primary, width: 1.5),
        ),
      );
}
