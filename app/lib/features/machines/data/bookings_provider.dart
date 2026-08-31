import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:maxwell/core/api/dio_provider.dart';
import 'package:maxwell/core/api/socket_provider.dart';
import 'package:maxwell/features/machines/domain/booking.dart';

part 'bookings_provider.g.dart';

@riverpod
Stream<DateTime> currentTime(CurrentTimeRef ref)
{
  return Stream.periodic(const Duration(seconds: 1), (_) => DateTime.now());
}

@riverpod
Future<List<Booking>> bookings(BookingsRef ref) async
{
  final dio = ref.watch(dioProvider);

  ref.listen(socketProvider, (previous, next) {
    if (next.value?['type'] == 'bookings_updated') {
      ref.invalidateSelf();
    }
  });

  final response = await dio.get('/api/bookings');

  return (response.data as List)
    .map((json) => Booking.fromJson(json))
    .toList();
}

@riverpod
Future<List<Booking>> bookingsForMachine(
  BookingsForMachineRef ref,
  String machineId
) async
{
  final allBookings = await ref.watch(bookingsProvider.future);
  final machineBookings = allBookings.where((b) => b.machineId == machineId).toList();
  machineBookings.sort((a, b) => a.startTime.compareTo(b.startTime));
  return machineBookings;
}

@riverpod
Booking? currentBookingForMachine(CurrentBookingForMachineRef ref, String machineId)
{
  final bookingsAsync = ref.watch(bookingsForMachineProvider(machineId));
  final now = ref.watch(currentTimeProvider).value ?? DateTime.now();

  return bookingsAsync.valueOrNull?.where((b) => 
    b.startTime.isBefore(now) && b.endTime.isAfter(now)
  ).firstOrNull;
}
