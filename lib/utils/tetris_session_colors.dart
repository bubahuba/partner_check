import 'dart:math';

import 'package:flutter/material.dart';

import '../models.dart';
import 'color_utils.dart';

/// The four piece colors for a Tetris session (base + overlay per contact).
List<Color> tetrisPieceColorsFromSession(TetrisSession session) {
  return [
    ColorUtils.colorFromValue(session.contact1Color),
    ColorUtils.overlayColorFromValue(session.contact1Color),
    ColorUtils.colorFromValue(session.contact2Color),
    ColorUtils.overlayColorFromValue(session.contact2Color),
  ];
}

/// Base contact colors only — for UI that needs raw hex without reversed overlay.
(Color, Color) sessionBaseColorsFromSession(TetrisSession session) {
  return (
    ColorUtils.colorFromValue(session.contact1Color),
    ColorUtils.colorFromValue(session.contact2Color),
  );
}

/// Picks two distinct random colors from [pool] for the animated background.
(Color, Color) pickRandomTetrisBackgroundPair(
  List<Color> pool, {
  Random? random,
}) {
  final shuffled = List<Color>.from(pool)..shuffle(random ?? Random());
  return (shuffled[0], shuffled[1]);
}
