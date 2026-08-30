import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:maxwell/features/machines/data/machines_provider.dart';
import 'package:maxwell/features/machines/data/bookings_provider.dart';
import 'package:maxwell/features/machines/domain/machine.dart';
import 'package:maxwell/features/machines/domain/booking.dart';
import 'package:maxwell/features/booking/presentation/booking_sheet.dart';
import 'package:maxwell/shared/widgets/custom_primary_button.dart';
import 'package:maxwell/shared/widgets/glass_card.dart';

class MachineDetailsScreen extends ConsumerWidget
{
  final String id;

  const MachineDetailsScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref)
  {
    final machine = ref.watch(machineByIdProvider(id));
    final bookings = ref.watch(bookingsForMachineProvider(id));
    final currentBooking = ref.watch(currentBookingForMachineProvider(id));

    if (machine == null) {
      return const Scaffold(body: Center(child: Text('Machine not found')));
    }

    final isIOS = Theme.of(context).platform == TargetPlatform.iOS;
    final backgroundColor = Theme.of(context).scaffoldBackgroundColor;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text('${machine.name} Details'),
        backgroundColor: backgroundColor,
        scrolledUnderElevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(context, machine, currentBooking),
            _buildReservationsList(context, bookings),
          ],
        ),
      ),
      bottomNavigationBar: _buildFooter(context, machine, isIOS),
    );
  }

  Widget _buildHeader(BuildContext context, Machine machine, Booking? currentBooking)
  {
    final isInUse = currentBooking != null && machine.baseStatus == MachineBaseStatus.functional;
    final isMaintenance = machine.baseStatus == MachineBaseStatus.maintenance;

    final statusColor = isMaintenance
      ? Colors.red
      : (isInUse ? Colors.orange : Colors.green); // todo: no nested ternary operators

    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Icon(
            machine.type == MachineType.washer
              ? Icons.local_laundry_service
              : Icons.wb_sunny_outlined,
            size: 80,
            color: Theme.of(context).colorScheme.primary,
          )
          .animate(onPlay: (c) => isInUse ? c.repeat() : null)
          .rotate(duration: 2000.ms),

          const Gap(24),

          Text(
            isMaintenance
              ? 'Maintenance'
              : (isInUse ? 'In Use' : 'Available Now'),
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: statusColor,
              fontWeight: FontWeight.w800,
            ),
          ),

          if (isInUse) ...[
            const Gap(8),
            Text(
              'Used by ${currentBooking.userName}',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const Gap(4),
            Text(
              '${currentBooking.endTime.difference(DateTime.now()).inMinutes} minutes remaining',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).hintColor,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildReservationsList(BuildContext context, List<Booking> bookings)
  {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Upcoming Reservations',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const Gap(16),
          if (bookings.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 32.0),
              child: Center(child: Text('No reservations yet')),
            ),
          if (bookings.isNotEmpty)
            ListView.separated(
              shrinkWrap: true,
              itemCount: bookings.length,
              physics: const NeverScrollableScrollPhysics(),
              separatorBuilder: (context, index) {
                final current = bookings[index];
                final next = index + 1 < bookings.length ? bookings[index + 1] : null;

                if (next != null && !_isSameDay(current.startTime, next.startTime)) {
                  return _buildDateSeparator(context, next.startTime);
                }
                return const Gap(12);
              },
              itemBuilder: (context, index) {
                final booking = bookings[index];
                final timeFormat = DateFormat('HH:mm');
                final now = DateTime.now();
                final isCurrent = booking.startTime.isBefore(now) && booking.endTime.isAfter(now);

                Widget item = GlassCard(
                  borderRadius: 16,
                  border: isCurrent ? Border.all(color: Colors.orange.withOpacity(0.5), width: 1.5) : null,
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: isCurrent ? Colors.orange : Colors.blueAccent,
                      child: const Icon(Icons.person, color: Colors.white),
                    ),
                    title: Text(
                      booking.userName,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      '${timeFormat.format(booking.startTime)} - ${timeFormat.format(booking.endTime)}',
                    ),
                    trailing: isCurrent ? const Text('NOW', style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)) : null,
                  ),
                )
                    .animate()
                    .fadeIn(delay: (index * 100).ms)
                    .slideX(begin: 0.1, end: 0);

                if (index == 0) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDateSeparator(context, booking.startTime),
                      item,
                    ],
                  );
                }

                return item;
              },
            ),
        ],
      ),
    );
  }

  bool _isSameDay(DateTime date1, DateTime date2)
  {
    return date1.year == date2.year && date1.month == date2.month && date1.day == date2.day;
  }

  Widget _buildDateSeparator(BuildContext context, DateTime date)
  {
    final dateFormat = DateFormat('MMMM d\'th\'');
    final now = DateTime.now();
    final label = _isSameDay(date, now) ? 'Today' : dateFormat.format(date);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Row(
        children: [
          Expanded(child: Divider(color: Theme.of(context).dividerColor.withOpacity(0.1))),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              label,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: Theme.of(context).hintColor,
                letterSpacing: 0.5,
              ),
            ),
          ),
          Expanded(child: Divider(color: Theme.of(context).dividerColor.withOpacity(0.1))),
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context, Machine machine, bool isIOS)
  {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final footer = Padding(
      padding: const EdgeInsets.all(24.0),
      child: CustomPrimaryButton(
        text: 'Book this machine',
        onPressed: () => BookingSheet.show(context, machine),
      ),
    );

    if (isIOS) {
      return GlassCard(
        borderRadius: 0,
        blur: 20,
        color: isDark ? Colors.black : Colors.white,
        child: SafeArea(top: false, child: footer),
      );
    }

    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: SafeArea(top: false, child: footer),
    );
  }
}
