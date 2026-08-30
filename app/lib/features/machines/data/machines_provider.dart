import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:maxwell/features/machines/domain/machine.dart';

part 'machines_provider.g.dart';

@riverpod
List<Machine> machines(MachinesRef ref)
{
  return [
    Machine(
      id: 'dryer_1',
      type: MachineType.dryer,
    ),
    Machine(
      id: 'washer_1',
      type: MachineType.washer,
    ),
  ];
}

@riverpod
Machine? machineById(MachineByIdRef ref, String id)
{
  final allMachines = ref.watch(machinesProvider);

  try {
    return allMachines.firstWhere((m) => m.id == id);
  } catch (_) {
    return null;
  }
}
