import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Normalized plasma shader parameters (touch center, speed, intensity).
class PlasmaMotionParams {
  const PlasmaMotionParams({
    required this.center,
    required this.speed,
    required this.intensity,
  });

  final Offset center;
  final double speed;
  final double intensity;

  static const PlasmaMotionParams defaults = PlasmaMotionParams(
    center: Offset(0.5, 0.5),
    speed: 0.85,
    intensity: 0.9,
  );
}

/// Computes LFO-driven plasma parameters at [elapsedSeconds].
PlasmaMotionParams plasmaMotionFromLfo(
  double elapsedSeconds, {
  double centerPeriodSeconds = 16.0,
  double speedPeriodSeconds = 14.0,
  double intensityPeriodSeconds = 18.0,
}) {
  final centerX =
      0.5 + 0.2 * math.sin(2 * math.pi * elapsedSeconds / centerPeriodSeconds);
  final centerY = 0.5 +
      0.15 *
          math.sin(2 * math.pi * elapsedSeconds / (centerPeriodSeconds * 1.25) +
              math.pi / 3);
  final speed =
      0.85 + 0.28 * math.sin(2 * math.pi * elapsedSeconds / speedPeriodSeconds);
  final intensity = 0.88 +
      0.1 *
          math.sin(2 * math.pi * elapsedSeconds / intensityPeriodSeconds +
              math.pi / 4);

  return PlasmaMotionParams(
    center: Offset(centerX.clamp(0.12, 0.88), centerY.clamp(0.12, 0.88)),
    speed: speed.clamp(0.45, 1.45),
    intensity: intensity.clamp(0.65, 1.0),
  );
}

abstract class PlasmaMotionController {
  PlasmaMotionParams get params;
  Listenable get listenable;
  void start();
  void setTouchCenter(Offset normalized);
  void clearTouchCenter();
  void dispose();
}
