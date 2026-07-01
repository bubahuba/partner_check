import 'package:flutter/material.dart';

/// Back-hand icon for tap-and-hold gesture.
class BackHandIcon extends StatelessWidget {
  final Color color;
  final double size;

  const BackHandIcon({
    super.key,
    this.color = Colors.white,
    this.size = 24,
  });

  @override
  Widget build(BuildContext context) {
    return Icon(Icons.back_hand_outlined, color: color, size: size);
  }
}
