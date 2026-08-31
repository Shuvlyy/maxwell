import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:maxwell/features/booking/presentation/booking_controller.dart';
import 'package:maxwell/features/machines/data/machines_provider.dart';
import 'package:maxwell/features/machines/data/bookings_provider.dart';
import 'package:maxwell/features/machines/domain/machine.dart';
import 'package:maxwell/features/machines/domain/booking.dart';
import 'package:maxwell/features/booking/presentation/booking_sheet.dart';
import 'package:maxwell/shared/widgets/custom_primary_button.dart';
import 'package:maxwell/shared/widgets/glass_card.dart';

import 'package:maxwell/features/auth/data/auth_controller.dart';

class MachineDetailsScreen extends ConsumerWidget
{
  final String id;

  const MachineDetailsScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final machineAsync = ref.watch(machineByIdProvider(id));
    final bookingsAsync = ref.watch(bookingsForMachineProvider(id));
    final currentBooking = ref.watch(currentBookingForMachineProvider(id));
    final user = ref.watch(authControllerProvider);

    final machine = machineAsync.valueOrNull;
    final bookings = bookingsAsync.valueOrNull;

    // We no longer check currentBookingAsync.isLoading because currentBooking is synchronous
    if (machine == null || bookings == null) {
      if (machineAsync.hasError || bookingsAsync.hasError) {
        return const Scaffold(body: Center(child: Text('Erreur ou machine introuvable')));
      }
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
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
            _buildReservationsList(context, bookings, ref, machine),
          ],
        ),
      ),
      bottomNavigationBar: _buildFooter(context, machine, isIOS),
    );
  }

  Widget _buildHeader(BuildContext context, Machine machine, Booking? currentBooking) {
    final isMaintenance = machine.status == MachineStatus.out_of_order;
    final isInUse = currentBooking != null && !isMaintenance;

    Color statusColor;
    if (isMaintenance) {
      statusColor = Colors.red;
    } else if (isInUse) {
      statusColor = Colors.orange;
    } else {
      statusColor = Colors.green;
    }

    final isIOS = Theme.of(context).platform == TargetPlatform.iOS;

    Widget icon = Icon(
      machine.type == MachineType.washer
        ? Icons.local_laundry_service
        : Icons.wb_sunny_outlined,
      size: 80,
      color: Theme.of(context).colorScheme.primary,
    );

    if (isInUse) {
      icon = icon
        .animate(onPlay: (c) => c.repeat())
        .rotate(duration: isIOS ? 3000.ms : 2000.ms, curve: Curves.linear);
    }

    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          icon,
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
              'Used by ${currentBooking.user.firstName} ${currentBooking.user.lastName}',
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

  Widget _buildReservationsList(BuildContext context, List<Booking> bookings, WidgetRef ref, Machine machine)
  {
    final currentUser = ref.watch(authControllerProvider);

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
                
                // Simplified ownership check - in a real app we'd compare IDs
                // but since the Booking model's user doesn't have an ID, we compare names/rooms
                // or ideally update the model. For now, let's assume if it matches currentUser it's ours.
                final isMine = currentUser != null && 
                               booking.user.firstName == currentUser.firstName && 
                               booking.user.lastName == currentUser.lastName;

                Widget item = GlassCard(
                  borderRadius: 16,
                  border: isCurrent ? Border.all(color: Colors.orange.withOpacity(0.5), width: 1.5) : null,
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: isMine ? Theme.of(context).colorScheme.primary : (isCurrent ? Colors.orange : Colors.blueAccent),
                      child: Icon(isMine ? Icons.star : Icons.person, color: Colors.white),
                    ),
                    title: Text(
                      isMine ? 'Your Reservation' : '${booking.user.firstName} ${booking.user.lastName}',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      '${timeFormat.format(booking.startTime.toLocal())} - ${timeFormat.format(booking.endTime.toLocal())}',
                    ),
                    trailing: isMine 
                      ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit_outlined, size: 20),
                              onPressed: () => BookingSheet.show(context, machine, existingBooking: booking),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, size: 20, color: Colors.redAccent),
                              onPressed: () => _confirmDeletion(context, ref, booking),
                            ),
                          ],
                        )
                      : (isCurrent
                        ? const Text('NOW', style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold))
                        : null),
                    onTap: isMine ? null : () {
                      showCupertinoDialog(
                        context: context,
                        builder: (context) => CupertinoAlertDialog(
                          title: Text('${booking.user.firstName} ${booking.user.lastName}'),
                          content: Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text('Room: ${booking.user.roomNumber}'),
                                if (booking.user.phone != null && booking.user.phone!.isNotEmpty)
                                  Text('Phone: ${booking.user.phone}'),
                              ],
                            ),
                          ),
                          actions: [
                            CupertinoDialogAction(
                              isDefaultAction: true,
                              child: const Text('Close'),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ).animate().fadeIn(delay: (index * 100).ms).slideX(begin: 0.1, end: 0);

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

  void _confirmDeletion(BuildContext context, WidgetRef ref, Booking booking) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Cancel Reservation?'),
        content: const Text('Are you sure you want to cancel this laundry booking?'),
        actions: [
          CupertinoDialogAction(
            child: const Text('No'),
            onPressed: () => Navigator.pop(context),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () async {
              Navigator.pop(context);
              try {
                await ref.read(bookingControllerProvider.notifier).deleteBooking(booking.id);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Reservation cancelled')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
                  );
                }
              }
            },
            child: const Text('Yes, Cancel'),
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
