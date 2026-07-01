import 'package:flutter/material.dart';

/// Tetromino-style icon for launching Tetris (24×24 viewBox from SVG).
class TetrisIcon extends StatelessWidget {
  final Color color;
  final double size;

  const TetrisIcon({
    super.key,
    this.color = Colors.white,
    this.size = 24,
  });

  static const _viewBox = 24.0;
  static const _cornerRadius = 1.0;

  static const _blocks = <Rect>[
    Rect.fromLTRB(5.5, 2, 11.5, 8),
    Rect.fromLTRB(5.5, 9, 11.5, 15),
    Rect.fromLTRB(12.5, 9, 18.5, 15),
    Rect.fromLTRB(12.5, 16, 18.5, 22),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _TetrisIconPainter(
          color: color,
          scale: size / _viewBox,
          cornerRadius: _cornerRadius,
        ),
      ),
    );
  }
}

class _TetrisIconPainter extends CustomPainter {
  final Color color;
  final double scale;
  final double cornerRadius;

  const _TetrisIconPainter({
    required this.color,
    required this.scale,
    required this.cornerRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final radius = Radius.circular(cornerRadius * scale);

    for (final block in TetrisIcon._blocks) {
      final rect = Rect.fromLTRB(
        block.left * scale,
        block.top * scale,
        block.right * scale,
        block.bottom * scale,
      );
      canvas.drawRRect(RRect.fromRectAndRadius(rect, radius), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _TetrisIconPainter oldDelegate) =>
      oldDelegate.color != color ||
      oldDelegate.scale != scale ||
      oldDelegate.cornerRadius != cornerRadius;
}
