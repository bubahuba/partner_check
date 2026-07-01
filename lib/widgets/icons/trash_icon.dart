import 'package:flutter/material.dart';

/// Trash icon for deleting a contact.
class TrashIcon extends StatelessWidget {
  final Color color;
  final double size;

  const TrashIcon({
    super.key,
    this.color = Colors.white,
    this.size = 24,
  });

  @override
  Widget build(BuildContext context) {
    return Icon(Icons.delete_outline, color: color, size: size);
  }
}
