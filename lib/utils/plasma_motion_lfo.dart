import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import 'plasma_motion_params.dart';

/// Schedules repaints on the next frame — safe during ticker callbacks.
class PlasmaMotionRepaintScheduler {
  PlasmaMotionRepaintScheduler(this.onRepaint);

  final VoidCallback onRepaint;
  bool _scheduled = false;
  bool _disposed = false;

  void dispose() {
    _disposed = true;
  }

  void schedule() {
    if (_disposed || _scheduled) return;
    _scheduled = true;
    SchedulerBinding.instance.scheduleFrameCallback((_) {
      _scheduled = false;
      if (_disposed) return;
      onRepaint();
    });
  }
}

/// Smooth LFO plasma parameter animation for web and desktop.
class LfoPlasmaMotionController implements PlasmaMotionController {
  LfoPlasmaMotionController({required TickerProvider vsync})
      : listenable = ValueNotifier<int>(0) {
    _scheduler = PlasmaMotionRepaintScheduler(_notify);
    _ticker = vsync.createTicker(_onTick);
  }

  @override
  final ValueNotifier<int> listenable;

  late final PlasmaMotionRepaintScheduler _scheduler;
  late final Ticker _ticker;
  bool _disposed = false;
  bool _touchActive = false;
  Offset _touchCenter = const Offset(0.5, 0.5);
  PlasmaMotionParams _params = PlasmaMotionParams.defaults;

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
    _touchCenter = Offset(
      normalized.dx.clamp(0.05, 0.95),
      normalized.dy.clamp(0.05, 0.95),
    );
    _params = PlasmaMotionParams(
      center: _touchCenter,
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
    if (_disposed || _ticker.isActive) return;
    _ticker.start();
  }

  void _onTick(Duration elapsed) {
    if (_disposed) return;
    final lfo = plasmaMotionFromLfo(elapsed.inMicroseconds / 1e6);
    final anchor = _touchCenter;
    final center = _touchActive
        ? anchor
        : Offset(
            (anchor.dx + (lfo.center.dx - 0.5) * 0.35).clamp(0.05, 0.95),
            (anchor.dy + (lfo.center.dy - 0.5) * 0.35).clamp(0.05, 0.95),
          );
    _params = PlasmaMotionParams(
      center: center,
      speed: lfo.speed,
      intensity: lfo.intensity,
    );
    _scheduler.schedule();
  }

  @override
  void dispose() {
    if (_disposed) return;
    _disposed = true;
    _scheduler.dispose();
    if (_ticker.isActive) {
      _ticker.stop();
    }
    _ticker.dispose();
    listenable.dispose();
  }
}
