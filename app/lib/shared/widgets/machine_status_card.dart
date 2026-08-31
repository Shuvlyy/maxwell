import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:maxwell/features/machines/domain/booking.dart';
import 'package:maxwell/features/machines/domain/machine.dart';
import 'package:maxwell/features/machines/data/bookings_provider.dart';
import 'package:maxwell/shared/widgets/glass_card.dart';

class MachineStatusCard extends ConsumerWidget {
  final Machine machine;
  final VoidCallback? onTap;

  const MachineStatusCard({
    super.key,
    required this.machine,
    this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentBooking = ref.watch(currentBookingForMachineProvider(machine.id));
    final isIOS = Theme.of(context).platform == TargetPlatform.iOS;

    final isMaintenance = machine.status == MachineStatus.out_of_order;
    final isInUse = currentBooking != null && !isMaintenance;

    final statusColor = isMaintenance ? Colors.red : (isInUse ? Colors.orange : Colors.green);
    final statusText = isMaintenance ? 'Maintenance' : (isInUse ? 'In Use' : 'Available');

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: GlassCard(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildAnimatedIcon(context, isInUse),
            const Gap(16),
            Text(
              machine.name,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            ),
            const Gap(8),
            _buildStatusBadge(statusColor, statusText, isIOS),
            const Gap(18),
            _buildDescriptionText(context, isInUse, isMaintenance, currentBooking),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.1, end: 0, curve: Curves.easeOutCubic);
  }

  Widget _buildAnimatedIcon(BuildContext context, bool isInUse) {
    final isIOS = Theme.of(context).platform == TargetPlatform.iOS;
    
    Widget icon = Icon(
      machine.type == MachineType.washer
        ? Icons.local_laundry_service
        : Icons.wb_sunny_outlined,
      size: 48,
      color: Theme.of(context).colorScheme.primary,
    );

    if (isInUse) {
      return icon
        .animate(onPlay: (controller) => controller.repeat())
        .rotate(duration: isIOS ? 3000.ms : 2000.ms, curve: Curves.linear);
    }

    return icon;
  }

  Widget _buildStatusBadge(Color statusColor, String text, bool isIOS) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: isIOS ? statusColor.withOpacity(0.15) : statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: isIOS ? Border.all(color: statusColor.withOpacity(0.2), width: 0.5) : null,
      ),
      child: Text(
        text,
        style: TextStyle(
          color: statusColor,
          fontSize: 13,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildDescriptionText(BuildContext context, bool isInUse, bool isMaintenance, Booking? currentBooking) {
    final hintColor = Theme.of(context).hintColor;
    
    if (isMaintenance) {
      return Text(
        'Under maintenance',
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: hintColor),
      );
    }

    if (isInUse && currentBooking != null) {
      final now = DateTime.now();
      final remaining = currentBooking.endTime.difference(now).inMinutes;

      return RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: hintColor),
          children: [
            const TextSpan(text: 'Used by '),
            TextSpan(
              text: "${currentBooking.user.firstName} ${currentBooking.user.lastName}",
              style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.blue),
            ),
            TextSpan(text: '\n$remaining min remaining'),
          ],
        ),
      );
    }
    
    return Text(
      'Ready for your laundry',
      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
        color: hintColor,
      ),
    );
  }
}
