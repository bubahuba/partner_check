import 'package:flutter/material.dart';

/// Share icon for copying Tetris deep links.
class ShareIcon extends StatelessWidget {
  final Color color;
  final double size;

  const ShareIcon({
    super.key,
    this.color = Colors.white,
    this.size = 24,
  });

  @override
  Widget build(BuildContext context) {
    return Icon(Icons.share, color: color, size: size);
  }
}
