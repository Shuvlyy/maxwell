import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:maxwell/features/machines/domain/machine.dart';
import 'package:maxwell/features/booking/presentation/booking_controller.dart';
import 'package:maxwell/shared/widgets/custom_primary_button.dart';
import 'package:maxwell/shared/widgets/glass_card.dart';

class BookingSheet extends ConsumerStatefulWidget {
  final Machine machine;

  const BookingSheet({super.key, required this.machine});

  static void show(BuildContext context, Machine machine) {
    showModalBottomSheet(
      context: context,
      useRootNavigator: true, // This hides the navbar behind the sheet
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (_) => BookingSheet(machine: machine),
    );
  }

  @override
  ConsumerState<BookingSheet> createState() => _BookingSheetState();
}

class _BookingSheetState extends ConsumerState<BookingSheet> {
  late DateTime _startTime;
  late DateTime _endTime;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _startTime = DateTime(now.year, now.month, now.day, now.hour, now.minute < 30 ? 30 : 0)
        .add(Duration(hours: now.minute < 30 ? 0 : 1));
    _endTime = _startTime.add(const Duration(hours: 1));
  }

  Future<void> _handleBooking() async {
    setState(() => _isLoading = true);
    try {
      await ref.read(bookingControllerProvider.notifier).createBooking(
        machineId: widget.machine.id,
        startTime: _startTime,
        endTime: _endTime,
      );
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Booking confirmed!'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GlassCard(
      borderRadius: 32,
      blur: 25,
      color: isDark ? Colors.grey[900] : Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Book ${widget.machine.name}',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const Gap(32),
          Text('Select Timeslot', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
          const Gap(16),
          _buildTimeRow('Start Time', _startTime, (newTime) {
            setState(() {
              _startTime = newTime;
              if (_endTime.isBefore(_startTime)) {
                _endTime = _startTime.add(const Duration(hours: 1));
              }
            });
          }),
          const Gap(12),
          _buildTimeRow('End Time', _endTime, (newTime) {
            setState(() => _endTime = newTime);
          }),
          const Gap(40),
          CustomPrimaryButton(
            text: 'Confirm Reservation',
            isLoading: _isLoading,
            onPressed: _handleBooking,
          ),
          const Gap(16),
        ],
      ),
    );
  }

  Widget _buildTimeRow(String label, DateTime time, Function(DateTime) onChanged) {
    final isIOS = Theme.of(context).platform == TargetPlatform.iOS;
    final timeFormat = DateFormat('HH:mm');

    return InkWell(
      onTap: () => isIOS ? _showCupertinoPicker(context, time, onChanged) : _showMaterialPicker(context, time, onChanged),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface.withOpacity(0.8),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.1)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
            Text(
              timeFormat.format(time),
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCupertinoPicker(BuildContext context, DateTime initialTime, Function(DateTime) onChanged) {
    showCupertinoModalPopup(
      context: context,
      builder: (_) => Container(
        height: 250,
        color: CupertinoColors.systemBackground.resolveFrom(context),
        child: CupertinoDatePicker(
          mode: CupertinoDatePickerMode.time,
          initialDateTime: initialTime,
          use24hFormat: true,
          onDateTimeChanged: onChanged,
        ),
      ),
    );
  }

  Future<void> _showMaterialPicker(BuildContext context, DateTime initialTime, Function(DateTime) onChanged) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initialTime),
    );
    if (picked != null) {
      final now = DateTime.now();
      onChanged(DateTime(now.year, now.month, now.day, picked.hour, picked.minute));
    }
  }
}
