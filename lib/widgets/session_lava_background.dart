import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../utils/lava_gyro_timeline.dart';
import '../utils/self_contact_gradient.dart';
import 'lava_blob_background.dart';
import 'self_contact_animated_background.dart';

/// Full-screen lava background with touch velocity and gyro playback speed.
class SessionLavaBackground extends StatefulWidget {
  final List<Color> colors;
  final LavaGyroTimelineController? gyroTimeline;
  final Widget? child;

  const SessionLavaBackground({
    super.key,
    required this.colors,
    this.gyroTimeline,
    this.child,
  });

  @override
  State<SessionLavaBackground> createState() => _SessionLavaBackgroundState();
}

class _SessionLavaBackgroundState extends State<SessionLavaBackground>
    with SingleTickerProviderStateMixin {
  static const List<Color> _defaultColors = [
    SelfContactGradientPalette.defaultInner,
    SelfContactGradientPalette.defaultOuter,
    SelfContactGradientPalette.defaultAccent,
    SelfContactGradientPalette.defaultInner,
  ];

  static const double _basePlayback = 0.6;
  static const double _offsetFollow = 0.11;
  static const double _dragOffsetFollow = 0.55;
  static const double _speedReference = 380;
  static const double _maxTouchBoost = 3.2;
  static const double _touchHoldBoost = 0.35;

  late Ticker _ticker;
  late final ValueNotifier<double> _playback;
  late final LavaFlowInput _flowInput;
  Duration _lastTick = Duration.zero;

  Offset _lastPointer = Offset.zero;
  Duration _lastPointerTime = Duration.zero;
  bool _touchActive = false;
  Offset _targetVelocity = Offset.zero;
  Offset _velocity = Offset.zero;

  List<Color> get _palette =>
      widget.colors.length >= 4 ? widget.colors : _defaultColors;

  @override
  void initState() {
    super.initState();
    _playback = ValueNotifier(_basePlayback);
    _flowInput = LavaFlowInput();
    _ticker = createTicker(_onTick)..start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    _playback.dispose();
    super.dispose();
  }

  double _touchPlaybackBoost(Offset velocity) {
    return (velocity.distance / _speedReference).clamp(0.0, _maxTouchBoost);
  }

  void _onTick(Duration elapsed) {
    if (_lastTick == Duration.zero) {
      _lastTick = elapsed;
      return;
    }
    final dt = (elapsed - _lastTick).inMicroseconds / 1e6;
    _lastTick = elapsed;
    if (dt <= 0) return;

    widget.gyroTimeline?.advance(dt);

    if (!_touchActive) {
      _targetVelocity = Offset.zero;
    } else if ((elapsed - _lastPointerTime).inMilliseconds > 60) {
      final stopDecay = math.exp(-10 * dt);
      _targetVelocity = Offset(
        _targetVelocity.dx * stopDecay,
        _targetVelocity.dy * stopDecay,
      );
    }

    final velocityBlend = _touchActive ? 0.62 : 0.25;
    final blend = 1 - math.pow(1 - velocityBlend, dt * 60);
    _velocity = Offset(
      _velocity.dx + (_targetVelocity.dx - _velocity.dx) * blend,
      _velocity.dy + (_targetVelocity.dy - _velocity.dy) * blend,
    );

    _flowInput.stirVelocity = _velocity;
    _flowInput.dragDelta += _velocity * dt * _offsetFollow;

    final tiltOffset = widget.gyroTimeline?.tiltOffset ?? Offset.zero;
    final tiltScale = _touchActive ? 0.35 : 1.0;
    _flowInput.tiltOffset = Offset(
      tiltOffset.dx * tiltScale,
      tiltOffset.dy * tiltScale,
    );

    final gyroMultiplier = widget.gyroTimeline?.playbackMultiplier ?? 1.0;
    final touchBoost =
        _touchActive ? _touchHoldBoost + _touchPlaybackBoost(_velocity) : 0.0;
    _playback.value = (_basePlayback * gyroMultiplier + touchBoost)
        .clamp(0.06, 10.0);
  }

  void _handlePointerDown(PointerDownEvent event) {
    _touchActive = true;
    _lastPointer = event.localPosition;
    _lastPointerTime = event.timeStamp;
    _targetVelocity = Offset.zero;
  }

  void _handlePointerMove(PointerMoveEvent event) {
    if (!_touchActive) return;

    final dt = (event.timeStamp - _lastPointerTime).inMicroseconds / 1e6;
    if (dt <= 0) return;

    final delta = event.localPosition - _lastPointer;
    _lastPointer = event.localPosition;
    _lastPointerTime = event.timeStamp;
    _targetVelocity = delta / dt;
    _flowInput.dragDelta += delta * _dragOffsetFollow;
  }

  void _handlePointerEnd() {
    _touchActive = false;
    _targetVelocity = Offset.zero;
  }

  @override
  Widget build(BuildContext context) {
    final palette = _palette;

    return Listener(
      behavior: HitTestBehavior.opaque,
      onPointerDown: _handlePointerDown,
      onPointerMove: _handlePointerMove,
      onPointerUp: (_) => _handlePointerEnd(),
      onPointerCancel: (_) => _handlePointerEnd(),
      child: LavaBlobBackground(
        baseColor: bokehBaseFromColors(palette),
        colors: palette,
        playbackListenable: _playback,
        flowInput: _flowInput,
        child: widget.child,
      ),
    );
  }
}
