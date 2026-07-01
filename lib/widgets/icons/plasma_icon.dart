import 'package:flutter/material.dart';

/// Orbital energy icon for launching the plasma visualizer (24×24 viewBox).
class PlasmaIcon extends StatelessWidget {
  final Color color;
  final double size;

  const PlasmaIcon({
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
        painter: _PlasmaIconPainter(
          color: color,
          scale: size / _viewBox,
        ),
      ),
    );
  }
}

class _PlasmaIconPainter extends CustomPainter {
  final Color color;
  final double scale;

  const _PlasmaIconPainter({
    required this.color,
    required this.scale,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    canvas.translate(center.dx, center.dy);

    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5 * scale
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true;

    final fill = Paint()
      ..color = color
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    canvas.drawCircle(Offset.zero, 2.4 * scale, fill);

    for (final angle in [0.0, 1.047, 2.094]) {
      canvas.save();
      canvas.rotate(angle);
      final orbit = Path()
        ..addOval(
          Rect.fromCenter(
            center: Offset.zero,
            width: 14 * scale,
            height: 7 * scale,
          ),
        );
      canvas.drawPath(orbit, stroke);
      canvas.restore();
    }

    final arc = Path()
      ..moveTo(-4 * scale, -1 * scale)
      ..quadraticBezierTo(0, -6 * scale, 4 * scale, -1 * scale);
    canvas.drawPath(arc, stroke);
  }

  @override
  bool shouldRepaint(covariant _PlasmaIconPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.scale != scale;
  }
}
