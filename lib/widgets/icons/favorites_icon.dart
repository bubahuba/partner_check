import 'package:flutter/material.dart';

/// Heart icon for toggling favorites mode in the contacts HUD.
class FavoritesIcon extends StatelessWidget {
  final bool filled;
  final Color color;
  final double size;

  const FavoritesIcon({
    super.key,
    required this.filled,
    this.color = Colors.white,
    this.size = 24,
  });

  @override
  Widget build(BuildContext context) {
    return Icon(
      filled ? Icons.favorite : Icons.favorite_border,
      color: color,
      size: size,
    );
  }
}
