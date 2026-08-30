import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:maxwell/features/auth/data/auth_controller.dart';
import 'package:maxwell/features/machines/data/machines_provider.dart';
import 'package:maxwell/shared/widgets/machine_status_card.dart';

class HomeScreen extends ConsumerWidget
{
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref)
  {
    final machinesAsync = ref.watch(machinesProvider);
    final user = ref.watch(authControllerProvider);
    final username = user?.username ?? '';

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text('Maxwell', style: TextStyle(fontWeight: FontWeight.w800)),
            if (username.isNotEmpty)
              Text(
                '@$username',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).hintColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
          ],
        ),
      ),
      body: machinesAsync.when(
        data: (machines) => Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(48, 0, 48, 48),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: machines.map((machine) => Padding(
                padding: const EdgeInsets.only(bottom: 24.0),
                child: AspectRatio(
                  aspectRatio: 1,
                  child: MachineStatusCard(
                    machine: machine,
                    onTap: () => context.push('/machine/${machine.id}'),
                  ),
                ),
              )).toList(),
            ),
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Erreur: $err')),
      ),
    );
  }
}
