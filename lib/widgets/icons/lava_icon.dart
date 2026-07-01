import 'package:flutter/material.dart';

/// Soft blob icon for launching the lava visualizer (24×24 viewBox).
class LavaIcon extends StatelessWidget {
  final Color color;
  final double size;

  const LavaIcon({
    super.key,
    this.color = Colors.white,
    this.size = 24,
  });

  static const _viewBox = 24.0;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _LavaIconPainter(
          color: color,
          scale: size / _viewBox,
        ),
      ),
    );
  }
}

class _LavaIconPainter extends CustomPainter {
  final Color color;
  final double scale;

  const _LavaIconPainter({
    required this.color,
    required this.scale,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    canvas.translate(center.dx, center.dy);

    final fill = Paint()
      ..color = color.withValues(alpha: 0.35)
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5 * scale
      ..isAntiAlias = true;

    void drawBlob(Offset offset, double radius) {
      canvas.drawCircle(offset, radius * scale, fill);
      canvas.drawCircle(offset, radius * scale, stroke);
    }

    drawBlob(const Offset(-4, 2), 6.5);
    drawBlob(const Offset(5, -3), 5.5);
    drawBlob(const Offset(1, 6), 4.5);
  }

  @override
  bool shouldRepaint(covariant _LavaIconPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.scale != scale;
  }
}
