import 'dart:async';

import 'package:flutter/material.dart';

/// [onHoldReady] when held long enough (still pressed). [onHoldComplete] on release after ready.
/// Movement cancels so horizontal pane scrolling is not mistaken for a hold.
class SelfContactHoldDetector extends StatefulWidget {
  final Widget child;
  final VoidCallback onHoldReady;
  final VoidCallback onHoldComplete;
  final VoidCallback? onHoldCancel;

  static const int holdMs = 500;
  static const double moveCancelSlop = 18;

  const SelfContactHoldDetector({
    super.key,
    required this.child,
    required this.onHoldReady,
    required this.onHoldComplete,
    this.onHoldCancel,
  });

  @override
  State<SelfContactHoldDetector> createState() =>
      _SelfContactHoldDetectorState();
}

class _SelfContactHoldDetectorState extends State<SelfContactHoldDetector> {
  Offset? _pointerDownPosition;
  Timer? _holdTimer;
  bool _holdReady = false;

  void _cancelHold({bool notify = true}) {
    _holdTimer?.cancel();
    _holdTimer = null;
    if (notify && _holdReady) {
      widget.onHoldCancel?.call();
    }
    _holdReady = false;
    _pointerDownPosition = null;
  }

  void _onPointerDown(PointerDownEvent event) {
    _cancelHold();
    _pointerDownPosition = event.position;
    _holdTimer = Timer(
      const Duration(milliseconds: SelfContactHoldDetector.holdMs),
      () {
        if (_pointerDownPosition == null) return;
        _holdReady = true;
        widget.onHoldReady();
      },
    );
  }

  void _onPointerMove(PointerMoveEvent event) {
    if (_pointerDownPosition == null) return;
    if ((event.position - _pointerDownPosition!).distance >
        SelfContactHoldDetector.moveCancelSlop) {
      _cancelHold();
    }
  }

  void _onPointerUp(PointerUpEvent event) {
    _holdTimer?.cancel();
    _holdTimer = null;
    final wasReady = _holdReady;
    _holdReady = false;
    _pointerDownPosition = null;
    if (wasReady) {
      widget.onHoldComplete();
    }
  }

  @override
  void dispose() {
    _holdTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: _onPointerDown,
      onPointerMove: _onPointerMove,
      onPointerUp: _onPointerUp,
      onPointerCancel: (_) => _cancelHold(),
      behavior: HitTestBehavior.translucent,
      child: widget.child,
    );
  }
}
