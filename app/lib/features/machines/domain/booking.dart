class Booking
{
  final String id;
  final String machineId;
  final String userName;
  final DateTime startTime;
  final DateTime endTime;

  Booking({
    required this.id,
    required this.machineId,
    required this.userName,
    required this.startTime,
    required this.endTime,
  });
}
