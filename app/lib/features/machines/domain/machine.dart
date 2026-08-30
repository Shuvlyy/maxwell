import 'package:json_annotation/json_annotation.dart';

part 'machine.g.dart';

enum MachineType { washer, dryer }
enum MachineStatus { available, running, out_of_order }

@JsonSerializable(fieldRename: FieldRename.snake)
class Machine {
  final String id;
  final MachineType type;
  final MachineStatus status;
  final String? currentUserId;
  final DateTime? nextBooking;

  Machine({
    required this.id,
    required this.type,
    this.status = MachineStatus.available,
    this.currentUserId,
    this.nextBooking,
  });

  factory Machine.fromJson(Map<String, dynamic> json) => _$MachineFromJson(json);

  Map<String, dynamic> toJson() => _$MachineToJson(this);

  String get name => type == MachineType.washer ? 'Washing Machine' : 'Dryer';
}
