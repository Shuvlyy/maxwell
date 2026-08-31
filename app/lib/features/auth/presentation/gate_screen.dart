import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:maxwell/shared/widgets/api_url_dialog.dart';
import 'package:maxwell/shared/widgets/custom_primary_button.dart';
import 'package:maxwell/shared/widgets/glass_card.dart';

class GateScreen extends StatelessWidget
{
  const GateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: isDark 
                  ? [const Color(0xFF000000), const Color(0xFF1C1C1E)] 
                  : [const Color(0xFFE0EAFC), const Color(0xFFCFDEF3)],
              ),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            right: 16,
            child: IconButton(
              icon: Icon(Icons.settings_outlined, color: isDark ? Colors.white70 : Colors.black54),
              onPressed: () => ApiUrlDialog.show(context),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(),
                  const Icon(
                    Icons.local_laundry_service_rounded,
                    size: 100,
                    color: Color(0xFF007AFF),
                  ).animate().fadeIn(duration: 800.ms).scale(delay: 200.ms),
                  const Gap(24),
                  Text(
                    'Maxwell',
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2, end: 0),
                  const Gap(12),
                  Text(
                    'Laundry booking for Herden residents',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).hintColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.2, end: 0),
                  const Spacer(),
                  GlassCard(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        CustomPrimaryButton(
                          text: 'Login',
                          onPressed: () => context.push('/login'),
                        ).animate().fadeIn(delay: 800.ms).slideY(begin: 0.2, end: 0),
                        const Gap(16),
                        SizedBox(
                          width: double.infinity,
                          child: TextButton(
                            onPressed: () => context.push('/register'),
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              backgroundColor: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.03),
                            ),
                            child: const Text(
                              'Register',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF007AFF),
                              ),
                            ),
                          ),
                        ).animate().fadeIn(delay: 1000.ms).slideY(begin: 0.2, end: 0),
                      ],
                    ),
                  ),
                  const Gap(40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
