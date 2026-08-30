enum MachineType { washer, dryer }
enum MachineBaseStatus { functional, maintenance }

class Machine
{
  final String id;
  final MachineType type;
  final MachineBaseStatus baseStatus;

  Machine({
    required this.id,
    required this.type,
    this.baseStatus = MachineBaseStatus.functional,
  });

  String get name => type == MachineType.washer ? 'Washing Machine' : 'Dryer';
}
