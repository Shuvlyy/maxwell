import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:maxwell/core/api/base_url_provider.dart';
import 'package:maxwell/shared/widgets/custom_primary_button.dart';
import 'package:maxwell/shared/widgets/glass_card.dart';
import 'package:maxwell/shared/widgets/modern_text_field.dart';

class ApiUrlDialog extends ConsumerStatefulWidget
{
  const ApiUrlDialog({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const ApiUrlDialog(),
    );
  }

  @override
  ConsumerState<ApiUrlDialog> createState() => _ApiUrlDialogState();
}

class _ApiUrlDialogState extends ConsumerState<ApiUrlDialog>
{
  late TextEditingController _controller;

  @override
  void initState()
  {
    super.initState();
    final currentUrl = ref.read(baseUrlProvider);
    _controller = TextEditingController(text: currentUrl);
  }

  @override
  void dispose()
  {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: GlassCard(
        borderRadius: 32,
        padding: const EdgeInsets.all(32),
        color: isDark ? Colors.grey[900] : Colors.white,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Server Settings',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const Gap(8),
            Text(
              'Change the API Base URL. The app will remember this setting.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).hintColor,
              ),
            ),
            const Gap(24),
            ModernTextField(
              hintText: 'http://localhost:8000',
              controller: _controller,
              prefixIcon: Icons.lan_outlined,
            ),
            const Gap(32),
            CustomPrimaryButton(
              text: 'Save & Restart Connection',
              onPressed: () async {
                final newUrl = _controller.text.trim();
                if (newUrl.isNotEmpty) {
                  await ref.read(baseUrlProvider.notifier).setBaseUrl(newUrl);
                  if (mounted) {
                    Navigator.pop(context);
                  }
                }
              },
            ),
            const Gap(16),
          ],
        ),
      ),
    );
  }
}
