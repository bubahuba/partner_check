import 'package:flutter/material.dart';

/// Short hold → [onShortHold]. Longer hold → [onLongHold].
/// Movement cancels so horizontal pane scrolling is not mistaken for a hold.
class SelfContactHoldDetector extends StatefulWidget {
  final Widget child;
  final VoidCallback onShortHold;
  final VoidCallback onLongHold;

  static const int shortHoldMs = 500;
  static const int longHoldMs = 950;
  static const double moveCancelSlop = 18;

  const SelfContactHoldDetector({
    super.key,
    required this.child,
    required this.onShortHold,
    required this.onLongHold,
  });

  @override
  State<SelfContactHoldDetector> createState() =>
      _SelfContactHoldDetectorState();
}

class _SelfContactHoldDetectorState extends State<SelfContactHoldDetector> {
  DateTime? _pointerDownTime;
  Offset? _pointerDownPosition;

  void _cancelHold() {
    _pointerDownTime = null;
    _pointerDownPosition = null;
  }

  void _onPointerDown(PointerDownEvent event) {
    _pointerDownTime = DateTime.now();
    _pointerDownPosition = event.position;
  }

  void _onPointerMove(PointerMoveEvent event) {
    if (_pointerDownPosition == null) return;
    if ((event.position - _pointerDownPosition!).distance >
        SelfContactHoldDetector.moveCancelSlop) {
      _cancelHold();
    }
  }

  void _onPointerUp(PointerUpEvent event) {
    final downTime = _pointerDownTime;
    _cancelHold();
    if (downTime == null) return;

    final heldMs = DateTime.now().difference(downTime).inMilliseconds;
    if (heldMs >= SelfContactHoldDetector.longHoldMs) {
      widget.onLongHold();
    } else if (heldMs >= SelfContactHoldDetector.shortHoldMs) {
      widget.onShortHold();
    }
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
