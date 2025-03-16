import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Animation constants for consistent animations throughout the app
class AnimationConstants {
  // Duration constants
  static const Duration ultraFast = Duration(milliseconds: 200);
  static const Duration fast = Duration(milliseconds: 400);
  static const Duration medium = Duration(milliseconds: 600);
  static const Duration slow = Duration(milliseconds: 800);
  static const Duration ultraSlow = Duration(milliseconds: 1200);

  // Fade animation
  static Effect fadeIn = FadeEffect(duration: medium, curve: Curves.easeInOut);

  // Scale animation
  static Effect scaleIn = ScaleEffect(
    duration: medium,
    curve: Curves.easeOutBack,
    begin: const Offset(0.8, 0.8),
    end: const Offset(1.0, 1.0),
  );

  // Slide animation
  static Effect slideIn(Offset begin) => SlideEffect(
    duration: medium,
    curve: Curves.easeOutCubic,
    begin: begin,
    end: const Offset(0.0, 0.0),
  );

  // Common entrance animations
  static List<Effect> fadeInUp = [fadeIn, slideIn(const Offset(0.0, 0.2))];

  static List<Effect> fadeInDown = [fadeIn, slideIn(const Offset(0.0, -0.2))];

  static List<Effect> fadeInLeft = [fadeIn, slideIn(const Offset(-0.2, 0.0))];

  static List<Effect> fadeInRight = [fadeIn, slideIn(const Offset(0.2, 0.0))];

  static List<Effect> popIn = [fadeIn, scaleIn];

  // Staggered animation helpers
  static List<Effect> staggeredFadeIn(
    int index, {
    double staggerFactor = 0.1,
  }) => [
    FadeEffect(
      duration: medium,
      delay: Duration(milliseconds: (index * staggerFactor * 1000).toInt()),
      curve: Curves.easeInOut,
    ),
  ];

  static List<Effect> staggeredFadeInUp(
    int index, {
    double staggerFactor = 0.1,
  }) => [
    FadeEffect(
      duration: medium,
      delay: Duration(milliseconds: (index * staggerFactor * 1000).toInt()),
      curve: Curves.easeInOut,
    ),
    SlideEffect(
      duration: medium,
      delay: Duration(milliseconds: (index * staggerFactor * 1000).toInt()),
      curve: Curves.easeOutCubic,
      begin: const Offset(0.0, 0.2),
      end: const Offset(0.0, 0.0),
    ),
  ];

  static List<Effect> shimmerEffect = [
    ShimmerEffect(
      duration: const Duration(seconds: 2),
      color: Colors.white.withOpacity(0.3),
      delay: const Duration(milliseconds: 200),
    ),
  ];

  // Button press animation
  static List<Effect> buttonTapEffects = [
    ScaleEffect(
      begin: const Offset(1.0, 1.0),
      end: const Offset(0.95, 0.95),
      duration: const Duration(milliseconds: 100),
    ),
  ];

  // Loop animation
  static List<Effect> pulseAnimation = [
    ScaleEffect(
      begin: const Offset(1.0, 1.0),
      end: const Offset(1.05, 1.05),
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeInOut,
    ),
  ];
}
