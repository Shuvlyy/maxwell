import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:maxwell/core/constants.dart';
import 'package:maxwell/features/auth/data/auth_controller.dart';
import 'package:maxwell/shared/utils/dialog.dart';
import 'package:maxwell/shared/widgets/glass_card.dart';

class SettingsScreen extends ConsumerWidget
{
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref)
  {
    final user = ref.watch(authControllerProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings', style: TextStyle(fontWeight: FontWeight.w800)),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 100),
        children: [
          // Profile section
          Text(
            'Profile',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
          const Gap(16),
          GlassCard(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  child: Text(
                    user?.firstName.substring(0, 1).toUpperCase() ?? 'U',
                    style: const TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
                const Gap(16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${user?.firstName} ${user?.lastName}',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '@${user?.username}',
                        style: TextStyle(color: Theme.of(context).hintColor),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Gap(32),

          // App settings section
          Text(
            'App Settings',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
          const Gap(16),
          _buildSettingsGroup([
            _SettingsTile(
              icon: Icons.language_rounded,
              title: 'Language',
              trailing: 'English',
              onTap: () {
                showBaseDialog(context, "Soon", "This feature is coming soon.");
              },
            ),
            _SettingsTile(
              icon: isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
              title: 'Appearance',
              trailing: isDark ? 'Dark' : 'Light',
              onTap: () {
                showBaseDialog(context, "Soon", "This feature is coming soon.");
              },
            ),
            _SettingsTile(
              icon: Icons.notifications_none_rounded,
              title: 'Notifications',
              onTap: () {
                showBaseDialog(context, "Soon", "This feature is coming soon.");
              },
            ),
          ]),
          const Gap(32),

          // Account actions
          _buildSettingsGroup([
            _SettingsTile(
              icon: Icons.logout_rounded,
              title: 'Log Out',
              titleColor: Colors.red,
              showChevron: false,
              onTap: () => _handleLogout(context, ref),
            ),
          ]),
          const Gap(16),

          const Center(child: Text(Constants.appVersion))
        ],
      ),
    );
  }

  Widget _buildSettingsGroup(List<Widget> tiles)
  {
    return GlassCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: tiles.asMap().entries.map((entry) {
          final isLast = entry.key == tiles.length - 1;
          return Column(
            children: [
              entry.value,
              if (!isLast)
                const Divider(height: 1, indent: 56, endIndent: 16),
            ],
          );
        }).toList(),
      ),
    );
  }

  void _handleLogout(BuildContext context, WidgetRef ref)
  {
    showDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text(
          'Log Out',
          style: TextStyle(
            fontSize: 20
          ),
        ),
        content: const Padding(
          padding: EdgeInsetsGeometry.only(top: 4),
          child: Text(
            'Are you sure you want to log out?',
            style: TextStyle(
              fontSize: 16
            ),
          ),
        ),
        actions: [
          CupertinoDialogAction(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(context),
          ),
          CupertinoDialogAction(
            isDefaultAction: true,
            child: const Text('Log out', style: TextStyle(color: Colors.red)),
            onPressed: () {
              Navigator.pop(context);
              ref.read(authControllerProvider.notifier).logout();
            },
          ),
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget
{
  final IconData icon;
  final String title;
  final String? trailing;
  final Color? titleColor;
  final bool showChevron;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    this.trailing,
    this.titleColor,
    this.showChevron = true,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context)
  {
    return ListTile(
      leading: Icon(icon, color: titleColor ?? Theme.of(context).colorScheme.primary),
      title: Text(
        title,
        style: TextStyle(color: titleColor, fontWeight: FontWeight.w600),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (trailing != null)
            Text(
              trailing!,
              style: TextStyle(color: Theme.of(context).hintColor, fontSize: 14),
            ),
          if (showChevron) ...[
            const Gap(8),
            Icon(Icons.chevron_right_rounded, size: 20, color: Theme.of(context).hintColor),
          ],
        ],
      ),
      onTap: onTap,
    );
  }
}
