import 'package:json_annotation/json_annotation.dart';

part 'booking.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class BookingUser {
  final String firstName;
  final String lastName;
  final String roomNumber;
  final String? phone;

  BookingUser({
    required this.firstName,
    required this.lastName,
    required this.roomNumber,
    this.phone,
  });

  factory BookingUser.fromJson(Map<String, dynamic> json) => _$BookingUserFromJson(json);
  Map<String, dynamic> toJson() => _$BookingUserToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class Booking {
  final String id;
  final String machineId;
  final BookingUser user;
  final DateTime startTime;
  final DateTime endTime;

  Booking({
    required this.id,
    required this.machineId,
    required this.user,
    required this.startTime,
    required this.endTime,
  });

  factory Booking.fromJson(Map<String, dynamic> json) => _$BookingFromJson(json);
  Map<String, dynamic> toJson() => _$BookingToJson(this);
}