import 'package:flutter/material.dart';

import '../game/tetris_engine.dart';

/// Largest playfield that fits inside [maxWidth] x [maxHeight].
Size tetrisPlayfieldSize(double maxWidth, double maxHeight) {
  const aspect = TetrisEngine.hCount / TetrisEngine.vCount;
  final heightFromWidth = maxWidth / aspect;
  if (heightFromWidth <= maxHeight) {
    return Size(maxWidth, heightFromWidth);
  }
  return Size(maxHeight * aspect, maxHeight);
}

/// Shared playfield width so Tetris screens align with the board aspect ratio.
double tetrisPlayfieldMaxWidth(
  BuildContext context, {
  double horizontalPadding = 16,
  double? availableHeight,
  double? availableWidth,
}) {
  final size = MediaQuery.sizeOf(context);
  final height = availableHeight ?? size.height;
  final width = availableWidth ?? size.width - horizontalPadding * 2;
  return tetrisPlayfieldSize(width, height).width;
}

/// Renders the Tetris playfield using [CustomPainter].
class TetrisBoard extends StatelessWidget {
  final TetrisEngine engine;

  const TetrisBoard({super.key, required this.engine});

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: TetrisEngine.hCount / TetrisEngine.vCount,
      child: CustomPaint(
        painter: _TetrisBoardPainter(engine: engine),
      ),
    );
  }
}

class _TetrisBoardPainter extends CustomPainter {
  final TetrisEngine engine;

  _TetrisBoardPainter({required this.engine});

  @override
  void paint(Canvas canvas, Size size) {
    final cellWidth = size.width / TetrisEngine.hCount;
    final cellHeight = size.height / TetrisEngine.vCount;
    final boardRect = Rect.fromLTWH(0, 0, size.width, size.height);

    canvas.drawRect(
      boardRect,
      Paint()..color = Colors.white.withValues(alpha: 0.2),
    );

    final gridPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.22)
      ..strokeWidth = 0.5;

    for (var i = 1; i < TetrisEngine.hCount; i++) {
      final x = i * cellWidth;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (var i = 1; i < TetrisEngine.vCount; i++) {
      final y = i * cellHeight;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final map = engine.map;
    final activeColor = engine.activePieceColor;

    for (var w = 0; w < TetrisEngine.hCount; w++) {
      for (var h = 0; h < TetrisEngine.vCount; h++) {
        final cell = map[w][h];
        Color? fillColor;
        if (cell.isActive && activeColor != null) {
          fillColor = activeColor;
        } else if (cell.isSettled) {
          fillColor = Color(0xFF000000 | cell.settledColor!);
        }

        if (fillColor != null) {
          canvas.drawRect(
            Rect.fromLTWH(w * cellWidth, h * cellHeight, cellWidth, cellHeight),
            Paint()..color = fillColor,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant _TetrisBoardPainter oldDelegate) => true;
}
