import 'package:flutter/material.dart';

import '../utils/plasma_motion.dart';

/// Routes pointer events to [motionController] as normalized touch center.
class SessionShaderTouchSurface extends StatelessWidget {
  final Size size;
  final PlasmaMotionController motionController;
  final Widget child;

  const SessionShaderTouchSurface({
    super.key,
    required this.size,
    required this.motionController,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    if (size.isEmpty) {
      return child;
    }

    return Listener(
      behavior: HitTestBehavior.opaque,
      onPointerDown: _handlePointer,
      onPointerMove: _handlePointer,
      onPointerUp: (_) => motionController.clearTouchCenter(),
      onPointerCancel: (_) => motionController.clearTouchCenter(),
      child: SizedBox(width: size.width, height: size.height, child: child),
    );
  }

  void _handlePointer(PointerEvent event) {
    motionController.setTouchCenter(
      Offset(
        (event.localPosition.dx / size.width).clamp(0.0, 1.0),
        (event.localPosition.dy / size.height).clamp(0.0, 1.0),
      ),
    );
  }
}
