import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:maxwell/features/auth/data/auth_controller.dart';
import 'package:maxwell/shared/utils/dialog.dart';
import 'package:maxwell/shared/widgets/custom_primary_button.dart';
import 'package:maxwell/shared/widgets/modern_text_field.dart';

class LoginScreen extends ConsumerStatefulWidget
{
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
{
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _login() async
  {
    setState(() => _isLoading = true);
    try {
      await ref.read(authControllerProvider.notifier).login(
        _usernameController.text,
        _passwordController.text,
      );
    } catch (e) {
      if (mounted) {
        showErrorDialog(context, e.toString().replaceAll('Exception: ', ''));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context)
  {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Gap(40),
            Text(
              'Login',
              style: Theme.of(context).textTheme.displayLarge,
            ),
            const Gap(8),
            Text(
              'Sign in with your username and password.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).hintColor,
              ),
            ),
            const Gap(48),
            ModernTextField(
              hintText: 'Username (e.g. lboursette-1009)',
              controller: _usernameController,
              prefixIcon: Icons.alternate_email,
            ),
            const Gap(16),
            ModernTextField(
              hintText: 'Password',
              controller: _passwordController,
              prefixIcon: Icons.lock_outline,
              obscureText: true,
            ),
            const Gap(48),
            CustomPrimaryButton(
              text: 'Sign In',
              isLoading: _isLoading,
              onPressed: _login,
            ),
          ],
        ),
      ),
    );
  }
}
