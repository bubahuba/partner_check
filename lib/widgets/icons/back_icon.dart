import 'package:flutter/material.dart';

/// Back arrow for closing panels and screens.
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
    return Icon(Icons.arrow_back, color: color, size: size);
  }
}
