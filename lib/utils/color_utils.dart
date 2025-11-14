import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Utility class for color operations and matching
class ColorUtils {
  /// Convert color value to Color object
  static Color colorFromValue(int colorValue) {
    return Color(0xFF000000 | colorValue);
  }

  /// Reverse hex digits: 123456 -> 654321
  static Color overlayColorFromValue(int colorValue) {
    // Convert to 6-digit hex string, reverse it, then convert back
    final hexString = colorValue.toRadixString(16).padLeft(6, '0');
    final reversedHexString = hexString.split('').reversed.join('');
    final reversed = int.parse(reversedHexString, radix: 16);
    return Color(0xFF000000 | reversed);
  }

  /// Convert RGB to HSV to get hue
  static List<double> rgbToHsv(int r, int g, int b) {
    r = r.clamp(0, 255);
    g = g.clamp(0, 255);
    b = b.clamp(0, 255);

    final rNorm = r / 255.0;
    final gNorm = g / 255.0;
    final bNorm = b / 255.0;

    final max = math.max(math.max(rNorm, gNorm), bNorm);
    final min = math.min(math.min(rNorm, gNorm), bNorm);
    final delta = max - min;

    double h = 0;
    if (delta != 0) {
      if (max == rNorm) {
        h = ((gNorm - bNorm) / delta) % 6;
      } else if (max == gNorm) {
        h = (bNorm - rNorm) / delta + 2;
      } else {
        h = (rNorm - gNorm) / delta + 4;
      }
    }
    h = (h * 60) % 360;
    if (h < 0) h += 360;

    final s = max == 0 ? 0.0 : delta / max;
    final v = max;

    return [h, s, v];
  }

  /// Get hue from color
  static double getHue(Color color) {
    final r = color.red;
    final g = color.green;
    final b = color.blue;
    final hsv = rgbToHsv(r, g, b);
    return hsv[0];
  }

  /// Check if two hues are similar (within threshold) or complementary
  static bool areColorsMatching(Color color1, Color color2) {
    final hue1 = getHue(color1);
    final hue2 = getHue(color2);

    // Similar hue (within 30 degrees)
    final hueDiff = (hue1 - hue2).abs();
    final minDiff = math.min(hueDiff, 360 - hueDiff);
    if (minDiff <= 30) {
      return true;
    }
/*
    // Complementary hue (opposite on color wheel, within 30 degrees)
    final complementaryHue1 = (hue1 + 180) % 360;
    final complementaryDiff = (complementaryHue1 - hue2).abs();
    final minComplementaryDiff =
        math.min(complementaryDiff, 360 - complementaryDiff);
    if (minComplementaryDiff <= 30) {
      return true;
    }
*/
    return false;
  }
}

