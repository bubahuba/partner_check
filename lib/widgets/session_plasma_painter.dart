import 'dart:developer';
import 'dart:ui';

import 'package:flutter/material.dart';

import '../utils/plasma_motion_params.dart';
import '../utils/session_shader_uniforms.dart';

/// Plasma shader painter with live motion parameters and gradient fallback.
class SessionPlasmaPainter extends CustomPainter {
  SessionPlasmaPainter({
    required this.colors,
    required this.readParams,
    this.deviceDensity = 1.0,
  });

  final List<Color> colors;
  final PlasmaMotionParams Function() readParams;
  final double deviceDensity;

  FragmentShader? _shader;
  final DateTime _startTime = DateTime.now();
  bool _loadStarted = false;

  bool get isShaderLoaded => _shader != null;

  Future<void> ensureShaderLoaded() async {
    if (_shader != null || _loadStarted) return;
    _loadStarted = true;
    try {
      final program = await FragmentProgram.fromAsset(
        'shaders/plasma_session.frag',
      );
      _shader = program.fragmentShader();
    } catch (e) {
      log('Failed to load plasma shader: $e');
      _shader = null;
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;

    final params = readParams();
    if (_shader == null) {
      _paintFallback(canvas, size, params);
      return;
    }

    final shader = _shader!;
    var floatIndex = 0;
    shader.setFloat(floatIndex++, size.width * deviceDensity);
    shader.setFloat(floatIndex++, size.height * deviceDensity);
    shader.setFloat(
      floatIndex++,
      DateTime.now().difference(_startTime).inMilliseconds / 1000.0,
    );
    shader.setFloat(floatIndex++, params.speed);
    shader.setFloat(floatIndex++, params.intensity);
    shader.setFloat(floatIndex++, params.center.dx);
    shader.setFloat(floatIndex++, params.center.dy);

    writeSessionShaderColors(shader, floatIndex, colors);

    final paint = Paint()
      ..shader = shader
      ..filterQuality = FilterQuality.high;
    canvas.drawRect(Offset.zero & size, paint);
  }

  void _paintFallback(Canvas canvas, Size size, PlasmaMotionParams params) {
    final palette = _fallbackPalette();
    final paint = Paint()
      ..shader = RadialGradient(
        center: Alignment(
          params.center.dx * 2 - 1,
          params.center.dy * 2 - 1,
        ),
        colors: palette,
        stops: const [0.0, 0.33, 0.66, 1.0],
      ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, paint);
  }

  List<Color> _fallbackPalette() {
    if (colors.length >= 4) {
      return [colors[0], colors[1], colors[2], colors[3]];
    }
    if (colors.length >= 2) {
      return [colors[0], colors[1], colors[0], colors[1]];
    }
    const fallback = Color(0xFF808080);
    return [fallback, fallback, fallback, fallback];
  }

  @override
  bool shouldRepaint(covariant SessionPlasmaPainter oldDelegate) => true;

  void disposeShader() {
    _shader?.dispose();
    _shader = null;
    _loadStarted = false;
  }
}
