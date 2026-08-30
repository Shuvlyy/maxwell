import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:maxwell/core/api/dio_provider.dart';
import 'package:maxwell/features/machines/domain/booking.dart';

part 'bookings_provider.g.dart';

@riverpod
Future<List<Booking>> bookings(BookingsRef ref) async
{
  final dio = ref.watch(dioProvider);
  final response = await dio.get('/api/bookings');

  return (response.data as List)
    .map((json) => Booking.fromJson(json))
    .toList();
}

@riverpod
Future<List<Booking>> bookingsForMachine(BookingsForMachineRef ref, String machineId) async
{
  final allBookings = await ref.watch(bookingsProvider.future);
  final machineBookings = allBookings.where((b) => b.machineId == machineId).toList();
  machineBookings.sort((a, b) => a.startTime.compareTo(b.startTime));
  return machineBookings;
}

@riverpod
Future<Booking?> currentBookingForMachine(CurrentBookingForMachineRef ref, String machineId) async
{
  final bookings = await ref.watch(bookingsForMachineProvider(machineId).future);
  final now = DateTime.now();
  try {
    return bookings.firstWhere((b) => b.startTime.isBefore(now) && b.endTime.isAfter(now));
  } catch (_) {
    return null;
  }
}
