import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:sensors_plus/sensors_plus.dart';

import 'plasma_motion_lfo.dart';
import 'plasma_motion_params.dart';

/// Tilt-driven center and gyro-driven speed on mobile.
class GyroPlasmaMotionController implements PlasmaMotionController {
  GyroPlasmaMotionController({required TickerProvider vsync})
      : listenable = ValueNotifier<int>(0) {
    _scheduler = PlasmaMotionRepaintScheduler(_notify);
    _ticker = vsync.createTicker(_onTick);
  }

  @override
  final ValueNotifier<int> listenable;

  late final PlasmaMotionRepaintScheduler _scheduler;
  late final Ticker _ticker;
  StreamSubscription<AccelerometerEvent>? _accelSub;
  StreamSubscription<GyroscopeEvent>? _gyroSub;
  bool _disposed = false;

  PlasmaMotionParams _params = PlasmaMotionParams.defaults;
  double _targetCenterX = 0.5;
  double _targetCenterY = 0.5;
  double _centerX = 0.5;
  double _centerY = 0.5;
  bool _touchActive = false;
  double _gyroRate = 0;
  double _speedBoost = 0;
  Duration _lastTick = Duration.zero;

  @override
  PlasmaMotionParams get params => _params;

  void _notify() {
    if (_disposed) return;
    listenable.value++;
  }

  @override
  void setTouchCenter(Offset normalized) {
    if (_disposed) return;
    _touchActive = true;
    _targetCenterX = normalized.dx.clamp(0.05, 0.95);
    _targetCenterY = normalized.dy.clamp(0.05, 0.95);
    _centerX = _targetCenterX;
    _centerY = _targetCenterY;
    _params = PlasmaMotionParams(
      center: Offset(_centerX, _centerY),
      speed: _params.speed,
      intensity: _params.intensity,
    );
    _scheduler.schedule();
  }

  @override
  void clearTouchCenter() {
    if (_disposed) return;
    _touchActive = false;
  }

  @override
  void start() {
    if (_disposed) return;
    _accelSub ??= accelerometerEventStream().listen(_onAccelerometer);
    _gyroSub ??= gyroscopeEventStream().listen(_onGyroscope);
    if (!_ticker.isActive) {
      _lastTick = Duration.zero;
      _ticker.start();
    }
  }

  void _onAccelerometer(AccelerometerEvent event) {
    if (_disposed || _touchActive) return;
    const gravity = 9.81;
    final tiltX = (event.x / gravity).clamp(-1.0, 1.0);
    final tiltY = (event.y / gravity).clamp(-1.0, 1.0);
    _targetCenterX = (0.5 + tiltX * 0.32).clamp(0.12, 0.88);
    _targetCenterY = (0.5 + tiltY * 0.24).clamp(0.12, 0.88);
  }

  void _onGyroscope(GyroscopeEvent event) {
    if (_disposed) return;
    _gyroRate = event.z * 0.7 + (event.x + event.y) * 0.15;
  }

  void _onTick(Duration elapsed) {
    if (_disposed) return;
    if (_lastTick == Duration.zero) {
      _lastTick = elapsed;
      return;
    }
    final dt = (elapsed - _lastTick).inMicroseconds / 1e6;
    _lastTick = elapsed;
    if (dt <= 0) return;

    const smoothing = 0.16;
    final blend = 1 - math.pow(1 - smoothing, dt * 60);
    if (!_touchActive) {
      _centerX += (_targetCenterX - _centerX) * blend;
      _centerY += (_targetCenterY - _centerY) * blend;
    }

    _speedBoost += _gyroRate * dt;
    _speedBoost *= math.exp(-0.8 * dt);
    _speedBoost = _speedBoost.clamp(-0.35, 0.35);
    _gyroRate *= math.exp(-0.8 * dt);

    final tiltAmount =
        ((_centerX - 0.5).abs() + (_centerY - 0.5).abs()).clamp(0.0, 0.5);
    _params = PlasmaMotionParams(
      center: Offset(_centerX, _centerY),
      speed: (0.85 + _speedBoost).clamp(0.45, 1.45),
      intensity: (0.88 + tiltAmount * 0.18).clamp(0.65, 1.0),
    );
    _scheduler.schedule();
  }

  @override
  void dispose() {
    if (_disposed) return;
    _disposed = true;
    _scheduler.dispose();
    _accelSub?.cancel();
    _gyroSub?.cancel();
    _accelSub = null;
    _gyroSub = null;
    if (_ticker.isActive) {
      _ticker.stop();
    }
    _ticker.dispose();
    listenable.dispose();
  }
}
