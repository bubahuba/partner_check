import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

/// Mutable touch/tilt input consumed each frame by [LavaBlobBackground].
class LavaFlowInput {
  Offset dragDelta = Offset.zero;
  Offset stirVelocity = Offset.zero;
  Offset tiltOffset = Offset.zero;
}

/// Bokeh lava background with signed playback so animation can run faster or slower.
///
/// Pass [playbackListenable] to update speed without rebuilding this widget.
/// Pass [flowInput] to stir blob motion from touch and tilt.
/// Blob motion adapted from bokeh_lava_gradient (MIT).
class LavaBlobBackground extends StatefulWidget {
  final Color baseColor;
  final List<Color> colors;
  final ValueListenable<double>? playbackListenable;
  final LavaFlowInput? flowInput;
  final double playbackRate;
  final Widget? child;

  const LavaBlobBackground({
    super.key,
    required this.baseColor,
    required this.colors,
    this.playbackListenable,
    this.flowInput,
    this.playbackRate = 0.6,
    this.child,
  });

  @override
  State<LavaBlobBackground> createState() => _LavaBlobBackgroundState();
}

class _LavaBlobBackgroundState extends State<LavaBlobBackground>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  static const int _blobCount = 12;
  static const double _blobSpeed = 1.0;
  static const double _blurStrength = 0.05;
  static const double _blobOpacity = 0.85;
  static const double _minBlobRadius = 0.30;
  static const double _maxBlobRadius = 1.0;
  static const double _lowResFactor = 0.45;
  static const int _targetFps = 30;
  static const double _maxStepSeconds = 0.2;

  late final Ticker _ticker;
  late _LavaBlobField _field;
  final ValueNotifier<int> _repaint = ValueNotifier<int>(0);
  Duration _last = Duration.zero;

  double get _playback {
    return widget.playbackListenable?.value ?? widget.playbackRate;
  }

  @override
  void initState() {
    super.initState();
    _field = _LavaBlobField(
      _blobCount,
      _blobSpeed,
      _minBlobRadius,
      _maxBlobRadius,
    );
    WidgetsBinding.instance.addObserver(this);
    _ticker = createTicker(_onTick)..start();
  }

  void _onTick(Duration elapsed) {
    final intervalUs = 1000000 / _targetFps;
    final dtUs = (elapsed - _last).inMicroseconds;
    if (_last != Duration.zero && dtUs < intervalUs) return;
    final dt = _last == Duration.zero ? 1 / _targetFps : dtUs / 1000000.0;
    _last = elapsed;

    final playbackAbs = _playback.abs();
    final maxStep = min(0.42, _maxStepSeconds + playbackAbs * 0.045);
    final scaledDt = (dt * _playback).clamp(-maxStep, maxStep);
    if (scaledDt != 0) {
      _field.tick(scaledDt);
    }
    _applyFlowInput(dt);
    _repaint.value++;
  }

  void _applyFlowInput(double dt) {
    final input = widget.flowInput;
    if (input == null) return;

    if (input.dragDelta != Offset.zero) {
      _field.applyDelta(input.dragDelta);
      input.dragDelta = Offset.zero;
    }

    _field.applyStir(input.stirVelocity, dt);

    if (input.tiltOffset != Offset.zero) {
      _field.applyDelta(input.tiltOffset * dt * 0.12);
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final active = state == AppLifecycleState.resumed;
    if (active && !_ticker.isActive) {
      _last = Duration.zero;
      _ticker.start();
    } else if (!active && _ticker.isActive) {
      _ticker.stop();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _ticker.dispose();
    _repaint.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth.isFinite ? constraints.maxWidth : 0.0;
        final h = constraints.maxHeight.isFinite ? constraints.maxHeight : 0.0;
        final f = _lowResFactor.clamp(0.1, 1.0);
        final lowW = max(1.0, w * f);
        final lowH = max(1.0, h * f);
        final sigma = max(0.1, min(lowW, lowH) * _blurStrength);

        final paintColors = <Color>[
          for (final c in widget.colors) c.withValues(alpha: _blobOpacity),
        ];

        return Stack(
          fit: StackFit.expand,
          children: [
            ColoredBox(color: widget.baseColor),
            ClipRect(
              child: Align(
                alignment: Alignment.topLeft,
                child: Transform.scale(
                  scale: 1 / f,
                  alignment: Alignment.topLeft,
                  filterQuality: FilterQuality.low,
                  child: SizedBox(
                    width: lowW,
                    height: lowH,
                    child: RepaintBoundary(
                      child: ImageFiltered(
                        imageFilter: ui.ImageFilter.blur(
                          sigmaX: sigma,
                          sigmaY: sigma,
                          tileMode: TileMode.decal,
                        ),
                        child: CustomPaint(
                          painter:
                              _LavaBlobPainter(_field, paintColors, _repaint),
                          child: const SizedBox.expand(),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            if (widget.child != null) widget.child!,
          ],
        );
      },
    );
  }
}

class _LavaBlobPainter extends CustomPainter {
  final _LavaBlobField field;
  final List<Color> colors;

  _LavaBlobPainter(this.field, this.colors, Listenable repaint)
      : super(repaint: repaint);

  @override
  void paint(Canvas canvas, Size size) {
    field.ensureSize(size);

    for (var i = 0; i < field.blobs.length; i++) {
      final b = field.blobs[i];
      final c = colors[i % colors.length];
      final center = Offset(b.x, b.y);
      final shader = RadialGradient(
        colors: <Color>[c, c, c.withValues(alpha: 0)],
        stops: const <double>[0.0, 0.45, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: b.r));
      canvas.drawCircle(center, b.r, Paint()..shader = shader);
    }
  }

  @override
  bool shouldRepaint(_LavaBlobPainter oldDelegate) =>
      !identical(oldDelegate.field, field) ||
      !identical(oldDelegate.colors, colors);
}

class _LavaBlob {
  double x, y;
  double vx, vy;
  double r;

  _LavaBlob(this.x, this.y, this.vx, this.vy, this.r);
}

class _LavaBlobField {
  final int count;
  final double speed;
  final double minR;
  final double maxR;

  Size size = Size.zero;
  final List<_LavaBlob> blobs = [];
  final Random _rand = Random();

  _LavaBlobField(this.count, this.speed, this.minR, this.maxR);

  void ensureSize(Size newSize) {
    if (newSize == size && blobs.isNotEmpty) return;
    size = newSize;
    final shortest = size.shortestSide;
    blobs.clear();
    for (var i = 0; i < count; i++) {
      final r = shortest * (minR + (maxR - minR) * _rand.nextDouble());
      double v() =>
          (_rand.nextBool() ? 1 : -1) *
          (0.3 + 0.9 * _rand.nextDouble()) *
          speed *
          shortest *
          0.06;
      blobs.add(_LavaBlob(
        _rand.nextDouble() * size.width,
        _rand.nextDouble() * size.height,
        v(),
        v(),
        r,
      ));
    }
  }

  void tick(double dt) {
    if (blobs.isEmpty) return;
    final bounds = size;
    for (final b in blobs) {
      b.x += b.vx * dt;
      b.y += b.vy * dt;
      final mx = b.r * 0.4;
      if (b.x < -mx) {
        b.x = -mx;
        b.vx = -b.vx;
      } else if (b.x > bounds.width + mx) {
        b.x = bounds.width + mx;
        b.vx = -b.vx;
      }
      if (b.y < -mx) {
        b.y = -mx;
        b.vy = -b.vy;
      } else if (b.y > bounds.height + mx) {
        b.y = bounds.height + mx;
        b.vy = -b.vy;
      }
    }
  }

  void applyDelta(Offset delta) {
    if (blobs.isEmpty || delta == Offset.zero) return;
    for (final b in blobs) {
      b.x += delta.dx;
      b.y += delta.dy;
    }
    _wrapPositions();
  }

  void applyStir(Offset velocity, double dt) {
    if (blobs.isEmpty || velocity == Offset.zero || dt <= 0) return;
    final scale = size.shortestSide * 0.00012;
    for (final b in blobs) {
      b.vx += velocity.dx * scale;
      b.vy += velocity.dy * scale;
      final maxSpeed = size.shortestSide * 0.35;
      b.vx = b.vx.clamp(-maxSpeed, maxSpeed);
      b.vy = b.vy.clamp(-maxSpeed, maxSpeed);
    }
  }

  void _wrapPositions() {
    if (blobs.isEmpty) return;
    for (final b in blobs) {
      final margin = b.r * 1.2;
      final spanX = size.width + margin * 2;
      final spanY = size.height + margin * 2;
      while (b.x < -margin) {
        b.x += spanX;
      }
      while (b.x > size.width + margin) {
        b.x -= spanX;
      }
      while (b.y < -margin) {
        b.y += spanY;
      }
      while (b.y > size.height + margin) {
        b.y -= spanY;
      }
    }
  }
}
