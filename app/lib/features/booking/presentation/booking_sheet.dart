import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:maxwell/features/machines/domain/machine.dart';
import 'package:maxwell/features/booking/presentation/booking_controller.dart';
import 'package:maxwell/shared/utils/dialog.dart';
import 'package:maxwell/shared/widgets/custom_primary_button.dart';
import 'package:maxwell/shared/widgets/glass_card.dart';

import 'package:maxwell/features/machines/domain/booking.dart';

class BookingSheet extends ConsumerStatefulWidget {
  final Machine machine;
  final Booking? existingBooking;

  const BookingSheet({
    super.key,
    required this.machine,
    this.existingBooking,
  });

  static void show(BuildContext context, Machine machine, {Booking? existingBooking}) {
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (_) => BookingSheet(machine: machine, existingBooking: existingBooking),
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
    if (widget.existingBooking != null) {
      _startTime = widget.existingBooking!.startTime.toLocal();
      _endTime = widget.existingBooking!.endTime.toLocal();
    } else {
      final now = DateTime.now();
      _startTime = DateTime(now.year, now.month, now.day, now.hour, now.minute < 30 ? 30 : 0)
          .add(Duration(hours: now.minute < 30 ? 0 : 1));
      _endTime = _startTime.add(const Duration(hours: 1));
    }
  }

  Future<void> _handleBooking() async {
    if (_startTime.isBefore(DateTime.now())) {
      showErrorDialog(context, 'You cannot book a machine in the past.');
      return;
    }

    setState(() => _isLoading = true);
    try {
      if (widget.existingBooking != null) {
        await ref.read(bookingControllerProvider.notifier).updateBooking(
          bookingId: widget.existingBooking!.id,
          machineId: widget.machine.id,
          startTime: _startTime,
          endTime: _endTime,
        );
      } else {
        await ref.read(bookingControllerProvider.notifier).createBooking(
          machineId: widget.machine.id,
          startTime: _startTime,
          endTime: _endTime,
        );
      }
      
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.existingBooking != null ? 'Booking updated!' : 'Booking confirmed!'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        showErrorDialog(context, e.toString().replaceAll('Exception: ', ''));
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
    final isEdit = widget.existingBooking != null;

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
                isEdit ? 'Edit Reservation' : 'Book ${widget.machine.name}',
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
          _buildDateRow(),
          const Gap(12),
          _buildTimeRow('Start Time', _startTime, (newTime) {
            setState(() {
              // Preserve the date part of _startTime
              _startTime = DateTime(
                _startTime.year, _startTime.month, _startTime.day,
                newTime.hour, newTime.minute,
              );
              if (_endTime.isBefore(_startTime)) {
                _endTime = _startTime.add(const Duration(hours: 1));
              }
            });
          }),
          const Gap(12),
          _buildTimeRow('End Time', _endTime, (newTime) {
            setState(() {
              // Preserve the date part of _endTime
              _endTime = DateTime(
                _endTime.year, _endTime.month, _endTime.day,
                newTime.hour, newTime.minute,
              );
            });
          }),
          const Gap(40),
          CustomPrimaryButton(
            text: isEdit ? 'Save Changes' : 'Confirm Reservation',
            isLoading: _isLoading,
            onPressed: _handleBooking,
          ),
          const Gap(16),
        ],
      ),
    );
  }

  Widget _buildDateRow() {
    final isIOS = Theme.of(context).platform == TargetPlatform.iOS;
    final dateFormat = DateFormat('EEEE, MMMM d');

    return InkWell(
      onTap: () => isIOS ? _showCupertinoDatePicker() : _showMaterialDatePicker(),
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
            const Text('Date', style: TextStyle(fontWeight: FontWeight.w500)),
            Text(
              dateFormat.format(_startTime),
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

  void _showCupertinoDatePicker() {
    showCupertinoModalPopup(
      context: context,
      builder: (_) => Container(
        height: 250,
        color: CupertinoColors.systemBackground.resolveFrom(context),
        child: CupertinoDatePicker(
          mode: CupertinoDatePickerMode.date,
          initialDateTime: _startTime,
          minimumDate: DateTime.now().subtract(const Duration(minutes: 1)),
          onDateTimeChanged: (newDate) {
            setState(() {
              _startTime = DateTime(
                newDate.year, newDate.month, newDate.day,
                _startTime.hour, _startTime.minute,
              );
              _endTime = DateTime(
                newDate.year, newDate.month, newDate.day,
                _endTime.hour, _endTime.minute,
              );
            });
          },
        ),
      ),
    );
  }

  Future<void> _showMaterialDatePicker() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startTime,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (picked != null) {
      setState(() {
        _startTime = DateTime(
          picked.year, picked.month, picked.day,
          _startTime.hour, _startTime.minute,
        );
        _endTime = DateTime(
          picked.year, picked.month, picked.day,
          _endTime.hour, _endTime.minute,
        );
      });
    }
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
