import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:maxwell/features/auth/data/auth_controller.dart';
import 'package:maxwell/features/onboarding/presentation/onboarding_controller.dart';
import 'package:maxwell/shared/widgets/custom_primary_button.dart';
import 'package:maxwell/shared/widgets/modern_text_field.dart';

class ActivationStep extends ConsumerStatefulWidget
{
  const ActivationStep({super.key});

  @override
  ConsumerState<ActivationStep> createState() => _ActivationStepState();
}

class _ActivationStepState extends ConsumerState<ActivationStep>
{
  String _code = '';

  Future<void> _showUsernameDialog(String username) async
  {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Registration Successful!'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                const Text('Please remember your username for future logins:'),
                const Gap(16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF007AFF).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    username,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF007AFF),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Got it!'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context)
  {
    final state = ref.watch(onboardingControllerProvider);
    final controller = ref.read(onboardingControllerProvider.notifier);

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Gap(80),
          Text(
            'Activation',
            style: Theme.of(context).textTheme.displayLarge,
          ),
          const Gap(8),
          Text(
            'Please enter the activation code given by Lysandre to access the app.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).hintColor,
            ),
          ),
          const Gap(40),
          ModernTextField(
            hintText: 'Enter Code',
            prefixIcon: Icons.lock_outline,
            obscureText: true,
            textCapitalization: TextCapitalization.characters,
            onChanged: (value) => setState(() => _code = value),
          ),
          const Gap(48),
          CustomPrimaryButton(
            text: 'Verify & Start',
            isLoading: state.isLoading,
            onPressed: () async {
              try {
                await controller.verifyActivationCode(_code);
                
                final user = ref.read(authControllerProvider);

                if (user != null && context.mounted) {
                  await _showUsernameDialog(user.username);
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(e.toString().replaceAll('Exception: ', '')),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
          ),
        ],
      ),
    );
  }
}
