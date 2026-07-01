import 'package:flutter/material.dart';

/// Settings gear for the contacts HUD.
class SettingsIcon extends StatelessWidget {
  final Color color;
  final double size;

  const SettingsIcon({
    super.key,
    this.color = Colors.white,
    this.size = 24,
  });

  @override
  Widget build(BuildContext context) {
    return Icon(Icons.settings, color: color, size: size);
  }
}
