import 'package:flutter/material.dart';

import 'color_utils.dart';

/// Base / inner, overlay / outer, and a blended accent for three-stop gradients.
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
class SelfContactGradient {
  static Color _lerp(Color a, Color b, double t) => Color.lerp(a, b, t)!;

  static (Color, Color, Color) colorsAt(
    double t,
    SelfContactGradientPalette palette,
  ) {
    final inner = palette.inner;
    final outer = palette.outer;
    final accent = palette.accent;

    if (t < 0.33) {
      final localT = t / 0.33;
      return (
        _lerp(inner, outer, localT),
        outer,
        accent,
      );
    }
    if (t < 0.66) {
      final localT = (t - 0.33) / 0.33;
      return (
        outer,
        _lerp(outer, accent, localT),
        accent,
      );
    }
    final localT = (t - 0.66) / 0.34;
    return (
      outer,
      accent,
      _lerp(accent, inner, localT),
    );
  }
}
