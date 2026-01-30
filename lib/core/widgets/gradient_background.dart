import 'package:flutter/material.dart';
import '../theming/app_colors.dart';

/// Reusable gradient background widget for consistent styling across screens
class GradientBackground extends StatelessWidget {
  final Widget child;
  final Gradient? gradient;
  final List<Color>? colors;

  const GradientBackground({
    Key? key,
    required this.child,
    this.gradient,
    this.colors,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient:
            gradient ??
            LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors:
                  colors ??
                  [
                    AppColors.backgroundGradient.colors[0],
                    AppColors.backgroundGradient.colors[1],
                  ],
            ),
      ),
      child: child,
    );
  }
}

/// Glassmorphism container widget for modern UI effects
class GlassmorphicContainer extends StatelessWidget {
  final Widget child;
  final double blur;
  final double opacity;
  final BorderRadius? borderRadius;
  final Border? border;

  const GlassmorphicContainer({
    Key? key,
    required this.child,
    this.blur = 10,
    this.opacity = 0.1,
    this.borderRadius,
    this.border,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(opacity),
        borderRadius: borderRadius ?? BorderRadius.circular(16),
        border:
            border ??
            Border.all(color: Colors.white.withOpacity(0.2), width: 1.5),
      ),
      child: child,
    );
  }
}
