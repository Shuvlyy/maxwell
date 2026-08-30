import 'package:maxwell/core/api/dio_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:maxwell/features/machines/domain/machine.dart';

part 'machines_provider.g.dart';

@riverpod
Future<List<Machine>> machines(MachinesRef ref) async {
  final dio = ref.watch(dioProvider);
  final response = await dio.get('/api/machines');

  return (response.data as List)
      .map((json) => Machine.fromJson(json))
      .toList();
}

@riverpod
Future<Machine?> machineById(MachineByIdRef ref, String id) async
{
  final machines = await ref.watch(machinesProvider.future);
  return machines.firstWhere((m) => m.id == id);
}
