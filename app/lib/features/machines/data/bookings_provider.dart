import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:maxwell/features/machines/domain/booking.dart';

part 'bookings_provider.g.dart';

@Riverpod(keepAlive: true)
class Bookings extends _$Bookings
{
  @override
  List<Booking> build() {
    final now = DateTime.now();
    final tomorrow = now.add(const Duration(days: 1));
    final nextWeek = now.add(const Duration(days: 5));

    return [
      Booking(
        id: '1',
        machineId: 'dryer_1',
        userName: 'Alice Smith',
        startTime: now.add(const Duration(hours: 1)),
        endTime: now.add(const Duration(hours: 2)),
      ),
      Booking(
        id: '2',
        machineId: 'dryer_1',
        userName: 'Lucas Chalandon',
        startTime: now.add(const Duration(hours: 3)),
        endTime: now.add(const Duration(hours: 4)),
      ),
      Booking(
        id: '3',
        machineId: 'dryer_1',
        userName: 'Lysandre boursette',
        startTime: now.subtract(const Duration(minutes: 10)),
        endTime: now.add(const Duration(minutes: 50)),
      ),
      Booking(
        id: '4',
        machineId: 'dryer_1',
        userName: 'Charlie Brown',
        startTime: DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 10, 0),
        endTime: DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 11, 30),
      ),
      Booking(
        id: '5',
        machineId: 'washer_1',
        userName: 'Bob Johnson',
        startTime: now.add(const Duration(hours: 1)),
        endTime: now.add(const Duration(hours: 2)),
      ),
      Booking(
        id: '6',
        machineId: 'washer_1',
        userName: 'John Doe',
        startTime: DateTime(nextWeek.year, nextWeek.month, nextWeek.day, 14, 0),
        endTime: DateTime(nextWeek.year, nextWeek.month, nextWeek.day, 15, 0),
      ),
    ];
  }

  void addBooking(Booking booking)
  {
    state = [...state, booking];
  }
}

@riverpod
List<Booking> bookingsForMachine(BookingsForMachineRef ref, String machineId)
{
  final allBookings = ref.watch(bookingsProvider);
  final machineBookings = allBookings.where((b) => b.machineId == machineId).toList();
  
  // Sort by start time (soonest first)
  machineBookings.sort((a, b) => a.startTime.compareTo(b.startTime));
  
  return machineBookings;
}

@riverpod
Booking? currentBookingForMachine(
  CurrentBookingForMachineRef ref,
  String machineId
)
{
  final bookings = ref.watch(bookingsForMachineProvider(machineId));
  final now = DateTime.now();

  try {
    return bookings.firstWhere(
      (b) => b.startTime.isBefore(now) && b.endTime.isAfter(now),
    );
  } catch (_) {
    return null;
  }
}
