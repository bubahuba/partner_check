import 'package:flutter/material.dart';

/// Bar chart icon for reordering contacts by match count.
class ChartIcon extends StatelessWidget {
  final Color color;
  final double size;

  const ChartIcon({
    super.key,
    this.color = Colors.white,
    this.size = 24,
  });

  @override
  Widget build(BuildContext context) {
    return Icon(Icons.bar_chart, color: color, size: size);
  }
}
