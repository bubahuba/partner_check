import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' show Offset;

import 'package:sensors_plus/sensors_plus.dart';

import 'platform_info.dart';

/// Tilt- and twist-driven playback speed for the lava screen.
///
/// Calibrates a neutral hold pose on start so speed reacts to *changes* in tilt,
/// not the phone's absolute orientation in space.
class LavaGyroTimelineController {
  StreamSubscription<GyroscopeEvent>? _gyroSub;
  StreamSubscription<AccelerometerEvent>? _accelSub;
  bool _active = false;
  bool _calibrated = false;

  double _neutralX = 0;
  double _neutralY = 0;
  int _calibrationSamples = 0;
  double _calibrationSumX = 0;
  double _calibrationSumY = 0;

  double _targetTiltX = 0;
  double _targetTiltY = 0;
  double _tiltX = 0;
  double _tiltY = 0;
  double _gyroSample = 0;
  double _smoothedGyro = 0;
  double _playbackMultiplier = 1;
  double _tiltOffsetX = 0;
  double _tiltOffsetY = 0;

  static const int _calibrationTargetSamples = 10;
  static const double _tiltSpeedGain = 9.0;
  static const double _twistSpeedGain = 3.5;
  static const double _minMultiplier = 0.08;
  static const double _maxMultiplier = 10.0;
  static const double _maxTiltOffset = 52;

  bool get isActive => _active;

  /// 1.0 = default speed; above 1 faster, below 1 slower.
  double get playbackMultiplier => _playbackMultiplier;

  /// Parallax from device tilt relative to the calibrated neutral pose.
  Offset get tiltOffset => Offset(_tiltOffsetX, _tiltOffsetY);

  void start() {
    if (!supportsPlasmaMotionSensors || _accelSub != null) return;
    _resetState();
    _active = true;
    _accelSub = accelerometerEventStream().listen(_onAccelerometer);
    _gyroSub = gyroscopeEventStream().listen(_onGyroscope);
  }

  /// Re-subscribe after hot reload; stream closures cannot patch renamed fields.
  void restart() {
    if (!supportsPlasmaMotionSensors) return;
    _accelSub?.cancel();
    _gyroSub?.cancel();
    _accelSub = null;
    _gyroSub = null;
    _active = false;
    start();
  }

  void _resetState() {
    _calibrated = false;
    _calibrationSamples = 0;
    _calibrationSumX = 0;
    _calibrationSumY = 0;
    _neutralX = 0;
    _neutralY = 0;
    _targetTiltX = 0;
    _targetTiltY = 0;
    _tiltX = 0;
    _tiltY = 0;
    _gyroSample = 0;
    _smoothedGyro = 0;
    _playbackMultiplier = 1;
    _tiltOffsetX = 0;
    _tiltOffsetY = 0;
  }

  void _onGyroscope(GyroscopeEvent event) {
    _gyroSample = event.z + (event.x + event.y) * 0.12;
  }

  void _onAccelerometer(AccelerometerEvent event) {
    const gravity = 9.81;
    final normX = event.x / gravity;
    final normY = event.y / gravity;

    if (!_calibrated) {
      _calibrationSumX += normX;
      _calibrationSumY += normY;
      _calibrationSamples++;
      if (_calibrationSamples >= _calibrationTargetSamples) {
        _neutralX = _calibrationSumX / _calibrationSamples;
        _neutralY = _calibrationSumY / _calibrationSamples;
        _calibrated = true;
      }
      return;
    }

    _targetTiltX = (normX - _neutralX).clamp(-1.0, 1.0);
    _targetTiltY = (normY - _neutralY).clamp(-1.0, 1.0);
  }

  void advance(double dt) {
    if (!_active || dt <= 0) return;

    final blend = 1 - math.pow(1 - 0.32, dt * 60);
    _tiltX += (_targetTiltX - _tiltX) * blend;
    _tiltY += (_targetTiltY - _tiltY) * blend;
    _smoothedGyro += (_gyroSample - _smoothedGyro) * blend;

    final tiltAmount =
        math.sqrt(_tiltX * _tiltX + _tiltY * _tiltY).clamp(0.0, 1.0);
    final tiltDrive = (_tiltX * 0.72 + _tiltY * 0.48).clamp(-1.0, 1.0);
    final speedFromTilt = 1 + tiltAmount * _tiltSpeedGain + tiltDrive * 2.2;
    final speedFromTwist = _smoothedGyro.abs() * _twistSpeedGain;
    final targetMultiplier =
        (speedFromTilt + speedFromTwist).clamp(_minMultiplier, _maxMultiplier);

    final multBlend = 1 - math.pow(1 - 0.42, dt * 60);
    _playbackMultiplier +=
        (targetMultiplier - _playbackMultiplier) * multBlend;

    final targetOffsetX = _tiltX * _maxTiltOffset;
    final targetOffsetY = _tiltY * _maxTiltOffset * 0.82;
    _tiltOffsetX += (targetOffsetX - _tiltOffsetX) * blend;
    _tiltOffsetY += (targetOffsetY - _tiltOffsetY) * blend;

    if (_calibrated &&
        tiltAmount < 0.05 &&
        _gyroSample.abs() < 0.02) {
      _gyroSample *= math.exp(-2 * dt);
      _playbackMultiplier += (1 - _playbackMultiplier) * multBlend * 0.4;
    }
  }

  void dispose() {
    _accelSub?.cancel();
    _gyroSub?.cancel();
    _accelSub = null;
    _gyroSub = null;
    _active = false;
  }
}
