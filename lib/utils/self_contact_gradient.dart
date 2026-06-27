import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'color_utils.dart';

/// Contact-card colors for gradients: [inner] is the main base fill,
/// [outer] is the bottom overlay strip (reversed hex), [accent] blends both.
class SelfContactGradientPalette {
  final Color inner;
  final Color outer;
  final Color accent;

  const SelfContactGradientPalette({
    required this.inner,
    required this.outer,
    required this.accent,
  });

  static const Color defaultInner = Color(0xFF6366F1);
  static const Color defaultOuter = Color(0xFFEC4899);
  static const Color defaultAccent = Color(0xFF3B82F6);

  static const SelfContactGradientPalette defaults = SelfContactGradientPalette(
    inner: defaultInner,
    outer: defaultOuter,
    accent: defaultAccent,
  );

  factory SelfContactGradientPalette.fromColorValue(int colorValue) {
    final inner = ColorUtils.colorFromValue(colorValue);
    final outer = ColorUtils.overlayColorFromValue(colorValue);
    final accent = Color.lerp(inner, outer, 0.5) ?? defaultAccent;
    return SelfContactGradientPalette(
      inner: inner,
      outer: outer,
      accent: accent,
    );
  }
}

/// Animated three-color gradient stops derived from a [SelfContactGradientPalette].
///
/// Uses cosine waves so t=0 and t=1 match for seamless looping.
/// [base] (main fill) leads the gradient; [strip] (overlay / reversed hex) blends mid-cycle.
class SelfContactGradient {
  static Color _lerp(Color a, Color b, double t) => Color.lerp(a, b, t)!;

  /// Smooth 0→1→0 loop; equal at t=0 and t=1 with continuous derivative.
  static double _wave(double t, double phase) {
    return (1 - math.cos(2 * math.pi * (t + phase))) / 2;
  }

  static (Color, Color, Color) colorsAt(
    double t,
    SelfContactGradientPalette palette,
  ) {
    final base = palette.inner;
    final strip = palette.outer;
    final accent = palette.accent;

    final wave1 = _wave(t, 0);
    final wave2 = _wave(t, 1 / 3);
    final wave3 = _wave(t, 2 / 3);

    return (
      _lerp(base, accent, wave1),
      _lerp(base, strip, wave2 * 0.55),
      _lerp(accent, base, wave3),
    );
  }
}
