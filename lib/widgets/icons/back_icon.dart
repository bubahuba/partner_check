import 'package:flutter/material.dart';

/// Chevron back for closing panels and screens.
class BackIcon extends StatelessWidget {
  final Color color;
  final double size;

  const BackIcon({
    super.key,
    this.color = Colors.white,
    this.size = 24,
  });

  @override
  Widget build(BuildContext context) {
    return Icon(Icons.chevron_left, color: color, size: size);
  }
}
