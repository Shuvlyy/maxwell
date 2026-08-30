import 'package:flutter/material.dart';
import 'package:maxwell/features/onboarding/presentation/user_info_step.dart';
import 'package:maxwell/features/onboarding/presentation/activation_step.dart';

class OnboardingScreen extends StatefulWidget
{
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
{
  final PageController _pageController = PageController();
  int _currentPage = 0;

  void _nextPage()
  {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context)
  {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (page) => setState(() => _currentPage = page),
                children: [
                  UserInfoStep(onNext: _nextPage),
                  const ActivationStep(),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(2, (index) => _buildDot(index)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDot(int index)
  {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      height: 8,
      width: _currentPage == index ? 24 : 8,
      decoration: BoxDecoration(
        color: _currentPage == index
          ? const Color(0xFF007AFF)
          : const Color(0xFFD1D1D6),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}
