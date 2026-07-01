import 'package:flutter/material.dart';

/// Touch icon for double-tap pane gesture.
class TouchAppIcon extends StatelessWidget {
  final Color color;
  final double size;

  const TouchAppIcon({
    super.key,
    this.color = Colors.white,
    this.size = 24,
  });

  @override
  Widget build(BuildContext context) {
    return Icon(Icons.touch_app, color: color, size: size);
  }
}
