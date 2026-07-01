import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../game/tetris_engine.dart';

/// Touch gestures on the playfield: drag horizontal to move, tap to rotate,
/// swipe down to hard-drop. Ignores mouse pointers so desktop/web keyboard
/// and on-screen buttons stay the primary controls there.
class TetrisBoardTouchHandler extends StatefulWidget {
  final Widget child;
  final bool enabled;
  final double boardWidth;
  final VoidCallback onMoveLeft;
  final VoidCallback onMoveRight;
  final VoidCallback onRotate;
  final VoidCallback onHardDrop;
  final VoidCallback? onTouchEnd;

  const TetrisBoardTouchHandler({
    super.key,
    required this.child,
    required this.enabled,
    required this.boardWidth,
    required this.onMoveLeft,
    required this.onMoveRight,
    required this.onRotate,
    required this.onHardDrop,
    this.onTouchEnd,
  });

  @override
  State<TetrisBoardTouchHandler> createState() =>
      _TetrisBoardTouchHandlerState();
}

class _TetrisBoardTouchHandlerState extends State<TetrisBoardTouchHandler> {
  static const double _tapSlop = 18;
  static const double _hardDropMinDy = 48;

  Offset? _pointerDown;
  double _horizontalRemainder = 0;
  bool _hardDropped = false;
  bool _movedBeyondTap = false;
  bool _trackingTouch = false;

  double get _horizontalStepPx => widget.boardWidth / TetrisEngine.hCount / 2;

  void _resetTracking() {
    _pointerDown = null;
    _horizontalRemainder = 0;
    _hardDropped = false;
    _movedBeyondTap = false;
    _trackingTouch = false;
  }

  bool _isTouchPointer(PointerEvent event) {
    return event.kind == PointerDeviceKind.touch ||
        event.kind == PointerDeviceKind.stylus;
  }

  void _applyHorizontalDelta(double delta) {
    _horizontalRemainder += delta;
    final step = _horizontalStepPx;
    while (_horizontalRemainder >= step) {
      widget.onMoveRight();
      _horizontalRemainder -= step;
      _movedBeyondTap = true;
    }
    while (_horizontalRemainder <= -step) {
      widget.onMoveLeft();
      _horizontalRemainder += step;
      _movedBeyondTap = true;
    }
  }

  void _onPointerDown(PointerDownEvent event) {
    if (!widget.enabled || !_isTouchPointer(event)) return;
    _trackingTouch = true;
    _pointerDown = event.position;
    _horizontalRemainder = 0;
    _hardDropped = false;
    _movedBeyondTap = false;
  }

  void _onPointerMove(PointerMoveEvent event) {
    if (!_trackingTouch || _pointerDown == null) return;

    final delta = event.position - _pointerDown!;
    if (!_movedBeyondTap && delta.distance > _tapSlop) {
      _movedBeyondTap = true;
    }

    _applyHorizontalDelta(event.delta.dx);

    if (!_hardDropped &&
        delta.dy >= _hardDropMinDy &&
        delta.dy.abs() > delta.dx.abs()) {
      widget.onHardDrop();
      _hardDropped = true;
    }
  }

  void _onPointerUp(PointerUpEvent event) {
    if (!_trackingTouch) return;

    if (!_hardDropped && !_movedBeyondTap) {
      widget.onRotate();
    }
    widget.onTouchEnd?.call();
    _resetTracking();
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: _onPointerDown,
      onPointerMove: _onPointerMove,
      onPointerUp: _onPointerUp,
      onPointerCancel: (_) => _resetTracking(),
      behavior: HitTestBehavior.translucent,
      child: widget.child,
    );
  }
}
