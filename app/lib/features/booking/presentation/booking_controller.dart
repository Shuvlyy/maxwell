import 'package:dio/dio.dart';
import 'package:maxwell/core/api/dio_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:maxwell/features/machines/data/bookings_provider.dart';

part 'booking_controller.g.dart';

@riverpod
class BookingController extends _$BookingController
{
  @override
  void build() {}

  Future<void> createBooking({
    required String machineId,
    required DateTime startTime,
    required DateTime endTime,
  })
    async
  {
    final dio = ref.read(dioProvider);

    final duration = endTime.difference(startTime);
    if (duration.inMinutes > 120) {
      throw Exception('Bookings cannot exceed 2 hours.');
    }
    if (duration.inMinutes <= 0) {
      throw Exception('Invalid time range.');
    }

    try {
      await dio.post('/api/bookings', data: {
        'machine_id': machineId,
        'start_time': startTime.toUtc().toIso8601String(),
        'end_time': endTime.toUtc().toIso8601String(),
      });

      ref.invalidate(bookingsProvider);
    } on DioException catch (e) {
      throw Exception(e.response?.data['detail'] ?? 'Booking failed');
    }
  }
}
