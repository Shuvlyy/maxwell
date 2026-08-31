import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:maxwell/features/onboarding/presentation/onboarding_controller.dart';
import 'package:maxwell/shared/utils/dialog.dart';
import 'package:maxwell/shared/widgets/custom_primary_button.dart';
import 'package:maxwell/shared/widgets/modern_text_field.dart';

class UserInfoStep extends ConsumerStatefulWidget
{
  final VoidCallback onNext;

  const UserInfoStep({super.key, required this.onNext});

  @override
  ConsumerState<UserInfoStep> createState() => _UserInfoStepState();
}

class _UserInfoStepState extends ConsumerState<UserInfoStep>
{
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context)
  {
    final controller = ref.read(onboardingControllerProvider.notifier);
    final state = ref.watch(onboardingControllerProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Gap(60),
            Text(
              'About You',
              style: Theme.of(context).textTheme.displayLarge,
            ),
            const Gap(8),
            Text(
              'Please provide your details and create a password.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).hintColor,
              ),
            ),
            const Gap(32),
            ModernTextField(
              hintText: 'First Name',
              prefixIcon: Icons.person_outline,
              onChanged: controller.updateFirstName,
            ),
            const Gap(16),
            ModernTextField(
              hintText: 'Last Name',
              prefixIcon: Icons.person_outline,
              onChanged: controller.updateLastName,
            ),
            const Gap(16),
            ModernTextField(
              hintText: 'Room Number',
              prefixIcon: Icons.room_outlined,
              keyboardType: TextInputType.number,
              onChanged: controller.updateRoomNumber,
            ),
            const Gap(16),
            ModernTextField(
              hintText: 'Create Password',
              prefixIcon: Icons.lock_outline,
              obscureText: true,
              onChanged: controller.updatePassword,
            ),
            const Gap(16),
            ModernTextField(
              hintText: 'Phone (Optional)',
              prefixIcon: Icons.phone_android_outlined,
              keyboardType: TextInputType.phone,
              onChanged: controller.updatePhone,
            ),
            const Gap(40),
            CustomPrimaryButton(
              text: 'Next',
              onPressed: () {
                if (!state.isComplete()) {
                  showErrorDialog(context, 'Please fill all required fields');
                  return;
                }

                final roomRegex = RegExp(r'^\d{4}$');
                if (!roomRegex.hasMatch(state.roomNumber)) {
                  showErrorDialog(context, 'Room number must be exactly 4 digits');
                  return;
                }

                if (state.phone != null && state.phone!.isNotEmpty) {
                  final phoneRegex = RegExp(r'^\+?[1-9]\d{1,14}(?:[\s.-]\d{1,13})*$');
                  if (!phoneRegex.hasMatch(state.phone!)) {
                    showErrorDialog(context, "Invalid phone format.\nUse international format (e.g., +33 7 67...)");
                    return;
                  }
                }

                widget.onNext();
              },
            ),
          ],
        ),
      ),
    );
  }
}
