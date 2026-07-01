import 'package:flutter/scheduler.dart';

import 'plasma_motion_gyro.dart';
import 'plasma_motion_lfo.dart';
import 'plasma_motion_params.dart';
import 'platform_info.dart';

export 'plasma_motion_params.dart'
    show PlasmaMotionController, PlasmaMotionParams, plasmaMotionFromLfo;

/// Creates gyro motion on mobile, LFO elsewhere.
PlasmaMotionController createPlasmaMotionController({
  required TickerProvider vsync,
}) {
  if (supportsPlasmaMotionSensors) {
    return GyroPlasmaMotionController(vsync: vsync);
  }
  return LfoPlasmaMotionController(vsync: vsync);
}
