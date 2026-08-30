import 'dart:ui';
import 'package:flutter/material.dart';

class GlassCard extends StatelessWidget {
  final Widget child;
  final double blur;
  final double borderRadius;
  final Color? color;
  final Border? border;
  final EdgeInsetsGeometry? padding;

  const GlassCard({
    super.key,
    required this.child,
    this.blur = 20.0, // Increased blur
    this.borderRadius = 24.0,
    this.color,
    this.border,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isIOS = Theme.of(context).platform == TargetPlatform.iOS;

    if (!isIOS) {
      return Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        color: isDark ? const Color(0xFF1C1C1E) : Colors.white, // Solid fallback
        child: Padding(
          padding: padding ?? EdgeInsets.zero,
          child: child,
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(borderRadius),
            border: border ??
                Border.all(
                  color: (isDark ? Colors.white : Colors.black).withOpacity(0.15), // Increased border opacity
                  width: 0.5,
                ),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                // Increased surface opacity for better visibility
                (color ?? (isDark ? Colors.grey[900]! : Colors.white)).withOpacity(isDark ? 0.4 : 0.6),
                (color ?? (isDark ? Colors.grey[900]! : Colors.white)).withOpacity(isDark ? 0.2 : 0.3),
              ],
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}
