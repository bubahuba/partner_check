import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../utils/plasma_motion.dart';
import 'session_plasma_painter.dart';
import 'session_shader_touch_surface.dart';

/// Full-screen plasma background driven by session colors and motion input.
class SessionPlasmaBackground extends StatefulWidget {
  final List<Color> colors;
  final Size size;
  final double deviceDensity;
  final PlasmaMotionController motionController;

  const SessionPlasmaBackground({
    super.key,
    required this.colors,
    required this.size,
    required this.deviceDensity,
    required this.motionController,
  });

  @override
  State<SessionPlasmaBackground> createState() =>
      _SessionPlasmaBackgroundState();
}

class _SessionPlasmaBackgroundState extends State<SessionPlasmaBackground>
    with SingleTickerProviderStateMixin {
  late Ticker _ticker;
  Object? _painterRef;

  SessionPlasmaPainter get _activePainter {
    if (_painterRef is SessionPlasmaPainter) {
      return _painterRef as SessionPlasmaPainter;
    }
    _createPainter();
    return _painterRef as SessionPlasmaPainter;
  }

  @override
  void initState() {
    super.initState();
    _ticker = createTicker((_) => _markDirty())..start();
    _createPainter();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadShader());
  }

  @override
  void reassemble() {
    super.reassemble();
    _createPainter();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadShader());
  }

  @override
  void didUpdateWidget(covariant SessionPlasmaBackground oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.colors != oldWidget.colors ||
        widget.deviceDensity != oldWidget.deviceDensity ||
        widget.motionController != oldWidget.motionController) {
      _createPainter();
      _loadShader();
    }
  }

  void _createPainter() {
    if (_painterRef is SessionPlasmaPainter) {
      (_painterRef as SessionPlasmaPainter).disposeShader();
    }
    _painterRef = SessionPlasmaPainter(
      colors: widget.colors,
      readParams: () => widget.motionController.params,
      deviceDensity: widget.deviceDensity,
    );
  }

  Future<void> _loadShader() async {
    if (!mounted) return;
    await _activePainter.ensureShaderLoaded();
    if (mounted) setState(() {});
  }

  void _markDirty() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _ticker.dispose();
    if (_painterRef is SessionPlasmaPainter) {
      (_painterRef as SessionPlasmaPainter).disposeShader();
    }
    _painterRef = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final painter = _activePainter;

    return ListenableBuilder(
      listenable: widget.motionController.listenable,
      builder: (context, _) {
        return SessionShaderTouchSurface(
          size: widget.size,
          motionController: widget.motionController,
          child: CustomPaint(painter: painter),
        );
      },
    );
  }
}
