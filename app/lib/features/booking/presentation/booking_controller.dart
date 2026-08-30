import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:maxwell/features/auth/data/auth_controller.dart';
import 'package:maxwell/features/machines/data/bookings_provider.dart';
import 'package:maxwell/features/machines/domain/booking.dart';

part 'booking_controller.g.dart';

@riverpod
class BookingController extends _$BookingController {
  @override
  void build() {}

  Future<void> createBooking({
    required String machineId,
    required DateTime startTime,
    required DateTime endTime,
  }) async {
    final user = ref.read(authControllerProvider);
    if (user == null) throw Exception('User not authenticated');

    // 1. Duration Check: Max 2 hours
    final duration = endTime.difference(startTime);
    if (duration.inMinutes > 120) {
      throw Exception('Bookings cannot exceed 2 hours.');
    }
    if (duration.inMinutes <= 0) {
      throw Exception('Invalid time range.');
    }

    // 2. Daily Limit Check: Max 3 bookings per day
    final allBookings = ref.read(bookingsProvider);
    final now = DateTime.now();
    final todayBookings = allBookings.where((b) => 
      b.userName == user.firstName && // Mock check using firstName since we don't have user IDs in mock bookings yet
      b.startTime.year == now.year &&
      b.startTime.month == now.month &&
      b.startTime.day == now.day
    ).length;

    if (todayBookings >= 3) {
      throw Exception('You have reached the limit of 3 bookings for today.');
    }

    // Mock API call
    await Future.delayed(const Duration(seconds: 1));

    final booking = Booking(
      id: 'b-${DateTime.now().millisecondsSinceEpoch}',
      machineId: machineId,
      userName: user.firstName,
      startTime: startTime,
      endTime: endTime,
    );

    ref.read(bookingsProvider.notifier).addBooking(booking);
  }
}
