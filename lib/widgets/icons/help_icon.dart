import 'package:flutter/material.dart';

/// Help / about icon for the contacts HUD.
class HelpIcon extends StatelessWidget {
  final Color color;
  final double size;

  const HelpIcon({
    super.key,
    this.color = Colors.white,
    this.size = 24,
  });

  @override
  Widget build(BuildContext context) {
    return Icon(Icons.help_outline, color: color, size: size);
  }
}
