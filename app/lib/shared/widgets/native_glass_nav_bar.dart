import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:native_glass_navbar/native_glass_navbar.dart';

class AppNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const AppNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return NativeGlassNavBar(
      currentIndex: currentIndex,
      onTap: _handleTap,
      // Uses native SF Symbols on iOS
      tabs: const [
        NativeGlassNavBarItem(
          label: 'Home',
          symbol: 'house.fill',
        ),
        NativeGlassNavBarItem(
          label: 'Settings',
          symbol: 'gear',
        ),
      ],
      fallback: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: _handleTap,
        elevation: 8,
        backgroundColor: (isDark ? Colors.black : Colors.white).withOpacity(0.9),
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Theme.of(context).hintColor.withOpacity(0.5),
        selectedLabelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
        unselectedLabelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded, size: 26),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_rounded, size: 26),
            label: 'Settings',
          ),
        ],
      ),
    );
  }

  void _handleTap(int index) {
    if (index != currentIndex) {
      HapticFeedback.lightImpact();
      onTap(index);
    }
  }
}